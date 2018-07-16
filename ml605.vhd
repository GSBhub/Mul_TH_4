------------------------------------------------------------------------------
-- Project Name    : 
------------------------------------------------------------------------------
-- File            : ml605.vhd
-- Author          : 
-- Created         : 
------------------------------------------------------------------------------
-- PB_N   => Reset Error, LCD, A and B input counters 
-- PB_S   => Pause
-- LED_W  => Stopped
-- LED_E  => Error
-- N      => multiple of four (number of input bits)
-- NPS    => number of asynchronous register stages 

-- CLK default freq is 10 MHz

-- to change the clock ...
-- CLK [MHz] = 1000 * CLKFBOUT_MULT_F / ( 5 * DIVCLK_DIVIDE ) / CLKOUT0_DIVIDE_F ;
-- where some range limitations include (not the only ones):
--           5.0 <= CLKFBOUT_MULT_F  <= 64.0
--            10 <=  DIVCLK_DIVIDE   <= 80
--           1.0 <= CLKOUT0_DIVIDE_F <= 128.0

-----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_arith.all;

-----------------------------------------------------------------------------
entity ml605 is
generic (  N : integer := 4 ;    -- number of multiplier input bits
           NPS : integer := 0 ;   -- number of asynchronous pipeline stages 
           CLKFBOUT_MULT_F  : real := 40.000;
           CLKOUT0_DIVIDE_F : real := 80.000;
           DIVCLK_DIVIDE    : integer := 10 );
port (
  --clk input
  SYSCLK_P        : in     std_logic;                 -- 200 MHz sys clock
  SYSCLK_N        : in     std_logic;                 -- 200 MHz sys clock
 
  --led outputs   
  GPIO_LED_N      :   out std_logic;                  -- Reset 
  GPIO_LED_S      :   out std_logic;                  -- Pause processing
  GPIO_LED_E      :   out std_logic;                  -- Error flag
  GPIO_LED_W      :   out std_logic;                  -- Stop flag

  --pushbutton
  GPIO_SW_N : in std_logic; --high when pressed
  GPIO_SW_S : in std_logic; --high when pressed

  --lcd display port
  LCD_DB4_LS  :   out std_logic; 
  LCD_DB5_LS  :   out std_logic;
  LCD_DB6_LS  :   out std_logic;
  LCD_DB7_LS  :   out std_logic;
  LCD_E_LS    :   out std_logic;
  LCD_RS_LS   :   out std_logic;
  LCD_RW_LS   :   out std_logic);
end;

-----------------------------------------------------------------------------
architecture structural of ml605 is
-----------------------------------------------------------------------------
-- Component Declarations
-----------------------------------------------------------------------------
component clk_synth
generic(
  CLKFBOUT_MULT_F  : real := 40.000;
  CLKOUT0_DIVIDE_F : real := 80.000;
  DIVCLK_DIVIDE    : integer := 10
 );
 port (
  -- Clock in ports
  CLK_IN1_P         : in     std_logic;  -- 200 MHz
  CLK_IN1_N         : in     std_logic;  -- 200 MHz
  -- Clock out ports
  CLK_200           : out    std_logic;  -- 200 MHz
  CLK_OUT0          : out    std_logic;  -- 10 MHz default
  -- Status and control signals
  LOCKED            : out    std_logic); 
end component;
component clk_LCD
 port (
  -- Clock in ports
  CLK_IN            : in     std_logic;  -- 200 MHz
  -- Clock out ports
  CLK_OUT0          : out    std_logic); -- 10 MHz 
end component;
component disp_control 
 port (
  CLK        : in std_logic;
  R          : in std_logic;
  DATA       : in std_logic_vector(7 downto 0);
  ADDR       : in std_logic_vector(7 downto 0);
  --lcd display port
  LCD_DB4_LS  :   out std_logic;
  LCD_DB5_LS  :   out std_logic;
  LCD_DB6_LS  :   out std_logic;
  LCD_DB7_LS  :   out std_logic;
  LCD_E_LS    :   out std_logic;
  LCD_RS_LS   :   out std_logic;
  LCD_RW_LS   :   out std_logic);
end component;
component TH_MULT 
 generic( N : integer := 4 );
 port(A1,A0,B1,B0: in std_logic_vector(N-1 downto 0); 
            P1,P0: out std_logic_vector(2*N-1 downto 0));
end component;

   
----------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------
  signal INDX                    : integer ;
  signal INDX_CNT                : std_logic_vector(19 downto 0);
  signal INDX_CNT_ONE            : std_logic_vector(19 downto 0);
  signal L_ADDR,L_DATA           : std_logic_vector(7 downto 0);
  signal CLK                     : std_logic;   -- 10 MHz default signal
  signal CLK_200                 : std_logic;   -- 200 MHz signal
  signal CLK_10                  : std_logic;   -- 10 MHz signal
  signal MMCM_LOCKED             : std_logic;   
  signal RESET                   : std_logic;   -- internal reset

  -- debounced push button pulse signals
  signal PB_EVENT_N              : std_logic;        -- PB pulse
  signal PB_DELAY_N              : std_logic_vector(11 downto 0);

  -- multiplier data
  signal A1,A0,B1,B0: std_logic_vector(N-1 downto 0);
  signal P1,P0: std_logic_vector(2*N-1 downto 0);

  -- multiplier test data
  type ARRAY_NPSxN is array (0 to NPS) of std_logic_vector(2*N-1 downto 0);
  signal TEST_P1, TEST_P0 : ARRAY_NPSxN;
  signal A,B : std_logic_vector(N-1 downto 0);
  signal COUNT,ONE,ZERO : std_logic_vector(2*N downto 0);
  signal STOP : std_logic;
  signal PERR : std_logic;
  signal PAUSE : std_logic;

----------------------------------------------------------------------------  
begin  
----------------------------------------------------------------------------
-- Signal assignments
----------------------------------------------------------------------------
  RESET <= PB_EVENT_N;
  PAUSE <= GPIO_SW_S; 
  ONE(2*N downto 1) <= (others => '0'); ONE(0) <= '1';
  ZERO <= (others => '0');
  INDX_CNT_ONE(19 downto 1) <= (others => '0'); INDX_CNT_ONE(0) <= '1';
  STOP <= PAUSE OR PERR;

----------------------------------------------------------------------------
-- Component Instantiations
----------------------------------------------------------------------------
comp_TH_MULT : TH_MULT
 generic map (N => N)
 port map(A1=>A1,A0=>A0,B1=>B1,B0=>B0,P1=>P1,P0=>P0);

----------------------------------------------------------------------------
-- Test Vector Generation
----------------------------------------------------------------------------
process(A,B,RESET,STOP,PERR,COUNT,ONE,CLK)    -- generate multiplier inputs
 begin
  if CLK'event and CLK='1' then
   if RESET = '1' then 
     COUNT <= (others => '0');
     A <= (others => '0');
     B <= (others => '0');
   else
    if STOP = '0' then
     COUNT <= COUNT + ONE;
     A <= COUNT(2*N downto N+1);
     B <= COUNT(N downto 1);
    end if;
   end if;
  end if; 
end process;

process(A,B,PERR,COUNT)     -- generate differential input signals
 begin
  if COUNT(0) = '0' and PERR = '0' then
   A1 <= (others => '0');
   B1 <= (others => '0');
   A0 <= (others => '0');
   B0 <= (others => '0');
  else
   A1 <= A;
   B1 <= B;
   for I in 0 to N-1 loop
    A0(I) <= not(A(I));
    B0(I) <= not(B(I));
   end loop;
  end if;
end process;

----------------------------------------------------------------------------
-- Output Comparison
----------------------------------------------------------------------------
process(TEST_P1,TEST_P0,P1,P0,COUNT,ZERO,RESET,PERR,CLK)
 variable TEMP_SET : std_logic;
 variable TEST_ANS : std_logic_vector(2*N-1 downto 0);
begin
 if CLK'event and CLK='1' then
  if RESET = '1' then
   PERR <= '0';
   for I in 0 to NPS loop
    TEST_P1(I) <= (others => '0');
    TEST_P0(I) <= (others => '0');
   end loop;
  elsif PERR = '0' then

   TEST_ANS := COUNT(2*N downto N+1) * COUNT(N downto 1);
   TEST_P1(0) <= TEST_ANS;

   for J in 0 to 2*N-1 loop
    TEST_P0(0)(J) <= not(TEST_ANS(J));      
   end loop;
   for I in 1 to NPS loop
    TEST_P1(I) <= TEST_P1(I-1);
    TEST_P0(I) <= TEST_P0(I-1);
   end loop; 

   if P1 = ZERO(2*N-1 downto 0) and P0 = ZERO(2*N-1 downto 0) then
    TEMP_SET := '0';
   else
    TEMP_SET := '1';
    for I in 0 to NPS loop
     if P1 = TEST_P1(I) and P0 = TEST_P0(I) then
      TEMP_SET := '0';
     end if; 
    end loop;
	end if;
   if TEMP_SET = '1' then
    PERR <= '1';
   end if;
	 
  end if;
 end if;
end process;
 
----------------------------------------------------------------------------
-- Clock Generation
----------------------------------------------------------------------------
comp_clk : clk_synth
 generic map(
  CLKFBOUT_MULT_F => CLKFBOUT_MULT_F,
  CLKOUT0_DIVIDE_F => CLKOUT0_DIVIDE_F,
  DIVCLK_DIVIDE => DIVCLK_DIVIDE)
 port map(
  CLK_IN1_P => SYSCLK_P,  -- 200 MHz 
  CLK_IN1_N => SYSCLK_N,  -- 200 MHz
  CLK_200 => CLK_200,     -- 200 MHz 
  CLK_OUT0 => CLK,        --  10 MHz default
  LOCKED => MMCM_LOCKED); 
comp_clk_LCD : clk_LCD
 port map(
  CLK_IN => CLK_200,     -- 200 MHz 
  CLK_OUT0 => CLK_10);   --  10 MHz 
comp_disp : disp_control 
 port map (CLK=>CLK_10,R=>GPIO_SW_N,DATA=>L_DATA,ADDR=>L_ADDR,
  LCD_DB4_LS=>LCD_DB4_LS,LCD_DB5_LS=>LCD_DB5_LS,LCD_DB6_LS=>LCD_DB6_LS,LCD_DB7_LS=>LCD_DB7_LS,
  LCD_E_LS=>LCD_E_LS,LCD_RS_LS=>LCD_RS_LS,LCD_RW_LS=>LCD_RW_LS);
  
----------------------------------------------------------------------------
-- led assignments
----------------------------------------------------------------------------
  GPIO_LED_N <= GPIO_SW_N;
  GPIO_LED_S <= GPIO_SW_S;
  GPIO_LED_E <= PERR;
  GPIO_LED_W <= STOP;

----------------------------------------------------------------------------
-- debounced push buttons   
----------------------------------------------------------------------------
  dff_pb: process (CLK)                                                     
  begin                                                                         
    if(CLK'event and CLK = '1') then
      PB_DELAY_N(0) <= GPIO_SW_N;  -- input from board push button
      for I in 1 to 11 loop
        PB_DELAY_N(I) <= PB_DELAY_N(I-1);
      end loop;
    end if;
  end process dff_pb;
  -- may need to add or delete delays depending on the board you are using ...
  PB_EVENT_N <= PB_DELAY_N(0) and PB_DELAY_N(1) and PB_DELAY_N(2) and PB_DELAY_N(3) and
		PB_DELAY_N(4) and PB_DELAY_N(5) and PB_DELAY_N(6) and PB_DELAY_N(7) and
		PB_DELAY_N(8) and PB_DELAY_N(9) and PB_DELAY_N(10) and
		not(PB_DELAY_N(11));

----------------------------------------------------------------------------
-- LCD DATA and ADDR
----------------------------------------------------------------------------
process(CLK_10,GPIO_SW_N,INDX)
 begin
  if CLK_10'event and CLK_10 = '1' then
   if INDX < N/4 then 
    if A1(N-4*INDX-1 downto N-4*INDX-4) > "1001" then
     L_DATA(7 downto 4) <= "0100" ;
     L_DATA(3 downto 0) <= A1(N-4*INDX-1 downto N-4*INDX-4) - "1001";
    else
     L_DATA(7 downto 4) <= "0011" ;
     L_DATA(3 downto 0) <= A1(N-4*INDX-1 downto N-4*INDX-4);
    end if;
    L_ADDR(7 downto 4) <= "1000" ;
    L_ADDR(3 downto 0) <= conv_std_logic_vector(INDX+0,4); -- "0000";                             

   elsif INDX < N/2 then
    if B1(N-4*(INDX-N/4)-1 downto N-4*(INDX-N/4)-4) > "1001" then
     L_DATA(7 downto 4) <= "0100" ;
     L_DATA(3 downto 0) <= B1(N-4*(INDX-N/4)-1 downto N-4*(INDX-N/4)-4) - "1001";
    else
     L_DATA(7 downto 4) <= "0011" ;
     L_DATA(3 downto 0) <= B1(N-4*(INDX-N/4)-1 downto N-4*(INDX-N/4)-4);
    end if;
    L_ADDR(7 downto 4) <= "1000" ;
    L_ADDR(3 downto 0) <= conv_std_logic_vector(INDX+1,4); -- "0000";                             

   elsif INDX < N   then
    if P1(2*N-4*(INDX-N/2)-1 downto 2*N-4*(INDX-N/2)-4) > "1001" then
     L_DATA(7 downto 4) <= "0100" ;
     L_DATA(3 downto 0) <= P1(2*N-4*(INDX-N/2)-1 downto 2*N-4*(INDX-N/2)-4) - "1001";
    else
     L_DATA(7 downto 4) <= "0011" ;
     L_DATA(3 downto 0) <= P1(2*N-4*(INDX-N/2)-1 downto 2*N-4*(INDX-N/2)-4);
    end if;
    L_ADDR(7 downto 4) <= "1100" ; -- bottom row
    L_ADDR(3 downto 0) <= conv_std_logic_vector(INDX-N/2,4); -- "0000";                             

   elsif INDX < N+1 then
    L_DATA(7 downto 4) <= "0010" ; L_DATA(3 downto 0) <= "1010";   --   '*'
    L_ADDR(7 downto 4) <= "1000" ;
    L_ADDR(3 downto 0) <= conv_std_logic_vector(N/4,4); -- "0100";

   else
    L_DATA(7 downto 4) <= "0011" ; L_DATA(3 downto 0) <= "1101";   --   '='
    L_ADDR(7 downto 4) <= "1000" ;
    L_ADDR(3 downto 0) <= conv_std_logic_vector(N/2+1,4); -- "1001";

   end if;

   if GPIO_SW_N ='1' then
    INDX <= 0;
    INDX_CNT <= (others => '0');
   elsif INDX_CNT(19) = '1' then
    if INDX <  N+2 then
     INDX <= INDX + 1;
    else
     INDX <= 0;
    end if;
    INDX_CNT <= (others => '0');
   else
    INDX_CNT <= INDX_CNT + INDX_CNT_ONE;
   end if;
  end if;
end process;
end;



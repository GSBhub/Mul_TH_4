-- File            : disp_control.vhd
-- writes DATA value to ADDR LCD position
-----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

-----------------------------------------------------------------------------
entity disp_control is
generic (
  T_scale    : integer := 7);   -- increase if display not stable 
port (
  CLK        : in std_logic;    -- assumed to be 10 MHz
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
end entity;

-----------------------------------------------------------------------------
architecture behav of disp_control is
----------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------
  type state_type is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,
  S16,S17,S18,S19,S20,S21,S22,S23,S24,S25,S26,S27,S28,S29,S30,S31,S32,S33,S34,
  S35,S36,S37,S38,S39,S40,S41,S42,S43,S44,S45,S46,S47,S48,S49,S50,S51,S52);
  signal NS, CS: state_type;
  signal LCD_COUNT: std_logic_vector(19 downto 0); 
  signal C_LCD_DATA: std_logic_vector(3 downto 0);
  signal LCD_CLK_R:std_logic;
  signal ADDRR,DATAR: std_logic_vector(7 downto 0);

----------------------------------------------------------------------------  
begin  
----------------------------------------------------------------------------
-- LCD control
----------------------------------------------------------------------------
  LCD_DB4_LS  <= C_LCD_DATA(0);
  LCD_DB5_LS  <= C_LCD_DATA(1);
  LCD_DB6_LS  <= C_LCD_DATA(2);
  LCD_DB7_LS  <= C_LCD_DATA(3);  

  STATE_CONTROL: process(CLK,R)  -- clock and reset
  begin
    if CLK'event and CLK='1' then
      if R = '1' then
        CS <= S0
        -- pragma synthesis_off
        after 10 ps
        -- pragma synthesis_on
        ;
      else
        CS <= NS
        -- pragma synthesis_off
        after 10 ps
        -- pragma synthesis_on
        ;
      end if;
    end if;
  end process;

  LCD_CLK : process(CLK,LCD_CLK_R)
    variable one:std_logic_vector(19 downto 0):="00000000000000000001";
  begin
    one := "00000000000000000001";
    if CLK'event and CLK='1' then
      if LCD_CLK_R = '1' then
        LCD_COUNT <= (others => '0');		
      else
        LCD_COUNT <= LCD_COUNT + one;
      end if;
    end if;
  end process;

  RUN_LCD: process(CS,LCD_COUNT,ADDR,ADDRR,DATA,DATAR)
  begin
    case CS is
	 
       when S0 =>    -- reset state 
         LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
         NS <= S1;
			
       when S1 =>    -- wait more than 15 ms
         if LCD_COUNT(19) = '1' then              -- 26 ms > 15 ms
           NS <= S2;
           LCD_CLK_R <= '1';
         else
           NS <= S1; 
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
       when S2 =>    -- apply 0 0 0011 for at least 220 ns
         if LCD_COUNT(2*T_scale) = '1' then      -- 14 cycles > 12 cycles
           NS <= S3;
           LCD_CLK_R <= '1';
         else
           NS <= S2;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
			
       when S3 =>    -- wait more than 4.1 ms
         if LCD_COUNT(15) = '1' then             -- 6 ms > 4.1 ms
           NS <= S4;
           LCD_CLK_R <= '1';
         else
           NS <= S3;  
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
       when S4 =>     -- apply  0 0 011 for at least 220 ns
         if LCD_COUNT(2*T_scale) = '1' then      -- 14 cycles > 12 cycles
           NS <= S5;
           LCD_CLK_R <= '1';
         else
           NS <= S4;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
			
       when S5 =>      -- wait more than 100 us
         if LCD_COUNT(2*T_scale) = '1' then       -- 14 cycles => 102 us > 100 us
           NS <= S6;
           LCD_CLK_R <= '1';
         else
           NS <= S5;  
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
       when S6 =>     -- apply 0 0 0011
         if LCD_COUNT(2*T_scale) = '1' then       -- 16 cycles  > 12 cycles
           NS <= S7;
           LCD_CLK_R <= '1';
         else
           NS <= S6;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
			
       when S7 =>     -- wait for 40 us
         if LCD_COUNT(12) = '1' then      -- 8 => 51 us      > 40 us
           NS <= S8;
           LCD_CLK_R <= '1';
         else
           NS <= S7;  
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
       when S8 =>      -- 
         if LCD_COUNT(2*T_scale) = '1' then       -- 16 cycles  > 12 cycles
           NS <= S9;
           LCD_CLK_R <= '1';
         else
           NS <= S8;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0011";
           LCD_CLK_R <= '0';
         end if;
			
       when S9 =>      -- puts it in 4 bit mode  -- apply 0 0 0010   wait 12 cycles
         if LCD_COUNT(2*T_scale) = '1' then      -- 14 cycles > 40 us
           NS <= S10;
           LCD_CLK_R <= '1';
         else
           NS <= S9;  
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0010";
           LCD_CLK_R <= '0';
         end if;
       when S10 =>
         if LCD_COUNT(2*T_scale) = '1' then       -- 14 cycles => 800 ns 
           NS <= S11;
           LCD_CLK_R <= '1';
         else
           NS <= S10;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0010";
           LCD_CLK_R <= '0';
         end if;




       -- issue a function set command x28
       -- write x2C  -or- x28
       when S11 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S12;
           LCD_CLK_R <= '1';
         else
           NS <= S11;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0010";
           LCD_CLK_R <= '0';
         end if;
       when S12 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S13;
           LCD_CLK_R <= '1';
         else
           NS <= S12;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0010";
           LCD_CLK_R <= '0';
         end if;
       when S13 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S14;
           LCD_CLK_R <= '1';
         else
           NS <= S13;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0010";
           LCD_CLK_R <= '0';
         end if;
       when S14 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S15;
           LCD_CLK_R <= '1';
         else
           NS <= S14;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1000";
           LCD_CLK_R <= '0';
         end if;
       when S15 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S16;
           LCD_CLK_R <= '1';
         else
           NS <= S15;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1000";
           LCD_CLK_R <= '0';
         end if;
       when S16 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S17;
           LCD_CLK_R <= '1';
         else
           NS <= S16;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1000";
           LCD_CLK_R <= '0';
         end if;





       -- issue a display OFF command x08
       -- write x04
       when S17 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S18;
           LCD_CLK_R <= '1';
         else
           NS <= S17;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S18 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S19;
           LCD_CLK_R <= '1';
         else
           NS <= S18;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S19 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S20;
           LCD_CLK_R <= '1';
         else
           NS <= S19;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S20 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S21;
           LCD_CLK_R <= '1';
         else
           NS <= S20;
           --LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1100";
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1000";
           LCD_CLK_R <= '0';
         end if;
       when S21 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S22;
           LCD_CLK_R <= '1';
         else
           NS <= S21;
           --LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1100";
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1000";
           LCD_CLK_R <= '0';
         end if;
       when S22 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S23;
           LCD_CLK_R <= '1';
         else
           NS <= S22;
           --LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1100";
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1000";
           LCD_CLK_R <= '0';
         end if;





       -- issue a Clear Display 
       -- write x01       
       when S23 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S24;
           LCD_CLK_R <= '1';
         else
           NS <= S23;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S24 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S25;
           LCD_CLK_R <= '1';
         else
           NS <= S24;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S25 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S26;
           LCD_CLK_R <= '1';
         else
           NS <= S25;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S26 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S27;
           LCD_CLK_R <= '1';
         else
           NS <= S26;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0001";
           LCD_CLK_R <= '0';
         end if;
       when S27 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S28;
           LCD_CLK_R <= '1';
         else
           NS <= S27;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0001";
           LCD_CLK_R <= '0';
         end if;
       when S28 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S29;
           LCD_CLK_R <= '1';
         else
           NS <= S28;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0001";
           LCD_CLK_R <= '0';
         end if;




       -- issue a Entry Mode Set with Bit Shift Disabled x06 -or- x04
       when S29 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S30;
           LCD_CLK_R <= '1';
         else
           NS <= S29;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S30 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S31;
           LCD_CLK_R <= '1';
         else
           NS <= S30;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S31 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S32;
           LCD_CLK_R <= '1';
         else
           NS <= S31;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S32 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S33;
           LCD_CLK_R <= '1';
         else
           NS <= S32;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0110";
           LCD_CLK_R <= '0';
         end if;
       when S33 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S34;
           LCD_CLK_R <= '1';
         else
           NS <= S33;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0110";
           LCD_CLK_R <= '0';
         end if;
       when S34 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S35;
           LCD_CLK_R <= '1';
         else
           NS <= S34;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0110";
           LCD_CLK_R <= '0';
         end if;




       -- issue a DISPLAY ON   CURSOR OFF   BLINK ON  x0C
       when S35 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S36;
           LCD_CLK_R <= '1';
         else
           NS <= S35;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S36 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S37;
           LCD_CLK_R <= '1';
         else
           NS <= S36;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S37 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S38;
           LCD_CLK_R <= '1';
         else
           NS <= S37;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "0000";
           LCD_CLK_R <= '0';
         end if;
       when S38 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S39;
           LCD_CLK_R <= '1';
         else
           NS <= S38;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1100";
           LCD_CLK_R <= '0';
         end if;
       when S39 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S40;
           LCD_CLK_R <= '1';
         else
           NS <= S39;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1100";
           LCD_CLK_R <= '0';
         end if;
       when S40 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S41;
           LCD_CLK_R <= '1';
         else
           NS <= S40;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= "1100";
           LCD_CLK_R <= '0';
         end if;







       -- issue and ADDR and a WRITE to display command
       -- write DATA  to address ADDR on display   
		 
		 
		 
       -- issue a set DD RAM address   x1LSBs (for first row) -or- xCLSBs (for second Row)
       when S41 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S42;
           LCD_CLK_R <= '1';
         else
           NS <= S41;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= ADDRR(7 downto 4);
           LCD_CLK_R <= '0';
           DATAR <= DATA;
           ADDRR <= ADDR;
         end if;
       when S42 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S43;
           LCD_CLK_R <= '1';
         else
           NS <= S42;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= ADDRR(7 downto 4);
           LCD_CLK_R <= '0';
         end if;
       when S43 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S44;
           LCD_CLK_R <= '1';
         else
           NS <= S43;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= ADDRR(7 downto 4);
           LCD_CLK_R <= '0';
         end if;
       when S44 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S45;
           LCD_CLK_R <= '1';
         else
           NS <= S44;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= ADDRR(3 downto 0);
           LCD_CLK_R <= '0';
         end if;
       when S45 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S46;
           LCD_CLK_R <= '1';
         else
           NS <= S45;
           LCD_E_LS <= '1'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= ADDRR(3 downto 0);
           LCD_CLK_R <= '0';
         end if;
       when S46 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S47;
           LCD_CLK_R <= '1';
         else
           NS <= S46;
           LCD_E_LS <= '0'; LCD_RS_LS <= '0'; LCD_RW_LS <= '0'; C_LCD_DATA <= ADDRR(3 downto 0);
           LCD_CLK_R <= '0';
         end if;




       -- issue a write data command
       when S47 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S48;
           LCD_CLK_R <= '1';
         else
           NS <= S47;
           LCD_E_LS <= '0'; LCD_RS_LS <= '1'; LCD_RW_LS <= '0'; C_LCD_DATA <= DATAR(7 downto 4);
           LCD_CLK_R <= '0';
         end if;
       when S48 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S49;
           LCD_CLK_R <= '1';
         else
           NS <= S48;
           LCD_E_LS <= '1'; LCD_RS_LS <= '1'; LCD_RW_LS <= '0'; C_LCD_DATA <= DATAR(7 downto 4);
           LCD_CLK_R <= '0';
         end if;
       when S49 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S50;
           LCD_CLK_R <= '1';
         else
           NS <= S49;
           LCD_E_LS <= '0'; LCD_RS_LS <= '1'; LCD_RW_LS <= '0'; C_LCD_DATA <= DATAR(7 downto 4);
           LCD_CLK_R <= '0';
         end if;
       when S50 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S51;
           LCD_CLK_R <= '1';
         else
           NS <= S50;
           LCD_E_LS <= '0'; LCD_RS_LS <= '1'; LCD_RW_LS <= '0'; C_LCD_DATA <= DATAR(3 downto 0);
           LCD_CLK_R <= '0';
         end if;
       when S51 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S52;
           LCD_CLK_R <= '1';
         else
           NS <= S51;
           LCD_E_LS <= '1'; LCD_RS_LS <= '1'; LCD_RW_LS <= '0'; C_LCD_DATA <= DATAR(3 downto 0);
           LCD_CLK_R <= '0';
         end if;
       when S52 =>
         if LCD_COUNT(T_scale*2) = '1' then       -- 2 => 800 ns     > 40 ns
           NS <= S41;
           LCD_CLK_R <= '1';
         else
           NS <= S52;
           LCD_E_LS <= '0'; LCD_RS_LS <= '1'; LCD_RW_LS <= '0'; C_LCD_DATA <= DATAR(3 downto 0);
           LCD_CLK_R <= '0';
         end if;
    end case;
  end process;
end behav;

-- file: clk_synth.vhd
-- 
------------------------------------------------------------------------------
-- Input Clock   Input Freq (MHz)   Input Jitter (UI)
------------------------------------------------------------------------------
-- primary         200.000            0.010

-- CLK_OUT0   1000 * CLKFBOUT_MULT_F / ( 5 * DIVCLK_DIVIDE ) / CLKOUT0_DIVIDE_F 

library ieee,unisim;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;

entity clk_synth is
generic(
 CLKFBOUT_MULT_F : real := 40.000;
 CLKOUT0_DIVIDE_F : real := 80.000;
 DIVCLK_DIVIDE : integer := 10
 );
port
 (-- Clock in ports
  CLK_IN1_P         : in     std_logic;
  CLK_IN1_N         : in     std_logic;
  -- Clock out ports
  CLK_200           : out    std_logic;   -- 200 MHz 
  CLK_OUT0          : out    std_logic;   -- 10 MHz default
  -- Status and control signals
  LOCKED            : out    std_logic
 );
end clk_synth;

architecture xilinx of clk_synth is
  -- Input clock buffering / unused connectors
  signal clkin1      : std_logic;
  -- Output clock buffering / unused connectors
  signal clkfbout         : std_logic;
  signal clkfbout_buf     : std_logic;
  signal clkfboutb_unused : std_logic;
  signal clkout0          : std_logic;    -- 10 MHz default
  signal clkout0b_unused  : std_logic;
  signal clkout1_unused   : std_logic; 
  signal clkout1b_unused  : std_logic;
  signal clkout2_unused   : std_logic;
  signal clkout2b_unused  : std_logic;
  signal clkout3_unused   : std_logic;
  signal clkout3b_unused  : std_logic;
  signal clkout4_unused   : std_logic;
  signal clkout5_unused   : std_logic;
  signal clkout6_unused   : std_logic;
  -- Dynamic programming unused signals
  signal do_unused        : std_logic_vector(15 downto 0);
  signal drdy_unused      : std_logic;
  -- Dynamic phase shift unused signals
  signal psdone_unused    : std_logic;
  -- Unused status signals
  signal clkfbstopped_unused : std_logic;
  signal clkinstopped_unused : std_logic;
begin


  -- Input buffering
  --------------------------------------
  clkin1_buf : IBUFGDS
  port map
   (O  => clkin1,
    I  => CLK_IN1_P,
    IB => CLK_IN1_N);

  CLK_200 <= clkin1;

  -- Output buffering
  -------------------------------------
  clkf_buf : BUFG
  port map
   (O => clkfbout_buf,
    I => clkfbout);
	 
  clkout0_buf : BUFG
  port map
   (O   => CLK_OUT0,
    I   => clkout0);

   -- default                  40.0                  10                 80.0	
   -- CLK_OUT0   1000 * CLKFBOUT_MULT_F / ( 5 * DIVCLK_DIVIDE ) / CLKOUT0_DIVIDE_F 
   MMCM_ADV_inst : MMCM_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",      -- Jitter programming ("HIGH","LOW","OPTIMIZED")
      CLKFBOUT_MULT_F => CLKFBOUT_MULT_F,        -- Multiply value for all CLKOUT (5.0-64.0).
      CLKFBOUT_PHASE => 0.0,         -- Phase offset in degrees of CLKFB (0.00-360.00).
      -- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKIN1_PERIOD => 5.0,          -- 5 ns => 200 MHz
      CLKIN2_PERIOD => 0.0,
      CLKOUT0_DIVIDE_F => CLKOUT0_DIVIDE_F,       -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      -- CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT4_CASCADE => FALSE,      -- Cascase CLKOUT4 counter with CLKOUT6 (TRUE/FALSE)
      CLOCK_HOLD => FALSE,           -- Hold VCO Frequency (TRUE/FALSE)
      COMPENSATION => "ZHOLD",       -- "ZHOLD", "INTERNAL", "EXTERNAL", "CASCADE" or "BUF_IN" 
      DIVCLK_DIVIDE => DIVCLK_DIVIDE,            -- Master division value (1-80)
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
      REF_JITTER1 => 0.010,   -- 0.0,
      REF_JITTER2 => 0.0,
      STARTUP_WAIT => FALSE,         -- Not supported. Must be set to FALSE.
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_USE_FINE_PS => FALSE,
      CLKOUT1_USE_FINE_PS => FALSE,
      CLKOUT2_USE_FINE_PS => FALSE,
      CLKOUT3_USE_FINE_PS => FALSE,
      CLKOUT4_USE_FINE_PS => FALSE,
      CLKOUT5_USE_FINE_PS => FALSE,
      CLKOUT6_USE_FINE_PS => FALSE 
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => CLKOUT0,                  -- 1-bit output: CLKOUT0 output      -- 10 MHz = 1000 * 40 /(5 * 10) / 80
      CLKOUT0B => CLKOUT0B_unused,         -- 1-bit output: Inverted CLKOUT0 output
      CLKOUT1 => CLKOUT1_unused,           -- 1-bit output: CLKOUT1 output      -- 160 MHz = 1000 * 40 /(5 * 10) / 5
      CLKOUT1B => CLKOUT1B_unused,         -- 1-bit output: Inverted CLKOUT1 output
      CLKOUT2 => CLKOUT2_unused,           -- 1-bit output: CLKOUT2 output
      CLKOUT2B => CLKOUT2B_unused,         -- 1-bit output: Inverted CLKOUT2 output
      CLKOUT3 => CLKOUT3_unused,           -- 1-bit output: CLKOUT3 output
      CLKOUT3B => CLKOUT3B_unused,         -- 1-bit output: Inverted CLKOUT3 output
      CLKOUT4 => CLKOUT4_unused,           -- 1-bit output: CLKOUT4 output
      CLKOUT5 => CLKOUT5_unused,           -- 1-bit output: CLKOUT5 output
      CLKOUT6 => CLKOUT6_unused,           -- 1-bit output: CLKOUT6 output
      -- DRP Ports: 16-bit (each) output: Dynamic reconfigration ports
      DO => DO_unused,                     -- 16-bit output: DRP data output
      DRDY => DRDY_unused,                 -- 1-bit output: DRP ready output
      -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
      PSDONE => PSDONE_unused,             -- 1-bit output: Phase shift done output
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => CLKFBOUT,         -- 1-bit output: Feedback clock output
      CLKFBOUTB => CLKFBOUTB_unused,       -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      CLKFBSTOPPED => CLKFBSTOPPED_unused, -- 1-bit output: Feedback clock stopped output
      CLKINSTOPPED => CLKINSTOPPED_unused, -- 1-bit output: Input clock stopped output
      LOCKED => LOCKED,             -- 1-bit output: LOCK output
      -- Clock Inputs: 1-bit (each) input: Clock inputs
      CLKIN1 => CLKIN1,             -- 1-bit input: Primary clock input
      CLKIN2 => '0',             -- 1-bit input: Secondary clock input
      -- Control Ports: 1-bit (each) input: MMCM control ports
      CLKINSEL => '1', -- CLKINSEL,         -- 1-bit input: Clock select input
      PWRDWN => '0', -- PWRDWN,             -- 1-bit input: Power-down input
      RST => '0', -- RST,                   -- active high 1-bit input: Reset input
      -- DRP Ports: 7-bit (each) input: Dynamic reconfigration ports
      DADDR => (others => '0'), -- DADDR,               -- 7-bit input: DRP adrress input
      DCLK => '0', -- DCLK,                 -- 1-bit input: DRP clock input
      DEN => '0', -- DEN,                   -- 1-bit input: DRP enable input
      DI => (others => '0'), -- DI,                     -- 16-bit input: DRP data input
      DWE => '0', -- DWE,                   -- 1-bit input: DRP write enable input
      -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      PSCLK => '0', -- PSCLK,               -- 1-bit input: Phase shift clock input
      PSEN => '0', -- PSEN,                 -- 1-bit input: Phase shift enable input
      PSINCDEC => '0', -- PSINCDEC,         -- 1-bit input: Phase shift increment/decrement input
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => CLKFBOUT_BUF            -- 1-bit input: Feedback clock input
   );

end xilinx;

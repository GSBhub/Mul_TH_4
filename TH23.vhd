-- TH23.vhd
-- N=3 M=2
--
--   Z <= AB + AC + BC
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
library ieee,work;
  use ieee.std_logic_1164.all;
entity TH23 is
  port(A,B,C: in std_logic;
       Z: out std_logic);
end ;
architecture STRUCTURAL of TH23 is
  component LUT4 
  generic(M : std_logic_vector(15 downto 0):="0000000000000000");
  port(I: in std_logic_vector(3 downto 0);
       O: out std_logic);
  end component; -- LUT4
  signal ZERO : std_logic;
  signal FB : std_logic;
begin
  ------------------------------------------------------------
  ZERO <= '0';
  -- FB                     1111111100000000
  -- I2                     1111000011110000
  -- I1                     1100110011001100
  -- I0                     1010101010101010
  L:LUT4 generic map (M => "1111111011101000") 
         port map (I(0) => A,I(1) => B,I(2) => C,I(3) => FB,O => FB);
  Z <= FB;
end ;


-- TH12.vhd
-- N=2 M=1
--
--   Z <= A + B
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
library ieee,work;
  use ieee.std_logic_1164.all;
entity TH12 is
  port(A,B: in std_logic;
       Z: out std_logic);
end ;
architecture STRUCTURAL of TH12 is
  component LUT4 
  generic(M : std_logic_vector(15 downto 0):="0000000000000000");
  port(I: in std_logic_vector(3 downto 0);
       O: out std_logic);
  end component; -- LUT4
  signal ZERO : std_logic;
begin
  ------------------------------------------------------------
  ZERO <= '0';
  L1:LUT4 generic map (M => "0000000000001110") 
         port map (I(0) => A,I(1) => B,I(2) => ZERO,I(3) => ZERO,O => Z);
end ;


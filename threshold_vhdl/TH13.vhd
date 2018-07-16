-- TH13.vhd
-- N=3 M=1
--
--   Z <= A + B + C
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
library ieee,work;
  use ieee.std_logic_1164.all;
entity TH13 is
  port(A,B,C: in std_logic;
       Z: out std_logic);
end ;
architecture STRUCTURAL of TH13 is
  component LUT4 
  generic(M : std_logic_vector(15 downto 0):="0000000000000000");
  port(I: in std_logic_vector(3 downto 0);
       O: out std_logic);
  end component; -- LUT4
  signal ZERO : std_logic;
begin
  ------------------------------------------------------------
  ZERO <= '0';
  L1:LUT4 generic map (M => "0000000011111110") 
         port map (I(0) => A,I(1) => B,I(2) => C,I(3) => ZERO,O => Z);
end ; 


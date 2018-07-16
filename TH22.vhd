-- TH22.vhd
-- N=2 M=2
--
--   Z <= AB
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
library ieee,work;
  use ieee.std_logic_1164.all;
entity TH22 is
  port(A,B: in std_logic;
       Z: out std_logic);
end ;
architecture STRUCTURAL of TH22 is
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
  -- FB                      xxxxxxxx11110000
  -- I1                      xxxxxxxx11001100
  -- I0                      xxxxxxxx10101010
  --  O                      xxxxxxxx11101000
  L1:LUT4 generic map (M => "0000000011101000") 
         port map (I(0) => A,I(1) => B,I(2) => FB,I(3) => ZERO,O => FB);
  Z <= FB;
end ; 


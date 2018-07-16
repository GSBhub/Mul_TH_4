-- THxor0.vhd
--
--   Z <= AB + CD
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
library ieee,work;
  use ieee.std_logic_1164.all;
entity THxor0 is
  port(A,B,C,D: in std_logic;
       Z: out std_logic);
end ;
architecture STRUCTURAL of THxor0 is
  component LUT4 
  generic(M : std_logic_vector(15 downto 0):="0000000000000000");
  port(I: in std_logic_vector(3 downto 0);
       O: out std_logic);
  end component; -- LUT4
  signal ZERO : std_logic;
  signal FB : std_logic;
  signal S1,S2 : std_logic;
begin
  ------------------------------------------------------------
  ZERO <= '0';
  -- FB                      11111111111111110000000000000000
  -- I3                      11111111000000001111111100000000
  -- I2                      11110000111100001111000011110000
  -- I1                      11001100110011001100110011001100
  -- I0                      10101010101010101010101010101010
  --  O                      11111111111111101111100010001000
  L1:LUT4 generic map                 (M => "1111100010001000") 
         port map (I(0) => A,I(1) => B,I(2) => C,I(3) => D,O => S1);
  L2:LUT4 generic map (M => "1111111111111110") 
         port map (I(0) => A,I(1) => B,I(2) => C,I(3) => D,O => S2);
  --L3:LUT4 generic map (M => "1100110010101010")
  --       port map (I(0) => S1,I(1) => S2,I(2) => ZERO,I(3) => FB,O => FB);
  process(S1,S2,FB)
  begin
    if FB = '0' then
       FB <= S1 ;
      else
       FB <= S2 ;
    end if;
  end process;
  Z <= FB;
end ;


-- INV1.vhd
---------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;

entity INV1 is
  port(A : in std_logic;
       Z : out std_logic);
end;

architecture  BEHAV of INV1 is
begin
  Z <= not(A);
end;



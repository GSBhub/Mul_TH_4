-- LUT4.vhd
--
-- LUT4 code

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
library ieee,work;
  use ieee.std_logic_1164.all;
entity LUT4 is
  generic(M : std_logic_vector(15 downto 0):="0000000000000000"
    -- pragma synthesis_off
    ; LUT_delay : time := 10 ps
    -- pragma synthesis_on
  );
  port(I: in std_logic_vector(3 downto 0);
       O: out std_logic);
end ; --LUT4; 
architecture STRUCTURAL of LUT4 is
begin
  ------------------------------------------------------------
  -- added delay for simulation
  process(I)
  begin
    case I is
     when "1111" =>
       O <= M(15)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1110" =>
       O <= M(14)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1101" =>
       O <= M(13)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1100" =>
       O <= M(12)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1011" =>
       O <= M(11)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1010" =>
       O <= M(10)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1001" =>
       O <= M(9)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "1000" =>
       O <= M(8)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0111" =>
       O <= M(7)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0110" =>
       O <= M(6)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0101" =>
       O <= M(5)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0100" =>
       O <= M(4)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0011" =>
       O <= M(3)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0010" =>
       O <= M(2)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when "0001" =>
       O <= M(1)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
     when others =>
       O <= M(0)
       -- pragma synthesis_off
       after LUT_delay
       -- pragma synthesis_on
       ;
    end case;
  end process;
  ------------------------------------------------------------
end ;


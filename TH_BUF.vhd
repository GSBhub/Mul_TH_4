-- fsm2.vhd
-----------------------------------------------------
library ieee,std ;
  use ieee.std_logic_1164.all;
  -- pragma synthesis_off
  use IEEE.STD_LOGIC_ARITH.ALL;
  use IEEE.STD_LOGIC_TEXTIO.ALL;
  use STD.TEXTIO.ALL;
  use IEEE.MATH_REAL.ALL;
  -- pragma synthesis_on

entity TH_BUF is
        generic(N:integer:=8);
        port(   A1,A0: in std_logic_vector(N-1 downto 0);
                S1,S0: in std_logic;
                OUT1,OUT0: out std_logic_vector(N-1 downto 0));

end;
-----------------------------------------------------
architecture BEHAVE of TH_BUF is

	buf: process (A1, A0, S1);
	
	BEGIN
		IF (S1) THEN
			OUT1 <= A1;
			OUT0 <= A0;
			
		END IF;
	END PROCESS buf;
	
end BEHAVE;

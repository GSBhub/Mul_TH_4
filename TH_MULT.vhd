-- TH_MULT.vhd

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE,WORK;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 use WORK.ALL;

entity TH_PEASANT_MULT_1 is
        generic(N:integer:=4);
        port(   M1,M0,N1,N0,Pi1,Pi0: in std_logic_vector(N-1 downto 0);
                Mo1,Mo0,No1,No0,P1,P0: out std_logic_vector(2*N-1 downto 0));
end; 

architecture STRUCT of TH_MULT is

  -- declarative area
	component TH_ADD16
        port(  	A1,A0,B1,B0,Ci1,Ci0: in std_logic;
                Co1,Co0,S1,S0: out std_logic);
	end component;
	
	component TH23
		port(A,B,C: in std_logic;
			 Z: out std_logic);
	end component;

	component TH33
		port(A,B,C: in std_logic;
			 Z: out std_logic);
			 
	component TH14
		port(A,B,C,D: in std_logic;
			 Z: out std_logic);
	end component;
	
begin

  -- instantiation area
	ACC: 
  
end;

entity TH_MULT is
        generic(N:integer:=4);
        port(   A1,A0,B1,B0: in std_logic_vector(N-1 downto 0);
                      P1,P0: out std_logic_vector(2*N-1 downto 0));
end; 

architecture STRUCT of TH_MULT is

  -- declarative area

  component TH_PEASANT_MULT_1 -- declare the peasant multiplier unit
    port(M1,M0,N1,N0,Pi1,Pi0:in std_logic;
		 Mo1,Mo0,No1,No0,P1,P0:out std_logic);
  end component;

 -- signal Mout1,M0,N1,N0:std_logic_vector(N downto 0); -- Intermediate N and M signal wires

begin

  -- instantiation area

  --Pi1(0) <= Ci1;
  --Pi0(0) <= Ci0;

  GI: for I in 0 to N-1 generate -- generate up to N peasant multiplier units
    GI:TH_PEASANT_MULT_1 port map(M1=>M1(I),M0=>M0(I),N1=>N1(I),N0=>N0(I),Pi1=>P1(I),Pi0=>P0(I),
                   Mo1=>M1(I+1),Mo0=>M0(I+1),No1=>N1(I+1),No0=>N0(I+1),P1=>P1(I),P0=>P0(I));
  end generate;

  --Co1 <= C1(N);
  --Co0 <= C0(N);

end;
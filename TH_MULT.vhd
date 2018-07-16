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

architecture STRUCT of TH_PEASANT_MULT_1 is

  -- declarative area
	component TH_ADD16
	    generic(N:integer:=8);

    port(  	A1,A0,B1,B0: in std_logic_vector (N-1 downto 0)	
				Ci1,Ci0: in std_logic;
                Co1,Co0: out std_logic;
				S1,S0: out std_logic_vector (N-1 downto 0);
	end component;
	
	component TH23
		port(A,B,C: in std_logic;
			 Z: out std_logic);
	end component;

	component TH33
		port(A,B,C: in std_logic;
			 Z: out std_logic);
	end component;
			 
	component TH14
		port(A,B,C,D: in std_logic;
			 Z: out std_logic);
	end component;
	
	component TH_BUF    
        generic(N:integer:=8);    
        port(   A1,A0: in std_logic_vector(N-1 downto 0);
                S1,S0: in std_logic;
                OUT1,OUT0: out std_logic_vector(N-1 downto 0));
	end component;
	
	component MULTIPLEXER         
		generic(N:integer:=8);
        port(   M1,M0: in std_logic_vector(N-1 downto 0);
				N1,N0: in std_logic;
                X1,X0: out std_logic_vector(N-1 downto 0));
	end component;
	
end; 
	
	signal MUX1,MUX0: std_logic_vector (N-1 downto 0);
end;
	
begin

  -- instantiation area
	ACC: TH_ADD16 port map (A1=>MUX1, A0=>MUX0, B1=>Pi1, Ci1=>'0', Ci0=>'1', B0=>Pi0, S1=>P1, S0=>P0);
	MUX: MULTIPLEXER port map (M1=>M1, M0=>M0,N1=>N1(0), N0=>N0(0) X1=>MUX1, X0=>MUX0);
	port map(No1(7)=>'0',No1(6)=>N1(7),No1(5)=>N1(6) ,No1(4)=>N1(5),No1(3)=>N1(4),No1(2)=>N1(3),No1(1)=>N1(2), No1(0)=>N1(1)) --right shift (N)
	port map(No0(7)=>'0',No0(6)=>N0(7),No0(5)=>N0(6) ,No0(4)=>N0(5),No0(3)=>N0(4),No0(2)=>N0(3),No0(1)=>N0(2), No0(0)=>N0(1)) --right shift
	port map(Mo1(7)=>M1(6),Mo1(6)=>M1(5),Mo1(5)=>M1(4) ,Mo1(4)=>M1(3),Mo1(3)=>M1(2),Mo1(2)=>M1(1),Mo1(1)=>M1(0), Mo1(0)=>'0') --left shift (M)
	port map(Mo0(7)=>M0(6),Mo0(6)=>M0(5),Mo0(5)=>M0(4) ,Mo0(4)=>M0(3),Mo0(3)=>M0(2),Mo0(2)=>M0(1),Mo0(1)=>M0(0), Mo0(0)=>'0') --left shift

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
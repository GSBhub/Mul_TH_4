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
        port(   M1, M0, N1, N0: in std_logic_vector(2*N-1 downto 0);
					 Pi1, Pi0: in std_logic_vector(2*N-1 downto 0);
                Mo1, Mo0, No1, No0: out std_logic_vector(2*N-1 downto 0);
					 MP1, MP0: out std_logic_vector(2*N-1 downto 0));
end; 

architecture STRUCT of TH_PEASANT_MULT_1 is

  -- declarative area
	component TH_ADD8
    port(  	A1,A0,B1,B0: in std_logic_vector(7 downto 0);	
				Ci1,Ci0: in std_logic;
                Co1,Co0: out std_logic;
				  S1,S0: out std_logic_vector(7 downto 0));
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
	
--	component TH_BUF      
--      port(   A1,A0: in std_logic_vector(7 downto 0);
--            S1,S0: in std_logic;
--          OUT1,OUT0: out std_logic_vector(7 downto 0));
--	end component;
	
	component MULTIPLEXER         
        port(   mM1,mM0: in std_logic_vector(7 downto 0);
					 mN1,mN0: in std_logic;
                X1,X0: out std_logic_vector(7 downto 0));
	end component;
	 	
	signal Carry1, Carry0: std_logic;
	signal MUX1, MUX0: std_logic_vector(7 downto 0);
	--signal RS1, RS0, LS1, LS0: std_logic_vector(7 downto 0);
		
begin
	

  -- instantiation area
	ACC: TH_ADD8 port map (A1=>MUX1, A0=>MUX0, B1=>Pi1, Ci1=>'0', Ci0=>'1', Co1=>Carry1, Co0=>Carry0, B0=>Pi0, S1=>MP1, S0=>MP0);
	MUX: MULTIPLEXER port map (mM1=>M1, mM0=>M0, mN1=>N1(0), mN0=>N0(0), X1=>MUX1, X0=>MUX0); -- bit extend M1 and M0 to fit in mux
				--- NEED a signed answer to above
				
   No1(7)<='0'; No1(6)<=N1(7);No1(5)<=N1(6); No1(4)<=N1(5); No1(3)<=N1(4); No1(2)<=N1(3); No1(1)<=N1(2); No1(0)<=N1(1); --right shift (N)
	No0(7)<='0'; No0(6)<=N0(7); No0(5)<=N0(6); No0(4)<=N0(5); No0(3)<=N0(4); No0(2)<=N0(3); No0(1)<=N0(2);  No0(0)<=N0(1); --right shift
	Mo1(7)<=M1(6); Mo1(6)<=M1(5); Mo1(5)<=M1(4); Mo1(4)<=M1(3); Mo1(3)<=M1(2); Mo1(2)<=M1(1); Mo1(1)<=M1(0); Mo1(0)<='0'; --left shift (M)
	Mo0(7)<=M0(6); Mo0(6)<=M0(5); Mo0(5)<=M0(4); Mo0(4)<=M0(3); Mo0(3)<=M0(2); Mo0(2)<=M0(1); Mo0(1)<=M0(0); Mo0(0)<='0';--left shift

end;

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE,WORK;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
		  use ieee.numeric_std.all;
		  
entity TH_MULT is
        generic(N:integer:=4);
        port(   A1,A0,B1,B0: in std_logic_vector(N-1 downto 0);
                      P1,P0: out std_logic_vector(2*N-1 downto 0));
end; 

architecture STRUCT of TH_MULT is

  -- declarative area
  type sig_array is array (0 to 3) of std_logic_vector(N-1 downto 0);
  type sig_array_long is array (0 to 3) of std_logic_vector(2*N-1 downto 0);
  
  component TH_PEASANT_MULT_1 -- declare the peasant multiplier unit
    port(M1,M0,N1,N0: in std_logic_vector(2*N-1 downto 0);
	    Pi1,Pi0: in std_logic_vector(2*N-1 downto 0);
		 Mo1, Mo0, No1, No0: out std_logic_vector(2*N-1 downto 0);
		 MP1, MP0: out std_logic_vector(2*N-1 downto 0));
  end component;

 signal iM1, iM0, iN1, iN0, iP1,iP0: sig_array_long; -- Intermediate accumulator signal wires
-- signal iM1, iM0, iN1, iN0: sig_array; -- intermediate N and P signal wires

begin

  -- instantiation area

  --Pi1(0) <= Ci1;
  --Pi0(0) <= Ci0;
	--AMP1 <= '0'; AMP2 <= '0';

	--M1 <= A1; M0 <= A0; N1 <= B1; N0 <= B0;
	
   Ginit:TH_PEASANT_MULT_1 port map(M1=>std_logic_vector(resize(signed(A1), 8)), M0=>std_logic_vector(resize(signed(A0), 8)), -- bit extend A and B to fit into the 8 bit peasant inputs
												N1=>std_logic_vector(resize(signed(B1), 8)), N0=>std_logic_vector(resize(signed(B0), 8)), 
												Pi1=>"00000000",Pi0=>"00000000", 																								 -- initial settings, inputs go to the first inputs, accumulator P set to 0
												Mo1=>iM1(0), Mo0=>iM0(0), No1=>iN1(0), No0=>iN0(0), MP1=>iP1(0), MP0=>iP0(0)); 									 -- outputs go to first spot in intermediate wire settings

	GI: for I in 1 to N-1 generate -- skip first run, as it has to have the inital values hardcoded
		GI:TH_PEASANT_MULT_1 port map(M1=>iM1(I-1), M0=>iM0(I-1), N1=>iN1(I-1), N0=>iN0(I-1), Pi1=>iP1(I-1),Pi0=>iP0(I-1), -- grab previous wire values
      Mo1=>iM1(I), Mo0=>iM0(I), No1=>iN1(I), No0=>iN0(I), MP1=>iP1(I), MP0=>iP0(I));  -- outputs go to next spot in intermediate wire settings
	end generate;

	P1 <= iP1(3);
	P0 <= iP0(3); -- grab final accumulator result, the product, from the accumulator 
end;
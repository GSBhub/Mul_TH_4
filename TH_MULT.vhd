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
        port(   M1, M0, N1, N0: in std_logic_vector(N-1 downto 0);
					 Pi1, Pi0: in std_logic_vector(2*N-1 downto 0);
                Mo1, Mo0, No1, No0: out std_logic_vector(N-1 downto 0);
					 MP1, MP0: out std_logic_vector(2*N-1 downto 0));
end; 

architecture STRUCT of TH_PEASANT_MULT_1 is

  -- declarative area
	component TH_ADD16
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
	ACC: TH_ADD16 port map (A1=>MUX1, A0=>MUX0, B1=>Pi1, Ci1=>'0', Ci0=>'1', Co1=>Carry1, Co0=>Carry0, B0=>Pi0, S1=>MP1, S0=>MP0);
	MUX: MULTIPLEXER port map (mM1=>M1, mM0=>M0, mN1=>N1(0), mN0=>N0(0), X1=>MUX1, X0=>MUX0);
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
entity TH_MULT is
        generic(N:integer:=4);
        port(   A1,A0,B1,B0: in std_logic_vector(N-1 downto 0);
                      P1,P0: out std_logic_vector(2*N-1 downto 0));
end; 

architecture STRUCT of TH_MULT is

  -- declarative area

  component TH_PEASANT_MULT_1 -- declare the peasant multiplier unit
    port(M1,M0,N1,N0: in std_logic_vector(N-1 downto 0);
	    Pi1,Pi0: in std_logic_vector(2*N-1 downto 0);
		 Mo1, Mo0, No1, No0: out std_logic_vector(N-1 downto 0);
		 MP1, MP0: out std_logic_vector(2*N-1 downto 0));
  end component;

 --signal AMP1,AMP0: std_logic_vector(2*N-1 downto 0); -- Intermediate N and M signal wires

begin

  -- instantiation area

  --Pi1(0) <= Ci1;
  --Pi0(0) <= Ci0;
	--AMP1 <= '0'; AMP2 <= '0';

	--M1 <= A1; M0 <= A0; N1 <= B1; N0 <= B0;
  G22:TH_PEASANT_MULT_1 port map(M1=>A1,M0=>A0,N1=>B1,N0=>B0,Pi1=>"00000000",Pi0=>"00000000",
                   Mo1=>M1, Mo0=>M0, No1=>N1, No0=>N0, P1=>MP1 ,P0=>MP0);
						 
  GI: for I in 0 to N-2 generate -- generate up to N peasant multiplier units
    GI:TH_PEASANT_MULT_1 port map(M1=>A1,M0=>A0,N1=>B1,N0=>B0,Pi1=>MP1,Pi0=>MP0,
                   Mo1=>M1,Mo0=>M0,No1=>N1,No0=>N0,P1=>MP1,P0=>MP0);
		
 end generate;

end;
-- TH_ADD16.vhd

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE,WORK;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity TH_FA is
        port(   A1,A0,B1,B0,Ci1,Ci0: in std_logic;
                Co1,Co0,S1,S0: out std_logic);
end; 

architecture BEHAV of TH_FA is

 -- component declarations from threshold_lib
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

 -- any internal signal declarations
 signal NOT3,NOTAB,NOTAC,NOTBC,NOTA,NOTB,NOTC,ABC:std_logic;

begin
 
 -- threshold gate instances that make the full adder
 
	-- Carry out bits, implemented using a TH23 circuit as they both follow the TH23 AB+AC+BC format
	G1:TH23 port map (A=>Ci1, B=>A1, C=>B1, Z=>Co1);
	G2:TH23 port map (A=>Ci0, B=>A0, C=>B0, Z=>Co0);
	-- Sum bitS
		--S0
	SUM0:TH33 port map (A=>Ci0, B=>A0, C=>B0, Z=>NOT3);
	SUM1:TH33 port map (A=>Ci0, B=>A0, C=>B1, Z=>NOTAB);
	SUM2:TH33 port map (A=>Ci0, B=>A1, C=>B0, Z=>NOTAC);
	SUM3:TH33 port map (A=>Ci1, B=>A0, C=>B0, Z=>NOTBC);
	G3:TH14 port map (A=>NOT3, B=>NOTAB, C=>NOTAC, D=>NOTBC, Z=>S0);
	
		--S1
	SUM4:TH33 port map (A=>Ci1, B=>A1, C=>B1, Z=>ABC);
	SUM5:TH33 port map (A=>Ci1, B=>A1, C=>B0, Z=>NOTC);
	SUM6:TH33 port map (A=>Ci1, B=>A0, C=>B1, Z=>NOTB);
	SUM7:TH33 port map (A=>Ci0, B=>A1, C=>B1, Z=>NOTA);
	
	G4:TH14 port map (A=>ABC, B=>NOTA, C=>NOTC, D=>NOTB, Z=>S0);

end;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE,WORK;
        use IEEE.STD_LOGIC_1164.ALL;
        use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity TH_ADD8 is
        generic(N:integer:=8);
        port(   A1,A0,B1,B0: in std_logic_vector(N-1 downto 0);
                    Ci1,Ci0: in std_logic;
                    Co1,Co0: out std_logic;
                      S1,S0: out std_logic_vector(N-1 downto 0));
end; 

architecture STRUCT of TH_ADD8 is

  -- declarative area

  component TH_FA 
    port(A1,A0,B1,B0,Ci1,Ci0:in std_logic;Co1,Co0,S1,S0:out std_logic);
  end component;

  signal C1,C0:std_logic_vector(N downto 0);

begin

  -- instantiation area

  C1(0) <= Ci1;
  C0(0) <= Ci0;

  GI: for I in 0 to N-1 generate
    GI:TH_FA port map(A1=>A1(I),A0=>A0(I),B1=>B1(I),B0=>B0(I),Ci1=>C1(I),Ci0=>C0(I),
                   Co1=>C1(I+1),Co0=>C0(I+1),S1=>S1(I),S0=>S0(I));
  end generate;

  Co1 <= C1(N);
  Co0 <= C0(N);

end;


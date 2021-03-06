-- Multiplexer.vhd

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE,WORK;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 use WORK.ALL;

entity MULTIPLEXER is
        generic(N:integer:=8);
        port(   mM1,mM0: in std_logic_vector(N-1 downto 0);
				mN1,mN0: in std_logic;
                X1,X0: out std_logic_vector(N-1 downto 0));
end; 

architecture STRUCT of MULTIPLEXER is



  -- declarative area
	component TH22
	 port(A,B: in std_logic;
		  Z: out std_logic);
	end component;
	
	component TH12
	 port(A,B: in std_logic;
		  Z: out std_logic);
	end component;
	
begin
 
 -- threshold gate instances that make the full adder
 G1:TH22 port map(A=>mN1,B=>mM1(0),Z=>X1(0));
 G2:TH12 port map(A=>mN0,B=>mM0(0),Z=>X0(0));
 
 G3:TH22 port map(A=>mN1,B=>mM1(1),Z=>X1(1));
 G4:TH12 port map(A=>mN0,B=>mM0(1),Z=>X0(1));
 
 G5:TH22 port map(A=>mN1,B=>mM1(2),Z=>X1(2));
 G6:TH12 port map(A=>mN0,B=>mM0(2),Z=>X0(2));
 
 G7:TH22 port map(A=>mN1,B=>mM1(3),Z=>X1(3));
 G8:TH12 port map(A=>mN0,B=>mM0(3),Z=>X0(3));
 
 G9:TH22 port map(A=>mN1,B=>mM1(4),Z=>X1(4));
 G10:TH12 port map(A=>mN0,B=>mM0(4),Z=>X0(4));
 
 G11:TH22 port map(A=>mN1,B=>mM1(5),Z=>X1(5));
 G12:TH12 port map(A=>mN0,B=>mM0(5),Z=>X0(5));
 
 G13:TH22 port map(A=>mN1,B=>mM1(6),Z=>X1(6));
 G14:TH12 port map(A=>mN0,B=>mM0(6),Z=>X0(6));
 
 G15:TH22 port map(A=>mN1,B=>mM1(7),Z=>X1(7));
 G16:TH12 port map(A=>mN0,B=>mM0(7),Z=>X0(7));

end;
-- tb_TH_ADD16.vhd
-- functional test only ...

library IEEE,STD,WORK;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.STD_LOGIC_ARITH.ALL;
  --use IEEE.STD_LOGIC_SIGNED.ALL;
  use IEEE.STD_LOGIC_UNSIGNED.ALL;
  use IEEE.STD_LOGIC_TEXTIO.ALL;
  use STD.TEXTIO.ALL;
  use IEEE.MATH_REAL.ALL;

entity TB_TH_ADD16 is
  generic (
    N_ITS:integer:= 4000 ;  -- number of random vectors for random TB
    N:integer:= 16 ;  -- number of input bits for multiplier
    WPD:time:= 33.0 ns
  );
end ; 

architecture TB of TB_TH_ADD16 is
  file OUT_FILE: text
    is out "sim_TH_ADD16.txt";  -- simulation output file
  component TH_ADD16
    generic(N:integer);
    port(A1,A0,B1,B0: in std_logic_vector(N-1 downto 0);
          Ci1,Ci0: in std_logic;
          Co1,Co0: out std_logic;
           S1,S0: out std_logic_vector(N-1 downto 0));
  end component ;
  signal A1,B1: std_logic_vector(N-1 downto 0);
  signal A0,B0: std_logic_vector(N-1 downto 0);
  signal S1: std_logic_vector(N downto 0);
  signal S0: std_logic_vector(N downto 0);
  signal Ci1: std_logic;
  signal Ci0: std_logic;
begin
  CUT:TH_ADD16                           -- Circuit Under Test
    generic map(N=>N)
    port map (A1=>A1,B1=>B1,Ci1=>Ci1,Co1=>S1(N),S1=>S1(N-1 downto 0),
              A0=>A0,B0=>B0,Ci0=>Ci0,Co0=>S0(N),S0=>S0(N-1 downto 0));

  test_VECTOR : process
    variable I,Cin : integer;
    variable SEED_1,SEED_2,RN1,RN2 : integer := 0;
    variable R_RAND : real;
    variable A,B: std_logic_vector(N-1 downto 0);
    variable Ci: std_logic;
  begin
    SEED_1 := 18; SEED_2 := 28;      -- seeds for random number generator
    I := N_ITS-1; WH_LOOPI : while I > -1 loop
      Cin := 0; WH_LOOPC : while Cin < 2 loop -- 0 to 1
        ----------------------------------
        A1 <= (others => '0');
        A0 <= (others => '0');
        B1 <= (others => '0');
        B0 <= (others => '0');
        Ci1 <= '0';
        Ci0 <= '0';
        wait for WPD;
        ----------------------------------
        UNIFORM(SEED_1,SEED_2,R_RAND);
        RN1 := integer((2.0**31.0)**R_RAND);
        RN1 := conv_integer(conv_std_logic_vector(RN1,N));
        UNIFORM(SEED_1,SEED_2,R_RAND);
        RN2 := integer((2.0**31.0)**R_RAND);
        RN2 := conv_integer(conv_std_logic_vector(RN2,N));
        A := conv_std_logic_vector(RN1,N);
        A1 <= A; for K in N-1 downto 0 loop A0(K) <= not(A(K)); end loop;
        B := conv_std_logic_vector(RN2,N);
        B1 <= B; for K in N-1 downto 0 loop B0(K) <= not(B(K)); end loop;
        if Cin = 1 then Ci := '1'; else Ci := '0'; end if;
        Ci1 <= Ci; Ci0 <= not(Ci);
        ----------------------------------
        wait for WPD;
        Cin := Cin + 1;
      end loop WH_LOOPC;
      I := I-1;
    end loop WH_LOOPI;
    assert (false) report "sim done :)" severity FAILURE;
  end process;

  test_TH_ADD16 : process
    variable OUTLINE : LINE;
    variable COMMA : string(1 to 3):= " , ";
    variable BLANK3 : string(1 to 3):= "   ";
    variable BLANK1 : string(1 to 1):= " ";
    variable I,Cin : integer;
    variable S_INTEGER: integer;
    variable ZERO : std_logic_vector(N-1 downto 0);
  begin
    ZERO := (others => '0');
    I := N_ITS-1; WH_LOOPI : while I > -1 loop
      Cin := 0; WH_LOOPC : while Cin < 2 loop -- 0 to 1
        wait for WPD;
        S_INTEGER := conv_integer(A1) + conv_integer(B1) + conv_integer(Ci1);
        if conv_integer(S1) /= ZERO or conv_integer(S0) /= ZERO then
          WRITE(OUTLINE, A1);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, A0);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, B1);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, B0);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, S1);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, S0);
          WRITELINE(OUT_FILE, OUTLINE);
          assert (false) report "error :(" severity FAILURE;
        end if;
        ----------------------------------
        wait for WPD;
        S_INTEGER := conv_integer(A1) + conv_integer(B1) + conv_integer(Ci1);
        if conv_integer(S1) /= S_INTEGER then
          WRITE(OUTLINE, A1);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, A0);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, B1);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, B0);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, S_INTEGER);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, conv_std_logic_vector(S_INTEGER,N+1));
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, S1);
          WRITE(OUTLINE, ' ');
          WRITE(OUTLINE, S0);
          WRITE(OUTLINE, ' ');
          WRITELINE(OUT_FILE, OUTLINE);
          assert (false) report "error :(" severity FAILURE;
        end if;
        Cin := Cin + 1;
      end loop WH_LOOPC;
      I := I-1;
    end loop WH_LOOPI;
  end process;

end ; 
    
configuration CFG_TB of TB_TH_ADD16 is
for TB
end for;
end ; 

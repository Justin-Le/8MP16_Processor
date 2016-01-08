-- Control Unit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY fsm IS PORT (
Opcode: IN STD_LOGIC_VECTOR(3 downto 0);
cond: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
Done, Mck, Strt, Reset, Nop: IN STD_LOGIC;
Ctrl: OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
R, W: OUT STD_LOGIC);
END fsm;

ARCHITECTURE fsmbehav OF fsm IS
COMPONENT clklog IS PORT (
Done, Mck, Rd, Wt, Wr: IN STD_LOGIC;
StrtStop: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
Enable, R, W: OUT STD_LOGIC);
END COMPONENT;
SIGNAL StrtStop: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL En: STD_LOGIC;
SIGNAL Control: STD_LOGIC_VECTOR(26 DOWNTO 0);

TYPE st_type IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, 
				 s10, s11, s12, s13, s14, s15, s16, s17, 
				 s18, s19, s20, s21, s22, s23, s24, s25, 
				 s26, s27, s28, s29);
SIGNAL currst, nextst: st_type;

BEGIN

StrtStop <= Strt & Control(25);
ClkLogic: clklog PORT MAP(Done, Mck, Control(9), Control(24), Control(8), StrtStop, En, R, W);

Ctrl <= Control;

PROCESS(Mck,Reset,En,currst)
BEGIN
IF Reset='1' THEN
currst <= s0;
ELSIF En='0' THEN
currst <= currst;
ELSIF Mck'EVENT AND Mck='0' THEN
currst <= nextst;
END IF;
END PROCESS;

PROCESS(currst,Opcode,cond,Nop)
BEGIN
CASE currst IS

WHEN s0 =>
Control <= "100000000000000000000000000";
nextst <= s1;

WHEN s1 =>
Control <= "000000100000001000000100000";
nextst <= s2;

WHEN s2 =>
Control <= "001000000000000001011000000";
nextst <= s3;

WHEN s3 =>
Control <= "000000000000010010000000000";
IF Nop='1' THEN
nextst <= s29;
ELSIF Opcode="0000" OR Opcode="0001" THEN
nextst <= s4;
ELSIF Opcode="0010" THEN
nextst <= s7;
ELSIF Opcode="0011" THEN
nextst <= s8;
ELSIF Opcode="0100" OR Opcode="0101" OR Opcode="0110" OR Opcode="0111" THEN
nextst <= s23;
ELSIF Opcode="1000" THEN
nextst <= s11;
ELSIF Opcode="1001" OR Opcode="1010" OR Opcode="1011" THEN
nextst <= s28;
ELSIF Opcode="1100" OR Opcode="1101" THEN
nextst <= s12;
ELSIF Opcode="1110" THEN
nextst <= s9;
ELSE  --op 1111
nextst <= s10;
END IF;

WHEN s4 =>
Control <= "000000001100000000000000000";
IF Opcode="0000" THEN
nextst <= s5;
ELSE  --op 0001
nextst <= s6;
END IF;

WHEN s5 =>
Control <= "000110010000000000000000000";
nextst <= s1;

WHEN s6 =>
Control <= "000111010000000000000000000";
nextst <= s1;

WHEN s7 =>
Control <= "000000010000000000000000010";
nextst <= s1;

WHEN s8 =>
Control <= "000000001000000000000000001";
nextst <= s1;

WHEN s9 =>
Control <= "000000001001000000000010000";
nextst <= s1;  --op 1000, 0100, 0101, 0110, 0111, 1110

WHEN s10 =>  --Stop
Control <= "010000000000000000000000000";
nextst <= s10;

WHEN s11 =>
Control <= "000011010001000000000001000";
nextst <= s9;

WHEN s12 =>
Control <= "000000000000001000000000100";
IF Opcode="1100" THEN
nextst <= s13;
ELSE  --op 1101
nextst <= s15;
END IF;

WHEN s13 =>
Control <= "000000001000000100000000000";
nextst <= s14;

WHEN s14 =>
Control <= "001000000000000000100000000";
nextst <= s1;

WHEN s15 =>
Control <= "001000000000000001000000000";
nextst <= s16;

WHEN s16 =>
Control <= "000000010000000010000000000";
nextst <= s1;

WHEN s17 =>
Control <= "000100010000000000000000100";
nextst <= s18;

WHEN s18 =>
Control <= "000000001000000000001000000";
nextst <= s1;

WHEN s19 =>
Control <= "000000001010000000000000000";
nextst <= s20;

WHEN s20 =>
IF cond(0)='1' THEN
Control <= "000100010000000000000000100";
nextst <= s18;
ELSE
Control <= "000000000000000000000000000";
nextst <= s29;
END IF;

WHEN s21 =>
Control <= "000000001010000000000000000";
nextst <= s22;

WHEN s22 =>
IF cond(1)='1' THEN
Control <= "000100010000000000000000100";
nextst <= s18;
ELSE
Control <= "000000000000000000000000000";
nextst <= s29;
END IF;

WHEN s23 =>
Control <= "000000000101000000000001000";
IF Opcode="0100" THEN
nextst <= s24;
ELSIF Opcode="0101" THEN
nextst <= s25;
ELSIF Opcode="0110" THEN
nextst <= s26;
ELSE  --op 0111
nextst <= s27;
END IF;

WHEN s24 =>
Control <= "000100010000100000000001000";
nextst <= s9;

WHEN s25 =>
Control <= "000101010000100000000001000";
nextst <= s9;

WHEN s26 =>
Control <= "000001010000100000000001000";
nextst <= s9;

WHEN s27 =>
Control <= "000010010000100000000001000";
nextst <= s9;

WHEN s28 =>
Control <= "000000000100000000010000000";
IF Opcode="1001" THEN
nextst <= s17;
ELSIF Opcode="1010" THEN
nextst <= s19;
ELSIF Opcode="1011" THEN
nextst <= s21;
ELSE  --to account for all cases
nextst <= s0;
END IF;

WHEN s29 =>
Control <= "000000000000000000000000000";
nextst <= s1;

END CASE;
END PROCESS;
END fsmbehav;

-- Clocking Logic
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY clklog IS PORT (
Done, Mck, Rd, Wt, Wr: IN STD_LOGIC;
StrtStop: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
Enable, R, W: OUT STD_LOGIC);
END clklog;

ARCHITECTURE clklogbehav OF clklog IS
SIGNAL Rcontent, Wcontent, runcontent, donecontent, Rq, Wq, SDone, Run: STD_LOGIC;
BEGIN

PROCESS(Done,donecontent)
BEGIN
donecontent <= Done;
END PROCESS;
SDone <= donecontent;

PROCESS(Rd,SDone,Rcontent)
BEGIN
IF Rd='0' THEN
Rcontent <= '0';
ELSIF Rd='1' AND SDone='0' THEN
Rcontent <= '1';
ELSE
Rcontent <= NOT Rd;
END IF;
END PROCESS;
Rq <= Rcontent;


PROCESS(Wr,SDone,Wcontent)
BEGIN
IF Wr='0' THEN
Wcontent <= '0';
ELSIF Wr='1' AND SDone='0' THEN
Wcontent <= '1';
ELSE
Wcontent <= NOT Wr;
END IF;
END PROCESS;
Wq <= Wcontent;

PROCESS(Mck,StrtStop,runcontent)
BEGIN
IF Mck'EVENT AND Mck='0' THEN
CASE StrtStop IS
WHEN "00" =>
NULL;
WHEN "01" =>
runcontent <= '0';
WHEN "10" =>
runcontent <= '1';
WHEN OTHERS =>
runcontent <= NOT runcontent;
END CASE;
END IF;
END PROCESS;
Run <= runcontent;

R <= Rq;
W <= Wq;
Enable <= Run AND (SDone OR NOT Wt OR NOT(Rq OR Wq));

END clklogbehav;

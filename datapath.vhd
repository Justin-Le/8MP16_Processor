-- Datapath
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY datapath IS PORT (
ALUop: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
clk, rststate, PC2in, Ain, Aout, Bin, CONDin, Gra, Grb, IRin, 
MAin, MDin, MDout, MDrd, MDwr, PC2out, PCin, PCout, 
Rin, Rout, Xout, inext, outext: IN STD_LOGIC;
Opcode: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
MemDataIn: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
instandard: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
outstandard: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
MemAddr: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
MemDataOut: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
cond: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
overflow, nop: OUT STD_LOGIC);
END datapath;

ARCHITECTURE datapathstruct OF datapath IS

COMPONENT TriState8 IS 
GENERIC(width: INTEGER := 8);
PORT(E: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Y: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT TriState16 IS 
GENERIC(width: INTEGER := 16);
PORT(E: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Y: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT ff IS
PORT(clock, Load, D: IN STD_LOGIC;
Q: OUT STD_LOGIC);
END COMPONENT;

COMPONENT reg8 IS
GENERIC(width: INTEGER := 8);
PORT(clock, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT reg16 IS
GENERIC(width: INTEGER := 16);
PORT(clock, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT pc IS
GENERIC(width: INTEGER := 8);
PORT(clock, Clear, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT MD IS
GENERIC(width: INTEGER := 16);
PORT(clock, MDin, MDrd: IN STD_LOGIC;
Dcpu, Dmem: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
MDq: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT regfile IS 
GENERIC(width: INTEGER := 8);
PORT(clock, RE, WE: IN STD_LOGIC;
addr: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
indata: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
outdata: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT rflogic IS
GENERIC(width: INTEGER := 2);
PORT(gra, grb: IN STD_LOGIC;
ra, rb: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
regsel: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT add2 IS 
GENERIC(width: INTEGER := 8);
PORT (A: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
F: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT ALU_8MP16 IS 
GENERIC(width: INTEGER := 8);
PORT (S: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	 	-- select for operations
A, B: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);	-- input operands
F: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0);		-- output
over: OUT STD_LOGIC);
END COMPONENT;

COMPONENT ffcond IS
GENERIC(width: INTEGER := 2);
PORT(Clock, Clear, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;

COMPONENT condlogic IS
PORT(acc: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
brzcond, brgcond: OUT STD_LOGIC);
END COMPONENT;

SIGNAL MDq, IRq, MDextend, IRextend: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL cpubus, PCq, PC2q, PC2d, Aq, Bq, F: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL rfaddr, CONDd: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL overf: STD_LOGIC;

BEGIN
MDextend <= cpubus & "00000000";
IRextend <= cpubus & MDq(7 DOWNTO 0);

ProgCount: pc PORT MAP(clk, rststate, PCin, cpubus, PCq);
ProgCountNext: reg8 PORT MAP(clk, PC2in, PC2d, PC2q);
PCadd: add2 PORT MAP(PCq, PC2d);
MAreg: reg8 PORT MAP(clk, MAin, cpubus, MemAddr);
Acc: reg8 PORT MAP(clk, Ain, F, Aq);
B: reg8 PORT MAP(clk, Bin, cpubus, Bq);
MDreg: MD PORT MAP(clk, MDin, MDrd, MDextend, MemDataIn, MDq);
IR: reg16 PORT MAP(clk, IRin, IRextend, IRq);
RFlog: rflogic PORT MAP(Gra, Grb, IRq(5 DOWNTO 4), IRq(1 DOWNTO 0), rfaddr);
RF: regfile PORT MAP(clk, Rout, Rin, rfaddr, cpubus, cpubus);
ArithLogUnit: ALU_8MP16 PORT MAP(ALUop, Bq, cpubus, F, overf);
CONDreg: ffcond PORT MAP(clk, rststate, CONDin, CONDd, cond);
CondLog: condlogic PORT MAP(cpubus, CONDd(0), CONDd(1));
outreg: reg8 PORT MAP(clk, outext, cpubus, outstandard);
overff: ff PORT MAP(clk, Ain, overf, overflow);

PCbuf: TriState8 PORT MAP(PCout, PCq, cpubus);
PC2buf: TriState8 PORT MAP(PC2out, PC2q, cpubus);
Accbuf: TriState8 PORT MAP(Aout, Aq, cpubus);
MDmembuf: TriState8 PORT MAP(MDwr, MDq(15 DOWNTO 8), MemDataOut);
MDcpubuf: TriState8 PORT MAP(MDout, MDq(15 DOWNTO 8), cpubus);
inbuf: TriState8 PORT MAP(inext, instandard, cpubus);
Xbuf: TriState8 PORT MAP(Xout, IRq(7 DOWNTO 0), cpubus);

Opcode <= IRq(11 DOWNTO 8);
nop <= IRq(12);
END datapathstruct;

-- Tri-state buffers
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY TriState8 IS 
GENERIC(width: INTEGER := 8);
PORT(E: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Y: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END TriState8;
ARCHITECTURE TriState8Behav OF TriState8 IS
BEGIN
PROCESS (E, D) -- get error message if no d
BEGIN
IF (E = '1') THEN
Y <= D;
ELSE
Y <= (OTHERS => 'Z');
END IF;
END PROCESS;
END TriState8Behav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY TriState16 IS 
GENERIC(width: INTEGER := 16);
PORT(E: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Y: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END TriState16;
ARCHITECTURE TriState16Behav OF TriState16 IS
BEGIN
PROCESS (E, D) -- get error message if no d
BEGIN
IF (E = '1') THEN
Y <= D;
ELSE
Y <= (OTHERS => 'Z');
END IF;
END PROCESS;
END TriState16Behav;

--Register File
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;	 -- needed for CONV_INTEGER()
ENTITY regfile IS 
GENERIC(width: INTEGER := 8);
PORT(clock, RE, WE: IN STD_LOGIC;
addr: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
indata: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
outdata: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END regfile;

ARCHITECTURE regfilebehav OF regfile IS
SUBTYPE reg IS STD_LOGIC_VECTOR(7 DOWNTO 0);
TYPE regArray IS array(0 to 3) OF reg;
SIGNAL RF: regArray;	 --register file contents
BEGIN
Write: PROCESS (clock, addr, WE, RF)
BEGIN
IF (clock'EVENT AND clock='1') THEN
IF (WE = '1') THEN
RF(CONV_INTEGER(addr)) <= indata;
END IF;
END IF;
END PROCESS;

Read: PROCESS (clock, addr, RE, RF)
BEGIN
IF (RE = '1') THEN
outdata <= RF(CONV_INTEGER(addr));
ELSE
outdata <= (OTHERS => 'Z');
END IF;
END PROCESS;
END regfilebehav;

--Adder for PC
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY add2 IS 
GENERIC(width: INTEGER := 8);
PORT (A: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
F: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END add2;
ARCHITECTURE add2behav OF add2 IS
BEGIN
F <= A + 2;
END add2behav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY ff IS
PORT(clock, Load, D: IN STD_LOGIC;
Q: OUT STD_LOGIC);
END ff;
ARCHITECTURE ffbehav OF ff IS
SIGNAL content: STD_LOGIC;
BEGIN
PROCESS(clock)
BEGIN
IF (clock'EVENT AND clock = '1') THEN
IF Load = '1' THEN
content <= D;
END IF;
END IF;
END PROCESS;
Q <= content;
END ffbehav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY reg8 IS
GENERIC(width: INTEGER := 8);
PORT(clock, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END reg8;
ARCHITECTURE reg8behav OF reg8 IS
SIGNAL content: STD_LOGIC_VECTOR(width-1 DOWNTO 0);
BEGIN
PROCESS(clock)
BEGIN
IF (clock'EVENT AND clock = '1') THEN
IF Load = '1' THEN
content <= D;
END IF;
END IF;
END PROCESS;
Q <= content;
END reg8behav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY reg16 IS
GENERIC(width: INTEGER := 16);
PORT(clock, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END reg16;
ARCHITECTURE reg16behav OF reg16 IS
SIGNAL content: STD_LOGIC_VECTOR(width-1 DOWNTO 0);
BEGIN
PROCESS(clock)
BEGIN
IF (clock'EVENT AND clock = '1') THEN
IF Load = '1' THEN
content <= D;
END IF;
END IF;
END PROCESS;
Q <= content;
END reg16behav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY pc IS
GENERIC(width: INTEGER := 8);
PORT(clock, Clear, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END pc;
ARCHITECTURE pcbehav OF pc IS
SIGNAL content: STD_LOGIC_VECTOR(width-1 DOWNTO 0);
BEGIN
PROCESS(clock)
BEGIN
IF (clock'EVENT AND clock = '1') THEN
IF Clear = '1' THEN
content <= (OTHERS => '0');
ELSIF Load = '1' THEN
content <= D;
END IF;
END IF;
END PROCESS;
Q <= content;
END pcbehav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY rflogic IS
GENERIC(width: INTEGER := 2);
PORT(gra, grb: IN STD_LOGIC;
ra, rb: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
regsel: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END rflogic;
ARCHITECTURE rflogicbehav OF rflogic IS
BEGIN
PROCESS(gra, grb, ra, rb)
BEGIN
IF gra='1' THEN
regsel <= ra;
ELSIF grb='1' THEN
regsel <= rb;
ELSE
regsel <= "ZZ";
END IF;
END PROCESS;
END rflogicbehav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY MD IS
GENERIC(width: INTEGER := 16);
PORT(clock, MDin, MDrd: IN STD_LOGIC;
Dcpu, Dmem: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
MDq: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END MD;
ARCHITECTURE MDbehav OF MD IS
SIGNAL content: STD_LOGIC_VECTOR(width-1 DOWNTO 0);
COMPONENT TriState16 IS 
GENERIC(width: INTEGER := 16);
PORT(E: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Y: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;
BEGIN
PROCESS(clock)
BEGIN
IF (clock'EVENT AND clock = '1') THEN
IF MDin = '1' THEN
content <= Dcpu;
ELSIF MDrd = '1' THEN
content <= Dmem;
END IF;
END IF;
END PROCESS;
MDq <= content;
END MDbehav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY ffcond IS
GENERIC(width: INTEGER := 2);
PORT(Clock, Clear, Load: IN STD_LOGIC;
D: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Q: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END ffcond;
ARCHITECTURE ffcondbehav OF ffcond IS
SIGNAL content: STD_LOGIC_VECTOR(width-1 DOWNTO 0);
BEGIN
PROCESS(Clock)
BEGIN
IF (Clock'EVENT AND Clock = '1') THEN
IF Clear = '1' THEN
content <= (OTHERS => '0');
ELSIF Load = '1' THEN
content <= D;
END IF;
END IF;
END PROCESS;
Q <= content;
END ffcondbehav;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY condlogic IS
PORT(acc: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
brzcond, brgcond: OUT STD_LOGIC);
END condlogic;
ARCHITECTURE condlogicbehav OF condlogic IS
BEGIN
brzcond <= NOT (acc(7) OR acc(6) OR acc(5) OR acc(4) OR acc(3) OR acc(2) OR acc(1) OR acc(0));
brgcond <= (NOT acc(7)) AND (acc(6) OR acc(5) OR acc(4) OR acc(3) OR acc(2) OR acc(1) OR acc(0));
END condlogicbehav;

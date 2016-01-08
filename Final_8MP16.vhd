-- Top-Level
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY Final_8MP16 IS
PORT (	Mck, Strt, Reset, Done: IN STD_LOGIC;
		input: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		output: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		overflow: OUT STD_LOGIC;
		MemDatachk: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MemAddrchk: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END Final_8MP16;

ARCHITECTURE Final_8MP16arch OF Final_8MP16 IS

SIGNAL Opcode: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL cond: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL R, W, Nop: STD_LOGIC;
SIGNAL Control: STD_LOGIC_VECTOR(26 DOWNTO 0);
SIGNAL DataRd: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL DataWr, MemAddr: STD_LOGIC_VECTOR(7 DOWNTO 0);

COMPONENT fsm IS PORT (
Opcode: IN STD_LOGIC_VECTOR(3 downto 0);
cond: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
Done, Mck, Strt, Reset, Nop: IN STD_LOGIC;
Ctrl: OUT STD_LOGIC_VECTOR(26 DOWNTO 0);
R, W: OUT STD_LOGIC);
END COMPONENT;

COMPONENT datapath IS PORT (
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
END COMPONENT;

COMPONENT dualportram IS
GENERIC(address_width 	: INTEGER := 8;
		data_width    	: INTEGER := 8);
PORT(	clock			: IN  STD_LOGIC;
		data			: IN  STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		write_address	: IN  STD_LOGIC_VECTOR(address_width-1 DOWNTO 0);
		read_address 	: IN  STD_LOGIC_VECTOR(address_width-1 DOWNTO 0);
		re, we			: IN  STD_LOGIC;
		q		        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END COMPONENT;

BEGIN

FiniteStateMachine: fsm PORT MAP(	Opcode, cond, Done, Mck, Strt, Reset, 
									Nop, Control, R, W);
						
Data: datapath PORT MAP(Control(23 DOWNTO 21), Mck, Control(26),
						Control(20), Control(19), Control(18),
						Control(17), Control(16), Control(15),
						Control(14), Control(13), Control(12),
						Control(11), Control(10), Control(9),
						Control(8), Control(7), Control(6),
						Control(5), Control(4), Control(3),
						Control(2), Control(1), Control(0),
						Opcode, DataRd, input, output, MemAddr,
						DataWr, cond, overflow, Nop);

Memory: dualportram PORT MAP(	Mck, DataWr, MemAddr, MemAddr, 
								R, W, DataRd);

MemDatachk <= DataRd;
MemAddrchk <= MemAddr;
END Final_8MP16arch;

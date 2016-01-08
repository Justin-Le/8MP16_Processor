--ALU
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY ALU_8MP16 IS 
GENERIC(width: INTEGER := 8);
PORT (S: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	 	-- select for operations
A, B: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);	-- input operands
F: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0);		-- output
over: OUT STD_LOGIC);
END ALU_8MP16;
ARCHITECTURE alustruct OF ALU_8MP16 IS
COMPONENT adders IS 
GENERIC(width: INTEGER := 8);
PORT (
x, y, Ci: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Cout: OUT STD_LOGIC;
SUM: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END COMPONENT;
SIGNAL SUBINC: STD_LOGIC;
SIGNAL faout: STD_LOGIC_VECTOR(width DOWNTO 0);
SIGNAL ASID, SNID, NEGv: STD_LOGIC_VECTOR(width-1 DOWNTO 0);
SIGNAL AND_AB, OR_AB, NOT_B, ADD, SUB, INC, DEC: STD_LOGIC;
BEGIN
AND_AB <= NOT S(2) AND NOT S(1) AND S(0);
OR_AB <= NOT S(2) AND S(1) AND NOT S(0);
NOT_B <= NOT S(2) AND S(1) AND S(0);
ADD <= S(2) AND NOT S(1) AND NOT S(0);
SUB <= S(2) AND NOT S(1) AND S(0);
INC <= S(2) AND S(1) AND NOT S(0);
DEC <= S(2) AND S(1) AND S(0);


FAin1: FOR i IN width-1 DOWNTO 0 GENERATE
ASID(i) <= (ADD OR SUB OR INC OR DEC) AND A(i);
END GENERATE FAin1;

FAin2: FOR j IN width-1 DOWNTO 0 GENERATE
SNID(j) <= ( (SUB OR NOT_B) XOR B(j) ) AND ( NOT(INC OR DEC) );
END GENERATE FAin2;

NEGin: FOR m IN width-1 DOWNTO 1 GENERATE
NEGv(m) <= DEC;
END GENERATE NEGin;
NEGv(0) <= SUB OR INC OR DEC;

RippleCarry: adders PORT MAP(ASID, SNID, NEGv,
							 faout(width), faout(width-1 DOWNTO 0));

over <= faout(width);

output: FOR z IN width-1 DOWNTO 0 GENERATE
F(z) <= (NOT AND_AB AND NOT OR_AB AND faout(z)) OR 
		(AND_AB AND A(z) AND B(z)) OR
		(OR_AB AND (A(z) OR B(z)));
END GENERATE output;
END alustruct;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY adders IS 
GENERIC(width: INTEGER := 8);
PORT (
x, y, Ci: IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
Cout: OUT STD_LOGIC;
SUM: OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0));
END adders;
ARCHITECTURE Structural OF adders IS
BEGIN
SUM <= x + y + Ci;
Cout <= (x(width-1) AND y(width-1)) OR 
		(Ci(width-1) AND (x(width-1) XOR y(width-1)));
END Structural;
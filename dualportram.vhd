LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; 
ENTITY dualportram IS
GENERIC(address_width 	: INTEGER := 8;
		data_width    	: INTEGER := 8);
PORT(	clock			: IN  STD_LOGIC;
		data			: IN  STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
		write_address	: IN  STD_LOGIC_VECTOR(address_width-1 DOWNTO 0);
		read_address 	: IN  STD_LOGIC_VECTOR(address_width-1 DOWNTO 0);
		re, we			: IN  STD_LOGIC;
		q		        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END dualportram;

ARCHITECTURE rtl OF dualportram IS
TYPE		ram IS ARRAY(0 TO 2**address_width-1) OF 
			STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
SIGNAL		ram_block                 	: ram;
ATTRIBUTE	ram_init_file             	: STRING;
ATTRIBUTE	ram_init_file OF ram_block	: SIGNAL IS "Test_br.mif";
BEGIN
PROCESS (clock)
BEGIN

IF RISING_EDGE(clock) THEN
	IF (we='1') THEN
		ram_block(TO_INTEGER(UNSIGNED(write_address))) <= data;
	END IF;
	IF (re='1') THEN
		q(15 DOWNTO 8) <= ram_block(TO_INTEGER(UNSIGNED(read_address)));
		q(7 DOWNTO 0) <= ram_block(TO_INTEGER(UNSIGNED(read_address))+1);
	END IF;
END IF;
END PROCESS;
END rtl;

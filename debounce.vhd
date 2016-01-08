LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY debounce IS
  GENERIC(
    counter_size  :  INTEGER := 5);		--counter width
    PORT(
    button  : IN  STD_LOGIC;
    db_clk  : IN  STD_LOGIC;
    result  : OUT STD_LOGIC);
END debounce;

ARCHITECTURE behav OF debounce IS
  SIGNAL flipflops   : STD_LOGIC_VECTOR(1 DOWNTO 0);	 --input flip flops
  SIGNAL clear : STD_LOGIC;                        			 --sync clear counter
  SIGNAL counter_out : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0');	--counter output
BEGIN

  clear <= flipflops(0) xor flipflops(1);  			--determine when to start/reset counter
  
  PROCESS(db_clk)
  BEGIN
    IF (db_clk'EVENT and db_clk = '1') THEN
      flipflops(0) <= button;
      flipflops(1) <= flipflops(0);
      IF (clear = '1') THEN                     				--reset counter if input is changing
        counter_out <= (OTHERS => '0');
      ELSIF(counter_out(counter_size) = '0') THEN 		--signal not yet stable
        counter_out <= counter_out + 1;           			--count until signal stable
      ELSE                                        --signal stable
        result <= flipflops(1);
      END IF;    
    END IF;
  END PROCESS;
END behav;
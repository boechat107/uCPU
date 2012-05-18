--
-- unit: rom
--


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.std_logic_extra.ALL;

ENTITY rom IS
	GENERIC( 
		FNAME: STRING := "";-- file name
		W: NATURAL := 8;	-- W bit data bus
		N: NATURAL := 10	-- N bit address
	);
	PORT(
		addr: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);	--
		data: OUT STD_LOGIC_VECTOR(W-1 DOWNTO 0)		--
	);
END ENTITY rom;

ARCHITECTURE a OF rom IS
    CONSTANT MAXADDR: NATURAL := 2**N - 1;
    TYPE memtype IS ARRAY ( 0 TO MAXADDR ) OF STD_LOGIC_VECTOR(W-1 DOWNTO 0);
    SIGNAL mem: memtype;
BEGIN

    data <= mem(TO_INTEGER(UNSIGNED(addr)));

    PROCESS
	VARIABLE d : STD_LOGIC_VECTOR(W-1 DOWNTO 0);
	VARIABLE a : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	VARIABLE xd: BIT_VECTOR(W-1 DOWNTO 0);
	VARIABLE xa: BIT_VECTOR(N-1 DOWNTO 0);
	FILE f: TEXT;
	VARIABLE l: LINE;
    BEGIN
	IF FNAME = 	"" THEN
	    WAIT;
	END IF;
	file_open(f,FNAME,read_mode);
	report LF & LF & "*********************************************" & LF &
		"CARREGANDO PROGRAMA NA ROM..." & LF &
		"*********************************************" & CR & LF;

	WHILE NOT endfile(f)
	LOOP
	    READLINE(f,l);
	    READ(l,xa);
	    READ(l,xd);
	    a := to_stdlogicvector(xa);
	    REPORT "a=" & to_string(a) & CR & LF;
	    --	REPORT "b=" & to_string(xb) & CR & LF;
	    mem(to_integer(unsigned(a))) <= to_stdlogicvector(xd);
	END LOOP;
	file_close(f);
	WAIT;
    END PROCESS;

END a;







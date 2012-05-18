--
-- functions to convert std_logic to/from character and
--           to convert std_logic_vector to/from string
--
-- author:		 hans (hans@ele.ufes.br)
--
-- v1.0   09/07 : only to_string functions
-- v2.0   09/08 : include to_stdlogic functions
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package std_logic_extra is
    function to_character(arg: std_logic) return character;
    function to_string(arg: std_logic_vector) return string;
    function to_stdlogic(arg: character) return std_logic;
    function to_stdlogicvector(arg: string) return std_logic_vector;
end package;

package body std_logic_extra is

    function to_character(arg: std_logic) return character is
    begin
	    case arg is
		when '0' => return '0';
		when '1' => return '1';
		when 'L' => return 'L';
		when 'H' => return 'H';
		when 'X' => return 'X';
		when 'U' => return 'U';
		when '-' => return '-';
		when 'W' => return 'W';
		when 'Z' => return 'Z';
		when others => return '*';
		end case;
    end function to_character;
    
    function to_stdlogic(arg: character) return std_logic is
    begin
	    case arg is
		when '0' => return '0';
		when '1' => return '1';
		when 'L' => return 'L';
		when 'H' => return 'H';
		when 'X' => return 'X';
		when 'U' => return 'U';
		when '-' => return '-';
		when 'W' => return 'W';
		when 'Z' => return 'Z';
		when others => return 'U';
		end case;    
    end function to_stdlogic;

    function to_string(arg: std_logic_vector) return string is
    variable S: string(1 to arg'length) := (others=>'*');
    variable J: natural;
    begin
	    J := 1;
	    for I in arg'range  loop
		    S(J) := to_character(arg(I));
		    J := J + 1;
	    end loop;
	    return S;
    end function to_string;
    
    function to_stdlogicvector(arg: string) return std_logic_vector is
    variable V: std_logic_vector(arg'length-1 downto 0) := (others=>'0');
    variable J: integer;
    variable II : natural;
    begin
	    J := V'left ;
	    for I in arg'range  loop
	          V(J) := to_stdlogic(arg(I));
		    J := J - 1;
	    end loop;
	    return V;
    end function to_stdlogicvector;

end package body std_logic_extra;


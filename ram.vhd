--****************************************************************** 
--ANDRE AMBROSIO BOECHAT
--GILBERTO ALVES SANTOS SEGUNDO
--TRABALHO DE ELETRONICA DIGITAL II
--Sat Nov 28 11:41:34 BRST 2009
--****************************************************************** 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE std.textio.ALL;
USE work.std_logic_extra.ALL;

entity ram is
    generic(	W : natural := 8;   -- largura do barramento de dados
		N : natural := 12   -- numero de bits para endereco
	    );
    port(	addr : in std_logic_vector(N-1 downto 0);
		data : inout std_logic_vector(W-1 downto 0);
		write : in std_logic;
		read : in std_logic;
		clk : in std_logic
	    );
end entity ram;


architecture a of ram is
    constant maxAddr : natural := 2**N - 1;	-- ultimo endereco possivel da memoria
    type memtype is array(0 to maxAddr) of std_logic_vector(W-1 downto 0);
    signal mem : memtype;

    signal mdata : std_logic_vector(W-1 downto 0);
begin

    data <= (others=>'Z') when read = '0' else mdata;

    mdata <= mem(to_integer(unsigned(addr)));

    process(clk)
    begin
	if rising_edge(clk) then
	    if write = '1' then
		mem(to_integer(unsigned(addr))) <= data;
	    end if;
	end if;
    end process;


    -- Imprime os dados armazenados na RAM quando se armazena os bits 11111111 em qualquer
    -- endereco da memoria
    process(data,write)
        variable index : integer range 0 to (maxAddr+1);
    begin
        if data = "11111111" and write = '1' then
            index := 0;
	    report "*********************************************"; 
	    report "IMPRIMINDO DADOS DA RAM...";

            while index /= (maxAddr+1)
            loop
        	if mem(index) /= "UUUUUUUU" then
		    report "Endereco " & integer'image(index) & " : " & to_string(mem(index));
        	end if;
        	index := index + 1;
            end loop;

	    report "*********************************************" & CR & LF;
        end if;
    end process;	    

end architecture a;

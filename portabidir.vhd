-- 
-- modulo: portabidir
--
-- implementa uma porta bidirecional de N bits onde cada pino pode ser usado 
-- como entrada ou saida de acordo com o sinal dir.
-- quando configurado como saida (dir(i)='1') o valor que entra em saida (!)
-- aparece no pino.
-- quando configurado como entrada (dir(i)='0') o valor dos pinos pode ser
-- acessado em entrada.
--            +-----------------------+
--            |                       |
--         => | saida           pinos | =>
--            |                       | 
--         => | dir                   |
--            |                       |
--         <= | entrada               |
--            |                       |
--            +-----------------------+ 
--
--
--
-- autor:	hans
-- data:	
--

library ieee;
use ieee.std_logic_1164.all;

entity portabidir is
	generic(
		N : natural := 8
	);
	port(	
		saida 	: in std_logic_vector(N-1 downto 0);
		dir 	: in std_logic_vector(N-1 downto 0);
		entrada : out std_logic_vector(N-1 downto 0);
		pinos	: inout std_logic_vector(N-1 downto 0)
		);
end entity portabidir;


architecture a of portabidir is
begin
	entrada <= pinos; 

	process(dir,saida) -- combinacional
	begin
		for I in 0 to N-1 
		loop
			if dir(i) = '1' then
				pinos(i) <= saida(i);
			else
				pinos(i) <= 'Z';
			end if;
		end loop;

	end process;


end architecture a;


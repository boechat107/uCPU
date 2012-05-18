--****************************************************************** 
--ANDRE AMBROSIO BOECHAT
--GILBERTO ALVES SANTOS SEGUNDO
--Mon Nov 30 08:19:35 BRST 2009
--****************************************************************** 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ioport is
    generic(B : natural := 8);
    port(   clk : in std_logic;
	    rst : in std_logic;
	    data : inout std_logic_vector(B-1 downto 0);
	    addr : in std_logic_vector(1 downto 0);
	    read : in std_logic;
	    write : in std_logic;
	    pins: inout std_logic_vector(B-1 downto 0)
	);
end entity ioport;


architecture a of ioport is
    constant iodta : integer := 0;
    constant iodir : integer := 1;
    constant ioset : integer := 2;
    constant ioclr : integer := 3;
    type regtype is array(0 to 3) of std_logic_vector(B-1 downto 0);
    signal reg : regtype;

    signal inputdata : std_logic_vector(B-1 downto 0);
    signal outputdata : std_logic_vector(B-1 downto 0);
    signal preoutput : std_logic_vector(B-1 downto 0);
begin

    portabidir: entity work.portabidir
	    generic map(N => B)
	    port map(	saida => outputdata, --reg(iodta),
			dir => reg(iodir),
			entrada => inputdata,
			pinos => pins
		    );
    
    data <= (others=>'Z') when read = '0' else inputdata;

    -- Prioridade para a operacao de reset
    preoutput <= reg(iodta) or reg(ioset);
    outputdata <= preoutput and (not reg(ioclr));

    process(clk, rst)
    begin
	if rst = '1' then
	    reg(iodir) <= (others=>'0');	    -- porta como entrada
	    reg(ioset) <= (others=>'0');
	    reg(ioclr) <= (others=>'0');
	    reg(iodta) <= (others=>'0');
	elsif rising_edge(clk) then
	    if write = '1' then
		reg(to_integer(unsigned(addr))) <= data;
	    end if;
	end if;
    end process;

end architecture a;

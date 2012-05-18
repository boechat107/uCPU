--****************************************************************** 
--ANDRE AMBROSIO BOECHAT
--GILBERTO ALVES SANTOS SEGUNDO
--TRABALHO DE ELETRONICA DIGITAL 2
--Fri Nov 27 17:30:45 BRST 2009
--****************************************************************** 

--
-- modulo: ucpu
--   implementa uma cpu de 8 bit com arquitetura harvard (memorias de dados e instrucoes separadas)
--   com instrucoes de 18 bits
-- as instrucoes tem os seguintes formatos
-- load		00 dddd xxxxxxxxxxxx
-- store	01 dddd xxxxxxxxxxxx
-- arit		10 dddd aaaa bbbb oooo
-- salto	11 ooo yyyyyyyyyyyyy
--
-- onde 
--
-- autor:	hans
-- data:	
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ucpu is
	port(	
		clk:	in	std_logic;	-- clock 
		rst:	in	std_logic;	-- reset (active high)
	-- memoria de instrucoes 
		iaddr:	out	std_logic_vector(12 downto 0);
		inst:	in	std_logic_vector(17 downto 0);
	-- memoria de dados
		maddr:	out	std_logic_vector(11 downto 0);
		mdata:	inout std_logic_vector(7 downto 0);
		mread:	out	std_logic;
		mwrite:	out	std_logic
		);
end entity ucpu;


architecture a of ucpu is
    type state_type is (fetch,execute);
    signal state: state_type;

    type regmem is array(1 to 15) of std_logic_vector(7 downto 0);
    signal reg: regmem;

    type stacktype is array(0 to 7) of std_logic_vector(12 downto 0);
    signal stack : stacktype;

    signal sp : integer range 0 to 8;		    -- stack pointer
    signal pc: unsigned(12 downto 0);
    signal ir: std_logic_vector(17 downto 0);
    signal ina,inb,inregres: std_logic_vector(7 downto 0);
    signal res : std_logic_vector(8 downto 0);
    signal aluop: std_logic_vector(3 downto 0);
    signal inda,indb,indres: integer range 0 to 15;
    signal read,write: std_logic;
    signal cf,zf,ov,sf : std_logic;		    -- flags
    signal overflow,zero,carry,negative : std_logic;-- ativa ou nao as flags
begin

-- ****************************************************************** 
-- ALU
-- ****************************************************************** 
    aluop <= ir(3 downto 0);

    inda <= to_integer(unsigned(ir(7 downto 4)));
    indb <= to_integer(unsigned(ir(11 downto 8)));
    indres <= to_integer(unsigned(ir(15 downto 12)));

    ina <= reg(inda) when inda /= 0 else (others=>'0');
    inb <= reg(indb) when indb /= 0 else (others=>'0');
    inregres <= reg(indres) when indres /= 0 else (others=>'0');

    process(ina,inb,aluop,res,cf,zero,carry,negative)
    begin
	case aluop is

	    -- ****************************************************************** 
	    -- As flags utilizadas neste projeto sao redundantes, mas foram
	    -- deixadas para enfatizar o uso/importancia de cada uma.
	    -- ****************************************************************** 
	    when "0000" =>	-- ADD
		res <= std_logic_vector(unsigned('0' & ina) + unsigned('0' & inb));
		if res(8) = '1' then
		    overflow <= '1';
		    carry <= '1';
		else
		    overflow <= '0';
		    carry <= '0';
		end if;

	    when "0001" =>	-- ADC
		if cf = '0' then
		    res <= std_logic_vector(unsigned('0' & ina) + unsigned('0' & inb));
		else
		    res <= std_logic_vector(unsigned('0' & ina) + unsigned('0' & inb) + 1);
		end if;
		if res(8) = '1' then
		    overflow <= '1';
		    carry <= '1';
		else
		    overflow <= '0';
		    carry <= '0';
		end if;

	    when "0010" =>	-- SUB
		res <= std_logic_vector(unsigned('0' & ina) - unsigned('0' & inb));
		if res(8) = '1' then 
		    negative <= '1';
		else
		    negative <= '0';
		end if;

	    when "0011" =>	-- AND
		res <= '0' & (ina and inb);

	    when "0100" =>	-- OR
		res <= '0' & (ina or inb);

	    when "0101" =>	-- XOR
		res <= '0' & (ina xor inb);

	    when others =>
		res <= (others=>'0');
	end case;

	if res(7 downto 0) = "00000000" then
	    zero <= '1';
	else
	    zero <= '0';
	end if;
    end process;


-- ****************************************************************** 
-- BUS
-- ****************************************************************** 
    mread <= read;
    mwrite <= write;
    read <= '1' when state = execute AND ir(17 downto 16) = "00" else '0'; -- load
    write <= '1' when state = execute AND ir(17 downto 16) = "01" else '0'; -- store
    mdata <= "ZZZZZZZZ" when read = '1' else inregres;
    maddr <= ir(11 downto 0);

    iaddr <= std_logic_vector(pc);


    process(clk,rst)
	variable indreg : unsigned(3 downto 0);
    begin
	if rst = '1' then
	    state <= fetch;
	    pc <= (others=>'0');
	    sp <= 0;
	elsif rising_edge(clk) then
	    case state is

		when fetch =>
		    ir <= inst;
		    state <= execute;
		    pc <= pc + 1;

		when execute =>
		    case ir(17 downto 16) is

			when "00" => -- load
			    if indres /= 0 then
				reg(indres) <= mdata;
			    else
				indreg := unsigned(ir(11 downto 8));
				reg(to_integer(indreg)) <= ir(7 downto 0);
			    end if;
			    pc <= pc + 1;
			    ir <= inst;


			when "01" => -- store
			    pc <= pc + 1;
			    ir <= inst;


			when "10" => -- arit
			    if indres /= 0 then
				reg(indres) <= res(7 downto 0);
			    end if;
			    ov <= overflow;
			    zf <= zero;
			    cf <= carry;
			    sf <= negative;
			    pc <= pc + 1;
			    ir <= inst;


			when others => -- jump
			    case ir(15 downto 13) is
				when "000" =>		    -- unconditional jump
				    pc <= unsigned(ir(12 downto 0));
				    state <= fetch;

				when "001" =>		    -- jump if res is zero
				    if zf = '1' then
					pc <= unsigned(ir(12 downto 0));
					state <= fetch;
				    else
					pc <= pc + 1;
					ir <= inst;
				    end if;

				when "010" =>		    -- jump if res is NOT zero
				    if zf = '0' then
					pc <= unsigned(ir(12 downto 0));
					state <= fetch;
				    else
					pc <= pc + 1;
					ir <= inst;
				    end if;

				when "011" =>		    -- jump if res is negative
				    if sf = '1' then
					pc <= unsigned(ir(12 downto 0));
					state <= fetch;
				    else
					pc <= pc + 1;
					ir <= inst;
				    end if;

				when "100" =>		    -- jump if there is carry
				    if cf = '1' then
					pc <= unsigned(ir(12 downto 0));
					state <= fetch;
				    else
					pc <= pc + 1;
					ir <= inst;
				    end if;

				when "101" =>		    -- jump if overflow
				    if ov = '1' then
					pc <= unsigned(ir(12 downto 0));
					state <= fetch;
				    else
					pc <= pc + 1;
					ir <= inst;
				    end if;

				when "110" =>		    -- calling a routine
				    stack(sp) <= std_logic_vector(pc);
				    pc <= unsigned(ir(12 downto 0));
				    sp <= sp + 1;
				    state <= fetch;

				when "111" =>		    -- returning from a routine
				    pc <= unsigned(stack(sp-1));
				    sp <= sp - 1;
				    state <= fetch;

				when others =>
				    pc <= pc + 1;
				    ir <= inst;
			    end case;

		    end case;
	    end case;
	end if;		
    end process;

end architecture a;


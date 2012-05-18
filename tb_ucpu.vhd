--****************************************************************** 
--ANDRE AMBROSIO BOECHAT
--GILBERTO ALVES SANTOS SEGUNDO
--TRABALHO DE ELETRONICA DIGITAL II
--Sat Nov 28 11:38:12 BRST 2009
--******************************************************************

--
-- testbench for ucpu


library ieee;
use ieee.Std_logic_1164.all;
use ieee.Numeric_Std.all;
use work.std_logic_extra.all;

entity tb_ucpu is
end;

architecture bench of tb_ucpu is
    signal clk: std_logic := '1';
    signal clken: std_logic := '1';
    signal rst: std_logic := '0';
    signal iaddr: std_logic_vector(12 downto 0);
    signal inst: std_logic_vector(17 downto 0);
    signal maddr: std_logic_vector(11 downto 0);
    signal mdata: std_logic_vector(7 downto 0);
    signal mread,ioread,ucpuread: std_logic;
    signal mwrite,iowrite,ucpuwrite: std_logic;
    signal iopinos : std_logic_vector(7 downto 0);

    constant PERIOD : time := 10 ns;
    constant MAXINST: natural := 100 + 4;	-- programa: maximo de 30 instrucoes
begin

	clk <= not clk and clken after PERIOD/2;

	uut: entity work.ucpu
		port map (
			clk    => clk,
			rst    => rst,
			iaddr  => iaddr,
			inst   => inst,
			maddr  => maddr,
			mdata  => mdata,
			mread  => ucpuread,
			mwrite => ucpuwrite
		);

	rom: entity work.rom
		generic map (
			fname =>  "PROGRAMA.TXT",
			n => 13,
			w => 18
		)
		port map (
			addr => iaddr,
			data => inst
		);

	ram: entity work.ram
		generic map(
			W => 8,
			N => 12
		    )
		port map(
			addr => maddr,
			data => mdata,
			write => mwrite,
			read => mread,
			clk => clk
		    );

	ioport: entity work.ioport
		generic map(B => 8)
		port map(
			clk => clk,
			rst => rst,
			data => mdata,
			addr => maddr(1 downto 0),
			read => ioread,
			write => iowrite,
			pins => iopinos
		    );
    
    -- Reserva-se os enderecos 10H a 13H para comunicacao com a porta paralela
    mread <= '0' when maddr(11 downto 2) = "0000000100" else ucpuread;
    mwrite <= '0' when maddr(11 downto 2) = "0000000100" else ucpuwrite;

    ioread <= '0' when maddr(11 downto 2) /= "0000000100" else ucpuread;
    iowrite <= '0' when maddr(11 downto 2) /= "0000000100" else ucpuwrite;

-- ****************************************************************** 
-- SIMULACAO
-- ****************************************************************** 

  stimulus: process
  begin
    -- Put initialisation code here
	rst <= '1';
	clken <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
  	rst <= '0';
	report LF & LF & "*********************************************" & LF &
		"EXECUTANDO PROGRAMA..." & LF &
		"*********************************************" & CR & LF;
	
    -- Put test bench stimulus code here
	while iaddr /= "1111111111111"  -- salto para 11111111111111 para a simulacao
          and now < PERIOD*MAXINST  -- MAXINST instrucoes
	loop
		report "pc = " & to_string(iaddr) & " instrucao = " & to_string(inst) &
		" pinos = " & to_string(iopinos) & CR & LF;

		-- Quando um salto eh executado, a proxima instrucao da memoria eh
		-- impressa mas nao eh executada, pois o estado da maquina de estados eh
		-- fetch.

		wait until rising_edge(clk);

		-- Teste da porta como entrada de dados
		iopinos(7 downto 4) <= "1100";
	end loop;
	
	report LF & LF & "*********************************************" & LF &
		"FIM DO PROGRAMA..." & LF &
		"*********************************************" & CR & LF;

	clken <= '0';
	
	report LF & LF & "=====================================================" & LF &
		"POR FAVOR, LEIA O README PARA CONHECER ALGUNS " & LF &
		"DETALHES E DECISOES DE PROJETO" & LF &
		"=====================================================" & CR & LF;
    wait;
  end process;


end;


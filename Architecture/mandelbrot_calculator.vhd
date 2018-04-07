-------------------------------------------------------------------------------
-- Title       : Architecture calcul fractal de mandelbrot
-- Project     : Labo LPSC fractal
-------------------------------------------------------------------------------
-- File        : mandelbrot_calculator.vhd
-- Authors     : Jérémie Macchi
-- Company     : HES-SO Master
-- Created     : 26.03.2018
-- Last update : 07.03.2018
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: Architecture pour le calcul de fractal pour le Labo de LPSC
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 26.03.2018   1.0		 JMI 	 Created
-- 07.03.2018		1.1		 JMI	 Correction à l'aide du testbench
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

-----------------------------
-- Déclaration de l'entité --
-----------------------------
entity mandelbrot_calculator is
generic (comma	: integer := 12;	-- nombres de bits après la virgule
	max_iter	: integer := 100;
	SIZE		: integer := 16);
port (
	clk 		: in 	std_logic;
	rst 		: in 	std_logic;
	ready		: out	std_logic;
	start		: in 	std_logic;
	finished	: out	std_logic;
	c_real		: in	std_logic_vector(SIZE-1 downto 0);
	c_imaginary	: in 	std_logic_vector(SIZE-1 downto 0);
	z_real		: out 	std_logic_vector(SIZE-1 downto 0);
	z_imaginary	: out 	std_logic_vector(SIZE-1 downto 0);
	iterations	: out 	std_logic_vector(SIZE-1 downto 0)
);
end mandelbrot_calculator;

--------------------
--	Architecture  --
--------------------
architecture calculator of mandelbrot_calculator is

	------------------
	--  Constantes  --
	------------------
	-- Etat de la machine d'état
	constant S_READY	: std_logic := '0';
	constant S_PROCESS	: std_logic := '1';

	constant DOUBLE_SIZE : integer := 2*SIZE;
	-- Valeur limite pour la comparaison (2^2 = 4)
	constant val_limite : std_logic_vector(DOUBLE_SIZE-1 downto 0) := "00000100" & "000000000000000000000000";

	---------------
	--  Signaux  --
	---------------
	signal ready_s			: std_logic;
	signal start_s			: std_logic;
	signal finished_s		: std_logic;
	signal z_real_s			: std_logic_vector(SIZE-1 downto 0);
	signal z_imaginary_s	: std_logic_vector(SIZE-1 downto 0);
	signal iterations_s		: std_logic_vector(SIZE-1 downto 0);

	-- Signaux intermediaires pour les calculs
	signal z_real2_s				: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_imaginary2_s			: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real_x_imaginary_s		: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_2_real_x_imaginary_s	: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real2_sub_imaginary2_s	: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real2_add_imaginary2_s	: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real_fut_s				: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_imaginary_fut_s		: std_logic_vector(DOUBLE_SIZE-1 downto 0);

	-- Signaux pour de sorties des bascules
	signal z_new_real_s				: std_logic_vector(SIZE-1 downto 0);
	signal z_new_imaginary_s		: std_logic_vector(SIZE-1 downto 0);
	signal new_iterations_s			: std_logic_vector(SIZE-1 downto 0);

	-- Signaux de controle
	signal enable_calcul: std_logic;
	signal rst_calcul: std_logic;

	-- Signaux pour la machine d'etat
	signal EtatPresent: std_logic;
	signal EtatFutur: std_logic;

-------------
--	Begin  --
-------------
begin
	-------------------------------
	--  Assignation des signaux  --
	-------------------------------
	z_real 		<= z_real_s;
	z_imaginary <= z_imaginary_s;
	iterations 	<= iterations_s;
	finished	<= finished_s;

	--------------------
	--  Combinatoire  --
	--------------------
	combinatoire : process(ready_s, c_real, c_imaginary, z_new_real_s, z_new_imaginary_s, z_real_s, z_imaginary_s, z_real_x_imaginary_s, z_real2_s, z_imaginary2_s, z_2_real_x_imaginary_s, z_real2_add_imaginary2_s, iterations_s, enable_calcul, z_real2_sub_imaginary2_s)
	begin
		--  Multiplexeur  --
		z_real_s 		<= z_new_real_s;
		z_imaginary_s 	<= z_new_imaginary_s;

		--  Multiplicateurs  --
		z_real2_s				<= std_logic_vector(signed(z_real_s) * signed(z_real_s));	-- ZR^2
		z_imaginary2_s			<= std_logic_vector(signed(z_imaginary_s) * signed(z_imaginary_s));	-- ZI^2
		z_real_x_imaginary_s	<= std_logic_vector(signed(z_real_s) * signed(z_imaginary_s));		-- ZR*ZI
		z_2_real_x_imaginary_s	<= std_logic_vector(z_real_x_imaginary_s((2*SIZE)-2 downto 0) & '0');		-- 2*ZR*ZI

		--  Additionneurs - Soustracteurs  --
		z_real2_sub_imaginary2_s 	<= std_logic_vector(signed(z_real2_s) - signed(z_imaginary2_s));
		z_real2_add_imaginary2_s 	<= std_logic_vector(signed(z_real2_s) + signed(z_imaginary2_s));
		z_real_fut_s				<= std_logic_vector(signed(z_real2_sub_imaginary2_s) + signed(c_real & "000000000000"));
		z_imaginary_fut_s			<= std_logic_vector(signed(z_2_real_x_imaginary_s) + signed(c_imaginary & "000000000000"));
		new_iterations_s			<= std_logic_vector(signed(iterations_s) + 1);

		--  Comparateurs  --
		-- Valeurs plus grande que 2^2
		if(unsigned(z_real2_add_imaginary2_s) > unsigned(val_limite)) then
			finished_s 	<= '1';
		-- Fin des iterations
		elsif(unsigned(iterations_s) >= max_iter) then
			finished_s 	<= '1';
		else
			finished_s	<= '0';
		end if;
	end process;

	-----------------------------------------------
	--  Reset, Bascules et incrément iterations  --
	-----------------------------------------------
	bascules: process(clk, rst, rst_calcul)
	begin
		-- Reset asynchrone --
		if rst = '1' then
			z_new_real_s		<= (others => '0');
			z_new_imaginary_s	<= (others => '0');
			iterations_s		<= (others => '0');

		-- Multiplexeurs --
		elsif rst_calcul = '1' then
			z_new_real_s		<= (others => '0');
			z_new_imaginary_s	<= (others => '0');
			iterations_s		<= (others => '0');
		elsif rising_edge(clk) then
			if (enable_calcul = '1') then
				--  Caster au bon endroit pour la gestion de la virgule
				z_new_real_s	 	<= z_real_fut_s((SIZE+comma-1) downto comma);
				z_new_imaginary_s	<= z_imaginary_fut_s((SIZE+comma-1) downto comma);
				iterations_s	    <= new_iterations_s;
			end if;
		end if;
	end process;

	----------------------
	--  Machine d'etat  --
	----------------------
	machine_etat: process(EtatPresent, start, finished_s, z_real_s, z_imaginary_s, iterations_s)
	begin
		-- Valeurs par defaut
		EtatFutur 		<= S_READY;
		enable_calcul 	<= '0';
		ready 			<= '0';
		rst_calcul 		<= '0';

		case EtatPresent is
			-- Prêt à lancer un nouveau calcul --
			when S_READY  =>
				ready <= '1';
				if (start = '1') then
					-- Mise à zero avant nouveau calcul
					rst_calcul <= '1';
					EtatFutur <= S_PROCESS;
				else
					EtatFutur <= S_READY;
				end if;

			-- Calcul et cours --
			when S_PROCESS  =>
				if (finished_s = '1') then
					EtatFutur 	<= S_READY;
				else
					enable_calcul <= '1';
					EtatFutur <= S_PROCESS;
				end if;

			when others => null;
		end case;
	end process;

	------------------------------------
	--  Gestion de la machine d'etat  --
	------------------------------------
	process (clk, rst)
	begin
		if (rst = '1') then
			EtatPresent <= S_READY;

		elsif Rising_Edge(clk) then
			EtatPresent <= EtatFutur;
		end if;
	end process;

end calculator;

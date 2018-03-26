-------------------------------------------------------------------------------
-- Title       : Architecture calcul fractal de mandelbrot
-- Project     : Labo LPSC fractal
-------------------------------------------------------------------------------
-- File        : mandelbrot_calculator.vhd
-- Authors     : Jérémie Macchi
-- Company     : HES-SO Master
-- Created     : 26.03.2018
-- Last update :
-- Platform    : Vivado (synthesis)
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: Architecture pour le calcul de fractal pour le Labo de LPSC
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 26.03.2018   1.0      JMI 	  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.<PACKAGE_NAME>.all;

-----------------------------
-- Déclaration de l'entity --
-----------------------------
entity mandelbrot_calculator is
generic (comma	: integer := 12;	-- nombres de bits après la virgule
	max_iter	: integer := 100;
	SIZE		: integer := 16);
port (
	clk 		: in 	std_logic;
	rst 		: in 	std_logic;
	ready		: in	std_logic;
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
architecture calculator of alu is
	---------------
	--  Signaux  --
	---------------
	--signal clk_s 			: std_logic;
	--signal rst_s 			: std_logic;
	signal ready_s			: std_logic;
	signal start_s			: std_logic;
	signal finished_s		: std_logic;
	signal c_real_s			: std_logic_vector(SIZE-1 downto 0);
	signal c_imaginary_s	: std_logic_vector(SIZE-1 downto 0);
	signal z_real_s			: std_logic_vector(SIZE-1 downto 0);
	signal z_imaginary_s	: std_logic_vector(SIZE-1 downto 0);
	signal iterations_s		: std_logic_vector(SIZE-1 downto 0);

	-- Signaux intermediaires pour les calculs
	signal z_real2_s				: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_imaginary2_s			: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_real_x_imaginary_s		: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_2_real_x_imaginary_s	: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_real2_sub_imaginary2_s	: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_real2_add_imaginary2_s	: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_real_fut_s				: std_logic_vector((2*SIZE)-1 downto 0);
	signal z_imaginary_fut_s		: std_logic_vector((2*SIZE)-1 downto 0);

	-- Signaux pour de sorties des bascules
	signal z_new_real_s				: std_logic_vector(SIZE-1 downto 0);
	signal z_new_imaginary_s		: std_logic_vector(SIZE-1 downto 0);

	-- Signaux de controle
	signal enable_calcul: std_logic;

	-- Signaux pour la machine d'etat
	signal EtatPresent: std_logic_vector (1 DOWNTO 0);
	signal EtatFutur: std_logic_vector (1 DOWNTO 0);

	------------------
	--  Constantes  --
	------------------
	-- Etat de la machine d'état
	constant S_READY	: std_logic := '0';
	constant S_PROCESS	: std_logic := '1';
	--constant S_FINISH	: std_logic_vector(1 DOWNTO 0) := "10";

-------------
--	Begin  --
-------------
begin
	-------------------------------
	--  Assignation des signaux  --
	-------------------------------
	--clk_s			<= clk;
	--rst_s			<= rst;
	ready_s			<= ready;
	--start_s			<= start;
	finished_s		<= finished;
	c_real_s		<= c_real;
	c_imaginary_s	<= c_imaginary;
	--z_real_s		<= z_real;
	--z_imaginary_s	<= z_imaginary;
	--iterations_s	<= iterations;


	-------------
	--  Reset  --
	-------------
	reset : process(clk_i, rst_i)
	begin
		if rising_edge(clk_i) then      -- rising clock edge
            -- synchronus reset (active high)
            if rst_i = '1' then         -- synchronous reset (active high)
                finished_s		<= '0';
                z_real_s    	<= (others => '0');
                z_imaginary_s 	<= (others => '0');
				iterations_s 	<= (others => '0');
				z_new_real_s	<= (others => '0');
				z_new_imaginary_s	<= (others => '0');
    		end if;
		end if;
	end process;

	--------------------
	--  Combinatoire  --
	--------------------
	combinatoire : process(ready_s, c_real_s, c_imaginary_s, z_new_real_s, z_new_imaginary_s)
	begin
		--  Multiplexeur  --
		if (enable_calcul = '1') then
			z_real_s 		<= z_new_real_s;
			z_imaginary_s 	<= z_new_imaginary_s;
		else
			z_real_s 		<= (others => '0');
			z_imaginary_s 	<= (others => '0');
		end if;

		--  Multiplicateurs  --
		z_real2_s				<= std_logic_vector(unsigned(z_real_s) * unsigned(z_real_s));	-- ZR^2
		z_imaginary2_s			<= std_logic_vector(unsigned(z_imaginary_s) * unsigned(z_imaginary_s));	-- ZI^2
		z_real_x_imaginary_s	<= std_logic_vector(unsigned(z_real_s) * unsigned(z_imaginary_s));		-- ZR*ZI
		z_2_real_x_imaginary_s	<= std_logic_vector(unsigned(z_real_x_imaginary_s) << 1);		-- 2*ZR*ZI

		--  Additionneurs - Soustracteurs  --
		z_real2_sub_imaginary2_s 	<= std_logic_vector(unsigned(z_real2_s) - unsigned(z_imaginary2_s));
		z_real2_add_imaginary2_s 	<= std_logic_vector(unsigned(z_real2_s) + unsigned(z_imaginary2_s));
		z_real_fut_s				<= std_logic_vector(unsigned(z_2_real_x_imaginary_s) + unsigned(c_real_s));
		z_imaginary_fut_s			<= std_logic_vector(unsigned(z_2_real_x_imaginary_s) + unsigned(c_real_s));

		--  Comparateurs  --
		if(z_real2_add_imaginary2_s > 4) then	-- Valeurs plus grande que 2
			finished_s 	<= '1';
		else
			finished_s	<= '0';
		end if;

		if(iterations_s >= max_iter) then		-- Fin des iterations
			finished_s 	<= '1';
		else
			finished_s	<= '0';
		end if;
	end process;

	----------------------------------------
	--  Bascules et incrément iterations  --
	----------------------------------------
	bascule: process(clk_i)
	begin
		if rising_edge(clk_i) then
			if enable_calcul then
				--  Caster au bon endroit pour la gestion de la virgule
				z_new_real_s	 	<= z_real_fut_s((SIZE-comma-1) downto comma);
				z_new_imaginary_s	<= z_imaginary_fut_s((SIZE-comma-1) downto comma);
				iterations_s	<= std_logic_vector(unsigned(iterations_s) + 1);
			else
				z_new_real_s		<= (others => '0');
				z_new_imaginary_s	<= (others => '0');
				iterations_s		<= (others => '0');
			end if;
		end if;
	end process;

	----------------------
	--  Machine d'etat  --
	----------------------
	machine_etat: process(EtatPresent)
	begin
		-- Valeurs par defaut
		EtatFutur 		<= S_READY;
		finished		<= '0';
		enable_calcul 	<= '0';
		ready 			<= '0';
		z_real 			<= (others => '0');
		z_imaginary 	<= (others => '0');
		iterations 		<= (others => '0');

		case EtatPresent is
			when S_READY  =>
				ready <= '1';
				if (start = '1') then
					enable_calcul <= '1';	-- Pour gagner 1 CLK
					EtatFutur <= S_PROCESS;
				else
					EtatFutur <= S_READY;
				end if;

			when S_PROCESS  =>
				enable_calcul <= '1';
				if (finished_s = '1') then
					finished 	<= '1';
					z_real 		<= z_real_s;
					z_imaginary <= z_imaginary_s;
					iterations 	<= iterations_s;
					EtatFutur 	<= S_FINISH;
				else
					EtatFutur <= S_READY;
				end if;

			--when S_FINISH  =>

			when others => null;
		end case;
	end process;

	------------------------------------
	--  Gestion de la machine d'etat  --
	------------------------------------
	process (clk, reset)
	begin
		if (reset = '1') then
			EtatPresent_Slave <= S_READY;

		elsif Rising_Edge(clk) then
			EtatPresent <= EtatFutur;
		end if;
	end process;

end calculator;

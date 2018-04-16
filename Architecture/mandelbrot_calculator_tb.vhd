-------------------------------------------------------------------------------
-- Title       : Testbench pour mandelbrot_calculator
-- Project     : Labo LPSC fractal
-------------------------------------------------------------------------------
-- File        : mandelbrot_calculator_tb.vhd
-- Authors     : Jérémie Macchi
-- Company     : HES-SO Master
-- Created     : 07.03.2018
-- Last update : 07.03.2018
-- Platform    : Vivado
-- Standard    : VHDL'08
-------------------------------------------------------------------------------
-- Description: Testbench pour l'unité de calcul pour la fractal de mandelbrot
-------------------------------------------------------------------------------
-- Copyright (c) 2018 HES-SO, Lausanne
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 07.04.2018   0.0      JMI      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

------------------------------------------
-- Déclaration de l'entité du testbench --
------------------------------------------
entity mandelbrot_calculator_tb is
  generic (
  comma : integer := 12; -- nombre de bits après la virgule
  max_iter : integer := 100;
  SIZE : integer := 16);
end mandelbrot_calculator_tb;

--------------------------------
--	Architecture du testbench --
--------------------------------
architecture testbench of mandelbrot_calculator_tb is

  -- Input/output of the DUV
  signal clk_sti          : std_logic;
  signal rst_sti          : std_logic;
  signal ready_obs        : std_logic;
  signal start_sti        : std_logic;
  signal finished_obs     : std_logic;
  signal c_real_sti       : std_logic_vector(SIZE-1 downto 0);
  signal c_imaginary_sti  : std_logic_vector(SIZE-1 downto 0);
  signal z_real_obs       : std_logic_vector(SIZE-1 downto 0);
  signal z_imaginary_obs  : std_logic_vector(SIZE-1 downto 0);
  signal iterations_obs   : std_logic_vector(7-1 downto 0);

  -- Internal singals
  signal sim_end_s : boolean := false; -- put true to end

  -----------------
  --	Component  --
  -----------------
  component mandelbrot_calculator is
    generic (
      comma : integer := 12; -- nombres de bits après la virgule
      max_iter : integer := 100;
      SIZE : integer := 16;
      SCREEN_RES 	: integer := 10);
);

    port(
      clk         : in std_logic;
      rst         : in std_logic;
      ready       : out std_logic;
      start       : in std_logic;
      finished    : out std_logic;
      c_real      : in std_logic_vector(SIZE-1 downto 0);
      c_imaginary : in std_logic_vector(SIZE-1 downto 0);
      z_real      : out std_logic_vector(SIZE-1 downto 0);
      z_imaginary : out std_logic_vector(SIZE-1 downto 0);
      iterations  : out std_logic_vector(7-1 downto 0);
      
      x_screen_i  : in std_logic_vector (10-1 downto 0);
      y_screen_i  : in std_logic_vector (10-1 downto 0);
      x_screen_o  : out std_logic_vector (10-1 downto 0);
      y_screen_o  : out std_logic_vector (10-1 downto 0)
    );
  end component;

  -------------
  --  Begin  --
  -------------
  begin
    -----------
    --	DUV  --
    -----------
    duv : mandelbrot_calculator
    generic map (
      comma       => comma,
      max_iter    => max_iter,
      SIZE        => SIZE,
      SCREEN_RES  => ,
    )
    port map (
      clk         => clk_sti,
      rst         => rst_sti,
      ready       => ready_obs,
      start       => start_sti,
      finished    => finished_obs,
      c_real      => c_real_sti,
      c_imaginary => c_imaginary_sti,
      z_real      => z_real_obs,
      z_imaginary => z_imaginary_obs,
      iterations  => iterations_obs
    );

    ---------------------
    --  Stimulus_proc  --
    ---------------------
    stimulus_proc : process is
      begin

        --------------------
        --  Premier test  --
        --------------------
        -- Reset
        start_sti <= '0';
        rst_sti <= '1';
        wait for 10 ns;
        --c_real_sti <= "0000" & "011000010100";
        --c_imaginary_sti <= "0000" & "001101000000";
        c_real_sti 		<= "0000" & "011000010100";
        c_imaginary_sti <= "0000" & "001100110011";
        wait for 20 ns;
        rst_sti <= '0';
        wait for 10 ns;
        start_sti <= '1';
        wait for 2 ns;
        start_sti <= '0';

        wait for 500 ns;

        --------------------------------------------------
        --  Deuxieme test (arret quand itération = 100) --
        --------------------------------------------------
        start_sti <= '0';
        -- rst_sti <= '1';
        wait for 10 ns;
        c_real_sti <= "0000" & "000000000000";
        c_imaginary_sti <= "0001" & "000000000000";
        wait for 20 ns;
        rst_sti <= '0';
        wait for 10 ns;
        start_sti <= '1';
        wait for 2 ns;
        start_sti <= '0';
        
        wait for 500 ns;

        -------------------------------------------------
        --  Troisieme test (arret quand itération = 5) --
        -------------------------------------------------
        start_sti <= '0';
        -- rst_sti <= '1';
        wait for 10 ns;
        c_real_sti <= "0000" & "100000000000";
        c_imaginary_sti <= "0000" & "000000000000";
        wait for 20 ns;
        rst_sti <= '0';
        wait for 10 ns;
        start_sti <= '1';
        wait for 2 ns;
        start_sti <= '0';

        --wait for 500 ns;

        --while finished_obs = '0' loop
        --do nothing, juste wait the end of the calcul
        --end loop;

        wait for 500 ns;

        sim_end_s <= true;
        wait; -- Stop the process
      end process; --stimulus_proc
      ----------------------------------------------
      -- clock_proc                        ---------
      ----------------------------------------------
      clock_proc : process
      begin
        while sim_end_s = false loop
          clk_sti <= '1';
          wait for 1 ns;
          clk_sti <= '0';
          wait for 1 ns;
        end loop;
        wait; -- Stop the process
      end process; --clock_proc

    end testbench;

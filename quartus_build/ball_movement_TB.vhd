library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ball_movement_TB is
end entity ball_movement_TB;

architecture behavioral of ball_movement_TB is

	signal clk				: std_logic; -- count1 from VGA timing
	signal reset			: std_logic; -- KEY(0)
	signal new_ball		: std_logic; -- KEY(1)
	signal collision	: std_logic_vector(0 to 3); -- from detector process
	signal ball_x			: integer;
	signal ball_y 		: integer;
	signal direction	: integer;
	signal LED				: std_logic_vector(9 downto 0);
	
	constant clk_period : time := 2ps;
	
	component ball_movement is
		port (
			clk					: in std_logic; -- count1 from VGA timing
			reset				: in std_logic := '1'; -- KEY(0)
			new_ball		: in std_logic; -- KEY(1)
			collision		: in std_logic_vector(3 downto 0); -- from detector process
			ball_x			: out integer;
			ball_y 			: out integer;
			direction		: out integer;
			LED					: out std_logic_vector(9 downto 0)
		);
	end component ball_movement;
	
begin	
	uut: ball_movement
		port map (
			clk => clk,
			reset => reset,
			new_ball => new_ball,
			collision => collision,
			ball_x => ball_x,
			ball_y => ball_y,
			direction => direction, 
			LED => LED
		);
		
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process;
	
	stm_process : process
	begin
		collision <= "1010";
		reset <= '0';
		wait for clk_period * 10;
		reset <= '1';
		wait for clk_period * 10;
		new_ball <= '0';
		wait for clk_period * 10;
		new_ball <= '1';
		wait for clk_period * 1000000;
		collision <= "0001";
		wait for clk_period*421000;
		collision <= "1010";
		wait for clk_period * 1000000;
		collision <= "1000";
		wait for clk_period*842000;
		collision <= "1010";
		wait for clk_period *421000;
		new_ball <= '0';
		wait for clk_period * 10;
		new_ball <= '1';
		wait for clk_period * 1000000;
		collision <= "1000";
		wait for clk_period*842000;
		collision <= "1010";
		wait for clk_period*421000;
		wait for clk_period * 1000000;
		collision <= "1000";
		wait for clk_period*842000;
		collision <= "1010";
		new_ball <= '0';
		wait for clk_period * 10;
		new_ball <= '1';
		wait for clk_period*1000000;
		collision <= "0101";
		wait for clk_period*421000;
		collision <= "1010";
		wait for clk_period * 10000000;
		wait for clk_period * 1000000;
		collision <= "1000";
		wait for clk_period*842000;
		collision <= "1010";
		new_ball <= '0';
		wait for clk_period * 10;
		new_ball <= '1';
		wait for clk_period*1000000;
		collision <= "0101";
		wait for clk_period*421000;
		collision <= "1010";
		wait for clk_period * 10000000;
		wait for clk_period * 1000000;
		collision <= "1000";
		wait for clk_period*842000;
		collision <= "1010";
		new_ball <= '0';
		wait for clk_period * 10;
		new_ball <= '1';
		wait for clk_period*1000000;
		collision <= "0101";
		wait for clk_period*421000;
		collision <= "1010";
		wait for clk_period * 10000000;
		wait for clk_period * 1000000;
		collision <= "1000";
		wait for clk_period*842000;
		collision <= "1010";
		new_ball <= '0';
		wait for clk_period * 10;
		new_ball <= '1';
		wait;
	end process;
	
end architecture behavioral;	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity brick_breaker is
	port(
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
		KEY : std_logic_vector(1 downto 0); -- [0] reset and [1] next
		LEDR : out std_logic_vector(9 downto 0);
		SW : in std_logic_vector(9 downto 0);
		VGA_R 	: out std_logic_vector(3 downto 0);
		VGA_G 	: out std_logic_vector(3 downto 0);
		VGA_B 	: out std_logic_vector(3 downto 0);
		VGA_HS 	: out std_logic;
		VGA_VS 	: out std_logic;		
		ARDUINO_IO : out std_logic_vector(15 downto 0);
		ARDUINO_RESET_N : inout std_logic
	);
end entity brick_breaker;

architecture behavioral of brick_breaker is

signal pot : std_logic_vector(11 downto 0) := X"000";
signal rst : std_logic := '0';
signal sound_fx : std_logic_vector(2 downto 0); -- b"000"/no sound, b"001"/ball paddle, b"010"/walls+ceiling, b"011"/dead ball, b"100"/brick break

signal vga_clk : std_logic; -- maps to c0 of myPLL
signal vga_rst : std_logic := '1';
signal color : std_logic_vector(11 downto 0) := X"000";

signal adc_clk : std_logic := '0';

	component sound_board is
		port (
			CLK : in std_logic := 'X';
			SOUND_EFFECT : in std_logic_vector (2 downto 0);
			SOUND_OUT : out std_logic
		);
	end component sound_board;
	
	component my_adc is 										-- creates digital value from potentiometer
		port (
			CLOCK : in  std_logic                     := 'X'; 	-- clk
			RESET : in  std_logic                     := 'X'; 	-- reset
			CH3   : out std_logic_vector(11 downto 0)        	-- CH0
		);
	end component my_adc;

	component myPLL is
		port
		(
			inclk0	: in std_logic; -- MAX10_CLK1_50
			c0			: out std_logic -- 25.17 MHz
		);
	end component myPLL;	
	
	component sync is
		port (
			clk 				: in std_logic;
			reset				: in std_logic;
			reset_l			: in std_logic;
			new_ball			: in std_logic;
			vs_sig 			: out std_logic;
			hs_sig 			: out std_logic;
			pixel_data 	: out std_logic_vector(11 downto 0);
			pot : in std_logic_vector(11 downto 0);
			LEDR : out std_logic_Vector(9 downto 0);
			sound_fx : out std_logic_Vector(2 downto 0)
		);
	end component sync;
	
	component adcPLL is
		port (
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	end component adcPLL;
	
begin
	
	u0 : component sound_board
		port map (
			CLK => MAX10_CLK1_50,
			SOUND_EFFECT => sound_fx,
			SOUND_OUT => ARDUINO_IO(7)
		);
	
	u1 : component my_adc
		port map (
			CLOCK => ADC_CLK_10, --      clk.clk
			RESET => rst, --    reset.reset
			CH3   => pot   --         .CH1
		);
	
	u2 : component myPLL
		port map
		(
			inclk0 => MAX10_CLK1_50,
			c0 => vga_clk
		);
	
	u3 : sync
		port map(
			clk 	=> vga_clk,
			reset	=> vga_rst,
			reset_l => KEY(0),
			new_ball => KEY(1),
			vs_sig => VGA_VS,
			hs_sig => VGA_HS,
			pixel_data 	=> color,
			pot => pot,
			LEDR => LEDR,
			sound_fx => sound_fx
		);	
		
	u4 : adcPLL
		port map(
			inclk0 => ADC_CLK_10,
			c0 => adc_clk
		);	
	
	VGA_R <= color(11 downto 8);
	VGA_G <= color(7 downto 4);
	VGA_B <= color(3 downto 0);
	
end architecture behavioral;
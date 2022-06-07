library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
	port (
		clk 				: in std_logic;
		reset				: in std_logic;
		reset_l			: in std_logic;
		new_ball			: in std_logic;
		vs_sig 			: out std_logic;
		hs_sig 			: out std_logic;
		pixel_data 	: out std_logic_vector(11 downto 0);
		pot : in std_logic_vector(11 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		sound_fx : out std_logic_vector(2 downto 0)
	);
end entity sync;

architecture behavioral of sync is

	-- Note / R: bits 11:8 / G: bits 7:4 / B: bits 3:0 /  MSB:LSB ->
	constant red : std_logic_vector(11 downto 0) := X"B00";
	constant black : std_logic_vector(11 downto 0) := X"000";
	constant brown : std_logic_vector(11 downto 0) := X"722";
	constant grey : std_logic_vector(11 downto 0) := X"FFF";
	
	type BRICK_STATE is array (0 to 1214) of std_logic;
	signal brick : BRICK_STATE	:= (others => '1');
	
	signal cur_brick : integer range 0 to 1214 := 0;
	
	type MY_MEM is array (0 to 639) of std_logic_vector(11 downto 0);
	constant full_bricks : MY_MEM := (red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey);
	constant staggered : MY_MEM := (red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red, red, red, red, red, red, red, red, grey, red, red, red, red, red, red, red, red);
	
	type vs_states is (V_FRONT_PORCH, V_SYNC, V_BACK_PORCH, DATA);
	signal current_vs_state, next_vs_state : vs_states;
	
	type hs_states is (H_FRONT_PORCH, H_SYNC, H_BACK_PORCH, P_DATA);
	signal current_hs_state, next_hs_state : hs_states;
	
	type my_horiz is range 0 to 799;

	signal x_pos : integer := 0;
	signal y_pos : integer := 0;
	signal layer : integer := 0;
	signal next_x_pos : integer := 0;
	signal next_y_pos : integer := 0;
	signal count1 : integer := 0;
	signal count2 : integer := 0;
	signal count1_mod : integer := 0;
	signal count2_mod : integer := 0;
	signal m : std_logic := '0';
	signal pad_pos : integer := 0;
	signal pot_sig : integer := 0;
	signal ball_x : integer := 316;
	signal ball_y : integer := 250;
	signal brick_x : integer := 0;
	signal difference : integer := 0; -- difference between pad_pos and ball_x
	signal collision : std_logic_Vector(3 downto 0) := "1010"; -- 0000 PAD_C / 0001 PAD_R1 / 0010 PAD_R2 / 0011 PAD_L1 / 0100 PAD_L2 / 0101 RIG / 0110 LEF / 0111 TOP / 1000 DIE / 1001 BRICK_BELOW / 1010 NONE
	
	signal brick_above : std_logic := '0';
	signal brick_above1 : std_logic := '0';	
	signal brick_left : std_logic := '0';
	signal brick_right : std_logic := '0';
	signal brick_below : std_logic := '0';
	signal brick_below1 : std_logic := '0';
	
	signal layer_above : integer := 0;
	signal layer_left : integer := 0;
	signal layer_right : integer := 0;
	signal layer_below : integer := 0;
	
	signal cur_brick_above : integer := 0;
	signal cur_brick_above1 : integer := 0;
	signal cur_brick_left : integer := 0;
	signal cur_brick_right : integer := 0;
	signal cur_brick_below : integer := 0;
	signal cur_brick_below1 : integer := 0;
	
	signal brick_above_x : integer := 0;
	signal brick_above_x1 : integer := 0;	
	signal brick_left_x : integer := 0;
	signal brick_right_x : integer := 0;
	signal brick_below_x : integer := 0;
	signal brick_below_x1 : integer := 0;
	signal direction : integer := 0;
	signal LED : std_logic_vector(9 downto 0);
	
	component ball_movement is
		port (
			clk				: in std_logic; 
			reset				: in std_logic; -- KEY(0)
			new_ball			: in std_logic; -- KEY(1)
			collision		: in std_logic_vector(3 downto 0); -- from detection process
			ball_x			: out integer;
			direction			: out integer;
			LED				: out std_logic_vector(9 downto 0);
			ball_y 			: out integer
		);
	end component ball_movement;
	
begin

	u0 : component ball_movement
		port map (
			clk => clk,
			reset => reset_l,
			new_ball => new_ball,
			collision => collision,
			direction => direction,
			ball_x => ball_x,
			LED => LED,
			ball_y => ball_y
		);


	process(clk, reset, current_vs_state, count1, count2, current_hs_state, x_pos, y_pos) 
	begin
		if rising_edge(clk) then
			if reset = '0' then	
				current_vs_state <= V_FRONT_PORCH;
				current_hs_state <= H_FRONT_PORCH;
				count1 <= 0;
				count2 <= 0;
				x_pos <= 0;
				y_pos <= 0;
			else
				x_pos <= next_x_pos;
				y_pos <= next_y_pos;
				if m = '0' then
					count1 <= count1 + 1;
					count2 <= count2 + 1;
				else
					count1 <= 0;
					count2 <= 0;
				end if;
				current_vs_state <= next_vs_state;
				current_hs_state <= next_hs_state;
			end if;
		end if;
	end process;
	
	process(count1, current_vs_state, count1_mod)
	begin
		count1_mod <= count1 mod 420000;
		case current_vs_state is
			when V_FRONT_PORCH =>
				m <= '0';
				vs_sig <= '1';
				if count1_mod < 8000 then
					next_vs_state <= V_FRONT_PORCH;
				else
					next_vs_state <= V_SYNC;
				end if;
				
			when V_SYNC =>
				m <= '0';
				vs_sig <= '0';
				if count1_mod < 9600 then
					next_vs_state <= V_SYNC;
				else	
					next_vs_state <= V_BACK_PORCH;
				end if;
				
			when V_BACK_PORCH =>
				m <= '0';
				vs_sig <= '1';
				if count1_mod < 36000 then
					next_vs_state <= V_BACK_PORCH;
				else
					next_vs_state <= DATA;
				end if;
				
			when DATA =>
				vs_sig <= '1';
				if count1_mod < 420000 and count1_mod >= 36000 then
					next_vs_state <= DATA;
					m <= '0';
				else
					next_vs_state <= V_FRONT_PORCH;
					m <= '1';
				end if;
		end case;	
	end process;
	
	process(layer, count2,count2_mod, x_pos, y_pos, current_hs_state, current_vs_state, pad_pos, ball_x, ball_y, brick, cur_brick, brick_above)
	begin
		count2_mod <= count2 mod 800;
		case current_hs_state is
			when H_FRONT_PORCH =>
				hs_sig <= '1';
				pixel_data <= black;
				next_x_pos <= 0;
				next_y_pos <= y_pos; 
				if count2_mod < 16 then
					next_hs_state <= H_FRONT_PORCH;
				else	
					next_hs_state <= H_SYNC;
				end if;
				
			when H_SYNC =>
				hs_sig <= '0';
				pixel_data <= black;
				next_x_pos <= 0;
				next_y_pos <= y_pos;
				if count2_mod < 112 then 
					next_hs_state <= H_SYNC;
				else	
					next_hs_state <= H_BACK_PORCH;
				end if;
				
			when H_BACK_PORCH =>
				hs_sig <= '1';
				pixel_data <= black;
				next_x_pos <= 0;
				if count2_mod < 160 then 
					next_hs_state <= H_BACK_PORCH;
					next_y_pos <= y_pos;
				else	
					next_hs_state <= P_DATA;
					next_y_pos <= y_pos + 1;
				end if;
				
			when P_DATA =>
				hs_sig <= '1';
				if count2_mod < 800 and count2_mod >= 160 then 
					next_hs_state <= P_DATA;
					next_y_pos <= y_pos;
					next_x_pos <= x_pos + 1;
				else	
					next_hs_state <= H_FRONT_PORCH;
					next_y_pos <= y_pos;
					next_x_pos <= x_pos;
				end if;
				if current_vs_state = V_FRONT_PORCH or current_vs_state = V_SYNC or current_vs_state = V_BACK_PORCH then
					pixel_data <= black;
					next_x_pos <= 0;
					next_y_pos <= 0;
				else
					next_y_pos <= y_pos;
					next_x_pos <= x_pos + 1;

					if (y_pos < 240) then
						if x_pos >= ball_x and x_pos < (ball_x + 10) and y_pos >= ball_y and y_pos < (ball_y + 10) then
								pixel_data <= grey; 
						elsif brick(cur_brick) = '0' then
								pixel_data <= black;
						else
							if (y_pos mod 8 = 0) then
								pixel_data <= grey;
							elsif layer mod 2 = 0 then
								pixel_data <= full_bricks(x_pos);
							else
								pixel_data <= staggered(x_pos);
							end if;
						end if;	
					end if;
																
					if y_pos >= 240 and y_pos <= 475 then
						if x_pos >= ball_x and x_pos < ball_x + 10 then
							if y_pos >= ball_y and y_pos < ball_y + 10 then
								pixel_data <= grey;
							else
								pixel_data <= black;
							end if;	
						else
							pixel_data <= black;
						end if;	
					end if;
				
					if y_pos < 481 and y_pos > 475 then  -- not sure the y_pos and x_pos perfectly match the displays x and y coordinates 
						if x_pos >= ball_x and x_pos < (ball_x + 10) and y_pos >= ball_y and y_pos < (ball_y + 10) then
								pixel_data <= grey; 
						elsif x_pos >= pad_pos and x_pos < pad_pos + 40 then
							pixel_data <= brown;
						else
							pixel_data <= black;
						end if;
					end if;
					
				end if;
		end case;
	end process;
	
	CURRENT_BRICK : process(x_pos, layer, brick_x) begin
		if layer mod 2 = 1 then	
			brick_x <= (x_pos+8)/16;
			cur_brick <= (layer*40) + layer/2 + brick_x;
		else
			brick_x <= x_pos/16;
			cur_brick <= (layer*40) + layer/2 + brick_x;
		end if;
	end process;
	
	BRICK_LAYER : process(y_pos) begin
		if(y_pos < 240) then
			layer <= y_pos/8;
		else 
			layer <= 0;
		end if;
	end process;
	
	PADDLE_POSITION : process(pot_sig) begin
			if pot_sig > 2400 then
				pad_pos <= 600;
			else
				pad_pos <= pot_sig/4;			
			end if;
	end process;
	
	-- 0000 PAD_C / 0001 PAD_R1 / 0010 PAD_R2 / 0011 PAD_L1 / 0100 PAD_L2 / 0101 RIG / 0110 LEF / 0111 TOP / 1000 DIE / 1001 BOT / 1010 NONE
	-- b"000"/no sound, b"001"/ball paddle, b"010"/walls+ceiling, b"011"/dead ball, b"100"/brick break
	COLLISION_DETECTION : process(clk, ball_x, ball_y, pad_pos, brick, current_vs_state, difference) begin
		if(rising_edge(clk)) then
			if ball_x <= 0 then
				collision <= "0110"; --hit left wall
				sound_fx <= "010"; 
			elsif ball_x >= 630 then
				collision <= "0101"; -- hit right wall
				sound_fx <= "010";
			elsif ball_y <= 1 then
				collision <= "0111"; -- hit top wall
				sound_fx <= "010";
			elsif ball_y >= 479 then
				collision <= "1000"; -- ball dead
				sound_fx <= "011";
			elsif brick_above = '1' then
				collision <= "0111"; -- ball hit bottom of brick
				sound_fx <= "100";
			elsif brick_below = '1' then
				collision <= "1001";	-- ball hit top of brick
				sound_fx <= "100";
			elsif brick_left = '1' then
				collision <= "0101"; -- ball hit left side of brick
				sound_fx <= "100";	
			elsif brick_right = '1' then
				collision <= "0110";	-- ball hit right side of brick
				sound_fx <= "100";				
			elsif ball_y >= 465 and ball_y <= 467 then
				if difference <= 9 and difference >= 0 then
					collision <= "0100";	-- PAD_L2
					sound_fx <= "001";
				elsif difference <= -1 and difference >= -10 then
					collision <= "0011"; -- PAD_L1
					sound_fx <= "001";
				elsif difference <= -11 and difference >= -20 then
					collision <= "0000"; -- PAD_C
					sound_fx <= "001";
				elsif difference <= -21 and difference >= -30 then
					collision <= "0001"; -- PAD_R1
					sound_fx <= "001";
				elsif difference <= -31 and difference >= -39 then
					collision <= "0010"; -- PAD_R2
					sound_fx <= "001";
				else
					collision <= "1010"; --no collision
					sound_fx <= "000";
				end if;	
			else
				collision <= "1010";
				sound_fx <= "000";
			end if;
		end if;	
	end process;
	
	DIFFERENCE_PAD_BALL : process(m, ball_x, pad_pos) begin
			difference <= pad_pos - ball_x;
	end process;
	
	BRICK_ABOVE_DETECTION : process(ball_x, ball_y, cur_brick_above, cur_brick_above1, layer_above, brick, brick_above_x, brick_above_x1, brick_above, brick_above1) begin
		if ball_y < 241 then
			layer_above <= (ball_y-1)/8;
			if layer_above mod 2 = 1 then	
				brick_above_x <= (ball_x+8)/16;
				brick_above_x1 <= (ball_x+18)/16;
				cur_brick_above <= (layer_above*40) + layer_above/2 + brick_above_x;
				cur_brick_above1 <= (layer_above*40) + layer_above/2 + brick_above_x1;
			else
				brick_above_x <= (ball_x)/16;
				brick_above_x1 <= (ball_x+10)/16;
				cur_brick_above <= (layer_above*40) + layer_above/2 + brick_above_x;
				cur_brick_above1 <= (layer_above*40) + layer_above/2 + brick_above_x1;
			end if;
			
			if brick(cur_brick_above) = '1' then
				brick_above <= '1';
			else
				brick_above <= '0';
			end if;
			if brick(cur_brick_above1) = '1' then
				brick_above1 <= '1';
			else
				brick_above1 <= '0';
			end if;
		else	
			layer_above <= 0;
			brick_above_x <= 0;
			brick_above <= '0';
			cur_brick_above <= 0;
			brick_above_x1 <= 0;
			brick_above1 <= '0';
			cur_brick_above1 <= 0;
		end if;
	end process;
	
	BRICK_LEFT_DETECTION : process(ball_x, ball_y, layer_left, brick_left_x, brick, cur_brick_left) begin
		if ball_y < 241 then
			layer_left <= (ball_y)/8;
			if layer_left mod 2 = 1 then
				brick_left_x <= (ball_x+18)/16;
				cur_brick_left <= (layer_left*40) + layer_left/2 + brick_left_x;
			else
				brick_left_x <= (ball_x+10)/16;
				cur_brick_left <= (layer_left*40) + layer_left/2 + brick_left_x;
			end if;
		
			if brick(cur_brick_left) = '1' then
				brick_left <= '1';
			else
				brick_left <= '0';
			end if;
		else
			brick_left_x <= 0;
			layer_left <= 0;
			brick_left <= '0';
			cur_brick_left <= 0;
		end if;	
	end process;

	BRICK_RIGHT_DETECTION : process(ball_x, ball_y, layer_right, brick_right_x, brick, cur_brick_right) begin
		if ball_y < 241 then
			layer_right <= (ball_y+10)/8;
			if layer_right mod 2 = 1 then
				brick_right_x <= (ball_x+8)/16;
				cur_brick_right <= (layer_right*40) + layer_right/2 + brick_right_x;
			else
				brick_right_x <= (ball_x)/16;
				cur_brick_right <= (layer_right*40) + layer_right/2 + brick_right_x;
			end if;
			
			if brick(cur_brick_right) = '1' then
				brick_right <= '1';
			else
				brick_right <= '0';
			end if;
		else 
			brick_right_x <= 0;
			layer_right <= 0;
			brick_right <= '0';
			cur_brick_right <= 0;
		end if;	
	end process;
	
	BRICK_BELOW_DETECTION : process(ball_x, ball_y, cur_brick_below, cur_brick_below1, layer_below, brick, brick_below_x, brick_below_x1, brick_below, brick_below1) begin
		if ball_y < 241 then
			layer_below <= (ball_y+10)/8;
			if layer_below mod 2 = 1 then
				brick_below_x <= (ball_x+18)/16;
				brick_below_x1 <= (ball_x + 8)/16;
				cur_brick_below <= (layer_below*40) + layer_below/2 + brick_below_x;
				cur_brick_below1 <= (layer_below*40) + layer_below/2 + brick_below_x1;
			else
				brick_below_x <= (ball_x+10)/16;
				brick_below_x1 <= (ball_x)/16;
				cur_brick_below <= (layer_below*40) + layer_below/2 + brick_below_x;
				cur_brick_below1 <= (layer_below*40) + layer_below/2 + brick_below_x1;
			end if;
			
			if brick(cur_brick_below) = '1' then
				brick_below <= '1';
			else
				brick_below <= '0';
			end if;
			
			if brick(cur_brick_below1) = '1' then
				brick_below1 <= '1';
			else
				brick_below1 <= '0';
			end if;
		else
			layer_below <= 0;
			brick_below_x <= 0;
			brick_below <= '0';
			cur_brick_below <= 0;
			brick_below_x1 <= 0;
			brick_below1 <= '0';
			cur_brick_below1 <= 0;
		end if;	
	end process;

	process(clk, count1_mod, brick_above, collision, brick) begin
		if rising_edge(clk) then
			if reset_l <= '0' then
				brick <= (others => '1');
			else	
				if ((brick_above = '1' or brick_above1 = '1') and collision = "0111" and direction = 1) then
					brick(cur_brick_above) <= brick(cur_brick_above) and '0';
					brick(cur_brick_above1) <= brick(cur_brick_above1) and '0';
				elsif ((brick_below = '1' or brick_below1 = '1') and collision = "1001" and direction = 2) then
					brick(cur_brick_below) <= brick(cur_brick_below) and '0';
					brick(cur_brick_below1) <= brick(cur_brick_below1) and '0';
				elsif (brick_left = '1' and collision = "0101" and direction = 3) then
					brick(cur_brick_left) <= brick(cur_brick_left) and '0';
				elsif (brick_right = '1' and collision = "0110" and direction = 4) then
					brick(cur_brick_right) <= brick(cur_brick_right) and '0';
				else
					brick(cur_brick_above) <= brick(cur_brick_above) and '1';
					brick(cur_brick_below) <= brick(cur_brick_below) and '1';
					brick(cur_brick_left) <= brick(cur_brick_left) and '1';
					brick(cur_brick_right) <= brick(cur_brick_right) and '1';
				end if;	
			end if;		
		end if;
	end process;
		
	LEDR <= LED;	
	pot_sig <= to_integer(unsigned(pot));
end architecture behavioral;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sound_board is
	port (
		CLK : in std_logic;
		SOUND_EFFECT : in std_logic_vector(2 downto 0);
		SOUND_OUT : out std_logic
	);
end entity sound_board;

architecture behavioral of sound_board is

signal output : std_logic := '0';
signal sound_effect_sig : std_logic_vector(2 downto 0) := b"000";
signal ready : std_logic := '1';
signal sound_count : integer := 0;

begin
	
	process(CLK) begin
		if rising_edge(CLK) then
			if ready = '1' then
				sound_effect_sig <= SOUND_EFFECT;
			else
				sound_effect_sig <= sound_effect_sig;
			end if;
			case sound_effect_sig is
				when(b"000") =>
					output <= '0';
					sound_count <= 0;
					ready <= '1';
					
				when(b"001") =>										-- ball hit paddle 
					if sound_count <= 9000000 then
						ready <= '0';
						sound_count <= sound_count + 1;
						if sound_count <= 4500000 then
							if sound_count mod 65536 = 0 then
									output <= not output;
							end if;
						else	
							if sound_count mod 32768 = 0 then
									output <= not output;
							end if;
						end if;	
					else
						ready <= '1';
						output <= '0';
					end if;	

				when(b"010") =>										-- ball hit wall or ceiling
					if sound_count <= 9000000 then
						ready <= '0';
						sound_count <= sound_count + 1;
						if sound_count <= 1500000 then
							if sound_count mod 65536 = 0 then
									output <= not output;
							end if;
						elsif sound_count <= 6000000 then
							if sound_count mod 16384 = 0 then
									output <= not output;
							end if;						
						else
							if sound_count mod 32768 = 0 then
									output <= not output;
							end if;
						end if;	
					else
						ready <= '1';
						output <= '0';
					end if;		
			
				when(b"011") =>										-- ball dead 					
					if sound_count <= 50000000 then
						ready <= '0';
						sound_count <= sound_count + 1;
						if sound_count <= 10000000 then
							if sound_count mod 131072 = 0 then
								output <= not output;
							end if;
						elsif sound_count <= 20000000 then
							if sound_count mod 524288 = 0 then
								output <= not output;
							end if;
						elsif sound_count <= 30000000 then
							if sound_count mod 262144 = 0 then
								output <= not output;
							end if;	
						elsif sound_count <= 40000000 then
							if sound_count mod 131072 = 0 then
								output <= not output;
							end if;								
						else
							if sound_count mod 524288 = 0 then
								output <= not output;
							end if;
						end if;
					else
						ready <= '1';
						output <= '0';
					end if;	
					
				when(b"100") =>										-- brick broken
					if sound_count <= 9000000 then
						ready <= '0';
						sound_count <= sound_count + 1;
						if sound_count <= 1500000 then
							if sound_count mod 131072 = 0 then
									output <= not output;
							end if;
						elsif sound_count <= 3000000 then
							if sound_count mod 524288 = 0 then
									output <= not output;
							end if;						
						else
							if sound_count mod 262144 = 0 then
									output <= not output;
							end if;
						end if;	
					else
						ready <= '1';
						output <= '0';
					end if;	
			
				when others =>
					output <= '0';
			end case;		
		end if;
	end process;

	process(output) begin
		SOUND_OUT <= output;
	end process;
	
end architecture behavioral;	
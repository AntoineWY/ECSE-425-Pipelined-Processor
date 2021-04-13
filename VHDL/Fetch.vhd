library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Fetch is

port(
	clk:						in std_logic;
	branch_target_address:		in std_logic_vector(31 downto 0);
	jump_target_address:		in std_logic_vector(31 downto 0);	
	next_pc_branch:				in std_logic;
	next_pc_jump:				in std_logic;
--	structure_stall:	in std_logic := '0';
--	pc_stall:					in std_logic := '0';
	pc_update:					out std_logic_vector(31 downto 0);
	Fetch_out:					out std_logic_vector(31 downto 0)
	);

end Fetch;

architecture fetch_arch of Fetch is

component Instruction_Memory is
	generic(
		ram_size: 		integer := 32768;
		mem_delay: 		time := 1 ns;
		clock_period: 	time := 1 ns
		);
	port(
		clock: 			in std_logic;
		writedata: 		in std_logic_vector(31 downto 0);
		address: 		in integer range 0 to ram_size-1;
		memwrite: 		in std_logic;
		memread: 		in std_logic;
		readdata: 		out std_logic_vector(31 downto 0);
		waitrequest: 	out std_logic
		);
end component;

	signal writedata: 		std_logic_vector(31 downto 0);
	signal address: 		integer range 0 to 32768-1;
	signal memwrite: 		std_logic := '0';
	signal memread:			std_logic := '1';
	signal readdata:		std_logic_vector(31 downto 0);
	signal waitrequest:		std_logic;	-- how do we do with this?
--	signal pc_stall:		std_logic;

	signal adder_output:	std_logic_vector(31 downto 0);
	signal adder_result:	integer;
	signal four:			integer := 4;

	-- program counter initialized at zero
	signal pc_next:			std_logic_vector(31 downto 0);		
	signal pc_value:		std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal instruction_out:	std_logic_vector(31 downto 0);

	-- signal for stalls?


begin

	-- mux connection:
	-- 
	fetch_mux : process(next_pc_jump, next_pc_branch)
	begin
		if (next_pc_jump'event and rising_edge(next_pc_jump)) then
			pc_next <= jump_target_address;
		elsif (next_pc_branch'event and rising_edge(next_pc_branch)) then
			pc_next <= branch_target_address;
		else
			pc_next <= adder_output;
		end if ;

	end process ; -- fetch_mux

	--pc_next <= branch_target_address when (mux_Select = '1') else adder_output;

	-- adder connection:

	--adder_result <= four + to_integer(unsigned(pc_value));
	--adder_output <= std_logic_vector(to_unsigned(adder_result, adder_output'length));
	--pc_update <= adder_output;

	-- instruction memory and pc connection:
	-- first conver pc_update to integer for memory read

	

	-- if need to jump or branch, then set stall flag and stall for 3 cycles


	-- once the clock rising edge, then pc is updated
	PC: process(clk)
	variable stall_count:	integer;
	begin
		if(clk'event and clk = '1') then
			if((next_pc_branch or next_pc_jump) = '0') then




				address <= to_integer(unsigned(pc_value));
				Fetch_out <= instruction_out;				
				--pc_value <= pc_next;

				adder_result <= four + to_integer(unsigned(pc_value));
				adder_output <= std_logic_vector(to_unsigned(adder_result, adder_output'length));
				pc_next<= adder_output;


				pc_value <= pc_next;

				pc_update <=pc_value;
				
				
			else
				-- stall 3 cycles by inserting add $r0, $r0, $r0 
				-- 000000;00000;00000;00000;00000;100000;
				stall_count := 0;
				Fetch_out <= "00000000000000000000000000100000";
				stall_loop : while (stall_count < 2) loop
					if (rising_edge(clk)) then
						Fetch_out <= "00000000000000000000000000100000";
						stall_count := stall_count + 1;
					end if ;

				end loop ; -- stall_loop


			end if;
			
		end if;
	end process;

	IM: Instruction_Memory
		port map(
			clock => clk,
			writedata => writedata,
			address => address,
			memwrite => memwrite,
			memread => memread,

			readdata => instruction_out,
			waitrequest => waitrequest
			);
	

end fetch_arch ; -- fetch_arch
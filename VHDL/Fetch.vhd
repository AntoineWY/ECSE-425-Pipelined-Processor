library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Fetch is

port(
	clk:				in std_logic;
	mux_input:			in std_logic_vector(31 downto 0);
	mux_Select:			in std_logic;
	structure_stall:	in std_logic := '0';
	pc_stall:			in std_logic := '0';
	pc_update:			out std_logic_vector(31 downto 0);
	instruction_out		out std_logic_vector(31 downto 0)
	);

end Fetch;

architecture fetch_arch of Fetch is

component Instruction_Memory is
	generic(
		ram_size: 		integer := 32768;
		mem_delay: 		time := 10 ns;
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
	signal memwrite: 		std_logic = '0';
	signal memread:			std_logic = '1';
	signal readdata:		std_logic_vector(31 downto 0);
	signal waitrequest:		std_logic;	-- how do we do with this?

	signal adder_output:	std_logic_vector(31 downto 0);
	signal adder_result:	integer;
	signal four:			integer := 4;

	-- program counter initialized at zero
	signal pc_value:		std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

	-- signal for stalls?


begin

	-- mux connection:
	-- if branch taken, EX/MEM send 1 and branch target address to mux, 
	-- else, by default increment PC by 4

	pc_update <= mux_input when (mux_Select = '1') else adder_output;

	-- adder connection:

	adder_result <= four + to_integer(unsigned(pc_value));
	adder_output <= std_logic_vector(to_unsigned(adder_result, adder_output'length));

	-- instruction memory and pc connection:
	-- first conver pc_update to integer for memory read

	address <= to_integer(unsigned(pc_value));

	-- once the clock rising edge, then pc is updated
	PC: process(clk)
	begin
		if(clk'event and clk = '1') then
			pc_value <= pc_update;
		end if;
	end process;

	IM: Instruction_Memory
		port map(
			clock => clk;
			writedata => writedata;
			address => address;
			memwrite => memwrite;
			memread => memread;
			readdata => instruction_out;
			waitrequest => waitrequest
			);
	

end architecture ; -- fetch_arch
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Instruction_Memory is 
	generic(
		ram_size: 		integer := 32768;
		mem_delay: 		time := 0 ns;
		clock_period: 	time := 1 ns
		);
	port(
		clock: 			in std_logic;
		writedata: 		in std_logic_vector(31 DOWNTO 0);
		address: 		in integer RANGE 0 TO ram_size-1;
		memwrite: 		in std_logic;
		memread: 		in std_logic;
		readdata: 		out std_logic_vector(31 DOWNTO 0);
		waitrequest: 	out std_logic
		);
end Instruction_Memory;

architecture rtl of Instruction_Memory is
	-- write/read data are 32 bits instead of 8 bits, same as the memory block.
	type mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
	signal ram_block:			mem;
	signal read_address_reg:	integer range 0 to ram_size-1;
	signal write_waitreq_reg:	std_logic := '1';
	signal read_waitreq_reg:	std_logic := '1';

begin
	mem_process: process(clock)

	file program_read: 		text;
	variable row:			line;
	variable row_data:		std_logic_vector(31 downto 0);
	variable row_counter:	integer := 0;

	begin
		-- read the text line by line and store in row_data, each line is a word
		if(now < 1 ps) then
			file_open(program_read,"program.txt",READ_MODE);
			-- store row_data into ramblock in sequence
			while(not endfile(program_read)) loop
				readline(program_read, row);
				read(row,row_data);
				ram_block(row_counter) <= row_data;
				row_counter := row_counter + 1;
			end loop;
		end if;
		file_close(program_read);
end process;
		read_address_reg <= address/4;
		readdata <= ram_block(read_address_reg);

end rtl ; -- rtl
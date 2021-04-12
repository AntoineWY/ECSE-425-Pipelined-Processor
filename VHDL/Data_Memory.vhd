library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Data_Memory is
	generic(
			ram_size:		integer := 8192; -- There're 8192 lines in the data memory
			mem_delay:		time := 1 ns;
			clock_period:	time := 1 ns;			
			);
	port(	
			clock:			in std_logic;
			EXMEM_WB:		in std_logic;	-- Directly pass to MEMWB_WB
			EXMEM_M:		in std_logic_vector(1 downto 0);	-- for the first bit, '0' refers to access Data Mem, '1' refers to pass through 
																-- for the second bit, '0' refers to read data from data memory		
																					-- '1' refers to write data to data memory
																					
			Write_data:		in std_logic_vector(31 downto 0);
			ALU_out	:		in std_logic_vector(31 downto 0);
			EXMEM_register:	in std_logic_vector(4 downto 0); 
			
			MEMWB_WB:		out std_logic;	-- writeback signal output
			Data_Mem_out:	out std_logic_vector(31 downto 0); -- output from data memory
			Address_to_WB:	out std_logic_vector(31 downto 0); -- output from ALU output	
			MEMWB_register:	out std_logic_vector(4 downto 0); -- output 
		);	
end Data_Memory;

architecture implementation of Data_Memory is
	
	type mem is array(ram_size - 1 downto 0) of std_logic_vector(31 downto 0);
	signal ram_block:			mem;
	signal write_waitreq_reg:	std_logic := '1';
	signal read_waitreq_reg:	std_logic := '1';

	file write_data_memory: 	text;
	file read_data_memory:		text;
	variable row:				line;
	variable row_data:			std_logic_vector(31 downto 0);
	variable address:			integer range 0 to ram_size - 1;
	variable address_counter:	integer := 0;
	variable memwrite: 			STD_LOGIC;
	variable memread: 			STD_LOGIC;

begin
	
	data_mem_process: process (clock)
		
	begin
	-- Initialize the file "memory.txt"
	if(now < 1 ps)then
		for i in 0 to ram_size - 1 loop
			ram_block(i) <= std_logic_vector(to_unsigned(0, 32));
			write(row, ram_block(i));
			writeline(write_data_memory, row);
		end loop;
	end if;
	
	if(EXMEM_M(0) = '1')then
		memwrite <= '1';
		memread <= '0';
	else
		memwrite <= '0';
		memread <= '1';
	end if;
	

	if(clock'event AND clock = '1') then	
		MEMEWB_WB <= EXMEM_WB;	-- Directly pass the writeback signal to next pipelin stage
		MEMWB_register <= EXMEM_register; -- Directly pass the register to the next stage;
		address := to_integer(unsigned(ALU_out));
	
		if(EXMEM_M(1) = '1') then
		Address_to_WB <= ALU_out;	-- no need to access data memory
		
		else 
			-- open the files
			file_open(read_data_memory, "memory.txt", read_mode);
			file_open(write_data_memory, "memory.txt", write_mode);
			
			--read until the desired line;
			while(address_counter < address)
				readline(read_data_memory, row);
				address_counter := address_counter + 4;
			end loop;			
			if(EXMEM_M(0) = '0' AND memread = '1') then	
			-- load data from the given address and pass it to the signal Data_Mem_out

				read(row, row_data);
				Data_Mem_out <= row_data;
				address_counter := 0;
			
			else
				if(memwrite = '1')then
					-- store data to the given address with the given value
					write(row, Write_data);
					writeline(write_data_memory, row);
					Data_Mem_out <= Write_data;
					address_counter := 0;
				end if;
			end if;
		end if;
	end if;
	end process;

	--Read and write should never happen at the same time.
	waitreq_w_proc: process (memwrite)
	begin
		if(memwrite'event AND memwrite = '1')then
			write_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;

		end if;
	end process;

	waitreq_r_proc: process (memread)
	begin
		if(memread'event AND memread = '1')then
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		end if;
	end process;



end implementation;
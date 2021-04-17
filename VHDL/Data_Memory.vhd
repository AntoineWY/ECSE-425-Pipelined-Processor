library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Data_Memory is
	generic(
			ram_size:		integer := 8192; -- There're 8192 lines in the data memory
			mem_delay:		time := 1 ns;
			clock_period:	time := 1 ns			
			);
	port(	
			clock:				in std_logic;
			EXMEM_WB:			in std_logic;	-- Directly pass to MEMWB_WB
			EXMEM_M:			in std_logic;	-- for the first bit, '0' refers to access Data Mem, '1' refers to pass through 
																-- for the second bit, '0' refers to read data from data memory		
																					-- '1' refers to write data to data memory
			opcode:				in std_logic_vector(4 downto 0); --
			
			Write_data:			in std_logic_vector(31 downto 0);
			ALU_out:			in std_logic_vector(31 downto 0);
			EXMEM_register:		in std_logic_vector(4 downto 0); 
			
			MEMWB_M:			out std_logic;
			MEMWB_WB:			out std_logic;	-- writeback signal output
			Data_Mem_out:		out std_logic_vector(31 downto 0); -- output from data memory
			Address_to_WB:		out std_logic_vector(31 downto 0); -- output from ALU output	
			MEMWB_register:		out std_logic_vector(4 downto 0); -- output 
			Reg_Mem_to_forwarding:	out std_logic_vector(4 downto 0);
			WB_Mem_to_forwarding:	out std_logic
		);	
end Data_Memory;

architecture implementation of Data_Memory is
	
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;

begin

	Reg_Mem_to_forwarding <= EXMEM_register;
	WB_Mem_to_forwarding <= EXMEM_WB;

	MEMWB_WB <= EXMEM_WB;	-- Directly pass the writeback signal to next pipelin stage
	MEMWB_M <= EXMEM_M;	-- input of multiplexer(WB)
	MEMWB_register <= EXMEM_register; -- Directly pass the register to the next stage;

	init: process (clock)
	
	file write_data_memory: 	text;
	variable row_write:			line;
	variable address:			integer range 0 to ram_size - 1;
	variable address_counter:	integer := 0;
	
	begin
	-- Initialize the memory
	if(now = 1 ps)then
		for i in 0 to ram_size - 1 loop
			ram_block(i) <= "00000000000000000000000000000000";
		end loop;
	end if;

	if(clock'event AND clock = '1') then	
		address := to_integer(unsigned(ALU_out));
		
		if(EXMEM_M = '0') then
		Address_to_WB <= ALU_out;	-- no need to access data memory
		
		else 	
			if(opcode = "10100") then	
				-- load data from the given address and pass it to the signal Data_Mem_out
				Data_Mem_out <= ram_block(address/4);
				address_counter := 0;
			elsif(opcode = "10101")then
				ram_block(address/4) <= Write_data;
				Data_Mem_out <= Write_data;
			end if;
		end if;
		
		
		file_open(write_data_memory, "memory.txt", WRITE_MODE);
		for i in 0 to ram_size-1 loop
			write(row_write, ram_block(i));
			writeline(write_data_memory, row_write);
		end loop;
		file_close(write_data_memory);
		
	end if;
	end process;


end implementation;
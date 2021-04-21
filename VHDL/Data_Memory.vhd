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
			clock:					in std_logic;		
			EXMEM_WB:				in std_logic;	-- write back flag, will be directly passed to MEMWB_WB
			EXMEM_M:				in std_logic;	-- data memory access flag, 
													-- '0' refers to access Data Mem, '1' refers to pass through
			opcode:					in std_logic_vector(4 downto 0); -- opcode of the instruction, sent by the execution stage
	
			Write_data:				in std_logic_vector(31 downto 0); -- data to write to the data memory
			ALU_out:				in std_logic_vector(31 downto 0); -- ALU output
			EXMEM_register:			in std_logic_vector(4 downto 0);

			MEMWB_M:				out std_logic;	-- memory access flag
			MEMWB_WB:				out std_logic;	-- writeback flag
			Data_Mem_out:			out std_logic_vector(31 downto 0); -- data that is loaded from data memory
			Address_to_WB:			out std_logic_vector(31 downto 0); -- actually it should be the data output from ALU, which is directly passed to the Writeback stage, wrong name
			MEMWB_register:			out std_logic_vector(4 downto 0);
			Reg_Mem_to_forwarding:	out std_logic_vector(4 downto 0);
			WB_Mem_to_forwarding:	out std_logic;
			ALU_out_to_ex: 			out std_logic_vector(31 downto 0)
		);
end Data_Memory;

architecture implementation of Data_Memory is
	
	-- declare an array of vectors, which will be used for storing data temporarily
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ram_block: MEM;

begin
	
	Reg_Mem_to_forwarding <= EXMEM_register;
	WB_Mem_to_forwarding <= EXMEM_WB;
	ALU_out_to_ex <= ALU_out;
	Address_to_WB <= ALU_out when EXMEM_M = '0';	--if data memory is not accessed, pass the ALU output to the writeback stage
	MEMWB_WB <= EXMEM_WB;	-- Directly pass the writeback signal to next pipelin stage
	MEMWB_M <= EXMEM_M;	-- input of multiplexer(WB)
	MEMWB_register <= EXMEM_register; -- Directly pass the register to the next stage;

	init: process (clock)

	file write_data_memory: 	text;
	variable row_write:			line;
	variable address:			integer range 0 to 32767;

	begin
	-- Initialize the memory to all 0
	if(now = 1 ps)then
		for i in 0 to ram_size - 1 loop
			ram_block(i) <= "00000000000000000000000000000000";
		end loop;
	end if;


	if(clock'event AND clock = '1') then
		-- get the address to access
		address := to_integer(unsigned(ALU_out));

		--if memory access signal is high, then check the opcode
		if(EXMEM_M = '1') then
			
			-- opcode "10100" refers to load word
			if(opcode = "10100") then
				-- load data from the given address and pass it to the signal Data_Mem_out
				Data_Mem_out <= ram_block(address/4);
				
			-- opcode "10101" refers to store word	
			elsif(opcode = "10101")then
				-- store the data sent by Write_data to the given address in the temporary data array
				-- meanwhile, pass the data to the Data_Mem_out
				ram_block(address/4) <= Write_data;
				Data_Mem_out <= Write_data;
			end if;
		end if;

		-- at each clock cycle after memory access, stores the temporary data array to the file "memory.txt"
		file_open(write_data_memory, "memory.txt", WRITE_MODE);
		for i in 0 to ram_size-1 loop
			write(row_write, ram_block(i));
			writeline(write_data_memory, row_write);
		end loop;
		file_close(write_data_memory);

	end if;
	end process;

end implementation;

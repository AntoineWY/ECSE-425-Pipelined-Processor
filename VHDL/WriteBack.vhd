library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity WriteBack is
	port(
		clock:				in std_logic;
		MEMWB_M:			in std_logic; -- input of multiplexer, data memory access flag
		MEMWB_WB:			in std_logic; -- writeback flag;
		Data_Mem_out:		in std_logic_vector(31 downto 0); -- data loaded from data memory
		Address_to_WB:		in std_logic_vector(31 downto 0); -- actually it should be the data from ALU, wrong name
		MEMWB_register:		in std_logic_vector(4 downto 0);

		WB_WB_to_forwarding:	out std_logic;
		Write_Data:			out std_logic_vector(31 downto 0);
		Write_Reg:			out std_logic_vector(4 downto 0)
	);
end WriteBack;

architecture implementation of WriteBack is
begin
	
	-- the writeback flag at pipeline stage MEM/WB should be directly forward to the forwarding unit
	WB_WB_to_forwarding <= MEMWB_WB;
	
	--if the writeback flag signal is low, then automatically set the write_reg signal to 00000, indicating that there's nothing to write to the register
	--otherwise, write the data sending by input signal MEMWB_register.
	Write_Reg <= "00000" when MEMWB_WB /= '1' else
						 MEMWB_register;

	--if the writeback flag signal is low, then automatically set the write_data signal to 32 bits of 0, indicating that there's no data to write back
	--otherwise, check the memory access flag.
	--if data memory is accessed, then send the data from Data_Mem_out to writeback signal, which indicates that the write back data is loaded from memory
	--if data memory is not accessed, then send the data from Address_to_WB, which indicates that the write back data is directly passed from the ALU output
	Write_Data <= "00000000000000000000000000000000" when MEMWB_WB /= '1' else
							 Data_Mem_out when (MEMWB_WB = '1' and MEMWB_M = '1') else
							 Address_to_WB;

end implementation;

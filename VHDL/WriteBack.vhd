library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity WriteBack is
	port(
		clock:				in std_logic;
		MEMWB_M:			in std_logic; -- input of multiplexer
		MEMWB_WB:			in std_logic; -- writeback flag;
		Data_Mem_out:		in std_logic_vector(31 downto 0);
		Address_to_WB:		in std_logic_vector(31 downto 0);
		MEMWB_register:		in std_logic_vector(4 downto 0);
		
		WB_WB_to_forwarding:	out std_logic;
	--	Reg_WB_to_forwarding:	out std_logic_vector(4 downto 0);
		Write_Data:			out std_logic_vector(31 downto 0);
		Write_Reg:			out std_logic_vector(4 downto 0)
	);
end WriteBack;

architecture implementation of WriteBack is

begin	
	
	WB_WB_to_forwarding <= MEMWB_WB;
--	Reg_WB_to_forwarding <= MEMWB_register;
	Write_Reg <= MEMWB_register;

	WB_process: process(clock)
	begin

	if(now < 1 ps) then
		Write_Data <= "00000000000000000000000000000000";	
		Write_Reg <= "00000";
	end if;	

	if(clock'event AND clock = '1' AND MEMWB_WB = '1') then	
		if(MEMWB_M = '1')then
			Write_Data <= Data_Mem_out;
		else
			Write_Data <= Address_to_WB;
		end if;
	elsif(clock'event AND clock = '1' AND MEMWB_WB = '0') then	
		Write_Data <= "00000000000000000000000000000000";	
		Write_Reg <= "00000";	
	end if;
	end process;
end implementation;
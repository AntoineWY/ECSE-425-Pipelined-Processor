library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Fetch is

port(
	clk:						in std_logic;
	bj_target_address:			in std_logic_vector(31 downto 0);
	pc_stall:					in std_logic;
	branch_taken:				in std_logic;
	hazard: 					in std_logic;
	pc_update:					out std_logic_vector(31 downto 0);
	Fetch_out:					out std_logic_vector(31 downto 0)
	);

end Fetch;

architecture fetch_arch of Fetch is

component Instruction_Memory is
	generic(
		ram_size: 		integer := 32768;
		mem_delay: 		time := 0 ns;
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
	signal address: 		integer range 0 to 32768-1;	-- address to go for in the instr mem
	signal memwrite: 		std_logic := '0';	-- As a fetch unit, thus write never zero.
	signal memread:			std_logic := '1';	-- As a fetch unit, thus read forever one.
	signal readdata:		std_logic_vector(31 downto 0);
	signal waitrequest:		std_logic;	-- how do we do with this? (might not used)

	-- program counter initialized at zero
	signal pc_value:		std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

	-- initialize to avoid "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU". Not a valid instr anyway
	signal instruction_out:	std_logic_vector(31 downto 0):="11111111111111111111111111111111";
	
	signal fetch_out_internal: std_logic_vector(31 downto 0);

begin
	pc_update <= pc_value; --when(bj_adress_ready = 0) else std_logic_vector(unsigned(bj_target_address) + 4);
	address <= to_integer(unsigned(pc_value)) when (branch_taken = '0') else to_integer(unsigned(bj_target_address));  -- see if there is a branch to fetch

	PC: process(clk)
	variable stall_count:	integer:= 0;
	begin
		if(clk'event and rising_edge(clk)) then

			if((pc_stall = '0') and (hazard = '0') and (stall_count = 0)) then

				fetch_out_internal <= instruction_out;	-- sending the instruction fetched from the instr_mem here

				-- based on branch situation, sending next PC increment or the branch target to pc
				if(branch_taken = '0')then
					pc_value <= std_logic_vector(unsigned(pc_value) + 4);
				else
					pc_value <= std_logic_vector(unsigned(bj_target_address)+4);
				end if;
			else
				-- stall 3 cycles by inserting add $r0, $r0, $r0
				-- 000000;00000;00000;00000;00000;100000;
				if(stall_count = 0)then
					if(hazard = '1') then
						stall_count := 2;
					elsif(pc_stall = '1') then
						stall_count := 1;
					end if;
					
				end if;
				fetch_out_internal <= "00000000000000000000000000100000";	-- this is a stall, thus load bubble instruction
				stall_count := stall_count - 1;
				if(stall_count = 0) then
					pc_value <= std_logic_vector(unsigned(pc_value) - 4);  -- offset the previous increment in the last cycles
				end if;
			end if;
		end if;
	end process;

	-- put this outside process blovk
	-- to ensure that fetched instr can be flushed right away when a branch or hazard is detected
	Fetch_out <= fetch_out_internal when ((pc_stall = '0') and (hazard = '0')) else
							"00000000000000000000000000100000";	---- there is a stall or hazrad, thus load bubble instruction

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

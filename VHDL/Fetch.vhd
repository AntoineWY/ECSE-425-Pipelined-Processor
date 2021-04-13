library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Fetch is

port(
	clk:						in std_logic;
	bj_target_address:			in std_logic_vector(31 downto 0);
--	jump_target_address:		in std_logic_vector(31 downto 0);	
	pc_stall:					in std_logic;
--	next_pc_jump:				in std_logic;
	bj_address_ready:				in std_logic;
--	structure_stall:	in std_logic := '0';
--	pc_stall:					in std_logic := '0';
	pc_update:					out std_logic_vector(31 downto 0);
	Fetch_out:					out std_logic_vector(31 downto 0)
	--addr:						out integer RANGE 0 TO 32768-1
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
	signal address: 		integer range 0 to 32768-1;
	signal memwrite: 		std_logic := '0';
	signal memread:			std_logic := '1';
	signal readdata:		std_logic_vector(31 downto 0);
	signal waitrequest:		std_logic;	-- how do we do with this?
--	signal pc_stall:		std_logic;

	signal adder_output:	std_logic_vector(31 downto 0);
	signal adder_result:	integer;

	signal add_result:	std_logic_vector(31 downto 0);
	signal four:			integer := 4;

	-- program counter initialized at zero
	--signal pc_next:			std_logic_vector(31 downto 0);		
	signal pc_value:		std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal instruction_out:	std_logic_vector(31 downto 0);

begin
	--mux connection:
	
	--fetch_mux : process(bj_adress_ready)
	--begin
		--if (bj_adress_ready'event and rising_edge(bj_adress_ready)) then
		--	pc_next <= bj_target_address;
		--end if ;

	--end process ; -- fetch_mux
	-- once the clock rising edge, then pc is updated

	pc_update <= pc_value; --when(bj_adress_ready = 0) else std_logic_vector(unsigned(bj_target_address) + 4);
	address <= to_integer(unsigned(pc_value)) when (bj_address_ready = '0') else to_integer(unsigned(bj_target_address));

	PC: process(clk,bj_address_ready)
	variable stall_count:	integer:= 0;
	begin
		if(clk'event and rising_edge(clk)) then

			if((pc_stall = '0') and (stall_count = 0) ) then

				Fetch_out <= instruction_out;					
				if(bj_address_ready = '0')then
					pc_value <= std_logic_vector(unsigned(pc_value) + 4);
				else
					pc_value <= std_logic_vector(unsigned(bj_target_address)+4);
				end if;
			else
				-- stall 3 cycles by inserting add $r0, $r0, $r0 
				-- 000000;00000;00000;00000;00000;100000;
				if(stall_count = 0)then
					stall_count := 3;
				end if;
				Fetch_out <= "00000000000000000000000000100000";
				stall_count := stall_count - 1;
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Execution is

port(
	clk:				in std_logic;
	-- relayed from ID
	pc_input:			in std_logic_vector(31 downto 0);
	ALU_op:				in std_logic_vector(4 downto 0);
	-- sign extended instruction
	instruction_input:	in std_logic_vector(31 downto 0);
	-- input from register file
	readdata1:			in std_logic_vector(31 downto 0);
	readdata2:			in std_logic_vector(31 downto 0);
	-- inputs from forwading unit
	mux1_select:		in std_logic_vector(1 downto 0);
	mux2_select:		in std_logic_vector(1 downto 0);
	-- inputs from other stages by forwarding
	WB_out:				in std_logic_vector(31 downto 0); -- mux1_in2 & mux2_in3
	MEM_out:			in std_logic_vector(31 downto 0); -- mux1_in3 & mux2_in2
	-- inputs from ID stage
	IDEX_WB_register:	in std_logic_vector(4 downto 0);
	IDEX_Rs_register:	in std_logic_vector(4 downto 0);
	IDEX_Rt_register:	in std_logic_vector(4 downto 0);
	-- intput from control blocks
	IDEX_EX:			in std_logic; -- check if alu is needed
	IDEX_M:				in std_logic; -- simple bypass
	IDEX_WB:			in std_logic; -- simple bypass
	-- output to writedata in MEM
	data_to_mem:		out std_logic_vector(31 downto 0);
	-- output to MEM stage
	EXMEM_WB_register:	out std_logic_vector(4 downto 0);
	-- output to control blocks
	EXMEM_WB:			out std_logic;
	EXMEM_M:			out std_logic;
	-- back to mux_in in Fetch stage
	branch_taken:		out std_logic;
	-- back to decode stage
	hi:					out std_logic_vector(31 downto 0);
	lo:					out std_logic_vector(31 downto 0);
	-- main output
	ALU_out:			out std_logic_vector(31 downto 0);
	adder_out:			out std_logic_vector(31 downto 0);
	ALU_op_to_dm:				out std_logic_vector(4 downto 0)
	);

end Execution;

architecture exe of Execution is
component ALU is
	port(
		clk:				in std_logic;
		ALU_in1:			in std_logic_vector(31 downto 0);
		ALU_in2:			in std_logic_vector(31 downto 0);
		ALU_op:				in std_logic_vector(4 downto 0);
		hi:					out std_logic_vector(31 downto 0);
		lo:					out std_logic_vector(31 downto 0);
		ALU_out:			out std_logic_vector(31 downto 0)
		);
end component;

	signal ALU_in1:			std_logic_vector(31 downto 0);
	signal ALU_in2:			std_logic_vector(31 downto 0);
	signal ALU_out_internal:std_logic_vector(31 downto 0);


begin

	-- bypassing control signals
	-- those signals are not changed in ex stages.
	-- thus there are passed through right away
	ALU_op_to_dm <= ALU_op;	-- ALU_op (our own version of opcode) tells data memory whether it is a store or ld
	EXMEM_WB <= IDEX_WB; --control logics
	EXMEM_M <= IDEX_M;
	EXMEM_WB_register <= IDEX_WB_register;

	-- pass EX result to next stage to the DM 
	ALU_out <= ALU_out_internal;
	
	-- this handles branch or jump
	-- the first condition contains conditions for BNE and BEQ. Thus we add offset to current PC to the desired position
	-- second is jump
	-- this output gives back to fetch stage
	adder_out <= std_logic_vector(to_unsigned((to_integer(unsigned(instruction_input))*4 + to_integer(unsigned(pc_input))),adder_out'length)) when (ALU_op = "10111" or ALU_op = "10110") else
								ALU_in1 when (ALU_op = "11000" or ALU_op = "11001" or ALU_op = "11010");

process(mux1_select,mux2_select,ALU_op,clk)
begin

	-- mux1: handles forwarding cases for input 1
	if(mux1_select = "00") then
		ALU_in1 <= readdata1;
	elsif(mux1_select = "01") then
		ALU_in1 <= WB_out;
	elsif(mux1_select = "10") then
		ALU_in1 <= MEM_out;
	else
		ALU_in1 <= readdata1;
	end if;

	-- mux2; handles forwarding cases for input 2
	if(mux2_select = "00") then

		if(ALU_op = "10101")then -- store case, the mux in the manual?
			ALU_in2 <= instruction_input;
			data_to_mem <= readdata2;
		elsif(ALU_op = "10100") then -- load case
			ALU_in2 <= readdata2;
		else
			ALU_in2 <= readdata2;
		end if;

	elsif(mux2_select = "01") then
		ALU_in2 <= MEM_out;
	elsif(mux2_select = "10") then
		ALU_in2 <= WB_out;
	else
		ALU_in2 <= readdata2;
	end if;

	-- branch and jump check
	if(ALU_op = "10110") then--beq
		if(ALU_in1 = ALU_in2) then
			branch_taken <= '1';
		else
			branch_taken <= '0';
		end if;
	elsif(ALU_op = "10111") then -- bne
		if(ALU_in1 /= ALU_in2) then
			branch_taken <= '1';	
		else
			branch_taken <= '0';
		end if;
	elsif(ALU_op = "11000" or ALU_op = "11001" or ALU_op = "11010") then -- jump, unconditional
		branch_taken <= '1';
	else
		branch_taken <= '0';
	end if;

end process;

alu_block: ALU
	port map(
		clk => clk,
		ALU_in1 => ALU_in1,
		ALU_in2 => ALU_in2,
		ALU_op => ALU_op,
		hi => hi,
		lo => lo,
		ALU_out => ALU_out_internal
		);
end exe ; -- exe

-- first version of pipeline:
-- connect Fetch, Decode, and Execution
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Pipeline is

port(
	clk:			in std_logic;
	pip_ALU_out:		out std_logic_vector(31 downto 0)
	);

end Pipeline;

architecture pipe of Pipeline is

component Fetch is
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
end component;

component Decode is

  port(

    clk: in std_logic;
    instruction: in std_logic_vector(31 downto 0);  -- opcode,rs, rt, rd, shift, funct  --opcode, rs, rt, immediate --
    -- from WB
    write_data: in std_logic_vector(31 downto 0);
    write_register: in std_logic_vector(4 downto 0);

    HI_data, LO_data : in std_logic_vector(31 downto 0);
    -- relay
    pc_update: inout std_logic_vector(31 downto 0); --pc+4

    -- output data to execution
    r_data_1: out std_logic_vector(31 downto 0); --done
    r_data_2: out std_logic_vector(31 downto 0);  -- done

    -- opcode for execution
    ALU_op: out std_logic_vector(4 downto 0); --done

    -- operation flag
    --JUMP:     out std_logic;
    --JUMP_ADDRESS: out std_logic_vector(31 downto 0);  -- the sign extend address
    IDEX_WB:   out std_logic; --done
    IDEX_M:    out std_logic; -- done
    IDEX_EX:   out std_logic; -- done
    SIGN_EXTEND: out std_logic_vector(31 downto 0); --done

    -- forwarding
    IDEXRs_forwarding: out std_logic_vector(4 downto 0);  --done
    --IFIDRt: out std_logic_vector(4 downto 0);
    IDEXRt_forwarding: out std_logic_vector(4 downto 0);
    --IFIDRd: out std_logic_vector(4 downto 0);
    IDEX_WB_register: out std_logic_vector(4 downto 0); --done
    -- stall
    --BRANCH: out std_logic; -- if there is a stall, always stall for 3 cc
    --JUMP:     out std_logic;

    stall: out std_logic
  );
end component;

component Execution is

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
	IDEX_Rs_register:	inout std_logic_vector(4 downto 0);
	IDEX_Rt_register:	inout std_logic_vector(4 downto 0);
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
	adder_out:			out std_logic_vector(31 downto 0)
	);

end component;

	-- fetch signal extension
	signal bj_target_address,			
			pc_update,							-- key mapping to execution
			Fetch_out:		std_logic_vector(31 downto 0);	-- key mapping to execution

	-- decode signal extension
	signal write_data, 
			HI_data, 
			LO_data,
			r_data_1,
			r_data_2,	
			pc_update_to_decode,	
			Fetch_out_to_decode,	
			SIGN_EXTEND:	std_logic_vector(31 downto 0);

	signal write_register,
			IDEXRs_forwarding,
			IDEX_Rt_register,
			IDEX_WB_register,
			IDEX_Rs_register,
			ALU_op:			std_logic_vector(4 downto 0);	

	signal IDEX_WB,
			IDEX_M,
			IDEX_EX,
			bj_address_ready,
			pc_stall:		std_logic;

	-- Execution signal extension
	signal mux1_select,
			mux2_select:	std_logic_vector(1 downto 0);

	signal WB_out,
			MEM_out,
			ALU_out,
			data_to_mem,
			adder_out,
			readdata1_to_execution,
			readdata2_to_execution,
			extended_to_execution,
			pc_update_to_execution:		std_logic_vector(31 downto 0); -- key mapping from fetch

	signal 	ALU_op_to_execution,
			EXMEM_WB_register: std_logic_vector(4 downto 0);



begin
process(clk)
begin
	if(rising_edge(clk)) then
		-- IF/ID
		pc_update_to_decode <= pc_update;
		Fetch_out_to_decode <= Fetch_out;

		-- ID/EX
		pc_update_to_execution <= pc_update_to_decode;
		readdata1_to_execution <= r_data_1;
		readdata2_to_execution <= r_data_2;
		extended_to_execution <= SIGN_EXTEND;
		ALU_op_to_execution <= ALU_op;
		pip_ALU_out <= ALU_out;


	end if;
end process;


	IF_stage: Fetch
		port map(
			clk => clk,
			bj_target_address => bj_target_address,
			pc_stall => pc_stall,
			bj_address_ready => bj_address_ready,
			pc_update => pc_update,
			Fetch_out => Fetch_out
			);
	ID: Decode
		port map(
			clk => clk,
			instruction => Fetch_out_to_decode, 			-- key mapping, from fetch
			write_data => write_data,
			write_register => write_register,
			HI_data => HI_data,					-- key mapping
			LO_data => LO_data,					-- key mapping
			pc_update => pc_update_to_decode,-- key mapping, from fetch
			r_data_1 => r_data_1,
			r_data_2 => r_data_2,
			ALU_op => ALU_op,
			IDEX_WB => IDEX_WB,
			IDEX_M => IDEX_M,
			IDEX_EX => IDEX_EX,
			SIGN_EXTEND => SIGN_EXTEND,			-- key mapping, to execution
			IDEXRs_forwarding => IDEXRs_forwarding,
			IDEXRt_forwarding => IDEX_Rt_register,
			IDEX_WB_register => IDEX_WB_register,
			stall => pc_stall					-- key mapping, to fetch
			);
	EX: Execution
		port map(
			clk => clk,
			pc_input => pc_update_to_execution, -- key mapping, from fetch
			ALU_op => ALU_op_to_execution, 					-- key mapping, from decode
			instruction_input => extended_to_execution,  	-- key mapping, from decode
			readdata1 => readdata1_to_execution, 				-- key mapping, from decode
			readdata2 => readdata2_to_execution,				-- key mapping, from decode
			mux1_select => mux1_select,
			mux2_select => mux2_select,
			WB_out => WB_out,
			MEM_out => MEM_out,
			IDEX_WB_register => IDEX_WB_register,
			IDEX_Rs_register => IDEX_Rs_register,
			IDEX_Rt_register => IDEX_Rt_register,
			IDEX_EX => IDEX_EX,
			IDEX_M => IDEX_M,
			IDEX_WB => IDEX_WB,
			EXMEM_M => IDEX_M,
			EXMEM_WB => IDEX_WB,
			data_to_mem => data_to_mem,
			EXMEM_WB_register => EXMEM_WB_register,
			branch_taken => pc_stall,
			hi => HI_data,
			lo => LO_data,
			ALU_out => ALU_out,
			adder_out => adder_out

			);

end pipe ; -- pipe
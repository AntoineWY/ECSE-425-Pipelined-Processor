library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Pipeline is

  port(
  	clk:				in std_logic;
    --- debug protocal
    debug_vector_1: out std_logic_vector(31 downto 0);
    debug_vector_2: out std_logic_vector(31 downto 0);
    debug_vector_3: out std_logic_vector(31 downto 0);
    debug_vector_4: out std_logic_vector(31 downto 0);
    debug_vector_5: out std_logic_vector(31 downto 0);
    debug_boolean_1: out std_logic;
    debug_boolean_2: out std_logic;
    debug_boolean_3: out std_logic;
    debug_boolean_4: out std_logic;
    debug_boolean_5: out std_logic;
    reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
    reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
    reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
    reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)
  	);

end Pipeline;

architecture structure of Pipeline is

-- *********************** signal of each stage **************
----------- signal for fetch --------------
signal fetch_bj_target_address:std_logic_vector(31 downto 0);
signal fetch_pc_stall:	std_logic;
signal fetch_branch_taken:	std_logic;
signal fetch_pc_update: std_logic_vector(31 downto 0);
signal fetch_Fetch_out: std_logic_vector(31 downto 0);
signal fetch_hazard: std_logic;
----------- signal for decode -------------------
signal decode_instruction: std_logic_vector(31 downto 0);
signal decode_write_data: std_logic_vector(31 downto 0);
signal decode_write_register: std_logic_vector(4 downto 0);
signal decode_HI_data, decode_LO_data :  std_logic_vector(31 downto 0);
signal decode_pc_update:  std_logic_vector(31 downto 0);
signal decode_r_data_1:  std_logic_vector(31 downto 0);
signal decode_r_data_2:  std_logic_vector(31 downto 0);
signal decode_ALU_op:  std_logic_vector(4 downto 0);
signal decode_IDEX_WB:    std_logic;
signal decode_IDEX_M:     std_logic;
signal decode_IDEX_EX:    std_logic;
signal decode_SIGN_EXTEND:  std_logic_vector(31 downto 0);
signal decode_IDEXRs_forwarding:  std_logic_vector(4 downto 0);
signal decode_IDEXRt_forwarding:  std_logic_vector(4 downto 0);
signal decode_IDEX_WB_register:  std_logic_vector(4 downto 0);
signal decode_pc_update_to_ex : std_logic_vector(31 downto 0);
signal decode_stall:  std_logic;
signal decode_hazard: std_logic;

----------------- execution signals -------------------
signal execution_pc_input:			 std_logic_vector(31 downto 0);
signal execution_ALU_op:				 std_logic_vector(4 downto 0);
signal execution_instruction_input:	 std_logic_vector(31 downto 0);
signal execution_readdata1:			 std_logic_vector(31 downto 0);
signal execution_readdata2:			 std_logic_vector(31 downto 0);
signal execution_mux1_select:		 std_logic_vector(1 downto 0);
signal execution_mux2_select:		 std_logic_vector(1 downto 0);
signal execution_WB_out:				 std_logic_vector(31 downto 0); -- mux1_in2 & mux2_in3
signal execution_MEM_out:			 std_logic_vector(31 downto 0); -- mux1_in3 & mux2_in2
signal execution_IDEX_WB_register:	 std_logic_vector(4 downto 0);
signal execution_IDEX_Rs_register:	 std_logic_vector(4 downto 0);
signal execution_IDEX_Rt_register:	 std_logic_vector(4 downto 0);
signal execution_IDEX_EX:			 std_logic; -- check if alu is needed
signal execution_IDEX_M:				 std_logic; -- simple bypass
signal execution_IDEX_WB:			 std_logic; -- simple bypass
signal execution_data_to_mem:		 std_logic_vector(31 downto 0);
signal execution_EXMEM_WB_register:	 std_logic_vector(4 downto 0);
signal execution_EXMEM_WB:			 std_logic;
signal execution_EXMEM_M:			 std_logic;
signal execution_branch_taken:		 std_logic := '0';
signal execution_hi:					 std_logic_vector(31 downto 0);
signal execution_lo:					 std_logic_vector(31 downto 0);
signal execution_ALU_out:			 std_logic_vector(31 downto 0);
signal execution_adder_out:			 std_logic_vector(31 downto 0);
signal execution_ALU_op_to_dm: std_logic_vector(4 downto 0);
---------------- data memory signals -------------------
signal dm_EXMEM_WB:			 std_logic;
signal dm_EXMEM_M:			 std_logic;
signal dm_opcode:				 std_logic_vector(4 downto 0);
signal dm_Write_data:			 std_logic_vector(31 downto 0);
signal dm_ALU_out:			 std_logic_vector(31 downto 0);
signal dm_EXMEM_register:		 std_logic_vector(4 downto 0);
signal dm_MEMWB_M:			 std_logic;
signal dm_MEMWB_WB:			 std_logic;
signal dm_Data_Mem_out:		 std_logic_vector(31 downto 0);
signal dm_Address_to_WB:		 std_logic_vector(31 downto 0);
signal dm_MEMWB_register:		 std_logic_vector(4 downto 0);
signal dm_Reg_Mem_to_forwarding:	 std_logic_vector(4 downto 0);
signal dm_WB_Mem_to_forwarding:	 std_logic;
signal dm_ALU_out_to_ex: std_logic_vector(31 downto 0);
---------------------- write back signals -----------------
signal wb_MEMWB_M:			 std_logic; -- input of multiplexer
signal wb_MEMWB_WB:			 std_logic; -- writeback flag;
signal wb_Data_Mem_out:		 std_logic_vector(31 downto 0);
signal wb_Address_to_WB:		 std_logic_vector(31 downto 0);
signal wb_MEMWB_register:		 std_logic_vector(4 downto 0);
signal wb_WB_WB_to_forwarding:	 std_logic;
signal wb_Write_Data:			 std_logic_vector(31 downto 0);
signal wb_Write_Reg:			 std_logic_vector(4 downto 0);
--********************* signal all finished ***************************

--************************* component ********************************
-------------- fetch component ----------------
component Fetch is
	port(
		clk:						    in std_logic;
		bj_target_address:	in std_logic_vector(31 downto 0);
		pc_stall:					  in std_logic;
		branch_taken:			  in std_logic;
    hazard:             in std_logic;
		pc_update:					out std_logic_vector(31 downto 0);
		Fetch_out:					out std_logic_vector(31 downto 0)
		);
end component;
--------------- decode component ---------------
component Decode is
  port(
    clk:                in std_logic;
    instruction:        in std_logic_vector(31 downto 0);
    write_data:         in std_logic_vector(31 downto 0);
    write_register:     in std_logic_vector(4 downto 0);
    HI_data, LO_data :  in std_logic_vector(31 downto 0);
    pc_update:          in std_logic_vector(31 downto 0);
    r_data_1:           out std_logic_vector(31 downto 0);
    r_data_2:           out std_logic_vector(31 downto 0);
    ALU_op:             out std_logic_vector(4 downto 0);
    IDEX_WB:            out std_logic;
    IDEX_M:             out std_logic;
    IDEX_EX:            out std_logic;
    SIGN_EXTEND:        out std_logic_vector(31 downto 0);
    IDEXRs_forwarding:  out std_logic_vector(4 downto 0);
    IDEXRt_forwarding:  out std_logic_vector(4 downto 0);
    IDEX_WB_register:   out std_logic_vector(4 downto 0);
    pc_update_to_ex:    out std_logic_vector (31 downto 0);
    stall:              out std_logic;
    hazard:             out std_logic;
    -- decode register debug
    reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
    reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
    reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
    reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)
  );
end component;
--------------- execution component ---------------
component Execution is
  port(
  	clk:				        in std_logic;
  	pc_input:			      in std_logic_vector(31 downto 0);
  	ALU_op:				      in std_logic_vector(4 downto 0);
  	instruction_input:	in std_logic_vector(31 downto 0);
  	readdata1:			    in std_logic_vector(31 downto 0);
  	readdata2:			    in std_logic_vector(31 downto 0);
  	mux1_select:		    in std_logic_vector(1 downto 0);
  	mux2_select:		    in std_logic_vector(1 downto 0);
  	WB_out:				      in std_logic_vector(31 downto 0); -- mux1_in2 & mux2_in3
  	MEM_out:			      in std_logic_vector(31 downto 0); -- mux1_in3 & mux2_in2
  	IDEX_WB_register:	  in std_logic_vector(4 downto 0);
  	IDEX_Rs_register:	  in std_logic_vector(4 downto 0);
  	IDEX_Rt_register:	  in std_logic_vector(4 downto 0);
  	IDEX_EX:			      in std_logic; -- check if alu is needed
  	IDEX_M:				      in std_logic; -- simple bypass
  	IDEX_WB:			      in std_logic; -- simple bypass
  	data_to_mem:		    out std_logic_vector(31 downto 0);
  	EXMEM_WB_register:	out std_logic_vector(4 downto 0);
  	EXMEM_WB:			      out std_logic;
  	EXMEM_M:			      out std_logic;
  	branch_taken:		    out std_logic;
  	hi:					        out std_logic_vector(31 downto 0);
  	lo:					        out std_logic_vector(31 downto 0);
  	ALU_out:			      out std_logic_vector(31 downto 0);
  	adder_out:			    out std_logic_vector(31 downto 0);
  	ALU_op_to_dm:				out std_logic_vector(4 downto 0)
  	);
end component;
--------------- data memory component ---------------
component Data_Memory is
  port(
      clock:				    in std_logic;
      EXMEM_WB:			    in std_logic;
      EXMEM_M:			    in std_logic;
      opcode:				    in std_logic_vector(4 downto 0);
      Write_data:			  in std_logic_vector(31 downto 0);
      ALU_out:			    in std_logic_vector(31 downto 0);
      EXMEM_register:		in std_logic_vector(4 downto 0);
      MEMWB_M:			    out std_logic;
      MEMWB_WB:			    out std_logic;
      Data_Mem_out:		  out std_logic_vector(31 downto 0);
      Address_to_WB:		out std_logic_vector(31 downto 0);
      MEMWB_register:		out std_logic_vector(4 downto 0);
      Reg_Mem_to_forwarding:	out std_logic_vector(4 downto 0);
      WB_Mem_to_forwarding:	  out std_logic;
      ALU_out_to_ex:          out std_logic_vector(31 downto 0)
    );
end component;
------------------- WriteBack component ---------------
component WriteBack is
  port(
		clock:				        in std_logic;
		MEMWB_M:			        in std_logic;
		MEMWB_WB:			        in std_logic;
		Data_Mem_out:		      in std_logic_vector(31 downto 0);
		Address_to_WB:		    in std_logic_vector(31 downto 0);
		MEMWB_register:		    in std_logic_vector(4 downto 0);
		WB_WB_to_forwarding:	out std_logic;
		Write_Data:			      out std_logic_vector(31 downto 0);
		Write_Reg:			      out std_logic_vector(4 downto 0)
	);
end component;
--********************** component all finished ********************

begin

-- ******************** port map begin ***************************
------------- fetch port map -------------
IF_stage: Fetch
  port map(
  clk =>clk,
  bj_target_address => fetch_bj_target_address,
  pc_stall => fetch_pc_stall,
  branch_taken => fetch_branch_taken,
  hazard => fetch_hazard,
  pc_update => fetch_pc_update,
  Fetch_out => fetch_Fetch_out
  );
----------------- decode port map --------------
ID_stage: Decode
  port map(
    clk => clk,
    instruction => decode_instruction,
    write_data => decode_write_data,
    write_register => decode_write_register,
    HI_data => decode_HI_data,
    LO_data => decode_LO_data,
    pc_update => decode_pc_update,
    r_data_1 => decode_r_data_1,
    r_data_2 => decode_r_data_2,
    ALU_op => decode_ALU_op,
    IDEX_WB => decode_IDEX_WB,
    IDEX_M => decode_IDEX_M,
    IDEX_EX => decode_IDEX_EX,
    SIGN_EXTEND => decode_SIGN_EXTEND,
    IDEXRs_forwarding => decode_IDEXRs_forwarding,
    IDEXRt_forwarding => decode_IDEXRt_forwarding,
    IDEX_WB_register => decode_IDEX_WB_register,
    pc_update_to_ex => decode_pc_update_to_ex,
    stall => decode_stall,
    hazard => decode_hazard,

    -- register debug_vector_1
    reg_0 => reg_0,
    reg_1 => reg_1,
    reg_2 => reg_2,
    reg_3 => reg_3,
    reg_4 => reg_4,
    reg_5 => reg_5,
    reg_6 => reg_6,
    reg_7 => reg_7,
    reg_8 => reg_8,
    reg_9 => reg_9,
    reg_10=> reg_10,
    reg_11=> reg_11,
    reg_12 => reg_12,
    reg_13 => reg_13,
    reg_14 => reg_14,
    reg_15 => reg_15,
    reg_16 => reg_16,
    reg_17 => reg_17,
    reg_18 => reg_18,
    reg_19 => reg_19,
    reg_20 => reg_20,
    reg_21=> reg_21,
    reg_22=> reg_22,
    reg_23 => reg_23,
    reg_24 => reg_24,
    reg_25 => reg_25,
    reg_26 => reg_26,
    reg_27 => reg_27,
    reg_28 => reg_28,
    reg_29 => reg_29,
    reg_30 => reg_30,
    reg_31 => reg_31
  );

  ------------------- execution port map --------------------
  EX_stage: Execution
    port map(
      clk => clk,
      pc_input => execution_pc_input,
      ALU_op => execution_ALU_op,
      instruction_input => execution_instruction_input,
      readdata1 => execution_readdata1,
      readdata2 => execution_readdata2,
      mux1_select => execution_mux1_select,
      mux2_select => execution_mux2_select,
      WB_out => execution_WB_out,
      MEM_out => execution_MEM_out,
      IDEX_WB_register => execution_IDEX_WB_register,
      IDEX_Rs_register => execution_IDEX_Rs_register,
      IDEX_Rt_register => execution_IDEX_Rt_register,
      IDEX_EX => execution_IDEX_EX,
      IDEX_M => execution_IDEX_M,
      IDEX_WB => execution_IDEX_WB,
      data_to_mem => execution_data_to_mem,
      EXMEM_WB_register => execution_EXMEM_WB_register,
      EXMEM_WB => execution_EXMEM_WB,
      EXMEM_M => execution_EXMEM_M,
      branch_taken => execution_branch_taken,
      hi => execution_hi,
      lo => execution_lo,
      ALU_out => execution_ALU_out,
      adder_out => execution_adder_out,
      ALU_op_to_dm => execution_ALU_op_to_dm
      );

------------------------ data memory port map ----------------------
DM_stage: Data_Memory
  port map(
      clock => clk,
      EXMEM_WB => dm_EXMEM_WB,
      EXMEM_M => dm_EXMEM_M,
      opcode => dm_opcode,
      Write_data => dm_Write_data,
      ALU_out => dm_ALU_out,
      EXMEM_register => dm_EXMEM_register,
      MEMWB_M => dm_MEMWB_M,
      MEMWB_WB => dm_MEMWB_WB,
      Data_Mem_out => dm_Data_Mem_out,
      Address_to_WB => dm_Address_to_WB,
      MEMWB_register => dm_MEMWB_register,
      Reg_Mem_to_forwarding => dm_Reg_Mem_to_forwarding,
      WB_Mem_to_forwarding => dm_WB_Mem_to_forwarding,
      ALU_out_to_ex => dm_ALU_out_to_ex
    );

----------------------- writeback port map ------------------------
WB_stage: writeback
port map(
  clock => clk,
  MEMWB_M => wb_MEMWB_M,
  MEMWB_WB => wb_MEMWB_WB,
  Data_Mem_out => wb_Data_Mem_out,
  Address_to_WB => wb_Address_to_WB,
  MEMWB_register => wb_MEMWB_register,
  WB_WB_to_forwarding => wb_WB_WB_to_forwarding,
  Write_Data => wb_Write_Data,
  Write_Reg => wb_Write_Reg
);
-- ********************* end of port map *************************

-- ******************* pipeline begin ******************************
process(clk)
begin
  if rising_edge(clk) then
    -- -- map write back input
    wb_MEMWB_M <= dm_MEMWB_M;
    wb_MEMWB_WB <= dm_MEMWB_WB;
    wb_Data_Mem_out <= dm_Data_Mem_out;
    wb_Address_to_WB <= dm_Address_to_WB;
    wb_MEMWB_register <= dm_MEMWB_register;
    -- -- map data memory input --
    dm_EXMEM_WB <= execution_EXMEM_WB;
    dm_EXMEM_M <= execution_EXMEM_M;
    dm_opcode <= execution_ALU_op_to_dm;
    dm_Write_data <= execution_data_to_mem;
    dm_ALU_out <= execution_ALU_out;
    dm_EXMEM_register <=execution_EXMEM_WB_register;
    -- map execution input
    execution_pc_input <= decode_pc_update_to_ex; -- need to change order
    execution_ALU_op <= decode_ALU_op;
    execution_instruction_input <= decode_SIGN_EXTEND;
    execution_readdata1 <= decode_r_data_1;
    execution_readdata2 <= decode_r_data_2;

    execution_IDEX_WB_register <= decode_IDEX_WB_register;
    execution_IDEX_Rs_register <= decode_IDEXRs_forwarding;
    execution_IDEX_Rt_register <= decode_IDEXRt_forwarding;
    execution_IDEX_EX <= decode_IDEX_EX;
    execution_IDEX_M <= decode_IDEX_M;
    execution_IDEX_WB <= decode_IDEX_WB;
    -- -- map decode input
    decode_instruction <= fetch_Fetch_out;
--    decode_write_data <= wb_Write_Data;--
--    decode_write_register <= wb_Write_Reg;--

    decode_pc_update <= fetch_pc_update;

    -- map fetch input
    --fetch_bj_target_address <= execution_adder_out;


    --fetch_bj_target_address <= "00000000000000000000000000000000";

    --fetch_branch_taken <= '0';
    --fetch_hazard <= '0';
  end if;
end process;
fetch_pc_stall <= decode_stall;
--fetch_branch_taken <= execution_branch_taken;
fetch_hazard <= decode_hazard;
fetch_branch_taken <= execution_branch_taken;
decode_write_data <= wb_Write_Data;--
decode_write_register <= wb_Write_Reg;--
decode_HI_data <= execution_hi;
decode_LO_data <= execution_lo;
execution_WB_out <= wb_Write_Data;
execution_MEM_out <= dm_ALU_out;
fetch_bj_target_address <= execution_adder_out;

--************** end of pipeline ********************

--************** start of forwarding ****************
execution_mux1_select <= "10" when (dm_EXMEM_WB = '1' and dm_EXMEM_register /= "00000" and dm_EXMEM_register = execution_IDEX_Rs_register) else
                         "01" when (wb_MEMWB_WB = '1' and wb_MEMWB_register /= "00000" and dm_EXMEM_register /= execution_IDEX_Rs_register and wb_MEMWB_register = execution_IDEX_Rs_register) else
                         "00";

execution_mux2_select <= "10" when (dm_EXMEM_WB = '1' and dm_EXMEM_register /= "00000" and dm_EXMEM_register = execution_IDEX_Rt_register) else
                         "01" when (wb_MEMWB_WB = '1' and wb_MEMWB_register /= "00000" and dm_EXMEM_register /= execution_IDEX_Rt_register and wb_MEMWB_register = execution_IDEX_Rt_register) else
                         "00";
--************** end of forwarding

--************* hazard detection ***********************
-- no need, handled in decode
--************* end of hazard detection ****************

-- debug --
debug_boolean_1 <= dm_EXMEM_M;
debug_vector_1(1 downto 0) <= execution_mux1_select;
debug_vector_2 <= decode_instruction;
debug_vector_3 <= dm_ALU_out;
debug_vector_4 <= dm_Write_data;

end structure;

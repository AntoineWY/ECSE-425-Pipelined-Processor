LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Execution_tb IS
END Execution_tb;

ARCHITECTURE behaviour OF Execution_tb IS

--Declare the component that you are testing:
    COMPONENT Execution IS

    port(
        clk:                in std_logic;
        -- relayed from ID
        pc_input:           in std_logic_vector(31 downto 0);
        ALU_op:             in std_logic_vector(4 downto 0);
        -- sign extended instruction
        instruction_input:  in std_logic_vector(31 downto 0);
        -- input from register file
        readdata1:          in std_logic_vector(31 downto 0);
        readdata2:          in std_logic_vector(31 downto 0);
        -- inputs from forwading unit
        mux1_select:        in std_logic_vector(1 downto 0);
        mux2_select:        in std_logic_vector(1 downto 0);
        -- inputs from other stages by forwarding
        WB_out:             in std_logic_vector(31 downto 0); -- mux1_in2 & mux2_in3
        MEM_out:            in std_logic_vector(31 downto 0); -- mux1_in3 & mux2_in2
        -- inputs from ID stage
        IDEX_WB_register:   in std_logic_vector(4 downto 0);
        IDEX_Rs_register:   inout std_logic_vector(4 downto 0);
        IDEX_Rt_register:   inout std_logic_vector(4 downto 0);
        -- intput from control blocks
        IDEX_EX:            in std_logic; -- check if alu is needed
        IDEX_M:             in std_logic; -- simple bypass
        IDEX_WB:            in std_logic; -- simple bypass
        -- output to writedata in MEM
        data_to_mem:        out std_logic_vector(31 downto 0);
        -- output to MEM stage  
        EXMEM_WB_register:  out std_logic_vector(4 downto 0);
        -- output to control blocks
        EXMEM_WB:           out std_logic;
        EXMEM_M:            out std_logic;
        -- back to mux_in in Fetch stage
        branch_taken:       out std_logic;
        -- back to decode stage
        hi:                 out std_logic_vector(31 downto 0);
        lo:                 out std_logic_vector(31 downto 0);
        -- main output
        ALU_out:            out std_logic_vector(31 downto 0);
        adder_out:          out std_logic_vector(31 downto 0)
    );
            
    END COMPONENT;

    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal dummy_vector: std_logic_vector(31 downto 0);
    signal dummy_logic: std_logic := '0';

    signal pc_input: std_logic_vector(31 downto 0);   
    signal ALU_op: std_logic_vector(4 downto 0); 
    signal instruction_input: std_logic_vector(31 downto 0); 
    signal readdata1: std_logic_vector(31 downto 0); 
    signal readdata2: std_logic_vector(31 downto 0); 
    signal mux1_select: std_logic_vector(1 downto 0); 
    signal mux2_select: std_logic_vector(1 downto 0); 
    signal WB_out: std_logic_vector(31 downto 0); 
    signal MEM_out: std_logic_vector(31 downto 0);
    signal IDEX_Rt_register: std_logic_vector(4 downto 0);
    signal IDEX_Rs_register: std_logic_vector(4 downto 0);  
    signal IDEX_WB_register: std_logic_vector(4 downto 0);
    signal IDEX_EX: std_logic;
    signal IDEX_M: std_logic;
    signal IDEX_WB: std_logic;
    signal data_to_mem: std_logic_vector(31 downto 0);
    signal EXMEM_WB_register: std_logic_vector(4 downto 0);
    signal EXMEM_WB: std_logic;
    signal EXMEM_M: std_logic;
    signal branch_taken: std_logic;
    signal hi: std_logic_vector(31 downto 0);
    signal lo: std_logic_vector(31 downto 0);
    signal ALU_out: std_logic_vector(31 downto 0);
    signal adder_out: std_logic_vector(31 downto 0);

BEGIN

    --dut => Device Under Test
    dut: Execution port MAP(
        clk => clk,
        --clk_period => clk_period,
        pc_input => pc_input,
        ALU_op => ALU_op,
        instruction_input => instruction_input,
        readdata1 => readdata1,
        readdata2 => readdata2,
        mux1_select => "00",
        mux2_select => "00",
        WB_out => WB_out,
        MEM_out => MEM_out,
        IDEX_Rt_register => IDEX_Rt_register,
        IDEX_Rs_register => IDEX_Rs_register,
        IDEX_WB_register => IDEX_WB_register,
        IDEX_EX => IDEX_EX,
        IDEX_M => IDEX_M,
        IDEX_WB => IDEX_WB,
        data_to_mem => data_to_mem,
        EXMEM_WB_register => EXMEM_WB_register,
        EXMEM_WB => EXMEM_WB,
        EXMEM_M => EXMEM_M,
        branch_taken => branch_taken,
        hi => hi,
        lo => lo,
        ALU_out => ALU_out,
        adder_out => adder_out

    );

    clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
        ALU_op <= "00000"; -- add
        readdata1 <= "00000000000000000000000000000010";
        readdata2 <= "00000000000000000000000000000001";
        wait for clk_period;
        ALU_op <= "00001"; -- sub
        readdata1 <= "00000000000000000000000000000100";
        readdata2 <= "00000000000000000000000000000001";
        wait for clk_period;
        ALU_op <= "00011"; -- mult
        readdata1 <= "00000000000000000000000000000100";
        readdata2 <= "00000000000000000000000000000010";
        wait for clk_period;
        ALU_op <= "00100"; -- div
        readdata1 <= "00000000000000000000000000001000";
        readdata2 <= "00000000000000000000000000000010";
        wait for clk_period;
        ALU_op <= "10110"; -- beq
        readdata1 <= "00000000000000000000000000001001";
        readdata2 <= "00000000000000000000000000001000";
        pc_input <= x"00000004";
        instruction_input <= x"00000001";
        --wait for clk_period;
        --ALU_op <= "10110"; -- beq
        --readdata1 <= "00000000000000000000000000001001";
       -- readdata2 <= "00000000000000000000000000001000";
        --pc_input <= x"00000008";
        --instruction_input <= x"00000001";
        wait for clk_period;
        ALU_op <= "10111"; -- bne
        readdata1 <= "00000000000000000000000000001000";
        readdata2 <= "00000000000000000000000000000010";

        wait;

    END PROCESS;

END;
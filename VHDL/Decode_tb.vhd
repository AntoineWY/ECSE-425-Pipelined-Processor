LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Decode_tb IS
END Decode_tb;

ARCHITECTURE behaviour OF Decode_tb IS

--Declare the component that you are testing:
    COMPONENT Decode IS

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
                r_data_1: out std_logic_vector(31 downto 0);
                r_data_2: out std_logic_vector(31 downto 0);
            
                -- opcode for execution
                ALU_op: out std_logic_vector(4 downto 0);
            
                -- operation flag
                --JUMP:     out std_logic;
                --JUMP_ADDRESS: out std_logic_vector(31 downto 0);  -- the sign extend address
                IDEX_WB:   out std_logic;
                IDEX_M:    out std_logic;
                IDEX_EX:   out std_logic;
                SIGN_EXTEND: out std_logic_vector(31 downto 0);
            
                -- forwarding
                IDEXRs_forwarding: out std_logic_vector(4 downto 0);
                --IFIDRt: out std_logic_vector(4 downto 0);
                IDEXRt_forwarding: out std_logic_vector(4 downto 0);
                --IFIDRd: out std_logic_vector(4 downto 0);
                IDEX_WB_register: out std_logic_vector(4 downto 0);
                -- stall
                BRANCH: out std_logic; -- if there is a stall, always stall for 3 cc
                JUMP:     out std_logic);
            
    END COMPONENT;

    signal clk:  std_logic;
    signal instruction:  std_logic_vector(31 downto 0);  
    signal write_data: std_logic_vector(31 downto 0);
    signal write_register: std_logic_vector(4 downto 0);

    signal HI_data, LO_data : std_logic_vector(31 downto 0);
    
    signal pc_update: std_logic_vector(31 downto 0); 

    signal r_data_1: std_logic_vector(31 downto 0);
    signal r_data_2: std_logic_vector(31 downto 0);

    signal ALU_op: std_logic_vector(4 downto 0);

    signal IDEX_WB:   std_logic;
    signal IDEX_M:    std_logic;
    signal IDEX_EX:   std_logic;
    signal SIGN_EXTEND: std_logic_vector(31 downto 0);

    signal IDEXRs_forwarding: std_logic_vector(4 downto 0);
    signal IDEXRt_forwarding: std_logic_vector(4 downto 0);
    
    signal IDEX_WB_register: std_logic_vector(4 downto 0);
    signal BRANCH:  std_logic; 
    signal JUMP:    std_logic;

    constant clk_period : time := 10 ns;


BEGIN

    --dut => Device Under Test
    dut: Decode port MAP(
        clk =>clk,
        instruction => instruction,
        write_data => write_data,
        write_register => write_register,
        HI_data=> HI_data,
        LO_data => LO_data,

        pc_update =>pc_update,
        r_data_1 => r_data_1,
        r_data_2 => r_data_2,
        ALU_op => ALU_op,
        IDEX_WB=> IDEX_WB,
        IDEX_M => IDEX_M,

        IDEX_EX =>IDEX_EX,
        SIGN_EXTEND => SIGN_EXTEND,
        IDEXRs_forwarding => IDEXRs_forwarding,
        IDEXRt_forwarding => IDEXRt_forwarding,
        IDEX_WB_register=> IDEX_WB_register,
        BRANCH => BRANCH,
        JUMP => JUMP
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
     
        -- case 1 : add
        --add rs =1, rt=2, rd=3
        instruction <="00000000001000100001100000100000";

        wait for clk_period*1;

        -- case 2 : substract
        --add rs =4, rt=5, rd=6
        instruction <="00000000100001010011000000100010";
        --wait for clk_period*10;


        wait;

    END PROCESS;

 
END;
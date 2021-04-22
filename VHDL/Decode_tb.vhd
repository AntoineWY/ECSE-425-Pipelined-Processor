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
                pc_update: in std_logic_vector(31 downto 0); --pc+4

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
                pc_update_to_ex: out std_logic_vector (31 downto 0);
                -- stall
                stall: out std_logic;
                hazard: out std_logic;
                reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
                reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
                reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
                reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)

                );

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
    signal stall:  std_logic;
    signal hazard: std_logic;
    signal pc_update_to_ex: std_logic_vector (31 downto 0);

    signal reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: std_logic_vector(31 downto 0);
    signal reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: std_logic_vector(31 downto 0);
    signal reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: std_logic_vector(31 downto 0);
    signal reg_27, reg_28, reg_29, reg_30, reg_31: std_logic_vector(31 downto 0);

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
        stall => stall,
        hazard => hazard,
        pc_update_to_ex => pc_update_to_ex,

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

    clk_process : process
    BEGIN
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
        pc_update <= "00000000000000000000000000000000";
        -- add
        instruction <="00000000001000100001100000100000";
        wait for clk_period*1;
        -- test for write back
        write_register <= "10000";
        write_data <= "00000000000000000000000000100000";
        -- subtract
        instruction <="00000000100001010011000000100010";
        -- addi
        wait for clk_period*1;
        instruction <= "00100000001000100000000000001010";
        --mul
        wait for clk_period*1;
        instruction <= "00000000011001000000000000011000";
        -- divide
        wait for clk_period*1;
        instruction <= "00000000101001100000000000011010";
        -- set less than
        wait for clk_period*1;
        instruction <= "00000000111010000100100000101010";
        -- set less than immediate
        wait for clk_period*1;
        instruction <= "00101001010010110000000000000101";
        -- and
        wait for clk_period*1;
        instruction <= "00000001100011010111000000100100";
        -- or
        wait for clk_period*1;
        instruction <= "00000001111100001000100000100101";
        -- nor
        wait for clk_period*1;
        instruction <= "00000010010100111010000000100111";
        -- xor
        wait for clk_period*1;
        instruction <= "00000010101101101011100000100110";
        --and immediate
        wait for clk_period*1;
        instruction <= "00110011000110010000000000000111";
        -- or immediate
        wait for clk_period*1;
        instruction <= "00110111010110110000000000011111";
        -- xor immediate
        wait for clk_period*1;
        instruction <= "00111011100111010000000000001111";

        wait for clk_period*1;
        -- move from hi
          instruction <= "00000000000000001000000000010000";
          wait for clk_period*1;
        --move from low
          instruction <= "00000000000000000100000000010010";
          wait for clk_period*1;
        -- load upper immediate
          instruction <= "00111100010000111010101010101010";
          wait for clk_period*1;
        -- shift left logical
          instruction <= "00000000010000110010000001000000";
          wait for clk_period*1;
        -- shift right logical
          instruction <= "00000000010000110010000001000010";
          wait for clk_period*1;
        -- shift right arithmetic
          instruction <= "00000000000000110010000001000010";
          wait for clk_period*1;
        -- load word
          instruction <= "10001100010000111010101010101010";
          wait for clk_period*1;
        -- store word
          instruction <= "10101100010000111010101010101010";
          wait for clk_period*1;
        -- branch on equal
          instruction <= "00010000010000111010101010101010";
          wait for clk_period*1;
        -- branch on not equal
          instruction <= "00010100010000111010101010101010";
          wait for clk_period*1;
        -- JUMP
          instruction <= "00001010101010101010101010101010";
          wait for clk_period*1;
        -- jump registers
          instruction <= "00000000010000000000000000001000";
          wait for clk_period*1;
        -- jump and link
          instruction <= "00001110101010101010101010101010";
        wait;

    END PROCESS;


END;

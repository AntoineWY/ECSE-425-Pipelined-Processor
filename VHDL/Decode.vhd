library ieee;
use ieee.std_logic_1164;
use ieee.numeric_std.all;

entity Decode is

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
    JUMP_ADDRESS: out std_logic_vector(31 downto 0);  -- the sign extend address
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
    JUMP:     out std_logic

  );
end Decode;

architecture implementation of Decode is

  type register_structure is array (31 downto 0) of std_logic_vector (31 downto 0);
  signal registers: register_structure;
  registers(0) <= "00000000000000000000000000000000";
  signal HI_reg, LO_reg : std_logic_vector(31 downto 0);
  signal four : unsigned(31 downto 0);
  four <= "00000000000000000000000000000100"
  signal opcode : std_logic_vector(5 downto 0);
  signal Rs, Rt, Rd : std_logic_vector(4 downto 0);
  signal shamt  : std_logic_vector(4 downto 0);
  signal funct  : std_logic_vector(5 downto 0);
  signal immediate  : std_logic_vector(15 downto 0);
  signal address  : std_logic_vector(25 downto 0);

begin

  decode_operation: process (clk)
  begin
    if (clk'event and rising_edge(clk)) then
      JUMP <= '0';
      opcode <= instruction(31 downto 26);
      --IDEX_WB_register <= Rd;
      BRANCH <= '0';
      IDEX_M <= '0';
      IDEX_EX <= '1';
      IDEX_WB <= '1';

      --funct <= instruction(5 downto 0);
      case opcode is
        -- R type instruction
        when "000000" =>  -- R type instruction
          funct <= instruction(5 downto 0);
          shamt <= instruction(10 downto 6);
          Rs <= instruction(25 downto 21);
          Rt <= instruction(20 downto 16);
          Rd <= instruction(15 downto 11);
          IDEXRs_forwarding <= Rs;
          IDEXRt_forwarding <= Rt;
          r_data_1 <= registers(to_integer(unsigned(Rs)));
          r_data_2 <= registers(to_integer(unsigned(Rt)));
          IDEX_WB_register <= Rd;
          --IDEX_WB <= '1';
          --IDEX_EX <= '1';
          --r_data_1 <= registers(to_integer(unsigned()));
          --r_data_2 <=
          case funct is
            when "100000" =>  -- 20 add 0
              ALU_op <= "00000";
            when "100010" =>  -- 22 subtract 1
              ALU_op <= "00001";
            when "011000" => --18 multiply 3
              ALU_op <= "00011";
              IDEX_WB <= '0';
            when "011010" => --1a divide 4
              ALU_op <= "00100";
              IDEX_WB <= '0';
            when "101010" =>  --2a set less than 5
              ALU_op <= "00101";
            when "100100" =>  --24  and 7
              ALU_op <= "00111";
            when "100101" =>  --25  or 8
              ALU_op <= "01000";
            when "100111" =>  --27  nor 9
              ALU_op <= "01001";
            when "100110" =>  --26  xor 10
              ALU_op <= "01010";
            when "010000" =>  --10  move from HI 14
              ALU_op <= "01110";
              registers(to_integer(unsigned(Rd))) <= HI_reg;
              IDEX_WB <= '0';
              IDEX_EX <= '0';
            when "010010" =>  --12  move from LO 15
              ALU_op <= "01111";
              registers(to_integer(unsigned(Rd))) <= LO_reg;
              IDEX_WB <= '0';
              IDEX_EX <= '0';
            when "000000" =>  --00  shift left logical 17
              ALU_op <= "10001";
              r_data_1 <= "000000000000000000000000000"&shamt;
              IDEXRs_forwarding <= "00000";
            when "000010" =>  --02  shift right logical 18
              ALU_op <= "10010";
              r_data_1 <= "000000000000000000000000000"&shamt;
              IDEXRs_forwarding <= "00000";
            when "000011" =>  --03  shift right arithmetic 19
              ALU_op <= "10011";
              r_data_1 <= "000000000000000000000000000"&shamt;
              IDEXRs_forwarding <= "00000";
            when "001000" =>  --08 jump register 25
              ALU_op <= "11001";
              JUMP <= '1';
              --JUMP_ADDRESS <= r_data_1;
              IDEX_WB <= '0';
              IDEX_EX <= '0';
          end case;

        -- two jumps -----------------------------------------------------------
        when "000010" =>
          ALU_op <= "11000"; -- jump -j 24
          IDEXRs_forwarding <= "00000";
          IDEXRt_forwarding <= "00000";
          IDEX_WB <= '0';
          IDEX_M <= '0';
          IDEX_EX <= '0';
          JUMP <= '1';
          r_data_1 <= pc_update(31 downto 28)&instruction(25 downto 0)&"00";

        when "000011" =>
          ALU_op <= "11010"; -- jump and link -j 26
          IDEXRs_forwarding <= "00000";
          IDEXRt_forwarding <= "00000";
          IDEX_WB <= '0';
          IDEX_M <= '0';
          IDEX_EX <= '0';
          JUMP <= '1';
          r_data_1 <= pc_update(31 downto 28)&instruction(25 downto 0)&"00";
          registers(31) <= std_logic_vector(unsigned(pc_update)+four);

        -- I type instructions --------------------------------------------------
        when others =>
          Rs <= instruction(25 downto 21);
          Rt <= instruction(20 downto 16);
          immediate <= instruction(15 downto 0);
          IDEX_WB_register <= Rt;
          r_data_1 <= registers(to_integer(unsigned(Rs)));
          IDEXRs_forwarding <= Rs;
          IDEXRt_forwarding <= "00000"
          --IDEXRt_forwarding <= Rt;
          case opcode is
            when "001000" =>
              ALU_op <= "00010"; -- addi 2
              if (immediate(15)='1') then
                r_data_2 <= "1111111111111111"&immediate;
              else
                r_data_2 <= "0000000000000000"&immediate;
              end if;
            when "001010" =>
              ALU_op <= "00110"; -- slti 6
              if (immediate(15)='1') then
                r_data_2 <= "1111111111111111"&immediate;
              else
                r_data_2 <= "0000000000000000"&immediate;
              end if;
            when "001000" =>
              ALU_op <= "01011"; -- andi 11
              r_data_2 <= "0000000000000000"&immediate;
            when "001101" =>
              ALU_op <= "01100"; -- ori 12
              r_data_2 <= "0000000000000000"&immediate;
            when "001110" =>
              ALU_op <= "01101"; -- xori 13
              r_data_2 <= "0000000000000000"&immediate;
            when "001111" =>
              ALU_op <= "10000"; -- lui 16
              IDEXRs_forwarding <= "00000";
              registers(to_integer(unsigned(Rt))) <= immediate&"0000000000000000";
            when "100011" =>
              ALU_op <= "10100"; -- lw 20
              IDEX_M <= '1';
              if (immediate(15)='1') then
                r_data_2 <= "1111111111111111"&immediate;
              else
                r_data_2 <= "0000000000000000"&immediate;
              end if;
            when "101011" =>
              ALU_op <= "10101"; -- sw 21
              IDEX_M <= '1';
              IDEX_WB <= '0';
              IDEXRt_forwarding <= Rt;
              r_data_2 <= registers(to_integer(unsigned(Rt)));
              if (immediate(15)='1') then
                SIGN_EXTEND <= "1111111111111111"&immediate;
              else
                SIGN_EXTEND <= "0000000000000000"&immediate;
              end if;
            when "000100" =>
              ALU_op <= "10110"; -- beq 22
              IDEX_WB <= '0';
              IDEXRt_forwarding <= Rt;
              BRANCH <= '1';
              r_data_2 <= registers(to_integer(unsigned(Rt)));
              if (immediate(15)='1') then
                SIGN_EXTEND <= "1111111111111111"&immediate;
              else
                SIGN_EXTEND <= "0000000000000000"&immediate;
              end if;
            when "000101" =>
              ALU_op <= "10111"; -- bne 23
              IDEX_WB <= '0';
              IDEXRt_forwarding <= Rt;
              BRANCH <= '1';
              r_data_2 <= registers(to_integer(unsigned(Rt)));
              if (immediate(15)='1') then
                SIGN_EXTEND <= "1111111111111111"&immediate;
              else
                SIGN_EXTEND <= "0000000000000000"&immediate;
              end if;
          end case;

      end case;

    end if;

  end process;


  -- this is for write back
  write_back: process(clk)
  begin
    if (clk'event and rising_edge(clk)) then
      if (write_register = "00000") then
        registers(0) <= "00000000000000000000000000000000";
      else
        registers(to_integer(unsigned(write_register))) <= write_data;
      end if;
      HI_reg <= HI_data;
      LO_reg <= LO_data;
    end if;
    --write_data: in std_logic_vector(31 downto 0);
    --write_register: in std_logic_vector(4 downto 0);
    --HI_data, LO_data : in std_logic_vector(31 downto 0);
    -- extend pc? (pc_update is already extended)
  end process;

end implementation;

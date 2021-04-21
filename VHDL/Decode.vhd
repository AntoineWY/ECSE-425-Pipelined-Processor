library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Decode is

  port(

    clk: in std_logic;
    instruction: in std_logic_vector(31 downto 0);  -- opcode,rs, rt, rd, shift, funct  --opcode, rs, rt, immediate --
    -- from WB
    write_data: in std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- write back data from WB stage
    write_register: in std_logic_vector(4 downto 0) := "00000";     -- write back register from WB stage

    HI_data, LO_data : in std_logic_vector(31 downto 0);  -- HI and LO from execution (mult and div)
    -- relay
    pc_update: in std_logic_vector(31 downto 0); --pc+4 -- next pc value from instruction fectch stage

    -- output data to execution
    r_data_1: out std_logic_vector(31 downto 0); --done
    r_data_2: out std_logic_vector(31 downto 0);  -- done

    -- opcode for execution
    ALU_op: out std_logic_vector(4 downto 0); --done

    -- operation flag
    --JUMP:     out std_logic;
    --JUMP_ADDRESS: out std_logic_vector(31 downto 0);  -- the sign extend address
    IDEX_WB:   out std_logic; --done -- write back flag
    IDEX_M:    out std_logic; -- done -- memory access flag
    IDEX_EX:   out std_logic; -- done --execution flag
    SIGN_EXTEND: out std_logic_vector(31 downto 0); --done --sign extend

    -- forwarding
    IDEXRs_forwarding: out std_logic_vector(4 downto 0);  --done --Rs register forwarding
    IDEXRt_forwarding: out std_logic_vector(4 downto 0); -- Rt register forwarding
    IDEX_WB_register: out std_logic_vector(4 downto 0); --done -- write back register to next stage (execution)
    pc_update_to_ex: out std_logic_vector (31 downto 0); -- pc update extend to next stage (execution)


    stall: out std_logic; -- stall flag
    hazard: out std_logic; -- hazard flag

    -- debug registers
    reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
    reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
    reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
    reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)
  );
end Decode;

architecture implementation of Decode is

  type register_structure is array (0 to 31) of std_logic_vector (31 downto 0); -- register array, initialize to 0
  signal registers: register_structure :=(
  0 => "00000000000000000000000000000000",
  1 =>"00000000000000000000000000000000",
  2 =>"00000000000000000000000000000000",
  3 =>"00000000000000000000000000000000",
  4 =>"00000000000000000000000000000000",
  5 =>"00000000000000000000000000000000",
  others => (others =>'0'));

  signal HI_reg, LO_reg : std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- HI and LO register, initialized to 0
  signal four : unsigned(31 downto 0) := "00000000000000000000000000000100"; -- four
  signal opcode : std_logic_vector(5 downto 0); -- opcode
  signal Rs, Rt, Rd : std_logic_vector(4 downto 0); -- input registers from instruction
  signal shamt  : std_logic_vector(4 downto 0); -- shamt
  signal funct  : std_logic_vector(5 downto 0); -- funct
  signal immediate  : std_logic_vector(15 downto 0); -- immediate value
  signal address  : std_logic_vector(25 downto 0); -- J type, address


begin
  pc_update_to_ex <= pc_update;
  funct <= instruction(5 downto 0);
  shamt <= instruction(10 downto 6);
  Rs <= instruction(25 downto 21);
  Rt <= instruction(20 downto 16);
  Rd <= instruction(15 downto 11);
  opcode <= instruction(31 downto 26);
  immediate <= instruction(15 downto 0);

-- need to stall for branch and jump, need to stall 2 cycles
  stall <= '1'
          --  beq, bne, jump, jump register, jump and link
          when (opcode = "000100" or opcode = "000101" or opcode = "000010" or (opcode = "000000" and funct = "001000") or opcode = "100011") else
          '0';

-- hazard for load, need to stall 3 cycles
 hazard <= '1'
            -- load
            when (opcode = "100011" ) else
            '0';

-- read data 1 to execution stage
  r_data_1 <= registers(to_integer(unsigned(Rs))) -- add
              when (opcode = "000000" and funct = "100000" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- subtract
              when (opcode = "000000" and funct = "100010" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- multiply
              when (opcode = "000000" and funct = "011000" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- divide
              when (opcode = "000000" and funct = "011010" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- set less than
              when (opcode = "000000" and funct = "101010" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- and
              when (opcode = "000000" and funct = "100100" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- or
              when (opcode = "000000" and funct = "100101" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- nor
              when (opcode = "000000" and funct = "100111" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) --xor
              when (opcode = "000000" and funct = "100110" and Rs /= "00000") else
              "00000000000000000000000000000000" -- move from HI
              when (opcode = "000000" and funct = "010000") else--10
              "00000000000000000000000000000000" --move from lO
              when (opcode = "000000" and funct = "010010") else--11
              "000000000000000000000000000"&shamt -- shift left logical
              when (opcode = "000000" and funct = "000000") else
              "000000000000000000000000000"&shamt --shift right logical
              when (opcode = "000000" and funct = "000010") else
              "000000000000000000000000000"&shamt -- shift right arithmetic
              when (opcode = "000000" and funct = "000011") else
              registers(to_integer(unsigned(Rs))) -- jump register
              when (opcode = "000000" and funct = "001000" and Rs /= "00000") else---- last R type-------
              pc_update(31 downto 28)&instruction(25 downto 0)&"00" -- jump
              when (opcode = "000010" ) else
              pc_update(31 downto 28)&instruction(25 downto 0)&"00" -- jump and link
              when (opcode = "000011" ) else------ last J type ---------
              registers(to_integer(unsigned(Rs))) -- addi
              when (opcode = "001000" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) --slti
              when (opcode = "001010" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) --andi
              when (opcode = "001100" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) --ori
              when (opcode = "001101" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) --xori
              when (opcode = "001110" and Rs /= "00000") else
              "00000000000000000000000000000000" --lui
              when (opcode = "001111" ) else
              registers(to_integer(unsigned(Rs))) --lw
              when (opcode = "100011" and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- sw
              when (opcode = "101011"  and Rs /= "00000") else
              registers(to_integer(unsigned(Rs))) -- beq
              when (opcode = "000100"  and Rs /= "00000") else------------------------
              registers(to_integer(unsigned(Rs))) -- bne
              when (opcode = "000101"  and Rs /= "00000") else
              "00000000000000000000000000000000"; -- for the cases that access register 0, just return 0s

-- read data 2 to execution stage
r_data_2 <= registers(to_integer(unsigned(Rt)))-- add
            when (opcode = "000000" and funct = "100000" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- subtract
            when (opcode = "000000" and funct = "100010" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- multiply
            when (opcode = "000000" and funct = "011000" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- divide
            when (opcode = "000000" and funct = "011010" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- set less than
            when (opcode = "000000" and funct = "101010" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- and
            when (opcode = "000000" and funct = "100100" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- or
            when (opcode = "000000" and funct = "100101" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- nor
            when (opcode = "000000" and funct = "100111" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))--xor
            when (opcode = "000000" and funct = "100110" and Rt /= "00000") else
            "00000000000000000000000000000000"-- move from HI
            when (opcode = "000000" and funct = "010000") else--10
            "00000000000000000000000000000000"--move from lO
            when (opcode = "000000" and funct = "010010") else--11
            registers(to_integer(unsigned(Rt)))-- shift left logical
            when (opcode = "000000" and funct = "000000" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))--shift right logical
            when (opcode = "000000" and funct = "000010" and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- shift right arithmetic
            when (opcode = "000000" and funct = "000011" and Rt /= "00000") else
            "00000000000000000000000000000000"-- jump register
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000000000000000000000000000000"-- jump
            when (opcode = "000010" ) else
            "00000000000000000000000000000000"-- jump and link
            when (opcode = "000011" ) else------ last J type
            "1111111111111111"&immediate-- addi
            when (opcode = "001000" and immediate(15)='1') else--sign extend
            "0000000000000000"&immediate-- addi
            when (opcode = "001000" and immediate(15)='0') else--sign extend
            "1111111111111111"&immediate--slti
            when (opcode = "001010" and immediate(15)='1') else--need sign extend
            "0000000000000000"&immediate--slti
            when (opcode = "001010" and immediate(15)='0') else--need sign extend
            "0000000000000000"&immediate--andi
            when (opcode = "001100" ) else
            "0000000000000000"&immediate--ori
            when (opcode = "001101" ) else
            "0000000000000000"&immediate--xori
            when (opcode = "001110" ) else
            "00000000000000000000000000000000"--lui
            when (opcode = "001111" ) else
            "1111111111111111"&immediate--lw
            when (opcode = "100011" and immediate(15)='1') else--need sign extend
            "0000000000000000"&immediate--lw
            when (opcode = "100011" and immediate(15)='0') else--need sign extend
            registers(to_integer(unsigned(Rt)))-- sw
            when (opcode = "101011"  and Rt /= "00000") else
            registers(to_integer(unsigned(Rt)))-- beq
            when (opcode = "000100"  and Rt /= "00000") else------------------------
            registers(to_integer(unsigned(Rt)))-- bne
            when (opcode = "000101"  and Rt /= "00000")else
            "00000000000000000000000000000000";-- for the cases that access register 0, just return 0s

-- translate opcode for ALU
ALU_op <=   "00000"-- add 0
            when (opcode = "000000" and funct = "100000") else
            "00001"-- subtract 1
            when (opcode = "000000" and funct = "100010") else
            "00011"-- multiply 3
            when (opcode = "000000" and funct = "011000") else
            "00100"-- divide 4
            when (opcode = "000000" and funct = "011010") else
            "00101"-- set less than 5
            when (opcode = "000000" and funct = "101010") else
            "00111"-- and 7
            when (opcode = "000000" and funct = "100100") else
            "01000"-- or 8
            when (opcode = "000000" and funct = "100101") else
            "01001"-- nor 9
            when (opcode = "000000" and funct = "100111") else
            "01010"--xor 10
            when (opcode = "000000" and funct = "100110") else
            "01110"-- move from HI 14
            when (opcode = "000000" and funct = "010000") else--10
            "01111"--move from lO 15
            when (opcode = "000000" and funct = "010010") else--11
            "10001"-- shift left logical 17
            when (opcode = "000000" and funct = "000000") else
            "10010"--shift right logical 18
            when (opcode = "000000" and funct = "000010") else
            "10011"-- shift right arithmetic 19
            when (opcode = "000000" and funct = "000011") else
            "11001"-- jump register 25
            when (opcode = "000000" and funct = "001000") else---- last R type
            "11000"-- jump 24
            when (opcode = "000010" ) else
            "11010"-- jump and link 26
            when (opcode = "000011" ) else------ last J type
            "00010"-- addi 2
            when (opcode = "001000") else
            "00110"--slti 6
            when (opcode = "001010") else
            "01011"--andi 11
            when (opcode = "001100" ) else
            "01100"--ori 12
            when (opcode = "001101" ) else
            "01101"--xori 13
            when (opcode = "001110" ) else
            "10000"--lui 16
            when (opcode = "001111" ) else
            "10100"--lw 20
            when (opcode = "100011") else
            "10101"-- sw 21
            when (opcode = "101011" ) else
            "10110"-- beq 22
            when (opcode = "000100" ) else
            "10111"-- bne 23
            when (opcode = "000101" );

-- write back flag
IDEX_WB <=  '1' -- add
            when (opcode = "000000" and funct = "100000") else
            '1'-- subtract
            when (opcode = "000000" and funct = "100010") else
            '0'-- multiply
            when (opcode = "000000" and funct = "011000") else
            '0'-- divide
            when (opcode = "000000" and funct = "011010") else
            '1'-- set less than
            when (opcode = "000000" and funct = "101010") else
            '1'-- and
            when (opcode = "000000" and funct = "100100") else
            '1'-- or
            when (opcode = "000000" and funct = "100101") else
            '1'-- nor
            when (opcode = "000000" and funct = "100111") else
            '1'--xor
            when (opcode = "000000" and funct = "100110") else
            '0'-- move from HI
            when (opcode = "000000" and funct = "010000") else--10
            '0'--move from lO
            when (opcode = "000000" and funct = "010010") else--11
            '1'-- shift left logical
            when (opcode = "000000" and funct = "000000") else
            '1'--shift right logical
            when (opcode = "000000" and funct = "000010") else
            '1'-- shift right arithmetic
            when (opcode = "000000" and funct = "000011") else
            '0'-- jump register
            when (opcode = "000000" and funct = "001000") else---- last R type
            '0'-- jump
            when (opcode = "000010" ) else
            '0'-- jump and link
            when (opcode = "000011" ) else------ last J type
            '1'-- addi
            when (opcode = "001000") else--sign extend
            '1'--slti
            when (opcode = "001010") else--need sign extend
            '1'--andi
            when (opcode = "001100" ) else
            '1'--ori
            when (opcode = "001101" ) else
            '1'--xori
            when (opcode = "001110" ) else
            '1'--lui
            when (opcode = "001111" ) else
            '1'--lw
            when (opcode = "100011") else--need sign extend
            '0'-- sw
            when (opcode = "101011" ) else
            '0'-- beq 22
            when (opcode = "000100" ) else------------------------
            '0'-- bne
            when (opcode = "000101" );

-- memory access flag, 1 for load and store
IDEX_M <=   '1' --lw
            when (opcode = "100011") else
            '1' --sw
            when (opcode = "101011" ) else
            '0';

-- execution stage flag, to know if execution stage need to implement any thing
IDEX_EX <=  '0' -- move from HI
            when (opcode = "000000" and funct = "010000") else--10
            '0' -- move from LO
            when (opcode = "000000" and funct = "010010") else--11
            '1';

-- sign extend (extend from 16 bits to 32 bits)
SIGN_EXTEND <=  "1111111111111111"&immediate --sw
                when (opcode = "101011" and immediate(15) = '1') else
                "0000000000000000"&immediate
                when (opcode = "101011" and immediate(15) = '0') else
                "1111111111111111"&immediate
                when (opcode = "000100" and immediate(15) = '1') else------------------------
                "0000000000000000"&immediate --beq
                when (opcode = "000100" and immediate(15) = '0') else------------------------
                "1111111111111111"&immediate
                when (opcode = "000101" and immediate(15) = '1')else
                "0000000000000000"&immediate --bne
                when (opcode = "000101" and immediate(15) = '0')else
                "00000000000000000000000000000000";

-- determine which register to write back, and forward to the next stage (execution)
IDEX_WB_register <= Rd -- add
            when (opcode = "000000" and funct = "100000") else
            Rd -- subtract
            when (opcode = "000000" and funct = "100010") else
            "00000" -- multiply
            when (opcode = "000000" and funct = "011000") else
            "00000" -- divide
            when (opcode = "000000" and funct = "011010") else
            Rd -- set less than
            when (opcode = "000000" and funct = "101010") else
            Rd -- and
            when (opcode = "000000" and funct = "100100") else
            Rd -- or
            when (opcode = "000000" and funct = "100101") else
            Rd -- nor
            when (opcode = "000000" and funct = "100111") else
            Rd --xor
            when (opcode = "000000" and funct = "100110") else
            "00000" -- move from HI
            when (opcode = "000000" and funct = "010000") else--10
            "00000" --move from lO
            when (opcode = "000000" and funct = "010010") else--11
            Rd -- shift left logical
            when (opcode = "000000" and funct = "000000") else
            Rd --shift right logical
            when (opcode = "000000" and funct = "000010") else
            Rd -- shift right arithmetic
            when (opcode = "000000" and funct = "000011") else
            "00000" -- jump register
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000" -- jump
            when (opcode = "000010" ) else
            "00000" -- jump and link
            when (opcode = "000011" ) else------ last J type
            Rt -- addi
            when (opcode = "001000") else--sign extend
            Rt --slti
            when (opcode = "001010") else--need sign extend
            Rt --andi
            when (opcode = "001100" ) else
            Rt --ori
            when (opcode = "001101" ) else
            Rt --xori
            when (opcode = "001110" ) else
            Rt --lui
            when (opcode = "001111" ) else
            Rt --lw
            when (opcode = "100011") else--need sign extend
            "00000" -- sw
            when (opcode = "101011" ) else
            "00000" -- beq
            when (opcode = "000100" ) else------------------------
            "00000" -- bne
            when (opcode = "000101" );

-- forward Rs register to execution, to check for forwarding
IDEXRs_forwarding <= Rs -- add
            when (opcode = "000000" and funct = "100000") else
            Rs -- subtract
            when (opcode = "000000" and funct = "100010") else
            Rs -- multiply
            when (opcode = "000000" and funct = "011000") else
            Rs -- divide
            when (opcode = "000000" and funct = "011010") else
            Rs -- set less than
            when (opcode = "000000" and funct = "101010") else
            Rs -- and
            when (opcode = "000000" and funct = "100100") else
            Rs -- or
            when (opcode = "000000" and funct = "100101") else
            Rs -- nor
            when (opcode = "000000" and funct = "100111") else
            Rs --xor
            when (opcode = "000000" and funct = "100110") else
            "00000" -- move from HI
            when (opcode = "000000" and funct = "010000") else--10
            "00000" --move from lO
            when (opcode = "000000" and funct = "010010") else--11
            "00000" -- shift left logical
            when (opcode = "000000" and funct = "000000") else
            "00000" --shift right logical
            when (opcode = "000000" and funct = "000010") else
            "00000" -- shift right arithmetic
            when (opcode = "000000" and funct = "000011") else
            Rs -- jump register
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000" -- jump
            when (opcode = "000010" ) else
            "00000" -- jump and link
            when (opcode = "000011" ) else------ last J type
            Rs -- addi
            when (opcode = "001000" ) else
            Rs --slti
            when (opcode = "001010" ) else
            Rs --andi
            when (opcode = "001100" ) else
            Rs --ori
            when (opcode = "001101" ) else
            Rs --xori
            when (opcode = "001110" ) else
            "00000" --lui
            when (opcode = "001111" ) else
            Rs --lw
            when (opcode = "100011" ) else
            Rs -- sw
            when (opcode = "101011" ) else
            Rs -- beq
            when (opcode = "000100" ) else------------------------
            Rs -- bne
            when (opcode = "000101" );

-- forward Rt register to execution, to check for forwarding
IDEXRt_forwarding <= Rt -- add
            when (opcode = "000000" and funct = "100000") else
            Rt -- subtract
            when (opcode = "000000" and funct = "100010") else
            Rt -- multiply
            when (opcode = "000000" and funct = "011000") else
            Rt -- divide
            when (opcode = "000000" and funct = "011010") else
            Rt -- set less than
            when (opcode = "000000" and funct = "101010") else
            Rt -- and
            when (opcode = "000000" and funct = "100100") else
            Rt -- or
            when (opcode = "000000" and funct = "100101") else
            Rt -- nor
            when (opcode = "000000" and funct = "100111") else
            Rt --xor
            when (opcode = "000000" and funct = "100110") else
            "00000" -- move from HI
            when (opcode = "000000" and funct = "010000") else--10
            "00000" --move from lO
            when (opcode = "000000" and funct = "010010") else--11
            Rt -- shift left logical
            when (opcode = "000000" and funct = "000000") else
            Rt --shift right logical
            when (opcode = "000000" and funct = "000010") else
            Rt -- shift right arithmetic
            when (opcode = "000000" and funct = "000011") else
            "00000" -- jump register
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000" -- jump
            when (opcode = "000010" ) else
            "00000" -- jump and link
            when (opcode = "000011" ) else------ last J type
            "00000" -- addi
            when (opcode = "001000" and immediate(15)='1') else--sign extend
            "00000" --addi
            when (opcode = "001000" and immediate(15)='0') else--sign extend
            "00000"--slti
            when (opcode = "001010" and immediate(15)='1') else--need sign extend
            "00000"--slti
            when (opcode = "001010" and immediate(15)='0') else--need sign extend
            "00000"--andi
            when (opcode = "001100" ) else
            "00000"--ori
            when (opcode = "001101" ) else
            "00000"--xori
            when (opcode = "001110" ) else
            "00000"--lui
            when (opcode = "001111" ) else
            "00000"--lw
            when (opcode = "100011" and immediate(15)='1') else--need sign extend
            "00000"--lw
            when (opcode = "100011" and immediate(15)='0') else--need sign extend
            Rt --sw
            when (opcode = "101011" ) else
            Rt --beq
            when (opcode = "000100" ) else
            Rt --bne
            when (opcode = "000101" );

HI_reg <= HI_data;
LO_reg <= LO_data;

-- write process
process(write_register,write_data,HI_data,LO_data)
BEGIN
    if(write_register /= "00000") then      -- if the write register is not R0
      registers(to_integer(unsigned(write_register))) <= write_data;
    else
      registers(0) <= "00000000000000000000000000000000";
    end if;
    if(opcode = "000000" and funct = "010000" and Rd /= "00000") then   -- load from high and register is not R0
      registers(to_integer(unsigned(Rd))) <= HI_data;
    elsif(opcode = "000000" and funct = "010010" and Rd /= "00000") then  -- load from low and register is not R0
      registers(to_integer(unsigned(Rd))) <= LO_data;
    end if;
    if (opcode = "000011") then       -- jump and link, update R31
      registers(31) <= std_logic_vector(unsigned(pc_update)+four);
    end if;
end process;

---- debug
reg_0 <= registers(0);
reg_1 <= registers(1);
reg_2 <= registers(2);
reg_3 <= registers(3);
reg_4 <= registers(4);
reg_5 <= registers(5);
reg_6 <= registers(6);
reg_7 <= registers(7);
reg_8 <= registers(8);
reg_9 <= registers(9);
reg_10 <= registers(10);
reg_11 <= registers(11);
reg_12 <= registers(12);
reg_13 <= registers(13);
reg_14 <= registers(14);
reg_15 <= registers(15);
reg_16 <= registers(16);
reg_17 <= registers(17);
reg_18 <= registers(18);
reg_19 <= registers(19);
reg_20 <= registers(20);
reg_21 <= registers(21);
reg_22 <= registers(22);
reg_23 <= registers(23);
reg_24 <= registers(24);
reg_25 <= registers(25);
reg_26 <= registers(26);
reg_27 <= registers(27);
reg_28 <= registers(28);
reg_29 <= registers(29);
reg_30 <= registers(30);
reg_31 <= registers(31);



end implementation;

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
end Decode;

architecture implementation of Decode is

  type register_structure is array (31 downto 0) of std_logic_vector (31 downto 0);
  signal registers: register_structure :=(0 =>"00000000000000000000000000000000",
  1 =>"00000000000000000000000000000001",
  2 =>"00000000000000000000000000000010",
  3 =>"00000000000000000000000000000100",
  4 =>"00000000000000000000000000001000",
  5 =>"00000000000000000000000000010000",
  others => (others =>'0'));

  signal HI_reg, LO_reg : std_logic_vector(31 downto 0);
  signal four : unsigned(31 downto 0) := "00000000000000000000000000000100";
  --four <= "00000000000000000000000000000100"
  signal opcode : std_logic_vector(5 downto 0);
  signal Rs, Rt, Rd : std_logic_vector(4 downto 0);
  signal shamt  : std_logic_vector(4 downto 0);
  signal funct  : std_logic_vector(5 downto 0);
  signal immediate  : std_logic_vector(15 downto 0);
  signal address  : std_logic_vector(25 downto 0);

  signal instruction_type : Integer;

begin

  funct <= instruction(5 downto 0);
  shamt <= instruction(10 downto 6);
  Rs <= instruction(25 downto 21);
  Rt <= instruction(20 downto 16);
  Rd <= instruction(15 downto 11);
  opcode <= instruction(31 downto 26);

  immediate <= instruction(15 downto 0);

  stall <= '1'
          when (opcode = "000100" or opcode = "000101" or opcode = "000010" or funct = "001000") else
            '0';

  r_data_1 <= registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "100000") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "100010") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "011000") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "011010") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "101010") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "100100") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "100101") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "100111") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "100110") else
              registers(0)
              when (opcode = "000000" and funct = "010000") else--10
              registers(0)
              when (opcode = "000000" and funct = "010010") else--11
              "000000000000000000000000000"&shamt
              when (opcode = "000000" and funct = "000000") else
              "000000000000000000000000000"&shamt
              when (opcode = "000000" and funct = "000010") else
              "000000000000000000000000000"&shamt
              when (opcode = "000000" and funct = "000011") else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000000" and funct = "001000") else---- last R type
              pc_update(31 downto 28)&instruction(25 downto 0)&"00"
              when (opcode = "000010" ) else
              pc_update(31 downto 28)&instruction(25 downto 0)&"00"
              when (opcode = "000011" ) else------ last J type
              registers(to_integer(unsigned(Rs)))
              when (opcode = "001000" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "001010" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "001100" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "001101" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "001110" ) else
              registers(0)
              when (opcode = "001111" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "100011" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "101011" ) else
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000100" ) else------------------------
              registers(to_integer(unsigned(Rs)))
              when (opcode = "000101" );

r_data_2 <= registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "100000") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "100010") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "011000") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "011010") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "101010") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "100100") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "100101") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "100111") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "100110") else
            registers(0)
            when (opcode = "000000" and funct = "010000") else--10
            registers(0)
            when (opcode = "000000" and funct = "010010") else--11
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "000000") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "000010") else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000000" and funct = "000011") else
            registers(0)
            when (opcode = "000000" and funct = "001000") else---- last R type
            registers(0)
            when (opcode = "000010" ) else
            registers(0)
            when (opcode = "000011" ) else------ last J type
            "1111111111111111"&immediate
            when (opcode = "001000" and immediate(15)='1') else--sign extend
            "0000000000000000"&immediate
            when (opcode = "001000" and immediate(15)='0') else--sign extend
            "1111111111111111"&immediate
            when (opcode = "001010" and immediate(15)='1') else--need sign extend
            "0000000000000000"&immediate
            when (opcode = "001010" and immediate(15)='0') else--need sign extend
            "0000000000000000"&immediate
            when (opcode = "001100" ) else
            "0000000000000000"&immediate
            when (opcode = "001101" ) else
            "0000000000000000"&immediate
            when (opcode = "001110" ) else
            registers(0)
            when (opcode = "001111" ) else
            "1111111111111111"&immediate
            when (opcode = "100011" and immediate(15)='1') else--need sign extend
            "0000000000000000"&immediate
            when (opcode = "100011" and immediate(15)='0') else--need sign extend
            registers(to_integer(unsigned(Rt)))
            when (opcode = "101011" ) else
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000100" ) else------------------------
            registers(to_integer(unsigned(Rt)))
            when (opcode = "000101" );

ALU_op <=   "00000"
            when (opcode = "000000" and funct = "100000") else
            "00001"
            when (opcode = "000000" and funct = "100010") else
            "00011"
            when (opcode = "000000" and funct = "011000") else
            "00100"
            when (opcode = "000000" and funct = "011010") else
            "00101"
            when (opcode = "000000" and funct = "101010") else
            "00111"
            when (opcode = "000000" and funct = "100100") else
            "01000"
            when (opcode = "000000" and funct = "100101") else
            "01001"
            when (opcode = "000000" and funct = "100111") else
            "01010"
            when (opcode = "000000" and funct = "100110") else
            "01110"
            when (opcode = "000000" and funct = "010000") else--10
            "01111"
            when (opcode = "000000" and funct = "010010") else--11
            "10001"
            when (opcode = "000000" and funct = "000000") else
            "10010"
            when (opcode = "000000" and funct = "000010") else
            "10011"
            when (opcode = "000000" and funct = "000011") else
            "11001"
            when (opcode = "000000" and funct = "001000") else---- last R type
            "11000"
            when (opcode = "000010" ) else
            "11010"
            when (opcode = "000011" ) else------ last J type
            "00010"
            when (opcode = "001000") else--sign extend
            "00110"
            when (opcode = "001010") else--need sign extend
            "01011"
            when (opcode = "001100" ) else
            "01100"
            when (opcode = "001101" ) else
            "01101"
            when (opcode = "001110" ) else
            "10000"
            when (opcode = "001111" ) else
            "10100"
            when (opcode = "100011") else--need sign extend
            "10101"
            when (opcode = "101011" ) else
            "10110"
            when (opcode = "000100" ) else------------------------
            "10111"
            when (opcode = "000101" );


IDEX_WB <=  '1'
            when (opcode = "000000" and funct = "100000") else
            '1'
            when (opcode = "000000" and funct = "100010") else
            '0'
            when (opcode = "000000" and funct = "011000") else
            '0'
            when (opcode = "000000" and funct = "011010") else
            '1'
            when (opcode = "000000" and funct = "101010") else
            '1'
            when (opcode = "000000" and funct = "100100") else
            '1'
            when (opcode = "000000" and funct = "100101") else
            '1'
            when (opcode = "000000" and funct = "100111") else
            '1'
            when (opcode = "000000" and funct = "100110") else
            '0'
            when (opcode = "000000" and funct = "010000") else--10
            '0'
            when (opcode = "000000" and funct = "010010") else--11
            '1'
            when (opcode = "000000" and funct = "000000") else
            '1'
            when (opcode = "000000" and funct = "000010") else
            '1'
            when (opcode = "000000" and funct = "000011") else
            '0'
            when (opcode = "000000" and funct = "001000") else---- last R type
            '0'
            when (opcode = "000010" ) else
            '0'
            when (opcode = "000011" ) else------ last J type
            '1'
            when (opcode = "001000") else--sign extend
            '1'
            when (opcode = "001010") else--need sign extend
            '1'
            when (opcode = "001100" ) else
            '1'
            when (opcode = "001101" ) else
            '1'
            when (opcode = "001110" ) else
            '1'
            when (opcode = "001111" ) else
            '1'
            when (opcode = "100011") else--need sign extend
            '0'
            when (opcode = "101011" ) else
            '0'
            when (opcode = "000100" ) else------------------------
            '0'
            when (opcode = "000101" );

IDEX_M <=   '1'
            when (opcode = "100011") else--need sign extend
            '1'
            when (opcode = "101011" ) else
            '0';

IDEX_EX <=  '0'
            when (opcode = "000000" and funct = "010000") else--10
            '0'
            when (opcode = "000000" and funct = "010010") else--11
            '1';

SIGN_EXTEND <=  "1111111111111111"&immediate
                when (opcode = "101011" and immediate(15) = '1') else
                "0000000000000000"&immediate
                when (opcode = "101011" and immediate(15) = '0') else
                "1111111111111111"&immediate
                when (opcode = "000100" and immediate(15) = '1') else------------------------
                "0000000000000000"&immediate
                when (opcode = "000100" and immediate(15) = '0') else------------------------
                "1111111111111111"&immediate
                when (opcode = "000101" and immediate(15) = '1')else
                "0000000000000000"&immediate
                when (opcode = "000101" and immediate(15) = '0')else
                "00000000000000000000000000000000";

IDEX_WB_register <= Rd
            when (opcode = "000000" and funct = "100000") else
            Rd
            when (opcode = "000000" and funct = "100010") else
            "00000"
            when (opcode = "000000" and funct = "011000") else
            "00000"
            when (opcode = "000000" and funct = "011010") else
            Rd
            when (opcode = "000000" and funct = "101010") else
            Rd
            when (opcode = "000000" and funct = "100100") else
            Rd
            when (opcode = "000000" and funct = "100101") else
            Rd
            when (opcode = "000000" and funct = "100111") else
            Rd
            when (opcode = "000000" and funct = "100110") else
            "00000"
            when (opcode = "000000" and funct = "010000") else--10
            "00000"
            when (opcode = "000000" and funct = "010010") else--11
            Rd
            when (opcode = "000000" and funct = "000000") else
            Rd
            when (opcode = "000000" and funct = "000010") else
            Rd
            when (opcode = "000000" and funct = "000011") else
            "00000"
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000"
            when (opcode = "000010" ) else
            "00000"
            when (opcode = "000011" ) else------ last J type
            Rt
            when (opcode = "001000") else--sign extend
            Rt
            when (opcode = "001010") else--need sign extend
            Rt
            when (opcode = "001100" ) else
            Rt
            when (opcode = "001101" ) else
            Rt
            when (opcode = "001110" ) else
            Rt
            when (opcode = "001111" ) else
            Rt
            when (opcode = "100011") else--need sign extend
            "00000"
            when (opcode = "101011" ) else
            "00000"
            when (opcode = "000100" ) else------------------------
            "00000"
            when (opcode = "000101" );

IDEXRs_forwarding <= Rs
            when (opcode = "000000" and funct = "100000") else
            Rs
            when (opcode = "000000" and funct = "100010") else
            Rs
            when (opcode = "000000" and funct = "011000") else
            Rs
            when (opcode = "000000" and funct = "011010") else
            Rs
            when (opcode = "000000" and funct = "101010") else
            Rs
            when (opcode = "000000" and funct = "100100") else
            Rs
            when (opcode = "000000" and funct = "100101") else
            Rs
            when (opcode = "000000" and funct = "100111") else
            Rs
            when (opcode = "000000" and funct = "100110") else
            "00000"
            when (opcode = "000000" and funct = "010000") else--10
            "00000"
            when (opcode = "000000" and funct = "010010") else--11
            "00000"
            when (opcode = "000000" and funct = "000000") else
            "00000"
            when (opcode = "000000" and funct = "000010") else
            "00000"
            when (opcode = "000000" and funct = "000011") else
            Rs
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000"
            when (opcode = "000010" ) else
            "00000"
            when (opcode = "000011" ) else------ last J type
            Rs
            when (opcode = "001000" ) else
            Rs
            when (opcode = "001010" ) else
            Rs
            when (opcode = "001100" ) else
            Rs
            when (opcode = "001101" ) else
            Rs
            when (opcode = "001110" ) else
            "00000"
            when (opcode = "001111" ) else
            Rs
            when (opcode = "100011" ) else
            Rs
            when (opcode = "101011" ) else
            Rs
            when (opcode = "000100" ) else------------------------
            Rs
            when (opcode = "000101" );

IDEXRt_forwarding <= Rt
            when (opcode = "000000" and funct = "100000") else
            Rt
            when (opcode = "000000" and funct = "100010") else
            Rt
            when (opcode = "000000" and funct = "011000") else
            Rt
            when (opcode = "000000" and funct = "011010") else
            Rt
            when (opcode = "000000" and funct = "101010") else
            Rt
            when (opcode = "000000" and funct = "100100") else
            Rt
            when (opcode = "000000" and funct = "100101") else
            Rt
            when (opcode = "000000" and funct = "100111") else
            Rt
            when (opcode = "000000" and funct = "100110") else
            "00000"
            when (opcode = "000000" and funct = "010000") else--10
            "00000"
            when (opcode = "000000" and funct = "010010") else--11
            Rt
            when (opcode = "000000" and funct = "000000") else
            Rt
            when (opcode = "000000" and funct = "000010") else
            Rt
            when (opcode = "000000" and funct = "000011") else
            "00000"
            when (opcode = "000000" and funct = "001000") else---- last R type
            "00000"
            when (opcode = "000010" ) else
            "00000"
            when (opcode = "000011" ) else------ last J type
            "00000"
            when (opcode = "001000" and immediate(15)='1') else--sign extend
            "00000"
            when (opcode = "001000" and immediate(15)='0') else--sign extend
            "00000"
            when (opcode = "001010" and immediate(15)='1') else--need sign extend
            "00000"
            when (opcode = "001010" and immediate(15)='0') else--need sign extend
            "00000"
            when (opcode = "001100" ) else
            "00000"
            when (opcode = "001101" ) else
            "00000"
            when (opcode = "001110" ) else
            "00000"
            when (opcode = "001111" ) else
            "00000"
            when (opcode = "100011" and immediate(15)='1') else--need sign extend
            "00000"
            when (opcode = "100011" and immediate(15)='0') else--need sign extend
            Rt
            when (opcode = "101011" ) else
            Rt
            when (opcode = "000100" ) else------------------------
            Rt
            when (opcode = "000101" );

registers(31) <= std_logic_vector(unsigned(pc_update)+four) when (opcode = "000011" );------ last J type

registers(to_integer(unsigned(Rd))) <= HI_reg when (opcode = "000000" and funct = "010000");--10

registers(to_integer(unsigned(Rd))) <= LO_reg when (opcode = "000000" and funct = "010010");--11

HI_reg <= HI_data;

LO_reg <= LO_data;

registers(to_integer(unsigned(write_register))) <= write_data;

end implementation;

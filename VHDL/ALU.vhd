library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		clk:				in std_logic;
		ALU_in1:			in std_logic_vector(31 downto 0);	-- two operands for ALU calculation
		ALU_in2:			in std_logic_vector(31 downto 0);
		ALU_op:				in std_logic_vector(4 downto 0);    -- opcode (our own version of opcode for ALU operations)
		hi:					out std_logic_vector(31 downto 0);	-- higher part of the multiply output
		lo:					out std_logic_vector(31 downto 0);	-- lower part of the multiply output
		ALU_out:			out std_logic_vector(31 downto 0)
		);

end ALU;

architecture alu_behavior of ALU is

	signal hi_s, lo_s:		std_logic_vector(31 downto 0);

	-- initializing a zero 64-bit vector to be the temp holder for multiply output
	signal long_bit:			std_logic_vector(63 downto 0):= "0000000000000000000000000000000000000000000000000000000000000000"; 

begin

hi <= long_bit(63 downto 32);
lo <= long_bit(31 downto 0);

process(ALU_in1,ALU_in2,ALU_op,clk)
variable bit_to_shift: integer;
begin
case(ALU_op) is

	-- NOTE:
	-- ALL alu_up defined by ourselves uniquely. They are not the same opcodes as MIPS_GREEN_SHEET.
	when "00000" => -- add
		ALU_out <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))+to_integer(signed(ALU_in2)), ALU_out'length));
	when "00001" => -- sub
		ALU_out <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))-to_integer(signed(ALU_in2)), ALU_out'length));
	when "00010" => -- addi (note input has already been decoded to imm. value. Thus this operation is the same as add)
		ALU_out <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))+to_integer(signed(ALU_in2)), ALU_out'length));
	when "00011" => -- mult
		ALU_out <= "00000000000000000000000000000000";
		long_bit <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))*to_integer(signed(ALU_in2)), 64));
	when "00100" => -- div
		ALU_out <= "00000000000000000000000000000000";
		long_bit(31 downto 0) <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))/to_integer(signed(ALU_in2)), 32));

		-- for lower part, we take the mode value
		long_bit(63 downto 32) <= std_logic_vector(to_signed(to_integer(signed(ALU_in1)) mod to_integer(signed(ALU_in2)), 32));

	when "00101" => -- slt (set less than)
		if(signed(ALU_in1)<signed(ALU_in2))then
			ALU_out <= x"00000001";
		else
			ALU_out <= x"00000000";
		end if;

	when "00110" => -- slti
		if(signed(ALU_in1)<signed(ALU_in2))then
			ALU_out <= x"00000001";
		else
			ALU_out <= x"00000000";
		end if;
	when "00111" => -- and
		ALU_out <= ALU_in1 and ALU_in2;
	when "01000" => -- or
		ALU_out <= ALU_in1 or ALU_in2;
	when "01001" => -- nor
		ALU_out <= ALU_in1 nor ALU_in2;
	when "01010" => -- xor
		ALU_out <= ALU_in1 xor ALU_in2;

	when "01011" => -- andi (same as addi, alu inputs has been changed to imm. in decode stage. Thus later cases like ORI are same.)
		ALU_out <= ALU_in1 and ALU_in2;
	when "01100" => -- ori
		ALU_out <= ALU_in1 or ALU_in2;
	when "01101" => -- xori
		ALU_out <= ALU_in1 xor ALU_in2;
	when "01110" => -- mfhi
		ALU_out <= hi_s;
	when "01111" => -- mflo
		ALU_out <= lo_s;
	when "10000" => -- lui
		ALU_out <= ALU_in2(15 downto 0) & std_logic_vector(to_unsigned(0,16));
	when "10001" => -- sll
		-- in1 is the bits to shift
		bit_to_shift:= to_integer(unsigned(ALU_in1));
		-- in2 is the register file to shift
		ALU_out <= ALU_in2((31-bit_to_shift) downto 0) & std_logic_vector(to_unsigned(0,bit_to_shift));
	when "10010" => -- srl
		-- in1 is the bits to shift
		bit_to_shift:= to_integer(unsigned(ALU_in1));
		-- in2 is the register file to shift
		ALU_out <= std_logic_vector(to_unsigned(0,bit_to_shift)) & ALU_in2(31 downto bit_to_shift);
	when "10011" => -- sra Shift Right Arith
		bit_to_shift:= to_integer(unsigned(ALU_in1));
		-- arithmetic shifting, need to pad the significant bits using its sign bits
		if (ALU_in2(31) = '1') then
			ALU_out <= std_logic_vector(to_unsigned(1,bit_to_shift)) & ALU_in2(31 downto bit_to_shift);
		else
			ALU_out <= std_logic_vector(to_unsigned(0,bit_to_shift)) & ALU_in2(31 downto bit_to_shift);
		end if ;
	when "10100" => --load
		ALU_out <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))+to_integer(signed(ALU_in2)), ALU_out'length));
	when "10101" => --store
		ALU_out <= std_logic_vector(to_signed(to_integer(signed(ALU_in1))+to_integer(signed(ALU_in2)), ALU_out'length));
	when "11000" => --jump
		ALU_out <= std_logic_vector(ALU_in1);
	when "11001" => --jump register
		ALU_out <=	std_logic_vector(ALU_in1);
	when "11010" => --jump and link
		ALU_out <= std_logic_vector(ALU_in1);
	when others =>
		ALU_out <= x"00000000";
end case ;
end process;

end alu_behavior ; -- alu_behavior

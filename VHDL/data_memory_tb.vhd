LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY data_memory_tb IS
END data_memory_tb;

ARCHITECTURE Behaviour of data_memory_tb IS

signal clock: std_logic := '0';
constant clk_period: time := 1 ns;
signal EXMEM_WB: std_logic;
signal EXMEM_M: std_logic;
signal opcode: std_logic_vector(4 downto 0);
signal Write_data: std_logic_vector(31 downto 0);
signal ALU_out: std_logic_vector(31 downto 0);
signal EXMEM_register: std_logic_vector(4 downto 0); 
signal MEMWB_M: std_logic;
signal MEMWB_WB: std_logic;	-- writeback signal output
signal Data_Mem_out: std_logic_vector(31 downto 0); -- output from data memory
signal Address_to_WB: std_logic_vector(31 downto 0); -- output from ALU output	
signal MEMWB_register: std_logic_vector(4 downto 0); -- output 
signal Reg_Mem_to_forwarding: std_logic_vector(4 downto 0);
signal WB_Mem_to_forwarding: std_logic;



COMPONENT Data_Memory
	generic(
			ram_size:		integer := 8192; -- There're 8192 lines in the data memory
			mem_delay:		time := 1 ns;
			clock_period:	time := 1 ns			
			);	
	port(	
			clock:				in std_logic;
			EXMEM_WB:			in std_logic;	-- Directly pass to MEMWB_WB
			EXMEM_M:			in std_logic;	-- for the first bit, '0' refers to access Data Mem, '1' refers to pass through 
																-- for the second bit, '0' refers to read data from data memory		
																					-- '1' refers to write data to data memory
			opcode:				in std_logic_vector(4 downto 0); --
			
			Write_data:			in std_logic_vector(31 downto 0);
			ALU_out:			in std_logic_vector(31 downto 0);
			EXMEM_register:		in std_logic_vector(4 downto 0); 
			
			MEMWB_M:			out std_logic;
			MEMWB_WB:			out std_logic;	-- writeback signal output
			Data_Mem_out:		out std_logic_vector(31 downto 0); -- output from data memory
			Address_to_WB:		out std_logic_vector(31 downto 0); -- output from ALU output	
			MEMWB_register:		out std_logic_vector(4 downto 0); -- output 
			Reg_Mem_to_forwarding:	out std_logic_vector(4 downto 0);
			WB_Mem_to_forwarding:	out std_logic
		);	
END COMPONENT;


    BEGIN

    	i1 : Data_Memory port 
		MAP(
    		clock => clock,
			EXMEM_WB => EXMEM_WB,
			EXMEM_M => EXMEM_M,
			opcode => opcode,
			Write_data => Write_data,
			ALU_out => ALU_out,
			EXMEM_register => EXMEM_register,
			MEMWB_M => MEMWB_M,
			MEMWB_WB => MEMWB_WB,
			Data_Mem_out => Data_Mem_out,
			Address_to_WB => Address_to_WB,
			MEMWB_register => MEMWB_register,
			Reg_Mem_to_forwarding => Reg_Mem_to_forwarding,
			WB_Mem_to_forwarding => WB_Mem_to_forwarding
    		);
			
			
       	clk_process : process
    	BEGIN
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
    	END PROCESS;

    	test_process : process
    	begin
			EXMEM_M <= '1';
			opcode <= "10101";
			ALU_out <= "00000000000000000000000000000000";
			Write_data <= "11111111111111111111111111111111";
			wait for clk_period;
			EXMEM_M <= '1';
			opcode <= "10101";
			ALU_out <= "00000000000000000000000000000100";
			Write_data <= "11111111111111111111110000011111";
			wait for clk_period;
			EXMEM_M <= '0';
			opcode <= "10101";
			ALU_out <= "00000000000000000000000000000100";
			Write_data <= "11111111111111111111111111111111";		
			wait for clk_period;
			EXMEM_M <= '1';
			opcode <= "10100";
			ALU_out <= "00000000000000000000000000000000";
			Write_data <= "11111111111111111111111111111111";		


    		wait;
    	END PROCESS;

    END Behaviour;
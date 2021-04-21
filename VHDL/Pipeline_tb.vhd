LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Pipeline_tb IS
END Pipeline_tb;

ARCHITECTURE Behaviour of Pipeline_tb IS

	COMPONENT Pipeline IS

	port(
	clk:				in std_logic;
	--- debug protocal
	fetch_instruction: out std_logic_vector(31 downto 0);
	decode_instruction_in: out std_logic_vector(31 downto 0);
	memory_write_data: out std_logic_vector(31 downto 0);
	register_write_data: out std_logic_vector(31 downto 0);
	execution_out: out std_logic_vector(31 downto 0);
	forwarding_signal_mux_1 : out std_logic_vector (1 downto 0);
	forwarding_signal_mux_2 : out std_logic_vector (1 downto 0);
	stall_signal: out std_logic;
	branch_taken_signal: out std_logic;
	memory_write_signal: out std_logic;
	register_wb_signal: out std_logic;
	execution_flag: out std_logic;
	reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: out std_logic_vector(31 downto 0);
	reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: out std_logic_vector(31 downto 0);
	reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: out std_logic_vector(31 downto 0);
	reg_27, reg_28, reg_29, reg_30, reg_31: out std_logic_vector(31 downto 0)
		);

	END COMPONENT;

		signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
		--- debug protocal
		signal fetch_instruction:  std_logic_vector(31 downto 0);
		signal decode_instruction_in:  std_logic_vector(31 downto 0);
		signal memory_write_data:  std_logic_vector(31 downto 0);
		signal register_write_data:  std_logic_vector(31 downto 0);
		signal execution_out:  std_logic_vector(31 downto 0);
		signal forwarding_signal_mux_1 : std_logic_vector (1 downto 0);
    signal forwarding_signal_mux_2 : std_logic_vector (1 downto 0);
		signal stall_signal:  std_logic;
		signal branch_taken_signal:  std_logic;
		signal memory_write_signal:  std_logic;
		signal register_wb_signal:  std_logic;
		signal execution_flag:  std_logic;

		signal reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: std_logic_vector(31 downto 0);
    signal reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: std_logic_vector(31 downto 0);
    signal reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: std_logic_vector(31 downto 0);
    signal reg_27, reg_28, reg_29, reg_30, reg_31: std_logic_vector(31 downto 0);

    BEGIN

    	dut: Pipeline port MAP(
    		clk => clk,
				fetch_instruction => fetch_instruction,
				decode_instruction_in => decode_instruction_in,
				memory_write_data => memory_write_data,
				register_write_data => register_write_data,
				execution_out => execution_out,
				forwarding_signal_mux_1 => forwarding_signal_mux_1,
				forwarding_signal_mux_2 => forwarding_signal_mux_2,
				stall_signal => stall_signal,
				branch_taken_signal => branch_taken_signal,
				memory_write_signal => memory_write_signal,
				register_wb_signal => register_wb_signal,
				execution_flag => execution_flag,
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
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    	END PROCESS;

    	test_process : process
    	begin
     --R--******+++++*****+++++*****++++++
        --00000000001000100001100000100000
        --00000000100001010011000000100010

    		wait;
    	END PROCESS;

    END;

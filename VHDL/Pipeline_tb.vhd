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

	END COMPONENT;

		signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
		--- debug protocal
		signal debug_vector_1:  std_logic_vector(31 downto 0);
		signal debug_vector_2:  std_logic_vector(31 downto 0);
		signal debug_vector_3:  std_logic_vector(31 downto 0);
		signal debug_vector_4:  std_logic_vector(31 downto 0);
		signal debug_vector_5:  std_logic_vector(31 downto 0);
		signal debug_boolean_1:  std_logic;
		signal debug_boolean_2:  std_logic;
		signal debug_boolean_3:  std_logic;
		signal debug_boolean_4:  std_logic;
		signal debug_boolean_5:  std_logic;

		signal reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8: std_logic_vector(31 downto 0);
    signal reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17: std_logic_vector(31 downto 0);
    signal reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26: std_logic_vector(31 downto 0);
    signal reg_27, reg_28, reg_29, reg_30, reg_31: std_logic_vector(31 downto 0);

    BEGIN

    	dut: Pipeline port MAP(
    		clk => clk,
				debug_vector_1 => debug_vector_1,
				debug_vector_2 => debug_vector_2,
				debug_vector_3 => debug_vector_3,
				debug_vector_4 => debug_vector_4,
				debug_vector_5 => debug_vector_5,
				debug_boolean_1 => debug_boolean_1,
				debug_boolean_2 => debug_boolean_2,
				debug_boolean_3 => debug_boolean_3,
				debug_boolean_4 => debug_boolean_4,
				debug_boolean_5 => debug_boolean_5,
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

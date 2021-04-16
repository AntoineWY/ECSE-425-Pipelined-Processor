LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Pipeline_tb IS
END Pipeline_tb;

ARCHITECTURE Behaviour of Pipeline_tb IS

	COMPONENT Pipeline IS

	port(
		clk:			in std_logic;
        stage1_fetch_out:   out std_logic_vector(31 downto 0);
        stage2_out_data:    out std_logic_vector(31 downto 0);  
        logic_out:          out std_logic;
		pip_ALU_out:		out std_logic_vector(31 downto 0)
		);

	END COMPONENT;

	signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal dummy_vector: std_logic_vector(31 downto 0);
    signal dummy_logic: std_logic := '0';
    signal stage1_fetch_out: std_logic_vector(31 downto 0);
    signal pip_ALU_out: std_logic_vector(31 downto 0);
    signal logic_out: std_logic;
    signal stage2_out_data: std_logic_vector(31 downto 0);  

    BEGIN

    	dut: Pipeline port MAP(
    		clk => clk,
            stage1_fetch_out => stage1_fetch_out,
            stage2_out_data => stage2_out_data,
    		pip_ALU_out => pip_ALU_out,
            logic_out => logic_out
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
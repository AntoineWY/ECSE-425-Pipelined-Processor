LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Pipline_tb IS
END Pipline_tb;

ARCHITECTURE Behaviour of Pipline_tb IS

	COMPONENT Pipline IS

	port(
		clk:			in std_logic;
		ALU_out:		out std_logic_vector(31 downto 0)
		);

	END COMPONENT;

	signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal dummy_vector: std_logic_vector(31 downto 0);
    signal dummy_logic: std_logic := '0';
    signal ALU_out: std_logic_vector(31 downto 0);

    BEGIN

    	dut: Pipline port MAP(
    		clk => clk,
    		ALU_out => ALU_out
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
            
    		wait;
    	END PROCESS;

    END;
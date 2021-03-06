LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Fetch_tb IS
END Fetch_tb;

ARCHITECTURE behaviour OF Fetch_tb IS

--Declare the component that you are testing:
    COMPONENT Fetch IS

            port(
                clk:						in std_logic;
                bj_target_address:		    in std_logic_vector(31 downto 0);
                pc_stall:				    in std_logic;
                branch_taken:               in std_logic;
                hazard:                     in std_logic;
                pc_update:					out std_logic_vector(31 downto 0);
                Fetch_out:					out std_logic_vector(31 downto 0)
                );
            
    END COMPONENT;



	signal writedata: 		std_logic_vector(31 downto 0);
	signal address: 		integer range 0 to 32768-1;
	signal memwrite: 		std_logic := '0';
	signal memread:			std_logic := '1';
	signal readdata:		std_logic_vector(31 downto 0);
	signal waitrequest:		std_logic;	-- how do we do with this?
    signal branch_taken:    std_logic;
    signal hazard:          std_logic;

	signal adder_output:	std_logic_vector(31 downto 0);
	signal adder_result:	integer;
	signal four:			integer := 4;

	-- program counter initialized at zero
	signal pc_next:			std_logic_vector(31 downto 0);		
	signal pc_value:		std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal instruction_out:	std_logic_vector(31 downto 0);



    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal bj_target_address: std_logic_vector(31 downto 0);
    signal pc_stall: std_logic := '0';
    signal bj_address_ready: std_logic := '0';
    signal pc_update:	 std_logic_vector(31 downto 0);


BEGIN

    --dut => Device Under Test
    dut: Fetch port MAP(
        clk =>clk,
        bj_target_address => bj_target_address,
        pc_stall => pc_stall,
        branch_taken => branch_taken,
        hazard => hazard,
        pc_update => pc_update,
        Fetch_out => readdata
    );

    clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    BEGIN
        hazard <= '0';
        branch_taken <= '0';
        --pc_stall <= '0';

        --wait for clk_period;
        --pc_stall <= '1';
        --wait for clk_period;
        --pc_stall <= '0';
        
        --wait for clk_period*2;
        --bj_address_ready <= '1';
        --bj_target_address <= "00000000000000000000000000001000";
        --wait for clk_period;
        --bj_address_ready <= '0';
        wait;

    END PROCESS;

 
END;
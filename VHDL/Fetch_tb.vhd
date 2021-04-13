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
                branch_target_address:		in std_logic_vector(31 downto 0);
                jump_target_address:		in std_logic_vector(31 downto 0);	
                next_pc_branch:				in std_logic;
                next_pc_jump:				in std_logic;
            --	structure_stall:	in std_logic := '0';
              --  pc_stall:					in std_logic := '0';
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

	signal adder_output:	std_logic_vector(31 downto 0);
	signal adder_result:	integer;
	signal four:			integer := 4;

	-- program counter initialized at zero
	signal pc_next:			std_logic_vector(31 downto 0);		
	signal pc_value:		std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal instruction_out:	std_logic_vector(31 downto 0);



    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal dummy_vector: std_logic_vector(31 downto 0);
    signal dummy_logic: std_logic := '0';
    signal pc_update:	 std_logic_vector(31 downto 0);


BEGIN

    --dut => Device Under Test
    dut: Fetch port MAP(
        clk =>clk,
        branch_target_address => dummy_vector,
        jump_target_address => dummy_vector,
        next_pc_branch => dummy_logic,
        next_pc_jump=> dummy_logic,
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
     
        wait;

    END PROCESS;

 
END;
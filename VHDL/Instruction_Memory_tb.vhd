LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Instruction_Memory_tb IS
END Instruction_Memory_tb;

ARCHITECTURE behaviour OF Instruction_Memory_tb IS

--Declare the component that you are testing:
    COMPONENT Instruction_Memory IS
        GENERIC(
            ram_size : INTEGER := 1024;
            mem_delay : time := 1 ns;
            clock_period : time := 1 ns
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            address: IN INTEGER RANGE 0 TO ram_size-1;
            memwrite: IN STD_LOGIC := '0';
            memread: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            waitrequest: OUT STD_LOGIC
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clk : std_logic := '0';
    constant clk_period : time := 1 ns;
    signal writedata: std_logic_vector(31 downto 0);
    signal address: INTEGER RANGE 0 TO 1024-1;
    signal memwrite: STD_LOGIC := '0';
    signal memread: STD_LOGIC := '1';
    signal readdata: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal waitrequest: STD_LOGIC;

BEGIN

    --dut => Device Under Test
    dut: Instruction_Memory GENERIC MAP(
            ram_size => 1024
                )
                PORT MAP(
                 clk ,
                 writedata =>   writedata,
                   address => address,
                  memwrite =>  memwrite,
                   memread=> memread,
                  readdata=>  readdata,
                  waitrequest=>  waitrequest
                );

    clk_process : process
    BEGIN
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        address <= address + 4;
    end process;

    test_process : process
    BEGIN
        --wait for clk_period;
     
        wait;

    END PROCESS;

 
END;
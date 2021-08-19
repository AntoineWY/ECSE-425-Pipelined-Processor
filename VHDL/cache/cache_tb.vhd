library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is
end cache_tb;

architecture behavior of cache_tb is

component cache is
generic(
    ram_size : INTEGER := 32768
);
port(
    clock : in std_logic;
    reset : in std_logic;

    -- Avalon interface --
    s_addr : in std_logic_vector (31 downto 0);
    s_read : in std_logic;
    s_readdata : out std_logic_vector (31 downto 0);
    s_write : in std_logic;
    s_writedata : in std_logic_vector (31 downto 0);
    s_waitrequest : out std_logic; 

    m_addr : out integer range 0 to ram_size-1;
    m_read : out std_logic;
    m_readdata : in std_logic_vector (7 downto 0);
    m_write : out std_logic;
    m_writedata : out std_logic_vector (7 downto 0);
    m_waitrequest : in std_logic
);
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 

begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);
				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
	variable temp : std_logic_vector (31 downto 0);
	variable temp_next : std_logic_vector (31 downto 0);
begin

--read/write	valid	dirty	Tag	
-- 1	R	Valid	Clean	Equal	cache hit
-- 2	R	Valid	Clean	not equal	cache miss + read from memory
-- 3	R	Valid	Dirty	Equal	cache hit (though dirty, but it is required data)
-- 4	R	Valid	Dirty	Not equal	cache miss + write current to memory + read from memory to cache
-- 5	R	Invalid	Clean	Equal	cache miss + read from memory
-- 6	R	Invalid	Clean	not equal	cache miss + read from memory
-- 7	R	Invalid	Dirty	Equal	impossible case
-- 8	R	Invalid	Dirty	Not equal	impossible case
-- 9	W	Valid	Clean	Equal	cache hit (W)
-- 10	W	Valid	Clean	not equal	cache miss + write in cache directly
-- 11	W	Valid	Dirty	Equal	cache hit + write in cache directly
-- 12	W	Valid	Dirty	Not equal	cache miss + write current to memory + write new to cache
-- 13	W	Invalid	Clean	Equal	cache miss + write to cache
-- 14	W	Invalid	Clean	not equal	cache miss + write to cache
-- 15	W	Invalid	Dirty	Equal	impossible case
-- 16	W	Invalid	Dirty	Not equal	impossible case
	
	-- Test case 1
	-- 1	R	Valid	Clean	Equal	cache hit
	
	s_addr <= "00000000000000000000000000101100";	-- read here turns this block from invalid to valid + clean
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
	temp := s_readdata(31 downto 0);

	s_read <= '0';
	s_write <= '0'; 
	wait for clk_period;

	s_addr <= "00000000000000000000000000101100";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
        assert s_readdata = temp report "Test 1 Not Passed!" severity error;   
	s_read <= '0';                                                       
	s_write <= '0'; 
	
	wait for 200*clk_period;

	-- Test case 2
	-- 2	R	Valid	Clean	not equal	cache miss + read from memory
        --s_addr <= "00000000000000000000010 00010  1100";
	s_addr <= "00000000000000000000010000101100";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
	temp := s_readdata(31 downto 0);

	s_read <= '0';
	s_write <= '0'; 
	wait for clk_period;


	-- s_addr <= "00000000000000000000001 00010 1100";
	s_addr <= "00000000000000000000001000101000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
	temp_next := s_readdata(31 downto 0);
	assert s_readdata /= temp report "Test 2.1 Not Passed!" severity error;  

	s_addr <= "00000000000000000000010000101100";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
	assert s_readdata = temp report "Test 2.2 Not Passed!" severity error;  
	s_read <= '0';                                                       
	s_write <= '0'; 

	wait for 200*clk_period;

	-- Test case 3
	-- 3	R	Valid	Dirty	Equal	cache hit (though dirty, but it is required data)
	s_addr <= "00000000000000000000000000001100";
	s_write <= '1';
	s_read <= '0'; 
	s_writedata <= x"0000ABCD";
	wait until rising_edge(s_waitrequest); 

	s_addr <= "00000000000000000000000000001100";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
        assert s_readdata = x"0000ABCD" report "Test 3 Not Passed!" severity error;   
	s_read <= '0';                                                       
	s_write <= '0'; 
	
	wait for 200*clk_period;

	-- Test case 4
	-- 4	R	Valid	Dirty	Not equal	cache miss + write current to memory + read from memory to cache
	s_addr <= "00000000000000000000000000001100";
	s_write <= '1';
	s_read <= '0'; 
	s_writedata <= x"0000ABCD";
	wait until rising_edge(s_waitrequest); 

	s_addr <= "00000000000000000000001000001100";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
        assert s_readdata /= x"0000ABCD" report "Test 4.1 Not Passed!" severity error;   

	s_addr <= "00000000000000000000000000001100";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 
        assert s_readdata = x"0000ABCD" report "Test 4.2 Not Passed!" severity error;

	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for 200*clk_period;

	-- Test case 5
	-- 5	R	Invalid	Clean	Equal	cache miss + read from memory
	-- Impossible case to implement
	-- The test logic and flow is covered by test 1

	-- Test case 6
	-- 6	R	Invalid	Clean	not equal	cache miss + read from memory
	-- The test logic and flow is covered by test 1

	-- Test case 7
	-- 7	R	Invalid	Dirty	Equal	impossible case

	-- Test case 8
	-- 8	R	Invalid	Dirty	Not equal	impossible case

	-- Test case 9
	-- 9	W	Valid	Clean	Equal	cache hit (W)
	s_addr <= "00000000000000000000000110000000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 

	s_addr <= "00000000000000000000000110000000";
	s_read <= '0';
	s_write <= '1'; 
	s_writedata <= x"00001234";
	wait until rising_edge(s_waitrequest);
	
	s_addr <= "00000000000000000000000110000000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"00001234" report "Test 9 Not Passed!" severity error;

	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for 200*clk_period;

	-- Test case 10
	-- 10	W	Valid	Clean	not equal	cache miss + write in cache directly
	s_addr <= "00000000000000000000000010101000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest); 

	s_addr <= "00000000000000000000100010101000";
	s_read <= '0';
	s_write <= '1'; 
	s_writedata <= x"00006666";
	wait until rising_edge(s_waitrequest);

	s_addr <= "00000000000000000000100010101000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"00006666" report "Test 10 Not Passed!" severity error;

	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for 200*clk_period;
	
	-- Test case 11
	-- 11	W	Valid	Dirty	Equal	cache hit + write in cache directly
	s_addr <= "00000000000000000000100010101000";
	s_read <= '0';
	s_write <= '1'; 
	s_writedata <= x"0F007777";
	wait until rising_edge(s_waitrequest);

	s_addr <= "00000000000000000000100010101000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"0F007777" report "Test 11 Not Passed!" severity error;

	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for 200*clk_period;

	-- Test case 12
	-- 12	W	Valid	Dirty	Not equal	cache miss + write current to memory + write new to cache
	s_addr <= "00000000000000000000111010101000";
	s_read <= '0';
	s_write <= '1'; 
	s_writedata <= x"00001111";
	wait until rising_edge(s_waitrequest);

	s_addr <= "00000000000000000000111010101000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"00001111" report "Test 12.1 Not Passed!" severity error;

	s_addr <= "00000000000000000000100010101000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"0F007777" report "Test 12.2 Not Passed!" severity error;

	s_read <= '0';                                                       
	s_write <= '0'; 
	wait for 200*clk_period;

	-- Test case 13+14

	-- 13	W	Invalid	Clean	Equal	cache miss + write to cache
	-- 14	W	Invalid	Clean	not equal	cache miss + write to cache
	s_addr <= "00000000000000000000100111100000";
	s_read <= '0';
	s_write <= '1'; 
	s_writedata <= x"11111111";
	wait until rising_edge(s_waitrequest); 

	s_addr <= "00000000000000000000100111100000";
	s_read <= '1';
	s_write <= '0'; 
	wait until rising_edge(s_waitrequest);
	assert s_readdata = x"11111111" report "Test 13/14 Not Passed!" severity error;

	s_read <= '0';                                                       
	s_write <= '0'; 
	wait;


	-- 15	W	Invalid	Dirty	Equal	impossible case
	-- 16	W	Invalid	Dirty	Not equal	impossible case



end process;
	
end;
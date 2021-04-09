library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
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
	m_waitrequest : in std_logic;

	cache_tag : OUT std_logic_vector (5 downto 0);
	access_tag : OUT std_logic_vector (5 downto 0)
);
end cache;

architecture arch of cache is

-- 31 downto 9: tag (32 - 5 - 4 = 23, only 6 bits used, others ignored)
-- 8 downto 4: cache block index (determin the block in cache, 4096/128 = 32 => 5 bits needed)
-- 3 downto 0: in-block offset (1 block = 4 word = 128 bit)
	-- 3 downto 2: word offset (1 word = 4 byte = 32 bit)
	-- 1 downto 0: byte offset (1 byte = 8 bit)

type state_type is (scheduler, read_from_cache, s_read_req, s_write_req, write_to_cache, memory_access, write_back, load2Cache, wait_load);
signal state: state_type;

signal next_state: state_type;
--signal read_done ;
--signal write_done;

-- 32 blocks, 4 word/block
-- 32*4 + 2 + 23 = 153 bit/block
-- 1 valid bit and 1 dirty bit per block
-- 152: 			valid bit
-- 151: 			dirty bit
-- 150 downto 128: 	tag
-- 127 downto 0:	data
	-- 31 downto 0: 	word 0
	-- 63 downto 32: 	word 1
	-- 95 downto 64: 	word 2
	-- 127 downto 96: 	word 3

type cache_structure is array (31 downto 0) of std_logic_vector (135 downto 0);
signal cache: cache_structure;

begin

-- setup reset, clock, and basic state
setup: process (clock, reset)
begin

	if reset = '1' then
		state <= scheduler;
	elsif (clock'event and clock = '1') then
		state <= next_state;
	end if;

end process;


FSM: process (s_read, s_write, m_waitrequest, state)

	-- main memory 32768 bytes = 2^15 bytes
	variable address: std_logic_vector (14 downto 0);
	variable block_offset: std_logic_vector (3 downto 0);
	variable block_index: integer;
	-- preserve the reading or writing state for load to cache
	variable doing_write: std_logic;
	variable doing_read: std_logic;
	variable byte_counter: integer := 0; -- maximum 15 byte/block

	variable mem_access_done: std_logic := '1';
	variable read_done: std_logic;
	variable write_done: std_logic;
	variable word_offset: integer;

begin

	-- map defined variable to port input signal
	block_offset := s_addr(3 downto 0);
	word_offset := to_integer(unsigned(s_addr(3 downto 2)));
	block_index :=  to_integer(unsigned(s_addr(8 downto 4)));
	cache_tag <= cache(block_index)(133 downto 128);
	access_tag <= s_addr(14 downto 9);
	case state is

		when scheduler =>

			-- defalt to be high
			s_waitrequest <= '1';
			if s_read = '1' then
				--doing_read := '1';
				next_state <= s_read_req;
			elsif s_write = '1' then
				--doing_write := '1';
				next_state <= s_write_req;
			else
				next_state <= scheduler;
			end if;

		when s_read_req =>

			-- check tag, if same, read directly; else, access memory
			if ((cache(block_index)(133 downto 128) = s_addr(14 downto 9))) then
				if cache(block_index)(135) = '1' then
					next_state <= read_from_cache;
				end if;
			else
				next_state <= memory_access;
			end if;

		when s_write_req =>

		-- check tag, if same, write directly; else, access memory
			if ((cache(block_index)(133 downto 128) = s_addr(14 downto 9)) and cache(block_index)(135) = '1') then
				next_state <= write_to_cache;
			else
				next_state <= memory_access;
			end if;

		-- 127 downto 0:	data
			-- upper downto lower
			-- 31 downto 0: 	word 0
			-- 63 downto 32: 	word 1
			-- 95 downto 64: 	word 2
			-- 127 downto 96: 	word 3
		when read_from_cache =>
			cache_tag <= cache(block_index)(133 downto 128);
			s_readdata <= cache(block_index)((word_offset+1)*32-1 downto word_offset*32);
			s_waitrequest <= '0';
			--read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
			next_state <= scheduler;

		-- write and set valid and dirty bit to 1
		when write_to_cache =>
			cache(block_index)((word_offset+1)*32-1 downto word_offset*32) <= s_writedata;
			cache(block_index)(135) <= '1';
			cache(block_index)(134) <= '1';
			-- update tag (might be redundant)
			cache(block_index)(133 downto 128) <= s_addr(14 downto 9);
			s_waitrequest <= '0';
			next_state <= scheduler;

		-- if the block is dirty, write back to memory, else direct load to cache
		when memory_access =>
			if cache(block_index)(134) = '1' then
				next_state <= write_back;
			else
				next_state <= load2Cache;
			end if;

		when write_back =>
			if (m_waitrequest = '1') and (byte_counter = 0) then
				-- find memory address
				-- 6 bit tag + 5 bit block index + 4 bit offset = 15 bit target address in memory
				address := cache(block_index)(133 downto 128) & s_addr(8 downto 4) & "0000";
				m_addr <= to_integer(unsigned(address)) + byte_counter;
				m_read <= '0';
				m_write <= '1';
				m_writedata <= cache(block_index)((byte_counter+1)*8-1 downto byte_counter*8);
				byte_counter := byte_counter + 1;
				next_state <= write_back;
				--report "m_waitrequest = 1";
			-- wait for the last write to complete
			elsif ((m_waitrequest'event and rising_edge(m_waitrequest)) and (byte_counter < 16)) then
				-- find memory address
				-- 6 bit tag + 5 bit block index + 4 bit offset = 15 bit target address in memory
				address := cache(block_index)(133 downto 128) & s_addr(8 downto 4) & "0000";
				m_addr <= to_integer(unsigned(address)) + byte_counter;
				m_read <= '0';
				m_write <= '1';
				m_writedata <= cache(block_index)((byte_counter+1)*8-1 downto byte_counter*8);
				byte_counter := byte_counter + 1;
				next_state <= write_back;
				--report "m_waitrequest = 0";
			-- exit loop
			elsif byte_counter = 16 then

				cache(block_index)(135) <= '0';
				--m_addr <= 0;
				m_write <= '0';
				byte_counter := 0;
				next_state <= load2Cache;
				--report "byte_counter = 16";
			-- memory return waitrequest = 0 after each write
			else
				m_write <= '0';
				next_state <= write_back;
				--report "write_back";
			end if;

		when wait_load =>
			if m_waitrequest'event and falling_edge(m_waitrequest) then
				cache(block_index)((byte_counter+1)*8-1 downto byte_counter*8) <= m_readdata;
				byte_counter := byte_counter + 1;
				m_read <= '0';
				next_state <= load2Cache;
			else
				next_state <= wait_load;
			end if;

		when load2Cache =>
			if (m_waitrequest = '1') and (byte_counter < 16) then

				-- find memory address
				-- 6 bit tag + 5 bit block index + 4 bit offset = 15 bit target address in memory
				address := s_addr(14 downto 4) & "0000";
				m_addr <= to_integer(unsigned(address(14 downto 0))) + byte_counter;
				m_read <= '1';
				m_write <= '0';
				--if m_waitrequest'event and rising_edge(m_waitrequest) then
					--cache(block_index)((byte_counter+1)*8-1 downto byte_counter*8) <= m_readdata;
					--report "successfully read from memory";
					--byte_counter := byte_counter + 1;
				--end if;
				next_state <= wait_load;
				--report "m_waitrequest = 1";
			-- wait for the last write to complete
			--elsif ((m_waitrequest'event and rising_edge(m_waitrequest)) and (byte_counter < 16)) then
				---- find memory address
				---- 6 bit tag + 5 bit block index + 4 bit offset = 15 bit target address in memory
				--address := s_addr(14 downto 4) & "0000";
				--m_addr <= to_integer(unsigned(address(14 downto 0))) + byte_counter;
				--m_read <= '1';
				--m_write <= '0';
				--if m_waitrequest'event and rising_edge(m_waitrequest) then
					--cache(block_index)((byte_counter+1)*8-1 downto byte_counter*8) <= m_readdata;
					--report "successfully read from memory";
					--byte_counter := byte_counter + 1;
				--end if;
				--next_state <= load2Cache;
				--report "m_waitrequest = 0";
			-- exit loop
			elsif byte_counter = 16 then


				--m_addr <= 0;
				m_read <= '0';
				m_write <= '0';
				byte_counter := 0;
				-- need to update valid dirty and tag
				cache(block_index)(135) <= '1';
				cache(block_index)(134) <= '0';
				cache(block_index)(133 downto 128) <= s_addr(14 downto 9);
				-- lead to appropriate next stage (read-from-cache or write-to-cache)
				if s_write = '1' then
					--doing_write := '0';
					next_state <= write_to_cache;
				elsif s_read = '1' then
					--doing_read := '0';
					next_state <= read_from_cache;
				end if ;
				--report"byte_counter = 16";
			-- memory return waitrequest = 0 after each write
			else
				next_state <= load2Cache;
				--report"else";
			end if;

	end case;

end process;



end arch;

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
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is

-- declare signals here

type state_type is (initial, cache_read, cache_write, read_load, writeback, write_load);

signal state : state_type;
signal state_next : state_type;

-- for cache:
-- 32-bit words , 128-bit blocks (4 words), 4096-bit of data storage
-- meaning 4096/128 = 32 blocks in the cache

-- for each block:
-- 128 bit for storage (bit 0-127)
-- 23 bit for tag (32 - 4 - 5 = 23 bit, bit 128 - 150)
-- 1 bit for dirty (bit 151)
-- 1 bit for valid (bit 152)
type cache_type is array (0 to 31) of std_logic_vector (152 downto 0);

signal cache_array: cache_type;

begin

-- make circuits here

clock_process : process(clock, reset)
begin
	if reset = '1' then
		state <= initial;
	elsif rising_edge(clock) then
		state <= state_next;
	end if;
		
end process;


state_machine : process(s_read, s_write, m_waitrequest, state)

	variable counter : INTEGER := 0;
	
	-- declare segment of memory
	variable word_offset : INTEGER :=0;   -- holding address bit 2 and 3 from the 32bit s_addr
	variable index : INTEGER :=0;		-- holding the value of bit 4-8 from 32bit addr
	variable tag : std_logic_vector (22 downto 0);	-- hold the rest 23 bits

	-- declare some intermediate signals
	variable old_address: std_logic_vector (27 downto 0);	-- a 28bit vector used when writing cache conent back to the memory
	variable from_writeback : INTEGER :=0;		-- a boolean flag to trigger load from memory, indicates whether the prev state is writeback (for write operation
							-- another load is requried after writeback)
	variable read_issued : INTEGER :=0;		-- a flag regulating the load flow.

begin

	-- segmenting memory address for cache uses
	word_offset := to_integer(unsigned (s_addr (3 downto 2)));
	index := to_integer(unsigned(s_addr(8 downto 4)));
	tag := s_addr (31 downto 9);
	
	case state is 
		
		when initial =>
			-- stall the cache i/o, indicating a task has begun
			s_waitrequest <= '1';
		
			-- check r/w requests
			if s_write = '1' then
				state_next <= cache_write;
			elsif s_read = '1' then
				state_next <= cache_read;
			else
				state_next <= initial;
			end if;	


		when cache_write =>

			-- if miss + clean, need to load from memory for the content to write
			if (cache_array(index)(152) /= '1' or cache_array(index)(150 downto 128) /= s_addr (31 downto 9)) 
				and cache_array(index)(151) /= '1' then
				if m_waitrequest = '1' then 
					m_read <= '1';
					m_addr <= to_integer(unsigned(s_addr(14 downto 4)))*16 + counter;
					state_next <= write_load;
				else
					state_next <= cache_write;
				end if;
			
			-- if the last state is writeback, then a similar process of loading is required
			-- here in cache_write, we issue the read request to memory
			-- when the state jumps to write_load, we will get the memory output data
			elsif from_writeback = 1 then
				if m_waitrequest = '1' then 
					m_read <= '1';
					m_addr <= to_integer(unsigned(s_addr(14 downto 4)))*16 + counter;
					state_next <= write_load;
				else
					state_next <= cache_write;
				end if;
				
			-- this is write hit (valid + tag hit)
			-- whether or not is dirty is not important here
			-- then this is a direct cache write without memory interaction
			elsif cache_array(index)(152) = '1' and cache_array(index)(150 downto 128) = s_addr (31 downto 9) then
				
				-- set content
				cache_array(index)( (word_offset+1)*32 -1 downto word_offset*32 ) <= s_writedata;
				-- set tag
				cache_array(index)(150 downto 128) <= tag;

				--set bits
				cache_array(index)(151) <= '1'; -- dirty
				cache_array(index)(152) <= '1'; -- valid
				s_waitrequest <= '0';

				state_next <= initial;
			
			-- rest of the situation: mainly (valid and miss + dirty)
			else 
				state_next <= writeback;
			end if;

		when cache_read =>
			-- read valid + tag hit
			-- thus directly read from cache and get the output
			if cache_array(index)(152) = '1' and
				cache_array(index)(150 downto 128) = s_addr (31 downto 9) then
				s_readdata <= cache_array(index)((word_offset+1)*32 -1 downto word_offset*32);
				s_waitrequest <= '0';
				state_next <= initial;
				
			-- miss and dirty, need write back
			elsif cache_array(index)(151) = '1' then
				state_next <= writeback;
			
			-- miss and clean, directly replace the memory
			else 
				state_next <= read_load;
			end if;

		
		when writeback =>
			-- In every writeback, we make sure that the entire block is loaded back. Each block is 16 byte 
			if counter < 16 and m_waitrequest = '1' then
				old_address := cache_array(index)(150 downto 128)& s_addr(8 downto 4);
				m_addr <= to_integer(unsigned( old_address))*16 + counter;	-- use the tag and index to find the address of the old content in cache
				m_write <= '1';
				m_writedata <= cache_array(index)( (counter+1)*8 -1 downto counter*8);
				counter := counter  + 1;
				state_next <= writeback;
			
			elsif counter = 16 then		-- 16 byte finished writing
				if s_write = '1' then
					-- if the request is write, trigger the process of load for write
					counter := 0;
					from_writeback := 1;
					m_write <= '0';
					state_next <= cache_write;
				else			
					-- if the request is read, trigger the provess of read_load
					counter := 0;
					m_write <= '0';
					state_next <= read_load;
				end if;
			-- latch in this state until the memory is ready for another write
			else
				m_write <= '0';
				state_next <= writeback;
			end if;
		
		when write_load =>
			-- if memory has something for output (m_waitrequest = '0')
			-- then keep take in byte until finished loading all 16 bytes
			if m_waitrequest = '0' and counter < 15 then
				cache_array(index)( (counter+1)*8 -1 downto counter*8) <= m_readdata;
				counter := counter + 1;
				m_read <= '0';
				state_next <= cache_write;	-- jump back to state cache_write, since the memory request is issued in cache_write
			elsif m_waitrequest = '0' and counter = 15 then
				cache_array(index)( (counter+1)*8 -1 downto counter*8) <= m_readdata;
				m_read <= '0';
				counter := counter + 1;
				state_next <= write_load;
			-- all 16 bytes are retrieved from memory
			-- the final step is to set flags to valid and clean, and also set the new tag
			elsif counter = 16 then
				counter := 0;
				cache_array(index)(152) <= '1'; -- valid
				cache_array(index)(151) <= '0'; -- clean
				cache_array(index)(150 downto 128) <= tag;
				from_writeback := 0;
				state_next <= cache_write;
			end if;

		when read_load =>
			-- if the memory is idle, and also we are not waiting for the previous read to respond (read_issued = 0)
			-- then issue a read
			if m_waitrequest = '1' and read_issued = 0 and counter < 16 then
				m_read <= '1';
				m_addr <= to_integer(unsigned(s_addr(14 downto 4)))*16 + counter;
				read_issued := 1;	-- indicating a read is in progress
				state_next <= read_load;
			-- if the memory is not responding, but a read is issued
			-- wait for that read
			elsif m_waitrequest = '1' and read_issued = 1 then
				state_next <= read_load;
			-- when memory responds
			-- we load the memory output byte into cache
			elsif m_waitrequest = '0' and counter < 16 then
				cache_array(index)( (counter+1)*8 -1 downto counter*8) <= m_readdata;
				counter := counter + 1;
				m_read <= '0';
				read_issued := 0;	-- this read is complete, reset the flag to trigger the next read
				state_next <= read_load;
			
			-- when all 16 read finished, set flag to valid and clean, and set the new tag in cache
			elsif counter = 16 then
				counter := 0;
				cache_array(index)(152) <= '1'; -- valid
				cache_array(index)(151) <= '0'; -- clean
				cache_array(index)(150 downto 128) <= tag;
				
				state_next <= cache_read;
			end if;
			
	end case;


end process;






end arch;
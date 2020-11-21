----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- BRAM 
--
-- ZX-Uno needs SRAM. We don't have that on the MEGA65, so we emulate it by
-- using a BRAM that is clocked 4x faster than the system clock
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram is
generic (
   ADDR_WIDTH  : integer;
   DATA_WIDTH  : integer
);
port (
   clk         : in std_logic;
   address     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
   data        : inout std_logic_vector(DATA_WIDTH - 1 downto 0);
   we_n        : in std_logic
);
end bram;

architecture beh of bram is

constant RAM_DEPTH : integer := 2**ADDR_WIDTH;
type RAM is array (0 to RAM_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

signal   mem         : RAM;
signal   data_out    : std_logic_vector (DATA_WIDTH - 1 downto 0);
signal   address_int : integer;
  
begin

   data <= data_out when we_n = '1' else (others => 'Z');
   address_int <= to_integer(unsigned(address));

   mem_read_write : process(clk)
   begin
      if rising_edge(clk) then
         if we_n = '0' then
            mem(address_int) <= data;
         end if;
         
         data_out <= mem(address_int);
      end if;
   end process;
   
end beh;

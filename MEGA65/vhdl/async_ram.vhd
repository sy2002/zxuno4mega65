----------------------------------------------------------------------------------
-- Asynchronous RAM
--
-- ZX-Uno needs SRAM. We don't have that on the MEGA65, so we emulate it.
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port in 2020 by sy2002
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity async_ram is
generic (
   ADDR_WIDTH  : integer := 17;
   DATA_WIDTH  : integer := 8
);
port (
   clk         : in std_logic;
   address     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
   data        : inout std_logic_vector(DATA_WIDTH - 1 downto 0);
   we_n        : in std_logic
);
end async_ram;

architecture beh of async_ram is

constant RAM_DEPTH : integer := 2**ADDR_WIDTH;
type RAM is array (0 to RAM_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

signal   mem         : RAM;
signal   data_out    : std_logic_vector (DATA_WIDTH - 1 downto 0);
signal   address_int : integer;
  
begin

   data <= data_out;
   address_int <= to_integer(unsigned(address));

   mem_write : process(clk)
   begin
      if falling_edge(clk) then
         if we_n = '0' then
            mem(address_int) <= data;
         end if;
      end if;
   end process;

   mem_read : process(mem, address_int, we_n)
   begin
      if we_n = '1' then
         data_out <= mem(address_int);
      else
         data_out <= (others => 'Z');
      end if;
   end process;
   
end beh;

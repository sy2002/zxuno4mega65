----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- BRAM 
--
-- ZX-Uno needs SRAM. We don't have that on the MEGA65, so we emulate it by
-- using a BRAM that is clocked with the system clock
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity zxbram is
generic (
   ADDR_WIDTH  : integer;
   DATA_WIDTH  : integer
);
port (
   clk         : in std_logic;
   address     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
   data_in     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
   data_out    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
   we_n        : in std_logic
);
end zxbram;

architecture beh of zxbram is

constant RAM_DEPTH : integer := 2**ADDR_WIDTH - 96 * 1024;
type RAM is array (0 to RAM_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

signal   mem         : RAM;
signal   address_int : integer;
  
begin

   address_int <= to_integer(unsigned(address));

   mem_read_write : process(clk)
   begin
      if rising_edge(clk) then
         if we_n = '0' then
            mem(address_int) <= data_in;
         end if;
         
         data_out <= mem(address_int);
      end if;
   end process;
   
end beh;

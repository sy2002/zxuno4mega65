----------------------------------------------------------------------------------
-- ZX-Uno on a Nexys4 DDR board
--
-- Top Module for synthesizing the whole machine
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- Nexys and MEGA65 port in 2020 by sy2002
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_nexys is
port (
   CLK         : in std_logic;                      -- 100 MHz clock
   RESET_N     : in std_logic;                      -- CPU reset button (negative, i.e. 0 = reset)
   
   -- 7 segment display: common anode and cathode
   SSEG_AN     : out std_logic_vector(7 downto 0);  -- common anode: selects digit
   SSEG_CA     : out std_logic_vector(7 downto 0);  -- cathode: selects segment within a digit 

   -- serial communication
   UART_RXD    : in std_logic;                      -- receive data
   UART_TXD    : out std_logic;                     -- send data
   UART_RTS    : in std_logic;                      -- (active low) equals cts from dte, i.e. fpga is allowed to send to dte
   UART_CTS    : out std_logic;                     -- (active low) clear to send (dte is allowed to send to fpga)   
   
   -- switches and LEDs
   SWITCHES    : in std_logic_vector(15 downto 0);  -- 16 on/off "dip" switches
   LEDs        : out std_logic_vector(15 downto 0); -- 16 LEDs
   
   -- PS/2 keyboard
   PS2_CLK     : in std_logic;
   PS2_DAT     : in std_logic;

   -- VGA
   VGA_RED     : out std_logic_vector(3 downto 0);
   VGA_GREEN   : out std_logic_vector(3 downto 0);
   VGA_BLUE    : out std_logic_vector(3 downto 0);
   VGA_HS      : out std_logic;
   VGA_VS      : out std_logic;
   
   -- SD Card
   SD_RESET    : out std_logic;
   SD_CLK      : out std_logic;
   SD_MOSI     : out std_logic;
   SD_MISO     : in std_logic;
   SD_DAT      : out std_logic_vector(3 downto 1)
); 
end top_nexys;

architecture Behavioral of top_nexys is

signal psram_address    : std_logic_vector(20 downto 0);
signal psram_data       : std_logic_vector(7 downto 0);
signal psram_we_n       : std_logic;

signal ps2_clk_int      : std_logic;
signal ps2_dat_int      : std_logic;
signal mouse_clk_int    : std_logic;
signal mouse_dat_int    : std_logic;

begin
   
   -- fixed outputs
   UART_CTS <= '0';        -- always allow sending to the fpga: basically this means RTS/CTS is not supported
   SD_DAT <= "000";        -- pull DAT1, DAT2 and DAT3 to GND (Nexys' pull-ups by default pull to VDD)
   LEDs(15 downto 1) <= (others => '0');

   zxuno_wrapper : entity work.tld_zxuno_a100t
   port map
   (
      -- assumes 100 MHz system clock and transforms it to 28 MHz
      clk100mhz            => CLK,

      -- VGA: Nexys only supports 4 bit per color channel
      r(5 downto 2)        => VGA_RED,
      g(5 downto 2)        => VGA_GREEN,
      b(5 downto 2)        => VGA_BLUE,
      hsync                => VGA_HS,
      vsync                => VGA_VS,
      
      -- audio
      ear                  => '0',           -- unknown, has something todo with "PZX_PLAYER", what is "PZX_PLAYER"?
      audio_out_left       => open,
      audio_out_right      => open,
      
      -- keyboard and mouse
      
clkps2               => ps2_clk_int,
      dataps2              => ps2_dat_int,
      mouseclk             => mouse_clk_int,
      
mousedata            => mouse_dat_int,

      -- UART
      uart_rx              => UART_RXD,
      uart_tx              => UART_TXD,
      uart_rts             => open,
            
      -- SRAM: we don't have SRAM, so connect to pseudo SRAM component
      sram_addr            => psram_address,
      sram_data            => psram_data,
      sram_we_n            => psram_we_n,
      sram_ub              => open,

      -- SD Card
      sd_cs_n              => SD_RESET,
      sd_clk               => SD_CLK,
      sd_mosi              => SD_MOSI,
      sd_miso              => SD_MISO,
      
      -- joystick
      joy_data             => '0',
      joy_clk              => open,
      joy_load_n           => open,
      
      -- flash
      flash_cs_n           => open,
      flash_mosi           => open, 
      flash_miso           => '0',
         
      testled              => LEDs(0)
   );
  
   pseudo_sram : entity work.async_ram
   generic map
   (
      ADDR_WIDTH  => 17,
      DATA_WIDTH  => 8
   )
   port map
   (
      address     => psram_address(16 downto 0),
      data        => psram_data,
      we_n        => psram_we_n
   );

end Behavioral;

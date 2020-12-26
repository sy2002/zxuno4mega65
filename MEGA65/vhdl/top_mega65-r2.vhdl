----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Nexys 4 DDR development testbed: Top Module for synthesizing the whole machine
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- Nexys and MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEGA65_R2 is
port (
   CLK            : in std_logic;                  -- 100 MHz clock
   RESET_N        : in std_logic;                  -- CPU reset button
   
   -- serial communication (rxd, txd only; rts/cts are not available)
   -- TODO
   UART_RXD    : in std_logic;                     -- receive data
   UART_TXD    : out std_logic;                    -- send data
     
   -- VGA
   VGA_RED        : out std_logic_vector(7 downto 0);
   VGA_GREEN      : out std_logic_vector(7 downto 0);
   VGA_BLUE       : out std_logic_vector(7 downto 0);
   VGA_HS         : out std_logic;
   VGA_VS         : out std_logic;
   
   -- VDAC
   vdac_clk       : out std_logic;
   vdac_sync_n    : out std_logic;
   vdac_blank_n   : out std_logic;
   
   -- MEGA65 smart keyboard controller
   kb_io0         : out std_logic;                 -- clock to keyboard
   kb_io1         : out std_logic;                 -- data output to keyboard
   kb_io2         : in std_logic;                  -- data input from keyboard   
   
   -- SD Card
   SD_RESET       : out std_logic;
   SD_CLK         : out std_logic;
   SD_MOSI        : out std_logic;
   SD_MISO        : in std_logic;
   
   -- Joystick Port 1
   joy_1_up       : in std_logic;
   joy_1_down     : in std_logic;
   joy_1_left     : in std_logic;
   joy_1_right    : in std_logic;
   joy_1_fire     : in std_logic
      
   -- HDMI via ADV7511
--   hdmi_vsync     : out std_logic;
--   hdmi_hsync     : out std_logic;
--   hdmired        : out std_logic_vector(7 downto 0);
--   hdmigreen      : out std_logic_vector(7 downto 0);
--   hdmiblue       : out std_logic_vector(7 downto 0);
   
--   hdmi_clk       : out std_logic;      
--   hdmi_de        : out std_logic;                 -- high when valid pixels being output
   
--   hdmi_int       : in std_logic;                  -- interrupts by ADV7511
--   hdmi_spdif     : out std_logic := '0';          -- unused: GND
--   hdmi_scl       : inout std_logic;               -- I2C to/from ADV7511: serial clock
--   hdmi_sda       : inout std_logic;               -- I2C to/from ADV7511: serial data
   
   -- TPD12S016 companion chip for ADV7511
   --hpd_a          : inout std_logic;
--   ct_hpd         : out std_logic := '1';          -- assert to connect ADV7511 to the actual port
--   ls_oe          : out std_logic := '1';          -- ditto
   
   -- Built-in HyperRAM
--   hr_d           : inout unsigned(7 downto 0);    -- Data/Address
--   hr_rwds        : inout std_logic;               -- RW Data strobe
--   hr_reset       : out std_logic;                 -- Active low RESET line to HyperRAM
--   hr_clk_p       : out std_logic;
   
   -- Optional additional HyperRAM in trap-door slot
--   hr2_d          : inout unsigned(7 downto 0);    -- Data/Address
--   hr2_rwds       : inout std_logic;               -- RW Data strobe
--   hr2_reset      : out std_logic;                 -- Active low RESET line to HyperRAM
--   hr2_clk_p      : out std_logic;
--   hr_cs0         : out std_logic;
--   hr_cs1         : out std_logic   
); 
end MEGA65_R2;

architecture beh of MEGA65_R2 is

signal psram_address    : std_logic_vector(20 downto 0);
signal psram_data       : std_logic_vector(7 downto 0);
signal psram_we_n       : std_logic;

signal ear_int          : std_logic;
signal ps2_clk_int      : std_logic;
signal ps2_dat_int      : std_logic;
signal mouse_clk_int    : std_logic;
signal mouse_dat_int    : std_logic;
signal joy_data_int     : std_logic;
signal joy_clk_int      : std_logic;
signal joy_load_n_int   : std_logic;
signal flash_miso_int   : std_logic;
signal testled_int      : std_logic;

signal vga_red_int      : std_logic_vector(5 downto 0);
signal vga_green_int    : std_logic_vector(5 downto 0);
signal vga_blue_int     : std_logic_vector(5 downto 0);
signal vga_hs_int       : std_logic;
signal vga_vs_int       : std_logic;

signal clk28mhz         : std_logic;   -- system clock & pixel clock

begin
            
   -- fixed inputs to the ZX Uno
   ear_int <= '0';
   mouse_clk_int <= '1';
   mouse_dat_int <= '1';
   ps2_clk_int <= '1';
   ps2_dat_int <= '1';
   joy_clk_int <= '1';
   joy_data_int <= '1';
   joy_load_n_int <= '1';
   flash_miso_int <= '0';
   
   clk_generator : entity work.clk
   port map
   (
      sys_clk_i            => CLK,
      clk28mhz_o           => clk28mhz
   );
      
   zxuno_wrapper : entity work.tld_zxuno_a100t
   port map
   (
      clk28mhz             => clk28mhz,
      reset_n              => RESET_N,

      -- VGA
      r                    => vga_red_int,
      g                    => vga_green_int,
      b                    => vga_blue_int,
      hsync                => vga_hs_int,
      vsync                => vga_vs_int,
      
      -- MEGA65 smart keyboard controller
      kb_io0               => kb_io0,
      kb_io1               => kb_io1,
      kb_io2               => kb_io2,   
            
      -- audio
      ear                  => ear_int,  -- unknown, has something todo with "PZX_PLAYER", what is "PZX_PLAYER"?
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
      joy_data             => joy_data_int,
      joy_clk              => joy_clk_int,
      joy_load_n           => joy_load_n_int,
      
      -- flash
      flash_cs_n           => open,
      flash_mosi           => open, 
      flash_miso           => flash_miso_int,
         
      testled              => testled_int
   );
  
   -- emulate the SRAM that ZX-Uno needs via 512kB of BRAM
   pseudo_sram : entity work.bram
   generic map
   (
      ADDR_WIDTH  => 19, -- 2^19 bytes = 512kB
      DATA_WIDTH  => 8   -- 8 bits
   )
   port map
   (
      clk         => clk28mhz,
      address     => psram_address(18 downto 0),
      data        => psram_data,
      we_n        => psram_we_n
   );
   
   video_signal_latches : process(clk28mhz)
   begin
      if rising_edge(clk28mhz) then
         -- VGA: wire the simplified color system of the VGA component to the VGA outputs         
         VGA_RED     <= vga_red_int & "00";
         VGA_GREEN   <= vga_green_int & "00";
         VGA_BLUE    <= vga_blue_int & "00";
         
         -- VGA horizontal and vertical sync
         VGA_HS      <= vga_hs_int;
         VGA_VS      <= vga_vs_int;
         
         -- HDMI: color signal
--         hdmired     <= vga_r & vga_r & vga_r & vga_r & vga_r & vga_r & vga_r & vga_r;
--         hdmigreen   <= vga_g & vga_g & vga_g & vga_g & vga_g & vga_g & vga_g & vga_g;
--         hdmiblue    <= vga_b & vga_b & vga_b & vga_b & vga_b & vga_b & vga_b & vga_b;
      end if;
   end process;

   -- make the VDAC output the image    
   vdac_sync_n <= '0';
   vdac_blank_n <= '1';   
   vdac_clk <= not clk28mhz; -- inverting the clock leads to a sharper signal for some reason
   
end beh;

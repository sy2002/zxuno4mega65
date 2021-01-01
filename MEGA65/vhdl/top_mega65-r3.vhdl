----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- R3-Version: Top Module for synthesizing the whole machine
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEGA65_R3 is
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
   
   -- Joysticks
   joy_1_up_n     : in std_logic;
   joy_1_down_n   : in std_logic;
   joy_1_left_n   : in std_logic;
   joy_1_right_n  : in std_logic;
   joy_1_fire_n   : in std_logic;
   
   joy_2_up_n     : in std_logic;
   joy_2_down_n   : in std_logic;
   joy_2_left_n   : in std_logic;
   joy_2_right_n  : in std_logic;
   joy_2_fire_n   : in std_logic;
   
   -- 3.5mm analog audio jack
   pwm_l          : out std_logic;
   pwm_r          : out std_logic
   
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
end MEGA65_R3;

architecture beh of MEGA65_R3 is

signal psram_address    : std_logic_vector(20 downto 0);
signal psram_data       : std_logic_vector(7 downto 0);
signal psram_we_n       : std_logic;

signal ear_int          : std_logic;
signal flash_miso_int   : std_logic;

signal vga_red_int      : std_logic_vector(5 downto 0);
signal vga_green_int    : std_logic_vector(5 downto 0);
signal vga_blue_int     : std_logic_vector(5 downto 0);
signal vga_hs_int       : std_logic;
signal vga_vs_int       : std_logic;

signal clk28mhz         : std_logic;   -- system clock & pixel clock

signal j1_up_n          : std_logic;
signal j1_down_n        : std_logic;
signal j1_left_n        : std_logic;
signal j1_right_n       : std_logic;
signal j1_fire_n        : std_logic;
signal j2_up_n          : std_logic;
signal j2_down_n        : std_logic;
signal j2_left_n        : std_logic;
signal j2_right_n       : std_logic;
signal j2_fire_n        : std_logic;
signal joy_null_n       : std_logic;

signal uno_audio_left   : std_logic;
signal uno_audio_right  : std_logic;

begin
            
   -- fixed inputs to the ZX Uno
   ear_int <= '0';
   flash_miso_int <= '0';

   -- joysticks (low-active)
   j1_up_n      <= joy_1_up_n;
   j1_down_n    <= joy_1_down_n;
   j1_left_n    <= joy_1_left_n;
   j1_right_n   <= joy_1_right_n;
   j1_fire_n    <= joy_1_fire_n;
   j2_up_n      <= joy_2_up_n;
   j2_down_n    <= joy_2_down_n;
   j2_left_n    <= joy_2_left_n;
   j2_right_n   <= joy_2_right_n;
   j2_fire_n    <= joy_2_fire_n;   
   joy_null_n   <= '1';
   
   -- 3.5 analog audio jack
   pwm_l        <= uno_audio_left;
   pwm_r        <= uno_audio_right;
   
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
      
      -- Joysticks      
      joy1up               => j1_up_n,
      joy1down             => j1_down_n,
      joy1left             => j1_left_n,
      joy1right            => j1_right_n,
      joy1fire1            => j1_fire_n,   
      joy1fire2            => joy_null_n,
   
      joy2up               => j2_up_n,
      joy2down             => j2_down_n,
      joy2left             => j2_left_n,
      joy2right            => j2_right_n,
      joy2fire1            => j2_fire_n,
      joy2fire2            => joy_null_n,
            
      -- audio
      ear                  => ear_int,  -- unknown, has something todo with "PZX_PLAYER", what is "PZX_PLAYER"?
      audio_out_left       => uno_audio_left,
      audio_out_right      => uno_audio_right,
      
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
           
      -- flash
      flash_cs_n           => open,
      flash_mosi           => open, 
      flash_miso           => flash_miso_int        
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
      end if;
   end process;

   -- make the VDAC output the image    
   vdac_sync_n <= '0';
   vdac_blank_n <= '1';   
   vdac_clk <= not clk28mhz; -- inverting the clock leads to a sharper signal for some reason
   
end beh;

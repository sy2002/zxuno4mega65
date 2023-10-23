----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   port (
      clk_main_i              : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(7 downto 0);
      video_green_o           : out std_logic_vector(7 downto 0);
      video_blue_o            : out std_logic_vector(7 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);
      
      --------------------------------------------------------------------------------------------------------
      -- Bypass M2M's SD card handling because the ZX-Uno core does this by itself
      --------------------------------------------------------------------------------------------------------
   
      sd_reset_o              : out std_logic;
      sd_clk_o                : out std_logic;
      sd_mosi_o               : out std_logic;
      sd_miso_i               : in  std_logic    
   );
end entity main;

architecture synthesis of main is

-- @TODO: Remove these demo core signals
signal keyboard_n          : std_logic_vector(79 downto 0);

signal psram_address    : std_logic_vector(20 downto 0);
signal psram_data_in    : std_logic_vector(7 downto 0);
signal psram_data_out   : std_logic_vector(7 downto 0);
signal psram_we_n       : std_logic;

signal vga_red_int      : std_logic_vector(5 downto 0);
signal vga_green_int    : std_logic_vector(5 downto 0);
signal vga_blue_int     : std_logic_vector(5 downto 0);
signal vga_hs_int       : std_logic;
signal vga_vs_int       : std_logic;
signal vga_clk_en_int   : std_logic;

signal dummy_zero       : std_logic;
signal dummy_one        : std_logic;

signal uno_audio_left   : std_logic_vector(10 downto 0);
signal uno_audio_right  : std_logic_vector(10 downto 0);

begin
   -- fixed inputs to the ZX Uno
   dummy_zero     <= '0';
   dummy_one      <= '1';

   -- Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
   -- Adjusted so that it works on the MEGA65 by sy2002
   i_zxuno_wrapper : entity work.tld_zxuno_a100t
   port map
   (
      clk28mhz             => clk_main_i,
      reset_n              => (not reset_soft_i) and (not reset_hard_i),

      -- VGA
      r                    => vga_red_int,
      g                    => vga_green_int,
      b                    => vga_blue_int,
      hsync                => vga_hs_int,
      vsync                => vga_vs_int,
      vga_clk_en           => vga_clk_en_int,
      
      -- MEGA65 smart keyboard controller
      key_num              => kb_key_num_i,
      key_status_n         => kb_key_pressed_n_i,
      
      -- Joysticks      
      joy1up               => joy_1_up_n_i,
      joy1down             => joy_1_down_n_i,
      joy1left             => joy_1_left_n_i,
      joy1right            => joy_1_right_n_i,
      joy1fire1            => joy_1_fire_n_i,   
      joy1fire2            => dummy_one,
   
      joy2up               => joy_2_up_n_i,
      joy2down             => joy_2_down_n_i,
      joy2left             => joy_2_left_n_i,
      joy2right            => joy_2_right_n_i,
      joy2fire1            => joy_2_fire_n_i,   
      joy2fire2            => dummy_one,

      -- audio
      ear                  => dummy_zero,
      audio_out_left       => uno_audio_left,
      audio_out_right      => uno_audio_right,
      
      -- UART
      uart_rx              => dummy_zero,
      uart_tx              => open,
      uart_rts             => open,
            
      -- SRAM: we don't have SRAM, so connect to pseudo SRAM component
      sram_addr            => psram_address,
      sram_data_in         => psram_data_in,
      sram_data_out        => psram_data_out,
      sram_we_n            => psram_we_n,
      sram_ub              => open,

      -- SD Card
      sd_cs_n              => sd_reset_o,
      sd_clk               => sd_clk_o,
      sd_mosi              => sd_mosi_o,
      sd_miso              => sd_miso_i,
           
      -- flash
      flash_cs_n           => open,
      flash_mosi           => open, 
      flash_miso           => dummy_zero      
   );
   
   -- The ZX-Uno scandoubler regenerates the rather quirky original ZX Spectrum resolution
   -- into something more useable, but it does not output HBlank and VBlank (both of them
   -- are needed by the M2M framework).
   -- See comment "Video timings adjusted by sy2002 in October 2023" in "zx-uno/vga_scandoubler.v"
   -- to learn more about the generics used for i_blank_generator 
   i_blank_generator : entity work.blank_gen
   generic map
   (
      H_PIXELS       => 360,
      H_FRONT_PORCH  => 32,
      H_BACK_PORCH   => 32,
      H_PULSE        => 32,
      V_PIXELS       => 576,
      V_FRONT_PORCH  => 5,
      V_BACK_PORCH   => 39,
      V_PULSE        => 5
   )
   port map
   (
      clk_i          => clk_main_i,
      clk_en_i       => vga_clk_en_int,
   
      -- The ZX-Uno only outputs 18-bits-per-pixel color info, we need to transform to 24bpp         
      red_i          => vga_red_int   & vga_red_int(5 downto 4),
      green_i        => vga_green_int & vga_green_int(5 downto 4),
      blue_i         => vga_blue_int  & vga_blue_int(5 downto 4),
      
      -- The ZX-Uno core outputs negative polarity, M2M expects positive polarity
      hsync_i        => not vga_hs_int,
      vsync_i        => not vga_vs_int,
      
      -- Signals for the M2M framework
      red_o          => video_red_o,
      green_o        => video_green_o,
      blue_o         => video_blue_o,
      hsync_o        => video_hs_o,      
      vsync_o        => video_vs_o,
      hblank_o       => video_hblank_o,
      vblank_o       => video_vblank_o
   );

   -- video_ce_o: You need to make sure that video_ce_o divides clk_main_i such that it transforms clk_main_i
   --             into the pixelclock of the core (means: the core's native output resolution pre-scandoubler)
   -- video_ce_ovl_o: Clock enable for the OSM overlay and for sampling the core's (retro) output in a way that
   --             it is displayed correctly on a "modern" analog input device: Make sure that video_ce_ovl_o
   --             transforms clk_main_o into the post-scandoubler pixelclock that is valid for the target
   --             resolution specified by VGA_DX/VGA_DY (globals.vhd)
   video_ce_o        <= vga_clk_en_int;
   video_ce_ovl_o    <= '1';    
           
   -- emulate the SRAM that ZX-Uno needs via 512kB of BRAM
   i_pseudo_sram : entity work.zxbram
   generic map
   (
      ADDR_WIDTH  => 19, -- 2^19 bytes = 512kB
      DATA_WIDTH  => 8   -- 8 bits
   )
   port map
   (
      clk         => clk_main_i,
      address     => psram_address(18 downto 0),
      data_in     => psram_data_out,
      data_out    => psram_data_in,
      we_n        => psram_we_n
   );
  
   -- ZX Uno outputs signed 11-bit: Convert to signed 16-bit
   -- Use the higher portion of the original to fill the lower bits but do not use the sign bit while doing so,
   -- as this might add distortion and DC offset.
   audio_left_o   <= signed(uno_audio_left  & uno_audio_left(9 downto 5));
   audio_right_o  <= signed(uno_audio_right & uno_audio_right(9 downto 5));

end architecture synthesis;


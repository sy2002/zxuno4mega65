-------------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- ZX-Uno for MEGA65:
-- MEGA65 main file that contains the whole machine
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022, 2023 and licensed under GPL v3
-------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.globals.all;
use work.types_pkg.all;

library xpm;
use xpm.vcomponents.all;

entity MEGA65_Core is
port (
   CLK                     : in  std_logic;              -- 100 MHz clock
   RESET_M2M_N             : in  std_logic;              -- Debounced system reset in system clock domain

   -- Share clock and reset with the framework
   main_clk_o              : out std_logic;              -- ZX-Uno's 28 MHz system clock
   main_rst_o              : out std_logic;              -- ZX-Uno's reset, synchronized

   --------------------------------------------------------------------------------------------------------
   -- QNICE Clock Domain
   --------------------------------------------------------------------------------------------------------

   -- Get QNICE clock from the framework: for the vdrives as well as for RAMs and ROMs
   qnice_clk_i             : in  std_logic;
   qnice_rst_i             : in  std_logic;

   -- Video and audio mode control
   qnice_dvi_o             : out std_logic;              -- 0=HDMI (with sound), 1=DVI (no sound)
   qnice_video_mode_o      : out natural range 0 to 3;   -- HDMI 1280x720 @ 50 Hz resolution = mode 0, 1280x720 @ 60 Hz resolution = mode 1, PAL 576p in 4:3 and 5:4 are modes 2 and 3
   qnice_scandoubler_o     : out std_logic;              -- 0 = no scandoubler, 1 = scandoubler
   qnice_audio_mute_o      : out std_logic;
   qnice_audio_filter_o    : out std_logic;
   qnice_zoom_crop_o       : out std_logic;
   qnice_ascal_mode_o      : out std_logic_vector(1 downto 0);
   qnice_ascal_polyphase_o : out std_logic;
   qnice_ascal_triplebuf_o : out std_logic;
   qnice_retro15kHz_o      : out std_logic;              -- 0 = normal frequency, 1 = retro 15 kHz frequency
   qnice_csync_o           : out std_logic;              -- 0 = normal HS/VS, 1 = Composite Sync  
   qnice_osm_cfg_scaling_o : out std_logic_vector(8 downto 0);

   -- Flip joystick ports
   qnice_flip_joyports_o   : out std_logic;

   -- On-Screen-Menu selections
   qnice_osm_control_i     : in  std_logic_vector(255 downto 0);

   -- QNICE general purpose register
   qnice_gp_reg_i          : in  std_logic_vector(255 downto 0);

   -- Core-specific devices
   qnice_dev_id_i          : in  std_logic_vector(15 downto 0);
   qnice_dev_addr_i        : in  std_logic_vector(27 downto 0);
   qnice_dev_data_i        : in  std_logic_vector(15 downto 0);
   qnice_dev_data_o        : out std_logic_vector(15 downto 0);
   qnice_dev_ce_i          : in  std_logic;
   qnice_dev_we_i          : in  std_logic;
   qnice_dev_wait_o        : out std_logic;

   --------------------------------------------------------------------------------------------------------
   -- Core Clock Domain
   --------------------------------------------------------------------------------------------------------

   -- M2M's reset manager provides 2 signals:
   --    m2m:   Reset the whole machine: Core and Framework
   --    core:  Only reset the core
   main_reset_m2m_i        : in  std_logic;
   main_reset_core_i       : in  std_logic;

   main_pause_core_i       : in  std_logic;

   -- Video output
   video_clk_o             : out std_logic;
   video_rst_o             : out std_logic;
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
   main_audio_left_o       : out signed(15 downto 0);
   main_audio_right_o      : out signed(15 downto 0);

   -- M2M Keyboard interface (incl. drive led)
   main_kb_key_num_i       : in  integer range 0 to 79;  -- cycles through all MEGA65 keys
   main_kb_key_pressed_n_i : in  std_logic;              -- low active: debounced feedback: is kb_key_num_i pressed right now?
   main_power_led_o        : out std_logic;
   main_power_led_col_o    : out std_logic_vector(23 downto 0);
   main_drive_led_o        : out std_logic;
   main_drive_led_col_o    : out std_logic_vector(23 downto 0);

   -- Joysticks input
   main_joy_1_up_n_i       : in  std_logic;
   main_joy_1_down_n_i     : in  std_logic;
   main_joy_1_left_n_i     : in  std_logic;
   main_joy_1_right_n_i    : in  std_logic;
   main_joy_1_fire_n_i     : in  std_logic;

   main_joy_2_up_n_i       : in  std_logic;
   main_joy_2_down_n_i     : in  std_logic;
   main_joy_2_left_n_i     : in  std_logic;
   main_joy_2_right_n_i    : in  std_logic;
   main_joy_2_fire_n_i     : in  std_logic;

   main_pot1_x_i           : in  std_logic_vector(7 downto 0);
   main_pot1_y_i           : in  std_logic_vector(7 downto 0);
   main_pot2_x_i           : in  std_logic_vector(7 downto 0);
   main_pot2_y_i           : in  std_logic_vector(7 downto 0);

   -- On-Screen-Menu selections
   main_osm_control_i      : in  std_logic_vector(255 downto 0);

   -- QNICE general purpose register converted to main clock domain
   main_qnice_gp_reg_i     : in  std_logic_vector(255 downto 0);

   --------------------------------------------------------------------------------------------------------
   -- Provide HyperRAM to core (in HyperRAM clock domain)
   --------------------------------------------------------------------------------------------------------

   hr_clk_i                : in  std_logic;
   hr_rst_i                : in  std_logic;
   hr_core_write_o         : out std_logic := '0';
   hr_core_read_o          : out std_logic := '0';
   hr_core_address_o       : out std_logic_vector(31 downto 0) := (others => '0');
   hr_core_writedata_o     : out std_logic_vector(15 downto 0) := (others => '0');
   hr_core_byteenable_o    : out std_logic_vector( 1 downto 0) := (others => '0');
   hr_core_burstcount_o    : out std_logic_vector( 7 downto 0) := (others => '0');
   hr_core_readdata_i      : in  std_logic_vector(15 downto 0);
   hr_core_readdatavalid_i : in  std_logic;
   hr_core_waitrequest_i   : in  std_logic;
   hr_high_i               : in  std_logic;  -- Core is too fast
   hr_low_i                : in  std_logic;  -- Core is too slow
   
   --------------------------------------------------------------------------------------------------------
   -- Bypass M2M's SD card handling because the ZX-Uno core does this by itself
   --------------------------------------------------------------------------------------------------------

   -- SD Card (internal/bottom)
   sd_int_reset_o          : out std_logic;
   sd_int_clk_o            : out std_logic;
   sd_int_mosi_o           : out std_logic;
   sd_int_miso_i           : in  std_logic;
   sd_int_cd_i             : in  std_logic;
   
   -- SD Card (external/back)
   sd_ext_reset_o          : out std_logic;
   sd_ext_clk_o            : out std_logic;
   sd_ext_mosi_o           : out std_logic;
   sd_ext_miso_i           : in  std_logic;
   sd_ext_cd_i             : in  std_logic
);
end entity MEGA65_Core;

architecture synthesis of MEGA65_Core is

---------------------------------------------------------------------------------------------
-- main_clk (ZX-Uno's core's clock)
---------------------------------------------------------------------------------------------

signal main_clk               : std_logic;               -- Core main clock
signal main_rst               : std_logic;

-- Bypass M2M's SD card handling because the ZX-Uno core does this by itself
signal reset_from_sdmux       : std_logic;
signal sd_active_reset        : std_logic;
signal sd_active_clk          : std_logic;
signal sd_active_mosi         : std_logic;
signal sd_active_miso         : std_logic;

---------------------------------------------------------------------------------------------
-- qnice_clk
---------------------------------------------------------------------------------------------

-- OSM menu items
constant C_MENU_HDMI_16_9_50  : natural := 5;
constant C_MENU_HDMI_16_9_60  : natural := 6;
constant C_MENU_HDMI_4_3_50   : natural := 7;
constant C_MENU_HDMI_5_4_50   : natural := 8;

begin

   ---------------------------------------------------------------------------------------------
   -- main_clk: ZX-Uno's core clock running at 28 MHz
   ---------------------------------------------------------------------------------------------
   
   clk_gen : entity work.clk
      port map (
         sys_clk_i         => CLK,             -- expects 100 MHz
         sys_rstn_i        => RESET_M2M_N,     -- Asynchronous, asserted low
         main_clk_o        => main_clk,        -- ZX-Uno's 28 MHz clock
         main_rst_o        => main_rst         -- ZX-Uno's reset, synchronized
      ); -- clk_gen

   -- Share core clock and video clock with M2M
   main_clk_o  <= main_clk;
   main_rst_o  <= main_rst;
   video_clk_o <= main_clk;
   video_rst_o <= main_rst;

   ---------------------------------------------------------------------------------------------
   -- main_clk (MiSTer core's clock)
   ---------------------------------------------------------------------------------------------

   -- MEGA65's power led: By default, it is on and glows green when the MEGA65 is powered on.
   -- We switch it to blue when a long reset is detected and as long as the user keeps pressing the reset button
   main_power_led_o     <= '1';
   main_power_led_col_o <= x"0000FF" when main_reset_m2m_i else x"00FF00";

   -- MEGA65's drive led: For the time being, we switch it OFF   
   main_drive_led_o     <= '0';
   main_drive_led_col_o <= x"00FF00";  -- 24-bit RGB value for the led

   -- ZX-Uno core
   i_main : entity work.main
      port map (
         clk_main_i           => main_clk,
         reset_soft_i         => main_reset_core_i or reset_from_sdmux,
         reset_hard_i         => main_reset_m2m_i,
         pause_i              => main_pause_core_i,

         clk_main_speed_i     => CORE_CLK_SPEED,

         -- Video output: The ZX-Uno outputs a slightly odd PAL signal
         -- See comment "Video timings adjusted by sy2002 in October 2023" in "zx-uno/vga_scandoubler.v"
         video_ce_o           => video_ce_o,
         video_ce_ovl_o       => video_ce_ovl_o,
         video_red_o          => video_red_o,
         video_green_o        => video_green_o,
         video_blue_o         => video_blue_o,
         video_vs_o           => video_vs_o,
         video_hs_o           => video_hs_o,
         video_hblank_o       => video_hblank_o,
         video_vblank_o       => video_vblank_o,

         -- audio output (pcm format, signed values)
         audio_left_o         => main_audio_left_o,
         audio_right_o        => main_audio_right_o,

         -- M2M Keyboard interface
         kb_key_num_i         => main_kb_key_num_i,
         kb_key_pressed_n_i   => main_kb_key_pressed_n_i,

         -- MEGA65 joysticks and paddles/mouse/potentiometers
         joy_1_up_n_i         => main_joy_1_up_n_i ,
         joy_1_down_n_i       => main_joy_1_down_n_i,
         joy_1_left_n_i       => main_joy_1_left_n_i,
         joy_1_right_n_i      => main_joy_1_right_n_i,
         joy_1_fire_n_i       => main_joy_1_fire_n_i,

         joy_2_up_n_i         => main_joy_2_up_n_i,
         joy_2_down_n_i       => main_joy_2_down_n_i,
         joy_2_left_n_i       => main_joy_2_left_n_i,
         joy_2_right_n_i      => main_joy_2_right_n_i,
         joy_2_fire_n_i       => main_joy_2_fire_n_i,

         pot1_x_i             => main_pot1_x_i,
         pot1_y_i             => main_pot1_y_i,
         pot2_x_i             => main_pot2_x_i,
         pot2_y_i             => main_pot2_y_i,
         
         --------------------------------------------------------------------------------------------------------
         -- Bypass M2M's SD card handling because the ZX-Uno core does this by itself
         --------------------------------------------------------------------------------------------------------

         sd_reset_o           => sd_active_reset,
         sd_clk_o             => sd_active_clk,
         sd_mosi_o            => sd_active_mosi,
         sd_miso_i            => sd_active_miso
   ); -- i_main
   
   -- SD Card multiplexer: Back slot takes precedence, any change in SD card config leads to a reset
   i_zxuno_sdmux : entity work.zxuno_sdmux
      port map (
         clk_i                => main_clk,
         
         -- See @TODO above: currently we need to reset the machine if the SD card configuration changes
         reset_core_o         => reset_from_sdmux,
              
         -- interface to bottom tray's SD card
         sd_tray_detect_n_i   => sd_int_cd_i,
         sd_tray_reset_o      => sd_int_reset_o,
         sd_tray_clk_o        => sd_int_clk_o,
         sd_tray_mosi_o       => sd_int_mosi_o,
         sd_tray_miso_i       => sd_int_miso_i,
         
         -- interface to the SD card in the back slot
         sd_back_detect_n_i   => sd_ext_cd_i,
         sd_back_reset_o      => sd_ext_reset_o,
         sd_back_clk_o        => sd_ext_clk_o,
         sd_back_mosi_o       => sd_ext_mosi_o,
         sd_back_miso_i       => sd_ext_miso_i,
         
         -- interface to the ZX-Uno core
         sd_active_reset_i    => sd_active_reset,
         sd_active_clk_i      => sd_active_clk,
         sd_active_mosi_i     => sd_active_mosi,
         sd_active_miso_o     => sd_active_miso 
      ); -- i_zxuno-sdmux

   ---------------------------------------------------------------------------------------------
   -- Audio and video settings (QNICE clock domain)
   ---------------------------------------------------------------------------------------------

   -- Due to a discussion on the MEGA65 discord (https://discord.com/channels/719326990221574164/794775503818588200/1039457688020586507)
   -- we decided to choose a naming convention for the PAL modes that might be more intuitive for the end users than it is
   -- for the programmers: "4:3" means "meant to be run on a 4:3 monitor", "5:4 on a 5:4 monitor".
   -- The technical reality is though, that in our "5:4" mode we are actually doing a 4/3 aspect ratio adjustment
   -- while in the 4:3 mode we are outputting a 5:4 image. This is kind of odd, but it seemed that our 4/3 aspect ratio
   -- adjusted image looks best on a 5:4 monitor and the other way round.
   -- Not sure if this will stay forever or if we will come up with a better naming convention.
   qnice_video_mode_o <= 3 when qnice_osm_control_i(C_MENU_HDMI_5_4_50)  = '1' else
                         2 when qnice_osm_control_i(C_MENU_HDMI_4_3_50)  = '1' else
                         1 when qnice_osm_control_i(C_MENU_HDMI_16_9_60) = '1' else
                         0;

   -- Use On-Screen-Menu selections to configure several audio and video settings
   -- Video and audio mode control
   qnice_dvi_o                <= '0';  -- 0=HDMI (with sound), 1=DVI (no sound)
   qnice_scandoubler_o        <= '0';  -- ZX-Uno uses a built-in scandoubler and outputs PAL 576p @ 50 Hz
   qnice_audio_mute_o         <= '0';  -- audio is not muted
   qnice_audio_filter_o       <= '0';  -- 0 = raw audio, 1 = use filters from globals.vhd
   qnice_zoom_crop_o          <= '0';  -- 0 = no zoom/crop
   
   -- These two signals are often used as a pair (i.e. both '1'), particularly when
   -- you want to run old analog cathode ray tube monitors or TVs (via SCART)
   -- If you want to provide your users a choice, then a good choice is:
   --    "Standard VGA":                     qnice_retro15kHz_o=0 and qnice_csync_o=0
   --    "Retro 15 kHz with HSync and VSync" qnice_retro15kHz_o=1 and qnice_csync_o=0
   --    "Retro 15 kHz with CSync"           qnice_retro15kHz_o=1 and qnice_csync_o=1
   qnice_retro15kHz_o         <= '0';
   qnice_csync_o              <= '0';
   qnice_osm_cfg_scaling_o    <= (others => '1');

   -- ascal filters that are applied while processing the input
   -- 00 : Nearest Neighbour
   -- 01 : Bilinear
   -- 10 : Sharp Bilinear
   -- 11 : Bicubic
   qnice_ascal_mode_o         <= "00";

   -- If polyphase is '1' then the ascal filter mode is ignored and polyphase filters are used instead
   -- @TODO: Right now, the filters are hardcoded in the M2M framework, we need to make them changeable inside m2m-rom.asm
   qnice_ascal_polyphase_o    <= '0';

   -- ascal triple-buffering
   -- @TODO: Right now, the M2M framework only supports OFF, so do not touch until the framework is upgraded
   qnice_ascal_triplebuf_o    <= '0';

   -- Flip joystick ports (i.e. the joystick in port 2 is used as joystick 1 and vice versa)
   qnice_flip_joyports_o      <= '0';

   ---------------------------------------------------------------------------------------------
   -- Core specific device handling (QNICE clock domain)
   ---------------------------------------------------------------------------------------------

   core_specific_devices : process(all)
   begin
      -- make sure that this is x"EEEE" by default and avoid a register here by having this default value
      qnice_dev_data_o     <= x"EEEE";
      qnice_dev_wait_o     <= '0';

      case qnice_dev_id_i is

         -- @TODO YOUR RAMs or ROMs (e.g. for cartridges) or other devices here
         -- Device numbers need to be >= 0x0100

         when others => null;
      end case;
   end process core_specific_devices;

   ---------------------------------------------------------------------------------------------
   -- Dual Clocks
   ---------------------------------------------------------------------------------------------

   -- <no dual clocks used at this moment>

end architecture synthesis;


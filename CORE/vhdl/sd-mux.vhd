----------------------------------------------------------------------------------
-- ZX-Uno for MEGA65
--
-- Smart SD Card multiplexer:
--
-- Activate the bottom tray's SD card, if there is no SD card in the slot on the
-- machine's back side. Otherwise the back side slot has precedence.
--
-- @TODO: In future we might find smarter ways to interact with the ZX-Uno
-- core's SD card controller and with esxDOS. But for now, we always need to
-- reset the whole machine as soon as the user changes the currently active
-- SD card, so that the file browser continues to work. 
--
-- CAVEAT: RIGHT NOW WE CANNOT DETECT THE TRAY SD CARD on R3 machines. This
-- is a PCB bug and it has been fixed on R3A machines.
--
-- done by sy2002 in 2023 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.globals.all;

entity zxuno_sdmux is
   port (
      clk_i                : in std_logic;
      
      -- See @TODO above: currently we need to reset the machine if the SD card configuration changes
      reset_core_o         : out std_logic;
           
      -- interface to bottom tray's SD card
      sd_tray_detect_n_i   : in std_logic;
      sd_tray_reset_o      : out std_logic;
      sd_tray_clk_o        : out std_logic;
      sd_tray_mosi_o       : out std_logic;
      sd_tray_miso_i       : in std_logic;
      
      -- interface to the SD card in the back slot
      sd_back_detect_n_i   : in std_logic;
      sd_back_reset_o      : out std_logic;
      sd_back_clk_o        : out std_logic;
      sd_back_mosi_o       : out std_logic;
      sd_back_miso_i       : in std_logic;
      
      -- interface to the ZX-Uno core
      sd_active_reset_i    : in std_logic;
      sd_active_clk_i      : in std_logic;
      sd_active_mosi_i     : in std_logic;
      sd_active_miso_o     : out std_logic       
   );
end zxuno_sdmux;

architecture beh of zxuno_sdmux is

constant COLDSTART_WAIT          : natural := 100;  -- clock pulses until we check the SD card detection line for the first time
constant DEBOUNCE_DURATION       : natural := 500;  -- milliseconds stable time
constant RESET_DURATION          : natural := 1000; -- reset duration in clock pulses

signal   cold_start_wait_cnt     : natural := COLDSTART_WAIT;
signal   wait_for_debounce_cnt   : natural;
signal   reset_counter           : natural;

type tSDMux_States is ( s_cold_start,
                        s_wait_for_initial_debounce,
                        s_idle,
                        s_perform_reset
                      );
                      
signal mux_state        : tSDMux_States := s_cold_start;

-- currently active SD card: 0=internal / 1=external
signal active           : std_logic := '0';

-- high active, debounced card detect signal for the back ("external" card
signal back_card_detect : std_logic := '0';

begin

   i_sd_card_detect_debouncer : entity work.debounce
      generic map (
         clk_freq       => CORE_CLK_SPEED,
         stable_time    => DEBOUNCE_DURATION
      )
      port map (
         clk            => clk_i,
         reset_n        => '1',
         button         => not sd_back_detect_n_i, -- low active
         result         => back_card_detect        -- high active
      );

   -- re-wire ZX-Uno's inputs/outputs according to the currently active SD card
   connect_sd_cards : process(all)
   begin
      if active = '0' then
         sd_tray_reset_o   <= sd_active_reset_i;
         sd_tray_clk_o     <= sd_active_clk_i;
         sd_tray_mosi_o    <= sd_active_mosi_i;
         sd_active_miso_o  <= sd_tray_miso_i;
         
         sd_back_reset_o   <= '1';
         sd_back_clk_o     <= '0';
         sd_back_mosi_o    <= '0';
      else
         sd_back_reset_o   <= sd_active_reset_i;
         sd_back_clk_o     <= sd_active_clk_i;
         sd_back_mosi_o    <= sd_active_mosi_i;
         sd_active_miso_o  <= sd_back_miso_i;
         
         sd_tray_reset_o   <= '1';
         sd_tray_clk_o     <= '0';
         sd_tray_mosi_o    <= '0';
      end if;
   end process;

   fsm_handle_sd_card_changes : process(clk_i)
   begin
      if rising_edge(clk_i) then
         reset_core_o <= '0';
         case mux_state is
         
            -- during cold start of the core, we do not use the debounced signal for not
            -- introducing any delay, and we are also not adding another reset to the reset logic
            when s_cold_start =>
               if cold_start_wait_cnt /= 0 then
                  cold_start_wait_cnt <= cold_start_wait_cnt - 1;
               else
                  if active /= (not sd_back_detect_n_i)  then
                     active                <= not sd_back_detect_n_i;
                     mux_state             <= s_wait_for_initial_debounce;
                     wait_for_debounce_cnt <= (CORE_CLK_SPEED/1000) * (DEBOUNCE_DURATION + 50);
                  else
                     mux_state             <= s_idle;
                  end if;
               end if;
                  
            -- during cold start, we need to wait for the debouncer to finish its work for making
            -- sure that as soon as we arrive at s_idle, in case there is a card inserted at the
            -- back, active will equal to back_card_detect
            -- we are adding 50 ms of buffer to DEBOUNCE_DURATION
            when s_wait_for_initial_debounce =>
               if wait_for_debounce_cnt /= 0 then
                  wait_for_debounce_cnt <= wait_for_debounce_cnt - 1;
               else
                  mux_state <= s_idle;
               end if;
               
            -- in normal operation, we are using the debounced signal
            -- since 0=internal and 1=external, we can set active to back_card_detect 
            when s_idle =>
               if active /= back_card_detect then
                  active         <= back_card_detect;
                  mux_state      <= s_perform_reset;
                  reset_counter  <= RESET_DURATION;
               end if;
               
            -- see @TODO in the comment at the top of this entity
            when s_perform_reset =>
               if reset_counter /= 0 then
                  reset_counter <= reset_counter - 1;
                  reset_core_o  <= '1';
               else
                  mux_state     <= s_idle;
               end if;
         
            when others => null;
         end case;
      end if;
   end process;
   
end beh;

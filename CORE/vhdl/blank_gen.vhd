--------------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Generate HBlank and VBlank from HSync and VSync. Assumes ZX-Uno's very specific
-- PAL 576 @ 50 Hz output signal, i.e. the constants for front porch, back porch and
-- pulse are fine tunes to the ZX-Uno.
--
-- Expects positive polarity for the inputs and outputs positive polarity.
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 & 2023 and licensed under GPL v3
--------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity blank_gen is
   port (
      clk_i           : in std_logic;
      clk_en_i        : in std_logic;
      hsync_i         : in std_logic;
      vsync_i         : in std_logic;
      hblank_o        : out std_logic;
      vblank_o        : out std_logic
   );
end blank_gen;

architecture beh of blank_gen is

constant H_PIXELS      : integer := 360;
constant H_FRONT_PORCH : integer := 17;
constant H_BACK_PORCH  : integer := 63;
constant H_PULSE       : integer := 64;

constant V_PIXELS      : integer := 576;
constant V_FRONT_PORCH : integer := 5;
constant V_BACK_PORCH  : integer := 39;
constant V_PULSE       : integer := 5;

 signal h_counter      : integer range 0 to 1023 := 0;
 signal v_counter      : integer range 0 to 1023 := 0;
 signal v_reset        : std_logic := '0';
 signal prev_hsync     : std_logic := '0';
 signal prev_vsync     : std_logic := '0';

begin
    p_blank_generator : process(clk_i)
    begin
        if rising_edge(clk_i) then
         if clk_en_i = '1' then

            prev_hsync <= hsync_i;
            prev_vsync <= vsync_i;
         
            -- Detect rising edge of HSync
            if prev_hsync = '0' and hsync_i = '1' then
                h_counter <= 0;
                
               -- Detect rising edge of VSync
               if v_reset = '1' then
                   v_reset   <= '0';
                   v_counter <= 0;
               else
                   v_counter <= v_counter + 1;
               end if;
            else
               h_counter <= h_counter + 1;
            end if;

            -- Detect rising edge of VSync
            if prev_vsync = '0' and vsync_i = '1' then
                v_reset <= '1';
            end if;

            -- Generate HBlank
            if h_counter <   H_PULSE + H_BACK_PORCH or
               h_counter >=  H_PULSE + H_BACK_PORCH + H_PIXELS then
                  hblank_o <= '1';
            else
                  hblank_o <= '0';
            end if;

            -- Generate VBlank
            if v_counter <  V_PULSE + V_BACK_PORCH or
               v_counter >= V_PULSE + V_BACK_PORCH + V_PIXELS then
                  vblank_o <= '1';
            else
                  vblank_o <= '0';
            end if;
         end if;
      end if;
    end process;

end beh;

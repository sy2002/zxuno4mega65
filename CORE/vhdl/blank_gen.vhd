----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- HBlank and VBlank generator
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2023 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity blank_gen is
   generic (
      H_PIXELS        : integer;
      H_FRONT_PORCH   : integer;
      H_BACK_PORCH    : integer;
      H_PULSE         : integer;
      V_PIXELS        : integer;
      V_FRONT_PORCH   : integer;
      V_BACK_PORCH    : integer;
      V_PULSE         : integer      
   );
   port (
      clk_i           : in std_logic;
      clk_en_i        : in std_logic;
      
      red_i           : in std_logic_vector(7 downto 0);
      green_i         : in std_logic_vector(7 downto 0);
      blue_i          : in std_logic_vector(7 downto 0);
      hsync_i         : in std_logic;
      vsync_i         : in std_logic;
      
      red_o           : out std_logic_vector(7 downto 0);
      green_o         : out std_logic_vector(7 downto 0);
      blue_o          : out std_logic_vector(7 downto 0);
      hsync_o         : out std_logic;      
      vsync_o         : out std_logic;      
      hblank_o        : out std_logic;
      vblank_o        : out std_logic
   );
end blank_gen;

architecture beh of blank_gen is

type stage_t is record
   red         : std_logic_vector(7 downto 0);
   green       : std_logic_vector(7 downto 0);
   blue        : std_logic_vector(7 downto 0);
   hsync       : std_logic;
   vsync       : std_logic;
end record stage_t;

signal stage1          : stage_t;
signal stage2          : stage_t;

signal h_counter       : integer range 0 to 1023 := 0;
signal v_counter       : integer range 0 to 1023 := 0;
signal v_reset         : std_logic := '0';
signal prev_hsync      : std_logic := '0';
signal prev_vsync      : std_logic := '0';
 
begin

   red_o    <= stage2.red;
   green_o  <= stage2.green;
   blue_o   <= stage2.blue;
   hsync_o  <= stage2.hsync;
   vsync_o  <= stage2.vsync;

   p_blank_generator : process(clk_i)
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then

            -- delay RGBHV by two clock cycles to compensate for the
            -- latency of the HBlank/VBlank generation
            stage1.red     <= red_i;
            stage1.green   <= green_i;
            stage1.blue    <= blue_i;
            stage1.hsync   <= hsync_i;
            stage1.vsync   <= vsync_i;
            stage2         <= stage1;

            -- Detect rising edge of HSync
            prev_hsync <= hsync_i;
            prev_vsync <= vsync_i;            
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

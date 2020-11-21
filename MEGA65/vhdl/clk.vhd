----------------------------------------------------------------------------------
-- ZX-Uno port for MEGA65
--
-- Clock Generator 
--
-- Converts the 100 MHz clock of the MEGA65 to the 28 MHz system clock of
-- the ZX-Uno and also outputs a 4x 28 MHz = 112 MHz clock for the simulated SRAM
--
-- The machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
-- MEGA65 port done by sy2002 in 2020 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity clk is
   port (
      sys_clk_i      : in  std_logic;
      clk28mhz_o     : out std_logic;
      clk112mhz_o    : out std_logic
   );
end clk;

architecture rtl of clk is

   signal clkfb         : std_logic;
   signal clkfb_mmcm    : std_logic;
   signal clk28_mmcm    : std_logic;
   signal clk112_mmcm   : std_logic;

begin

   i_mmcme2_adv : MMCME2_ADV
      generic map (
         BANDWIDTH            => "OPTIMIZED",
         CLKOUT4_CASCADE      => FALSE,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => FALSE,
         CLKIN1_PERIOD        => 10.0,       -- INPUT @ 100 MHz
         REF_JITTER1          => 0.010,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => 8.960,      -- scale to 896 MHz because it can be devided to produce 28 MHz as well as 112 MHz
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => FALSE,
         CLKOUT0_DIVIDE_F     => 32.0,       -- 896 MHz / 32 = 28 MHz 
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_USE_FINE_PS  => FALSE,
         CLKOUT1_DIVIDE       => 8,          -- 896 MHz / 8 = 112 MHz = 4 * 28 MHz
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.500,
         CLKOUT1_USE_FINE_PS  => FALSE
      )
      port map (
         -- Output clocks
         CLKFBOUT            => clkfb_mmcm,
         CLKOUT0             => clk28_mmcm,
         CLKOUT1             => clk112_mmcm,
         -- Input clock control
         CLKFBIN             => clkfb,
         CLKIN1              => sys_clk_i,
         CLKIN2              => '0',
         -- Tied to always select the primary input clock
         CLKINSEL            => '1',
         -- Ports for dynamic reconfiguration
         DADDR               => (others => '0'),
         DCLK                => '0',
         DEN                 => '0',
         DI                  => (others => '0'),
         DO                  => open,
         DRDY                => open,
         DWE                 => '0',
         -- Ports for dynamic phase shift
         PSCLK               => '0',
         PSEN                => '0',
         PSINCDEC            => '0',
         PSDONE              => open,
         -- Other control and status signals
         LOCKED              => open,
         CLKINSTOPPED        => open,
         CLKFBSTOPPED        => open,
         PWRDWN              => '0',
         RST                 => '0'
      );


   -------------------------------------
   -- Output buffering
   -------------------------------------

   clkfb_bufg : BUFG
   port map (
      I => clkfb_mmcm,
      O => clkfb
   );

   clk28_bufg : BUFG
   port map (
      I => clk28_mmcm,
      O => clk28mhz_o
   );
   
   clk224_bufg : BUFG
   port map (
      I => clk112_mmcm,
      O => clk112mhz_o
   );
   

end architecture rtl;


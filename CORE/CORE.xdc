## ZX-Uno for MEGA65 (zxuno4mega65)
##
## This machine is based on Miguel Angel Rodriguez Jodars ZX-Uno (Artix version)
## Powered by MiSTer2MEGA65
## MEGA65 port done by sy2002 & MJoergen in 2020/21 and 2023/24 and licensed under GPL v3


## Name Autogenerated Clocks
## Important: Using them in subsequent statements, e.g. clock dividers requires that they
## have been named/defined here before
## otherwise Vivado does not find the pins)
create_generated_clock -name main_clk      [get_pins CORE/clk_gen/i_clk_main/CLKOUT0]
# Add more clocks here, if needed


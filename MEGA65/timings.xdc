
# Contraints de tiempo
#create_clock -period 20.000 -name clk50mhz [get_ports clk50mhz]

#set_property IOB TRUE [all_inputs]
#set_property IOB TRUE [all_outputs]

#set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.CCLKPIN PULLNONE [current_design]
#set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
#set_property BITSTREAM.CONFIG.CCLK_TRISTATE FALSE [current_design]

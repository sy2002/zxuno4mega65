# Pines y estandares de niveles logicos
#Clock
set_property PACKAGE_PIN U22 [get_ports clk50mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk50mhz]

#Leds y Botones
set_property PACKAGE_PIN J19 [get_ports testled]
set_property IOSTANDARD LVCMOS33 [get_ports testled]

#Keyboard and mouse
set_property PACKAGE_PIN T2 [get_ports clkps2]
set_property IOSTANDARD LVCMOS33 [get_ports clkps2]
set_property PULLUP true [get_ports clkps2]
set_property PACKAGE_PIN R2 [get_ports dataps2]
set_property IOSTANDARD LVCMOS33 [get_ports dataps2]
set_property PACKAGE_PIN N1 [get_ports mouseclk]
set_property IOSTANDARD LVCMOS33 [get_ports mouseclk]
set_property PULLUP true [get_ports dataps2]
set_property PACKAGE_PIN R1 [get_ports mousedata]
set_property IOSTANDARD LVCMOS33 [get_ports mousedata]
set_property PULLUP true [get_ports mousedata]

# Video output
set_property IOSTANDARD LVCMOS33 [get_ports {r g b *sync}]
set_property PACKAGE_PIN K23 [get_ports hsync]
set_property PACKAGE_PIN K25 [get_ports vsync]
set_property PACKAGE_PIN D26 [get_ports {b[5]}]
set_property PACKAGE_PIN D25 [get_ports {b[4]}]
set_property PACKAGE_PIN G26 [get_ports {b[3]}]
set_property PACKAGE_PIN E23 [get_ports {b[2]}]
set_property PACKAGE_PIN F22 [get_ports {b[1]}]
set_property PACKAGE_PIN J26 [get_ports {b[0]}]

set_property PACKAGE_PIN G21 [get_ports {r[5]}]
set_property PACKAGE_PIN H21 [get_ports {r[4]}]
set_property PACKAGE_PIN H22 [get_ports {r[3]}]
set_property PACKAGE_PIN K21 [get_ports {r[2]}]
set_property PACKAGE_PIN J21 [get_ports {r[1]}]
set_property PACKAGE_PIN K26 [get_ports {r[0]}]

set_property PACKAGE_PIN E25 [get_ports {g[5]}]
set_property PACKAGE_PIN H26 [get_ports {g[4]}]
set_property PACKAGE_PIN F23 [get_ports {g[3]}]
set_property PACKAGE_PIN G22 [get_ports {g[2]}]
set_property PACKAGE_PIN J25 [get_ports {g[1]}]
set_property PACKAGE_PIN G20 [get_ports {g[0]}]

#Audio
set_property IOSTANDARD LVCMOS33 [get_ports {audio_out_* ear}]
set_property PACKAGE_PIN K22 [get_ports audio_out_left]
set_property PACKAGE_PIN M26 [get_ports audio_out_right]
set_property PACKAGE_PIN A5 [get_ports ear]

#Joystick
set_property IOSTANDARD LVCMOS33 [get_ports joy_*]
set_property PACKAGE_PIN AB26 [get_ports joy_clk]
set_property PACKAGE_PIN AC26 [get_ports joy_load_n]
set_property PACKAGE_PIN Y26 [get_ports joy_data]

#SRAM
set_property IOSTANDARD LVTTL [get_ports sram_*]
set_property SLEW SLOW [get_ports sram_*]
set_property PACKAGE_PIN N26 [get_ports {sram_addr[0]}]
set_property PACKAGE_PIN L22 [get_ports {sram_addr[1]}]
set_property PACKAGE_PIN P26 [get_ports {sram_addr[2]}]
set_property PACKAGE_PIN M24 [get_ports {sram_addr[3]}]
set_property PACKAGE_PIN N21 [get_ports {sram_addr[4]}]
set_property PACKAGE_PIN P25 [get_ports {sram_addr[5]}]
set_property PACKAGE_PIN Y23 [get_ports {sram_addr[6]}]
set_property PACKAGE_PIN W23 [get_ports {sram_addr[7]}]
set_property PACKAGE_PIN T25 [get_ports {sram_addr[8]}]
set_property PACKAGE_PIN V21 [get_ports {sram_addr[9]}]
set_property PACKAGE_PIN P23 [get_ports {sram_addr[10]}]
set_property PACKAGE_PIN V23 [get_ports {sram_addr[11]}]
set_property PACKAGE_PIN M25 [get_ports {sram_addr[12]}]
set_property PACKAGE_PIN Y22 [get_ports {sram_addr[13]}]
set_property PACKAGE_PIN R26 [get_ports {sram_addr[14]}]
set_property PACKAGE_PIN W25 [get_ports {sram_addr[15]}]
set_property PACKAGE_PIN AB24 [get_ports {sram_addr[16]}]
set_property PACKAGE_PIN AC24 [get_ports {sram_addr[17]}]
set_property PACKAGE_PIN W21 [get_ports {sram_addr[18]}]
set_property PACKAGE_PIN J4 [get_ports {sram_addr[19]}]
set_property PACKAGE_PIN A3 [get_ports {sram_addr[20]}]

#set_property PACKAGE_PIN N22 [get_ports {sram_data[0]}]
#set_property PACKAGE_PIN U21 [get_ports {sram_data[1]}]
#set_property PACKAGE_PIN P24 [get_ports {sram_data[2]}]
#set_property PACKAGE_PIN R25 [get_ports {sram_data[3]}]
#set_property PACKAGE_PIN L23 [get_ports {sram_data[4]}]
#set_property PACKAGE_PIN AA25 [get_ports {sram_data[5]}]
#set_property PACKAGE_PIN Y25 [get_ports {sram_data[6]}]
#set_property PACKAGE_PIN Y21 [get_ports {sram_data[7]}]
set_property PACKAGE_PIN M5 [get_ports {sram_data[0]}]
set_property PACKAGE_PIN K1 [get_ports {sram_data[1]}]
set_property PACKAGE_PIN J1 [get_ports {sram_data[2]}]
set_property PACKAGE_PIN K5 [get_ports {sram_data[3]}]
set_property PACKAGE_PIN N3 [get_ports {sram_data[4]}]
set_property PACKAGE_PIN L5 [get_ports {sram_data[5]}]
set_property PACKAGE_PIN P3 [get_ports {sram_data[6]}]
set_property PACKAGE_PIN M6 [get_ports {sram_data[7]}]
set_property PACKAGE_PIN T24 [get_ports sram_we_n]
set_property PACKAGE_PIN E26 [get_ports sram_ub]

#SD
set_property IOSTANDARD LVCMOS33 [get_ports {sd_* flash_*}]
set_property PACKAGE_PIN P5 [get_ports sd_cs_n]
set_property PACKAGE_PIN T4 [get_ports sd_miso]
set_property PULLUP true [get_ports sd_miso]
set_property PACKAGE_PIN P6 [get_ports sd_mosi]
set_property PACKAGE_PIN T3 [get_ports sd_clk]

#Flash SPI
set_property PACKAGE_PIN P18 [get_ports flash_cs_n]
# DQ1
set_property PACKAGE_PIN R15 [get_ports flash_miso]
# DQ0
set_property PACKAGE_PIN R14 [get_ports flash_mosi]

#UART
set_property IOSTANDARD LVCMOS33 [get_ports uart_*]
set_property PACKAGE_PIN B2 [get_ports uart_rx]
set_property PACKAGE_PIN E1 [get_ports uart_tx]
set_property PACKAGE_PIN H9 [get_ports uart_rts]


`timescale 1ns / 1ns
`default_nettype none

//    This file is part of the ZXUNO Spectrum core. 
//    Creation date is 02:28:18 2014-02-06 by Miguel Angel Rodriguez Jodar
//    (c)2014-2020 ZXUNO association.
//    ZXUNO official repository: http://svn.zxuno.com/svn/zxuno
//    Username: guest   Password: zxuno
//    Github repository for this core: https://github.com/mcleod-ideafix/zxuno_spectrum_core
//
//    ZXUNO Spectrum core is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    ZXUNO Spectrum core is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with the ZXUNO Spectrum core.  If not, see <https://www.gnu.org/licenses/>.
//
//    Any distributed copy of this file must keep this notice intact.

module tld_zxuno_a100t (
   input wire clk28mhz,
   input wire reset_n,

   output wire [5:0] r,
   output wire [5:0] g,
   output wire [5:0] b,
   output wire hsync,
   output wire vsync,
   output wire vga_clk_en,
   
   input wire ear,
   
   // modified by sy2002 to output a signed 11-bit signal as M2M expects a 16-bit signed signal
   output wire [10:0] audio_out_left,
   output wire [10:0] audio_out_right,   
   
   //M2M keyboard interface
   input wire [6:0] key_num,
   input wire key_status_n,   
            
   //Joysticks
   input wire joy1up,
   input wire joy1down,
   input wire joy1left,
   input wire joy1right,
   input wire joy1fire1,   
   input wire joy1fire2,
   
   input wire joy2up,
   input wire joy2down,
   input wire joy2left,
   input wire joy2right,
   input wire joy2fire1,
   input wire joy2fire2,
                  
   //output wire midi_out,
   //input wire clkbd,
   //input wire wsbd,
   //input wire dabd,    

   output wire uart_tx,
   input wire uart_rx,
   output wire uart_rts,
//   output wire uart_reset,

   //output wire stdn,
   //output wire stdnb,
   
   output wire [20:0] sram_addr,
   input wire [7:0] sram_data_in,
   output wire [7:0] sram_data_out,
   output wire sram_we_n,
   output wire sram_ub,
   
   output wire flash_cs_n,
   //output wire flash_clk,   // este pin se maneja desde el STARTUPE2
   output wire flash_mosi,
   input wire flash_miso,
   
   output wire sd_cs_n,    
   output wire sd_clk,     
   output wire sd_mosi,    
   input wire sd_miso
   );

   wire flash_clk;

   wire [2:0] ri, gi, bi, ro, go, bo;
   wire hsync_pal, vsync_pal, csync_pal;
   wire vga_enable, scanlines_enable;
   wire clk14en_tovga;
   
   assign vga_clk_en = clk14en_tovga;
   
   zxuno #(.FPGA_MODEL(3'b111), .MASTERCLK(28000000)) la_maquina (
    .sysclk(clk28mhz),
    .power_on_reset_n(reset_n),  // s�lo para simulaci�n. Para implementacion, dejar a 1
    .r(ri),
    .g(gi),
    .b(bi),
    .hsync(hsync_pal),
    .vsync(vsync_pal),
    .csync(csync_pal),
    .ear_ext(~ear),  // negada porque el hardware tiene un transistor inversor
    .audio_out_left(audio_out_left),
    .audio_out_right(audio_out_right),
    
    .key_num(key_num),
    .key_status_n(key_status_n),
   
    .midi_out(),
    .clkbd(),
    .wsbd(),
    .dabd(),
    
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),
    .uart_rts(uart_rts),

    .sram_addr(sram_addr),
    .sram_data_in(sram_data_in),
    .sram_data_out(sram_data_out),
    .sram_we_n(sram_we_n),
    
    .flash_cs_n(flash_cs_n),
    .flash_clk(flash_clk),
    .flash_di(flash_mosi), 
    .flash_do(flash_miso),
    
    .sd_cs_n(sd_cs_n),
    .sd_clk(sd_clk),
    .sd_mosi(sd_mosi),
    .sd_miso(sd_miso),
    
    .joy1up(joy1up),
    .joy1down(joy1down),
    .joy1left(joy1left),
    .joy1right(joy1right),
    .joy1fire1(joy1fire1),
    .joy1fire2(joy1fire2),    
	 
    .joy2up(joy2up),
    .joy2down(joy2down),
    .joy2left(joy2left),
    .joy2right(joy2right),
    .joy2fire1(joy2fire1),
    .joy2fire2(joy2fire2),    
    
    .clk14en_tovga(clk14en_tovga),
    .vga_enable(vga_enable),
    .scanlines_enable(scanlines_enable),
    .freq_option(),
    
    .ad724_xtal(),
    .ad724_mode()
    );

	vga_scandoubler #(.CLKVIDEO(14000)) salida_vga (
    .clk(clk28mhz),
    .clk14en(clk14en_tovga),
    .enable_scandoubling(vga_enable),
    .disable_scaneffect(~scanlines_enable),
    .ri(ri),
    .gi(gi),
    .bi(bi),
    .hsync_ext_n(hsync_pal),
    .vsync_ext_n(vsync_pal),
    .csync_ext_n(csync_pal),
    .ro(ro),
    .go(go),
    .bo(bo),
    .hsync(hsync),
    .vsync(vsync)
   );	 
       
   //assign uart_reset = 1'bz;
   assign sram_ub = 1'b0;
   
   assign r = {ro, ro};
   assign g = {go, go};
   assign b = {bo, bo};
   
   // Access to CCLK pin
   STARTUPE2 #(.PROG_USR("FALSE"), .SIM_CCLK_FREQ(0.0)) STARTUPE2_inst (
     .CFGCLK(),
     .CFGMCLK(),
     .EOS(),
     .PREQ(),
     .CLK(1'b0),
     .GSR(1'b0),
     .GTS(1'b0),
     .KEYCLEARB(1'b1),
     .PACK(1'b0),
     .USRCCLKO(flash_clk),
     .USRCCLKTS(1'b0),
     .USRDONEO(1'b1),
     .USRDONETS(1'b0)
   );
endmodule

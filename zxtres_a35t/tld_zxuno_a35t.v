`timescale 1ns / 1ns
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:28:18 02/06/2014 
// Design Name: 
// Module Name:    test1 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module tld_zxuno_a35t (
   input wire clk50mhz,

   output wire [5:0] r,
   output wire [5:0] g,
   output wire [5:0] b,
   output wire hsync,
   output wire vsync,
   //input wire ear,
   inout wire clkps2,
   inout wire dataps2,
   inout wire mouseclk,
   inout wire mousedata,
   output wire audio_out_left,
   output wire audio_out_right,
   //output wire stdn,
   //output wire stdnb,
   //output wire flash_ext1,
   //output wire flash_ext2,
   
   output wire [18:0] sram_addr,
   inout wire [7:0] sram_data,
   output wire sram_we_n,
   
   output wire flash_cs_n,
   output wire flash_clk,
   output wire flash_mosi,
   input wire flash_miso,
   
   input wire joy_data,
   output wire joy_clk,
   output wire joy_load_n,
   
   output wire sd_cs_n,    
   output wire sd_clk,     
   output wire sd_mosi,    
   input wire sd_miso,
   output wire testled   // nos servirá como testigo de uso de la SPI
   );

   wire sysclk;
   
   //clock_generator relojes_maestros
   relojes_mmcm relojes_maestros
   (// Clock in ports
    .CLK_IN1            (clk50mhz),
    // Clock out ports
    .CLK_OUT1           (sysclk),
    .CLK_OUT2           (),
    
    .reset(1'b0),
    .locked()
    );

   wire [2:0] ri, gi, bi;
   wire [2:0] ro, go, bo;
   wire hsync_pal, vsync_pal, csync_pal;   
   
   wire [20:0] sram_addr_2mb;
   assign sram_addr = sram_addr_2mb[18:0];
   
   wire vga_enable, scanlines_enable, clk14en;
   
   wire joy1up, joy1down, joy1left, joy1right, joy1fire1, joy1fire2;
   wire joy2up, joy2down, joy2left, joy2right, joy2fire1, joy2fire2;

   joydecoder decodificador_joysticks (
    .clk(sysclk),
    .joy_data(joy_data),
    .joy_latch_megadrive(1'b1),
    .joy_clk(joy_clk),
    .joy_load_n(joy_load_n),
    .joy1up(joy1up),
    .joy1down(joy1down),
    .joy1left(joy1left),
    .joy1right(joy1right),
    .joy1fire1(joy1fire1),
    .joy1fire2(joy1fire2),
    .joy1fire3(),
    .joy1start(),
    .joy2up(joy2up),
    .joy2down(joy2down),
    .joy2left(joy2left),
    .joy2right(joy2right),
    .joy2fire1(joy2fire1),
    .joy2fire2(joy2fire2),
    .joy2fire3(),
    .joy2start()    
   );   

   zxuno #(.MASTERCLK(28000000), .FPGA_MODEL(3'b011)) la_maquina (
    .sysclk(sysclk),
    .power_on_reset_n(1'b1),  // sólo para simulación. Para implementacion, dejar a 1
    .r(ri),
    .g(gi),
    .b(bi),
    .hsync(hsync_pal),
    .vsync(vsync_pal),
    .csync(csync_pal),
    .clkps2(clkps2),
    .dataps2(dataps2),
    .ear_ext(1'b0/*~ear*/),  // negada porque el hardware tiene un transistor inversor
    .audio_out_left(audio_out_left),
    .audio_out_right(audio_out_right),

    .midi_out(),
    .clkbd(1'b0),
    .wsbd(1'b0),
    .dabd(1'b0),    
  
    .uart_tx(),
    .uart_rx(1'b1),
    .uart_rts(),

    .sram_addr(sram_addr_2mb),
    .sram_data(sram_data),
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

    .mouseclk(mouseclk),
    .mousedata(mousedata),
    
    .vga_enable(vga_enable),
    .scanlines_enable(scanlines_enable),
    .freq_option(),
    .clk14en_tovga(clk14en),
    
    .ad724_xtal(),
    .ad724_mode(),
    .ad724_enable_gencolorclk()
    );

  vga_scandoubler #(.CLKVIDEO(14000)) salida_vga (
   .clk(sysclk),
   .clkcolor4x(1'b1),
   .clk14en(clk14en),
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
   
   assign r = {ro, ro};
   assign g = {go, go};
   assign b = {bo, bo};
       
   assign testled = flash_cs_n & sd_cs_n;
   //assign flash_ext1 = 1'b1;
   //assign flash_ext2 = 1'b1;

endmodule

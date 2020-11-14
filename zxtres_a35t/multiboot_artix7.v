module multiboot (
    input wire clk,
    input wire rst_n,
    input wire [7:0] zxuno_addr,
    input wire regaddr_changed,
    input wire zxuno_regrd,
    input wire zxuno_regwr,
    input wire [7:0] din,
    output reg [7:0] dout,
    output reg oe
    );
    
    parameter ADDR_COREADDR = 8'hFC,
              ADDR_COREBOOT = 8'hFD;
              
    parameter GOLDEN_CORE = 24'h0100000; // posición del core de Spectrum en la flash
              
    reg [23:0] spi_addr = GOLDEN_CORE;   // default value
    reg writting_to_spi_addr = 1'b0;
    reg writting_to_bootcore = 1'b0;
    reg boot_core = 1'b0;

    reg reading_from_spi_addr = 1'b0;
    reg [1:0] spi_addr_chunk = 2'b00; // which part of COREADDR to output
    reg [7:0] addrout = 8'h00;
    
    always @* begin
      dout = 8'hFF;
      oe = 1'b0;
      if (zxuno_addr == ADDR_COREADDR && zxuno_regrd ==1'b1) begin
        dout = addrout;
        oe = 1'b1;
      end
    end  

    always @(posedge clk) begin
        if (rst_n == 1'b0 || (regaddr_changed && zxuno_addr == ADDR_COREADDR)) begin
          writting_to_spi_addr <= 1'b0;
          writting_to_bootcore <= 1'b0;
          reading_from_spi_addr <= 1'b0;
          spi_addr_chunk <= 2'b00;
          boot_core <= 1'b0;
        end
        else begin
            if (zxuno_addr == ADDR_COREADDR) begin
              if (zxuno_regwr == 1'b1 && writting_to_spi_addr == 1'b0) begin
                  spi_addr <= {spi_addr[15:0], din};
                  writting_to_spi_addr <= 1'b1;
              end
              if (zxuno_regwr == 1'b0) begin
                  writting_to_spi_addr <= 1'b0;
              end
              if (zxuno_regrd == 1'b1 && reading_from_spi_addr == 1'b0) begin
                addrout <= (spi_addr_chunk == 2'b00)? spi_addr[23:16] :
                           (spi_addr_chunk == 2'b01)? spi_addr[15:8] :
                                                      spi_addr[7:0];
                spi_addr_chunk <= (spi_addr_chunk == 2'b10)? 2'b00 : spi_addr_chunk + 2'b01;
                reading_from_spi_addr <= 1'b1;
              end   
              if (zxuno_regrd == 1'b0) begin
                reading_from_spi_addr <= 1'b0;
              end                  
            end
            else begin
              writting_to_spi_addr <= 1'b0;
              reading_from_spi_addr <= 1'b0;
            end
            
            if (zxuno_addr == ADDR_COREBOOT) begin
                if (zxuno_regwr == 1'b1 && din[0] == 1'b1 && writting_to_bootcore == 1'b0) begin
                    boot_core <= 1'b1;
//                    writting_to_bootcore <= 1'b1;
                end
//                if (zxuno_regwr == 1'b0) begin
//                    writting_to_bootcore <= 1'b0;
//                end
            end
            else begin
//                boot_core <= 1'b0;
                writting_to_bootcore <= 1'b0;
            end
        end
    end

//    reg [4:0] q = 5'b00000;
//    always @(posedge clk_icap)
//      q <= {q[3:0], boot_core};
//    wire reboot_ff = (q == 5'b10000);

   reg regclkicap = 1'b0;
	 wire clk_icap;
	 always @(posedge clk)
	   regclkicap <= ~regclkicap;
	 BUFG bufclkicap (.I(regclkicap), .O(clk_icap) );

    wire icap_ce, icap_we;
    wire [31:0] icap_data;
    multiboot_artix7 el_multiboot (
      .clk(clk_icap),
      .spi_address({8'h00,spi_addr}),  // aqui suponemos que la dirección puesta son los bits 31 a 8
      .reboot(boot_core/*reboot_ff*/),
      .icap_ce(icap_ce),
      .icap_we(icap_we),
      .icap_data(icap_data)
    );
    
    icape el_icap (
      .clk(clk_icap),
      .ce(icap_ce),
      .we(icap_we),
      .din(icap_data)
    );  
endmodule            
    
// When using ICAPE2 to set the WBSTAR address, the 24 most significant address bits
// should be written to WBSTAR[23:0]. For SPI 32-bit addressing mode, WBSTAR[23:0]
// are sent as address bits [31:8]. The lower 8 bits of the address are undefined and
// the value could be as high as 0xFF. Any bitstream at the WBSTAR address should 
// contain 256 dummy bytes before the start of the bitstream.

// The software option spi_32bit_addr is used to generate a bitstream that can address 
// flash densities over 128 Mb. This option must be used consistently for all bitstreams 
// used for fallback MultiBoot such that all bitstreams have the option enabled if the SPI 
// flash is over 128 Mb or all bitstreams have it disabled if the SPI flash is 128 Mb or lower.

module multiboot_artix7 (
  input wire clk,
  input wire [31:0] spi_address,
  input wire reboot,
  output reg icap_ce,
  output reg icap_we,
  output reg [31:0] icap_data
  );
  
  reg [33:0] icap_command[0:15];
  localparam CYCLE_SPI_ADDRESS = 4'd4;
  initial begin  // Lista de comandos en UG470, p. 145
    icap_command[ 0] = {1'b0, 1'b0, 32'hFFFFFFFF};
    icap_command[ 1] = {1'b1, 1'b1, 32'hAA995566};  // sync word
    icap_command[ 2] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[ 3] = {1'b1, 1'b1, 32'h30020001};  // escritura en registro WBSTAR
    icap_command[ 4] = {1'b1, 1'b1, 32'h00000100};  // en este ciclo hay que poner la dirección SPI (28 bits)
    icap_command[ 5] = {1'b1, 1'b1, 32'h30008001};  // escritura en registro CMD
    icap_command[ 6] = {1'b1, 1'b1, 32'h0000000F};  // dar orden de warm reboot (IPROG)
    icap_command[ 7] = {1'b1, 1'b1, 32'h20000000};  // nop 
    icap_command[ 8] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[ 9] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[10] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[11] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[12] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[13] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[14] = {1'b1, 1'b1, 32'h20000000};  // nop
    icap_command[15] = {1'b1, 1'b1, 32'h20000000};  // nop
  end
  
  reg [4:0] indx = 5'b00000;
  always @(posedge clk) begin
    if (reboot == 1'b1 && indx[4] == 1'b0)
      indx <= 5'b10000;
    else begin
      if (indx[3:0] != CYCLE_SPI_ADDRESS)
        {icap_ce, icap_we, icap_data} <= icap_command[indx[3:0]];
      else
        {icap_ce, icap_we, icap_data} <= {2'b11, spi_address};
      if (indx[4] == 1'b1)
        indx <= indx + 5'd1;
    end
  end      
endmodule

module icape (
  input wire clk,
  input wire ce,
  input wire we,
  input wire [31:0] din
  );

  wire [31:0] swapped;
  genvar j;
  generate
    for(j=0; j<32; j=j+1) begin : swap
	    assign swapped[j] = din[31-j];
	  end
  endgenerate

   // Write and CE are active low, I is bit swapped
   ICAPE2 #(.ICAP_WIDTH("X32")) ICAP_i
     (.O(),
      .CLK(clk),
      .CSIB(~we),
      .I({swapped[7:0], swapped[15:8], swapped[23:16], swapped[31:24]}),
      .RDWRB(~ce)
      );
      
endmodule
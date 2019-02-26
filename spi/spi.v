`default_nettype none

`include "baudgen.vh"
`include "divider.vh"

module spi(input wire  clk,

           output wire ss,
           input wire  miso,
           output wire mosi,
           output wire sck,
           
           output wire D1,

           output wire tx);

   parameter BAUD =  `B115200;
   parameter DELAY = `T_250ms;

   reg [7:0]  uart_data = 0;

   reg [23:0] spi_addr;
   reg [15:0] spi_len;
   
   reg rst = 0;
   reg [7:0] rst_delay = 0;
   always @(posedge clk)
     if(~rst & (rst_delay < 8'b1000_0000))
       rst_delay <= rst_delay + 8'b1;
     else
        rst <=  1;
   
   wire transmit;
   
   dividerp1 #(.M(DELAY))
   DIV0(.clk(clk),
        .clk_out(transmit)
        );
   
   uart_tx #(BAUD)
   TX0 (.clk(clk),
        .rst(rst),
        .start(transmit),
        .data(uart_data),
        .tx(tx),
        .ready(uart_rdy)
        );

   reg spi_go;
   wire spi_rdy;
   wire uart_rdy;
   

   reg dbg = 0;
   assign D1 = dbg;
   reg [23:0] addr_counter;

   always @(posedge clk)
     if(!rst) begin
        spi_go <= 0;
     end else if(spi_rdy & ~spi_go & transmit) begin
        spi_addr <= addr_counter;
        spi_len <= 16'h0000;
        spi_go <= 1;
     end else begin
        spi_go <= 0;
     end

   wire [7:0] spi_data;
   wire       spi_valid;

   always @(posedge clk)
     if(!rst) begin
        addr_counter <= 24'h100000;
        uart_data <= " ";
     end else if(spi_valid) begin
        uart_data <= spi_data;
        addr_counter <= addr_counter + 24'b1;
     end
   
   spi_flash_reader
   SPI_READER (
   	// SPI interface
   	.spi_mosi(mosi),
   	.spi_miso(miso),
   	.spi_cs_n(ss),
   	.spi_clk(sck),
   
   	// Command interface
   	.addr(spi_addr),
   	.len(spi_len),
   	.go(spi_go),
   	.rdy(spi_rdy),
   
   	// Data interface
   	.data(spi_data),
   	.valid(spi_valid),
   
   	// Clock / Reset
   	.clk(clk),
   	.rst(rst)
   );
   
endmodule

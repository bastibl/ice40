`default_nettype none
`timescale 1ns / 100ps

module spi_tb;

   // Signals
   reg rst = 1'b0;
   reg clk = 1'b0;

   wire spi_mosi;
   reg  spi_miso=0;
   wire spi_cs_n;
   wire spi_clk;
   wire d1;
   wire d2;

   // Setup recording
   initial begin
      $dumpfile("spi_tb.vcd");
      $dumpvars(0, spi_tb);
   end

   initial begin

      // Slave sends 0xAB
      # 1011528    spi_miso = 1;
      # 84          spi_miso = 0;
      # 84          spi_miso = 1;
      # 84          spi_miso = 0;

      # 84          spi_miso = 1;
      # 84          spi_miso = 0;
      # 84          spi_miso = 1;
      # 84          spi_miso = 1;
      # 84          spi_miso = 0;

      # 20000000 $finish;
   end

   // Clocks
   always #42 clk = !clk;	// ~ 12 MHz

   // DUT
   spi #(.DELAY(12000))
   dut_I (
          .mosi(spi_mosi),
          .miso(spi_miso),
          .ss(spi_cs_n),
          .sck(spi_clk),
          .D1(d1),
          .tx(d2),
          .clk(clk)
          );

endmodule

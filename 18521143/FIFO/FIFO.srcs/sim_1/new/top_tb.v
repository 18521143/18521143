`include "ram_fifo.v"
`include "fifo.v"

module top();

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 3;

reg clk, rst, wr_cs, rd_cs;
reg rd_en, wr_en;
reg [DATA_WIDTH-1:0] data_in ;
wire full, empty;
wire [DATA_WIDTH-1:0] data_out ;

initial begin
  clk = 0;
  rst = 0;
  wr_cs = 0;
  rd_cs = 0;
  rd_en = 0;
  wr_en = 0;
  data_in = 0;
end

always  #1  clk  = ~clk;

fifo #(DATA_WIDTH,ADDR_WIDTH) fifo(
.clk      (clk),     // Clock input
.rst      (rst),     // Active high reset
.wr_cs    (wr_cs),   // Write chip select
.rd_cs    (rd_cs),   // Read chipe select
.data_in  (data_in), // Data input
.rd_en    (rd_en),   // Read enable
.wr_en    (wr_en),   // Write Enable
.data_out (data_out),// Data Output
.empty    (empty),   // FIFO empty
.full     (full)     // FIFO full
);

endmodule
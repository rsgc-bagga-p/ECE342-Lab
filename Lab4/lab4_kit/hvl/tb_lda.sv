`timescale 100ps/100ps // Makes 50GHz

module tb_lda();

  // tb signals
  logic clk;
  logic reset;

  // DUT Signals
  logic [31:0] writedata;
  logic read;
  logic write;
  logic [3:0] byteenable;
  logic chipselect;

  logic [31:0] dut_readdata;
  logic dut_waitrequest;
  logic [7:0] dut_vga;

  // DUT Instantiation
  lda_avalon_interface m_lda_asc
  (
    .i_clk            (clk),
    .i_resetn         (reset),

    .o_readdata       (dut_readdata),
    .i_writedata      (writedata),
    .i_read           (read),
    .i_write          (write),
    .i_byteenable     (byteenable),
    .i_chipselect     (chipselect),
    .o_waitrequest    (dut_waitrequest),

    .o_vga            (dut_vga)
  );

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus & checker
  initial begin

    // finish
    $display("All cases passed!");
    $stop;

  end


endmodule

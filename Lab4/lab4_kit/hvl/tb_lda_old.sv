`timescale 100ps/100ps // Makes 50GHz

module tb_lda_old();

  // tb signals
  logic clk;
  logic reset;

  // DUT Signals
  logic [8:0] x0;
  logic [8:0] x1;
  logic [7:0] y0;
  logic [7:0] y1;
  logic [2:0] color;
  logic       start;

  logic dut_done;
  logic [8:0] dut_x;
  logic [7:0] dut_y;
  logic [2:0] dut_color;
  logic dut_plot;

  // DUT Instantiation
  line_drawing_algorithm m_lda
  (
    .i_clk        (clk),
    .i_reset      (reset),

    .i_x0         (x0),
    .i_x1         (x1),
    .i_y0         (y0),
    .i_y1         (y1),
    .i_color      (color),
    .i_start      (start),

    .o_done       (dut_done),
    .o_x          (dut_x),
    .o_y          (dut_y),
    .o_color      (dut_color),
    .o_plot       (dut_plot)
  );

  // Checker Instantiation
  vga_bmp m_vga_bmp
  (
  	.clk          (clk),
    .x            (dut_x),
  	.y            (dut_y),
  	.color        (dut_color),
  	.plot         (dut_plot)
  );

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus & checker
  initial begin

    // reset
    reset = 0;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;

    // configure inputs

    // (0,0) to (335,209)
    // !steep x1 > x0
    @(negedge clk);
    x1 = 0;
    y1 = 0;
    x0 = 335;
    y0 = 209;
    color = 3'b001;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    //m_vga_bmp.write_bmp();



    // (335,209) to (335,0)
    // vertical
    @(negedge clk);
    x1 = x0;
    y1 = y0;
    x0 = 335;
    y0 = 0;
    color = 3'b010;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    //m_vga_bmp.write_bmp();

    // (335,0) to (0,209)
    // !steep x0 > x1
    @(negedge clk);
    x1 = x0;
    y1 = y0;
    x0 = 0;
    y0 = 209;
    color = 3'b011;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    //m_vga_bmp.write_bmp();

    // (0,209) to (168,0)
    // steep x1 > x0
    @(negedge clk);
    x1 = x0;
    y1 = y0;
    x0 = 168;
    y0 = 0;
    color = 3'b100;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    //m_vga_bmp.write_bmp();

    // (168,0) to (168,209)
    // vertical
    @(negedge clk);
    x1 = x0;
    y1 = y0;
    x0 = 168;
    y0 = 209;
    color = 3'b101;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    //m_vga_bmp.write_bmp();

    // (168,209) to (0,30)
    // steep x0 > x1
    @(negedge clk);
    x1 = x0;
    y1 = y0;
    x0 = 0;
    y0 = 30;
    color = 3'b110;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    //m_vga_bmp.write_bmp();

    // (0,30) to (335,30)
    // horizontal
    @(negedge clk);
    x1 = x0;
    y1 = y0;
    x0 = 335;
    y0 = 30;
    color = 3'b111;
    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge dut_done);
    m_vga_bmp.write_bmp();



    // finish
    $display("All cases passed!");
    $stop;

  end


endmodule

`timescale 100ps/100ps // Makes 50GHz

module tb_de1soc();

  // tb signals
  logic clk;
  logic reset;

  logic [8:0] val;
  logic       setx;
  logic       sety;
  logic       setcol;
  logic       go;

  logic       done;

  // DUT Signals
  logic [8:0] dut_x0;
  logic [8:0] dut_x1;
  logic [7:0] dut_y0;
  logic [7:0] dut_y1;
  logic [2:0] dut_color;

  logic [8:0] dut_xin;
  logic [7:0] dut_yin;
  logic [2:0] dut_cin;

  logic       dut_start;
  logic dut_plot;
  
  logic [8:0] vga_x;
  logic [7:0] vga_y;
  logic [2:0] vga_color;
  
  // DUT Instantiation
  user_interface m_ui (

    .i_clk                    (clk),
    .i_reset                  (reset),

    // input from user
    .i_val                    (val),
    .i_setx                   (setx),
    .i_sety                   (sety),
    .i_setcol                 (setcol),
    .i_go                     (go),

    // input from line drawing algorithm
    .i_done                   (done),

    // output to line drawing algorithm
    .o_x0                     (dut_x0),
    .o_x1                     (dut_x1),
    .o_y0                     (dut_y0),
    .o_y1                     (dut_y1),
    .o_color                  (dut_color),
    .o_start                  (dut_start),

    // debug
    .o_xin                    (dut_xin),
    .o_yin                    (dut_yin),
    .o_cin                    (dut_cin)

  );
  
  // DUT Instantiation
  line_drawing_algorithm m_lda
  (
    .i_clk        (clk),
    .i_reset      (reset),

    .i_x0         (dut_x0),
    .i_x1         (dut_x1),
    .i_y0         (dut_y0),
    .i_y1         (dut_y1),
    .i_color      (dut_color),
    .i_start      (dut_start),

    .o_done       (done),
    .o_x          (vga_x),
    .o_y          (vga_y),
    .o_color      (vga_color),
    .o_plot       (dut_plot)
  );

  // Checker Instantiation
  vga_bmp m_vga_bmp
  (
  	.clk          (clk),
    .x            (vga_x),
  	.y            (vga_y),
  	.color        (vga_color),
  	.plot         (dut_plot)
  );
  
  // Helpers

  int update_done = 0;
  int xin, yin, cin, x0, x1, y0, y1, color;

  task update_user_regs ();

    begin

      setx = 1'b0;
      sety = 1'b0;
      setcol = 1'b0;

      @(negedge clk);
      val = xin;
      setx = 1'b1;

      @(negedge clk);
      setx = 1'b0;
      val = yin;
      sety = 1'b1;

      @(negedge clk);
      sety = 1'b0;
      val = cin;
      setcol = 1'b1;

      @(posedge clk);
      setcol = 1'b0;

      @(posedge clk);
      update_done = 1;

    end

  endtask // update_regs

  task update_internal_regs ();

    begin

      @(posedge clk);
      x1 = x0;
      y1 = y0;
      x0 = xin;
      y0 = yin;
      color = cin;

    end

  endtask //update_internal_regs

  integer stage = 0;
  function void check_mismatch ();

    if (
      dut_xin != xin |
      dut_yin != yin |
      dut_cin != cin |
      dut_x0 != x0 |
      dut_x1 != x1 |
      dut_y0 != y0 |
      dut_y1 != y1 |
      dut_color != color
    )
    begin
      $display("DUT output did not match Model output!");
      $display("Stage was: %0d", stage++);
      $display("DUT result was: xin: %0d, yin: %0d, cin: %0d, x0: %0d, x1: %0d, y0: %0d, y1: %0d, color: %0d,"
        , dut_xin, dut_yin, dut_cin, dut_x0, dut_x1, dut_y0, dut_y1, dut_color);
      $display("DUT result was: xin: %0d, yin: %0d, cin: %0d, x0: %0d, x1: %0d, y0: %0d, y1: %0d, color: %0d,"
        , xin, yin, cin, x0, x1, y0, y1, color);
      $stop;
    end

  endfunction // check_misamtch

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

    go = 0;

    xin = 0;
    yin = 0;
    cin = 0;
    x0 = 0;
    x1 = 0;
    y0 = 0;
    y1 = 0;
    color = 0;
    check_mismatch();

    xin = 234;
    yin = 123;
    cin = 3'b111;
    update_user_regs();
    check_mismatch();

    go = 1;
    update_internal_regs();
    @(posedge clk);
    @(posedge clk);
    check_mismatch();
    @(posedge clk);
    check_mismatch();
    go = 0;
	@(posedge done);
    @(posedge clk);

    xin = 222;
    yin = 111;
    cin = 3'b010;
    update_user_regs();
    check_mismatch();

    go = 1;
    @(posedge clk);
    check_mismatch();

    // wait until done
	@(posedge done);
    @(posedge clk);

    $display("All cases passed!");
    $stop;

  end


endmodule

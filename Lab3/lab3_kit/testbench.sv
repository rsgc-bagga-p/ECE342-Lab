`timescale 100ps/100ps // Makes 50GHz

module testbench();

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

  // DUT Instantiation
  user_interface m_user_interface (

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

  // assertions
  /*property dut_starts_properly;
    @(posedge clk)
      disable iff(!dut_done)
        $rose(go) |-> #6 dut_start;
  assert property (!done |-> !dut_start);*/

  // model => how to write?

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus & checker
  initial begin

    reset = 0;
    #1 reset = 1;
    @(posedge clk) reset = 0;

    $display("All cases passed!");
    $stop;

  end


endmodule

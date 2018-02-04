`timescale 100ps/100ps // Makes 50GHz

module tb_cmp();

  //-----
  // DUT
  //-----

  // DUT Signals

  logic clk;

  logic [8:0] a;
  logic [8:0] b;

  logic dut_gt;
  logic dut_lt;
  logic dut_eq;

  // DUT Instantiation
  comparator #(
    .WIDTH (9)
  ) m_cmp (
    .i_cmp_a    (a),
    .i_cmp_b    (b),
    .o_cmp_gt   (dut_gt),
    .o_cmp_lt   (dut_lt),
    .o_cmp_eq   (dut_eq)
  );

  //-----------
  // Scoreboard
  //-----------

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus
  initial begin

    for (integer x = -2**8; x < 2**8; x++) begin
      for (integer y = -2**8; y < 2**8; y++) begin

        logic gt;
        logic lt;
        logic eq;

        gt = (x > y);
        lt = (x < y);
        eq = (x == y);

        a = x[8:0];
        b = y[8:0];

        @(posedge clk)

        if(dut_gt != gt) begin
          $display("DUT output did not match Model output!");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT gt result was: %s", dut_gt?"yes":"no");
          $display("Expected gt result was: %s", gt?"yes":"no");
          $stop;
        end

        if(dut_lt != lt) begin
          $display("DUT output did not match Model output!");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT lt result was: %s", dut_lt?"yes":"no");
          $display("Expected lt result was: %s", lt?"yes":"no");
          $stop;
        end

        if(dut_eq != eq) begin
          $display("DUT output did not match Model output!");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT eq result was: %s", dut_eq?"yes":"no");
          $display("Expected eq result was: %s", eq?"yes":"no");
          $stop;
        end

      end
    end

    $display("All cases passed!");
    $stop;

  end

endmodule

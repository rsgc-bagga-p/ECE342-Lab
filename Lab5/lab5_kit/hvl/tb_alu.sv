`timescale 1ns/1ns // Makes 100MHz

module tb_alu();

  //-----
  // DUT
  //-----

  // DUT Signals

  logic clk;

  logic [15:0] a;
  logic [15:0] b;
  logic sel;

  logic [15:0] dut_out;
  logic dut_n;
  logic dut_z;

  // DUT Instantiation
  alu #(
    .WIDTH (16)
  ) m_alu (
    .i_op_sel  (sel),
    .i_op_a    (a),
    .i_op_b    (b),
    .o_alu_out (dut_out),
    .o_n       (dut_n),
    .o_z       (dut_z)
  );

  //-----------
  // Scoreboard
  //-----------

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus
  initial begin

    for (logic [15:0] x = -2**15; x < 2**15; x++) begin
      for (logic [15:0] y = -2**15; y < 2**15; y++) begin

        logic [15:0] sum;
        logic [15:0] diff;
        logic s_negative;
        logic s_zero;
        logic d_negative;
        logic d_zero;

        sum = x + y;
        diff = x - y;
        if (sum < 0) s_negative = 1; else s_negative = 0;
        if (sum == 0) s_zero = 1; else s_zero = 0;
        if (diff < 0) d_negative = 1; else d_negative = 0;
        if (diff == 0) d_zero = 1; else d_zero = 0;

        a = x[15:0];
        b = y[15:0];

        sel = 0; // add
        @(posedge clk)

        if(dut_out != sum) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: ADD");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %0d", dut_out);
          $display("Expected result was: %0d", sum);
          $stop;
        end

        if(dut_n != s_negative) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: ADD");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %s", dut_n?"negative":"nonnegative");
          $display("Expected result was: %s", s_negative?"negative":"nonnegative");
          $stop;
        end

        if(dut_z != s_zero) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: ADD");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %s", dut_z?"zero":"nonzero");
          $display("Expected result was: %s", s_zero?"zero":"nonzero");
          $stop;
        end

        sel = 1; // subtract
        @(posedge clk)

        if(dut_out != diff) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: SUB");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %0d", dut_out);
          $display("Expected result was: %0d", diff);
          $stop;
        end

        if(dut_n != d_negative) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: SUB");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %s", dut_n?"negative":"nonnegative");
          $display("Expected result was: %s", d_negative?"negative":"nonnegative");
          $stop;
        end

        if(dut_z != d_zero) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: SUB");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %s", dut_z?"zero":"nonzero");
          $display("Expected result was: %s", d_zero?"zero":"nonzero");
          $stop;
        end

      end
    end

    $display("All cases passed!");
    $stop;

  end

endmodule

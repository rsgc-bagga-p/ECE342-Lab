`timescale 100ps/100ps // Makes 50GHz

module tb_salu();

  //-----
  // DUT
  //-----

  // DUT Signals

  logic clk;

  logic [8:0] a;
  logic [8:0] b;
  logic sel;

  logic [8:0] dut_out;
  logic dut_of;
  logic dut_uf;

  // DUT Instantiation
  simple_alu #(
    .WIDTH (9)
  ) m_salu (
    .i_salu_a   (a),
    .i_salu_b   (b),
    .i_salu_sel (sel),
    .o_salu_out (dut_out),
    .o_salu_of  (dut_of),
    .o_salu_uf  (dut_uf)
  );

  //-----------
  // Scoreboard
  //-----------

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus
  initial begin

    for (integer x = 0; x < 2**9; x++) begin
      for (integer y = 0; y < 2**9; y++) begin

        logic [8:0] sum;
        logic [8:0] diff;
        logic overflow;
        logic underflow;

        sum = x+y;
        diff = x-y;
        if (sum > 2**9-1) overflow = 1;
        if (diff < 0) underflow = 1;

        a = x[8:0];
        b = y[8:0];

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

        if(dut_of != overflow) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: ADD");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %s", dut_of?"overflow":"no overflow");
          $display("Expected result was: %s", overflow?"overflow":"no overflow");
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

        if(dut_uf != underflow) begin
          $display("DUT output did not match Model output!");
          $display("Operation was: SUB");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %s", dut_uf?"underflow":"no underflow");
          $display("Expected result was: %s", underflow?"underflow":"no underflow");
          $stop;
        end

      end
    end

    $display("All cases passed!");
    $stop;

  end

endmodule

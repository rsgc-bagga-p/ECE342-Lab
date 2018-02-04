`timescale 100ps/100ps // Makes 50GHz
//misSTEAK

module testbench();
  //-----
  // DUT
  //-----

  // DUT Signals
  logic [7:0] dut_x;
  logic [7:0] dut_y;
  logic [15:0] dut_debug_out;

  // DUT Instantiation
  booth_multiplier_n #(8) dut_cs_mult(dut_x, dut_y, dut_debug_out);
  
  
  //-----------
  // Scoreboard
  //-----------

  // Clock Signal
  logic dut_clk;
  initial dut_clk = 1'b0;
  always #1 dut_clk = ~dut_clk;

  // Stimulus
  initial begin

    @(posedge dut_clk);

    for (integer x = -2**7; x <= 2**7-1; x++) begin
      for (integer y = -2**7; y <= 2**7-1; y++) begin

        logic [15:0] product;
        product = x * y;

        dut_x = x[7:0];
        dut_y = y[7:0];

        @(posedge dut_clk);
        @(posedge dut_clk);
        if(dut_debug_out != product) begin
          $display("DUT output did not match Model output!");
          $display("Operands were: x = %0d, y = %0d", x, y);
          $display("DUT result was: %0d", dut_debug_out);
          $display("Expected result was: %0d", product);
          $stop;
        end

      end
    end

    $display("All cases passed!");
    $stop;

  end

endmodule

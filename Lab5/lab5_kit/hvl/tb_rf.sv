`timescale 1ns/1ns // Makes 100MHz

module tb_alu();

  //-----
  // DUT
  //-----

  // DUT Signals

  logic clk;
  logic reset;

  logic write;
  logic [2:0] addrw;
  logic [2:0] addrx;
  logic [2:0] addry;
  logic [15:0] data;

  logic [15:0] dut_datax;
  logic [15:0] dut_datay;

  // DUT Instantiation
  regfile #(
    .WIDTH    (16),
    .NUMREGS  (8)
  ) m_rf (
    .i_clk        (clk),
    .i_reset      (reset),
    .i_write      (write),
    .i_addrw      (addrw),
    .i_addrx      (addrx),
    .i_addry      (addry),
    .i_data_in    (data),
    .o_datax_out  (dut_datax),
    .o_datay_out  (dut_datay)
  );

  //-----------
  // Scoreboard
  //-----------


  task write_field (
    input [2:0] w_addr,
    input [15:0] w_data
  );
    begin
      @(negedge clk);
      write = 1;
      addrw = w_addr;
      data = w_data;
      @(posedge clk);
      @(posedge clk);
    end
  endtask

  task read_fields (
    input [2:0] x_addr,
    input [2:0] y_addr,
    output [15:0] x_data,
    output [15:0] y_data
  );
    begin
      @(negedge clk);
      addrx = x_addr;
      addry = y_addr;
      @(posedge clk);
      @(posedge clk);
      x_data = dut_datax;
      y_data = dut_datay;
    end
  endtask

  task read_and_write (
    input [2:0] x_addr,
    input [2:0] y_addr,
    output [15:0] x_data,
    output [15:0] y_data,
    input [2:0] w_addr,
    input [15:0] w_data
  );
    begin

    end
  endtask

  task read_all_fields (
    output [15:0] reg_data [7:0]
  );
    begin
      for (integer i = 0; i < 4; i++)
        read_fields(i*2, i*2+1, reg_data[i*2], reg_data[i*2+1]);
    end
  endtask

  task err_msg (
    input [15:0] act_data,
    input [15:0] exp_data,
    input integer reg_num,
    input integer iter_num
  );
    begin
      $display("DUT output did not match Model output!");
      $display("Register read was: %s", reg_num);
      $display("DUT result was: %0d", act_data);
      $display("Expected result was: %0d", exp_data);
      $stop;
    end
  endtask

  task compare_all_fields (
    input [15:0] input_data [7:0]
  );
    static integer iter = 0;
    begin
      logic [15:0] reg_data [7:0];
      read_all_fields(reg_data);
      for (integer i = 0; i < 8; i++)
        if (reg_data[i] != data[i]) err_msg(data[i], reg_data[i], i, iter);
      iter++;
    end
  endtask


  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus
  initial begin

    logic [15:0] regs [7:0];

    write = 0;
    addrw = 0;
    addrx = 0;
    addry = 0;
    data = 0;

    // reset
    reset = 0;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;

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

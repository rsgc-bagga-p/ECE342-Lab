`timescale 1ns/1ns // Makes 100MHz

module tb_rf();

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
    input [2:0]  w_addr,
    input [15:0] w_data
  );
    begin
      @(posedge clk);
      write = 1;
      addrw = w_addr;
      data = w_data;
      @(posedge clk);
      write = 0;
    end
  endtask

  task read_fields (
    input [2:0]   x_addr,
    input [2:0]   y_addr,
    output [15:0] x_data,
    output [15:0] y_data
  );
    begin
      @(posedge clk);
      addrx = x_addr;
      addry = y_addr;
      @(posedge clk);
      x_data = dut_datax;
      y_data = dut_datay;
    end
  endtask

  task read_and_write (
    input [2:0]   x_addr,
    input [2:0]   y_addr,
    output [15:0] x_data,
    output [15:0] y_data,
    input [2:0]   w_addr,
    input [15:0]  w_data
  );
    begin
      @(posedge clk);
      addrx = x_addr;
      addry = y_addr;
      write = 1;
      addrw = w_addr;
      data = w_data;
      @(posedge clk);
      x_data = dut_datax;
      y_data = dut_datay;
      write = 0;
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
    input [15:0]  act_data,
    input [15:0]  exp_data,
    input integer reg_num
  );
    begin
      $display("DUT output did not match Model output!");
      $display("Register read was: %s", reg_num);
      $display("DUT result was: %0d", act_data);
      $display("Expected result was: %0d", exp_data);
      $stop;
    end
  endtask

  task compare_fields (
    input [15:0] x_input_data,
    input [15:0] y_input_data,
    input [2:0]  x_addr,
    input [2:0]  y_addr,
    input [15:0] x_data,
    input [15:0] y_data
  );
    static integer iter = 0;
    begin
      read_fields(x_addr, y_addr, x_data, y_data);
      if (x_input_data != x_data) err_msg(x_data, x_input_data, x_addr);
      if (y_input_data != y_data) err_msg(y_data, y_input_data, y_addr);
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
        if (reg_data[i] != data[i]) begin
          err_msg(data[i], reg_data[i], i);
          $display("compare_all_fields iteration %0d", iter);
        end
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

    for (integer i = 0; i < 8; i++)
      regs[i] = {'0};

    compare_all_fields(regs);

    $display("All cases passed!");
    $stop;

  end

endmodule

`timescale 100ps/100ps // Makes 50GHz

module tb_avlintf();

  // tb signals
  logic clk;
  logic reset;

  // DUT Signals
  typedef enum logic [2:0]
  {
    MODE    = 3'b000,
    STATUS  = 3'b001,
    GO      = 3'b010,
    START_P = 3'b011,
    END_P   = 3'b100,
    COLOR   = 3'b101,
    NONE0   = 3'b110,
    NONE1   = 3'b111
  } addr_t;

  addr_t address;
  logic [3:0] byteenable;
  logic read;
  logic write;
  logic [31:0] writedata;

  logic [31:0] dut_readdata;
  logic dut_waitrequest;

  logic [8:0] vga_x;
  logic [7:0] vga_y;
  logic [2:0] vga_color;
  logic vga_plot;

  // DUT Instantiation
  lda_avalon_interface m_lda_avlintf
  (
    .clk,
    .reset,

    .avs_s1_address       (address),
    .avs_s1_byteenable    (byteenable),
    .avs_s1_read          (read),
    .avs_s1_write         (write),
    .avs_s1_readdata      (dut_readdata),
    .avs_s1_writedata     (writedata),
    .avs_s1_waitrequest   (dut_waitrequest),

    .o_vga_x              (vga_x),
    .o_vga_y              (vga_y),
    .o_vga_color          (vga_color),
    .o_vga_plot           (vga_plot)
  );

  vga_bmp m_vga_bmp
  (
    .clk,
    .x                    (vga_x),
    .y                    (vga_y),
    .color                (vga_color),
    .plot                 (vga_plot)
  );

  task write_field (
    input addr_t _address,
    input [31:0] _writedata
  );
    begin
      @(posedge clk);
      address = _address;
      writedata = _writedata;
      @(posedge clk);
      write = 1'b1;
      @(posedge clk);
      write = 1'b0;
      @(posedge clk);
    end
  endtask

  task read_field (
    input addr_t _address,
    output [31:0] _readdata
  );
    begin
      @(posedge clk);
      address = _address;
      @(posedge clk);
      read = 1'b1;
      @(negedge clk);
      _readdata = dut_readdata;
      @(posedge clk);
      read = 1'b0;
      @(posedge clk);
    end
  endtask

  task err_msg (
    input string reg_name,
    input [31:0] expected,
    input [31:0] actual
  );
    begin
      $display("DUT output did not match Model output!");
      $display("Register read was: %s", reg_name);
      $display("DUT result was: %0d", actual);
      $display("Expected result was: %0d", expected);
      $stop;
    end
  endtask

  task check_all (
    output [31:0] _readdata,
    input [31:0] _mode_exp,
    input [31:0] _status_exp,
    input [31:0] _go_exp,
    input [31:0] _start_p_exp,
    input [31:0] _end_p_exp,
    input [31:0] _color_exp,
    input [31:0] _none0_exp,
    input [31:0] _none1_exp
  );
    begin

      read_field(MODE, _readdata);
      if(_readdata != _mode_exp)
        err_msg("MODE", _mode_exp, _readdata);

      read_field(STATUS, _readdata);
      if(_readdata != _status_exp)
        err_msg("STATUS", _status_exp, _readdata);

      read_field(GO, _readdata);
      if(_readdata != _go_exp)
        err_msg("GO", _go_exp, _readdata);

      read_field(START_P, _readdata);
      if(_readdata != _start_p_exp)
        err_msg("START_P", _start_p_exp, _readdata);

      read_field(END_P, _readdata);
      if(_readdata != _end_p_exp)
        err_msg("END_P", _end_p_exp, _readdata);

      read_field(COLOR, _readdata);
      if(_readdata != _color_exp)
        err_msg("COLOR", _color_exp, _readdata);

      read_field(NONE0, _readdata);
      if(_readdata != _none0_exp)
        err_msg("NONE0", _none0_exp, _readdata);

      read_field(NONE1, _readdata);
      if(_readdata != _none1_exp)
        err_msg("NONE1", _none1_exp, _readdata);

    end
  endtask;

  task poll_status ();
    logic [31:0] _readdata;
    begin
      do
        read_field(STATUS, _readdata);
      while (_readdata != 0);
    end
  endtask

  // Clock Signal
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // Stimulus & Checker
  initial begin

    // test cases
    logic waitrequest;
    logic [31:0] readdata;
    logic [8:0] x0;
    logic [8:0] x1;
    logic [7:0] y0;
    logic [7:0] y1;
    logic [2:0] color;

    // reset
    reset = 0;
    @(negedge clk);
    reset = 1;
    @(negedge clk);
    reset = 0;

    // check initial value is 0
    check_all(readdata, {'0}, {'0}, {'0}, {'0}, {'0}, {'0}, {'0}, {'0});

    // set to poll mode
    write_field(MODE, {'0,1'b1});
    // write to status, should be ignored
    write_field(STATUS, {'0,1'b1});
    // set start point
    x0 = 9'd0;
    y0 = 8'd0;
    write_field(START_P, {'0,y0,x0});
    // set end point
    x1 = 9'd335;
    y1 = 8'd209;
    write_field(END_P, {'0,y1,x1});
    // set color
    color = 3'b101;
    write_field(COLOR, {'0,color});

    // check matching expected values
    check_all(readdata,
      {'0,1'b1}, {'0,1'b0}, {'0}, {'0,y0,x0}, {'0,y1,x1},
      {'0,color}, {'0}, {'0}
    );

    // go
    write_field(GO, {'0,1'b1});

    // check matching expected values
    check_all(readdata,
      {'0,1'b1}, {'0,1'b1}, {'0}, {'0,y0,x0}, {'0,y1,x1},
      {'0,color}, {'0}, {'0}
    );

    // write to all while poll mode
    // set to stall mode
    write_field(MODE, {'0,1'b0});
    // write to status, should be ignored
    write_field(STATUS, {'0,1'b0});
    // set start point
    x0 = 9'd335;
    y0 = 8'd0;
    write_field(START_P, {'0,y0,x0});
    // set end point
    x1 = 9'd0;
    y1 = 8'd209;
    write_field(END_P, {'0,y1,x1});
    // set color
    color = 3'b010;
    write_field(COLOR, {'0,color});
    // go
    write_field(GO, {'0,1'b1});

    // wait until lda finishes
    poll_status();

    // write to bmp
    m_vga_bmp.write_bmp();

    // check matching expected values
    check_all(readdata,
      {'0,1'b0}, {'0,1'b0}, {'0}, {'0,y0,x0}, {'0,y1,x1},
      {'0,color}, {'0}, {'0}
    );

    // start again in stall mode
    write_field(GO, {'0,1'b1});

    check_all(readdata,
      {'0,1'b0}, {'0,1'b1}, {'0}, {'0,y0,x0}, {'0,y1,x1},
      {'0,color}, {'0}, {'0}
    );

    // wait until lda finishes (as proxy for waitrequest going low)
    poll_status();

    // write to bmp
    m_vga_bmp.write_bmp();

    // finish
    $display("All cases passed!");
    $stop;

  end

endmodule

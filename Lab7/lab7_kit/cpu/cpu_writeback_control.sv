module cpu_writeback_control
(
  input i_clk,
  input i_reset,

  input  [15:0] i_ir_wr,

  output        o_rf_write,
  output        o_rf_addrw_sel,
  output [3:0]  o_rf_sel
);


  /*****************************************************************
   * Things to take care of:
   * 1: Normal Execution
   * - only need to worry about the instructions that write to RF
   *   - x0000->x0010 (mv, add, sub/mvi, addi, subi) => Rx
   *   - x0100        (ld)                           => Rx
   *   - x0110        (mvhi)                         => Rx
   *   - x1100        (call/callr)                   => R7
   ******************************************************************/


  logic rf_write;
  logic rf_addrw_sel;
  logic [3:0] rf_sel;

  assign o_rf_write = rf_write;
  assign o_rf_addrw_sel = rf_addrw_sel;
  assign o_rf_sel = rf_sel;


  // from https://www.32x8.com
  // y = B'E' + B'C'D' + CD'E'
  assign rf_write = (~i_ir_wr[3] & ~i_ir_wr[0])               |
                    (~i_ir_wr[3] & ~i_ir_wr[2] & ~i_ir_wr[1]) |
                    ( i_ir_wr[2] & ~i_ir_wr[1] & ~i_ir_wr[0]);

  // don't care about any other case, either Rx get written to RF is disabled
  assign rf_addrw_sel = (i_ir_wr[3:0] == 4'b1100);

  always_comb begin
    rf_sel = '0;
    if (i_ir_wr[4:0] == 5'b10000)               rf_sel = 3'd0;
    if (i_ir_wr[3:0] == 4'b0110)                rf_sel = 3'd1;
    if (i_ir_wr[3:2] == 2'b00 && |i_ir_wr[1:0]) rf_sel = 3'd2;
    if (i_ir_wr[3:0] == 4'b1100)                rf_sel = 3'd3;
    if (i_ir_wr[3:0] == 4'b0100)                rf_sel = 3'd4;
    if (i_ir_wr[4:0] == 5'b00000)               rf_sel = 3'd5;
  end


endmodule

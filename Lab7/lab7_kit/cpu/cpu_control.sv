module cpu_control
(
  input  i_clk,
  input  i_reset,

  // To Memory
  output o_pc_rd,
  output o_ldst_rd,
  output o_ldst_wr,

  // From Datapath
  input    [15:0] i_ir_dc,
  input    [15:0] i_ir_ex,
  input    [15:0] i_ir_wr,
  input          i_alu_n,
  input          i_alu_z,
  input          i_alu_n_imm,
  input          i_alu_z_imm,

  // To Datapath
  output        o_rf_write,
  output        o_rf_datax_ld,
  output        o_rf_datay_ld,
  output        o_datax_wr_ld,
  output        o_datay_wr_ld,
  output        o_rf_addrw_sel,
  output [2:0]  o_rf_sel,
  output        o_alu_r_ld,
  output        o_alu_n_ld,
  output        o_alu_z_ld,
  output [1:0]  o_alu_a_sel,
  output [1:0]  o_alu_b_sel,
  output        o_alu_op_sel,
  output        o_pc_ld,
  output        o_pc_dc_ld,
  output        o_pc_ex_ld,
  output        o_pc_wr_ld,
  output [1:0]  o_pc_sel,
  output [1:0]  o_pc_addr_sel,
  output        o_ldst_addr_sel,
  output        o_ldst_wrdata_sel,
  output        o_ir_ex_ld,
  output        o_ir_wr_ld,
  output        o_ir_ex_sel
);
  
  /*
   * Logic block for detecting if a jump instruction is suppose to occur
   */
  logic de_jump_i;
  logic ex_jump_r;
  detect_jump m_detect_jump (
    .i_ir_dc,
    .i_ir_ex,
    .i_alu_z,
    .i_alu_n,
    .i_alu_z_imm,
    .i_alu_n_imm,
    .o_de_jump_i(de_jump_i),
    .o_ex_jump_r(ex_jump_r)
  );

  assign o_rf_sel = '0;
  assign o_pc_sel = '0;
  assign o_pc_addr_sel = 0;
  assign o_pc_rd = 0;
  assign o_rf_datax_ld = 0;
  assign o_rf_datay_ld = 0;
  assign o_pc_ld = 0;
  assign o_pc_dc_ld = 0;
  assign o_pc_ex_ld = 0;
  assign o_ir_ex_ld = 0;
  assign o_ir_ex_sel = 0;

  /*
   * PREFETCH/FETCH
   */
  cpu_prefetch_control m_cpu_prefetch_control (
    .i_de_jump_r(de_jump_i),
    .i_ex_jump_i(ex_jump_r),
    .o_pc_sel,
    .o_pc_ld
  );
  
  cpu_fetch_control m_cpu_fetch_control (
    .i_de_jump_i(de_jump_i),
    .i_ex_jump_r(ex_jump_r),
    .o_pc_rd,
    .o_pc_addr_sel
  );

  /*
   * DECODE
   */
  cpu_decode_control (
    .i_ex_jump_r(ex_jump_r),
    .i_ir_dc,
    .o_ir_ex_sel
  );

  /*
   * EXECUTE
   */

  cpu_execute_control m_cpu_execute_control (
    .i_clk,
    .i_reset,
    .i_ir_ex,
    .i_ir_wr,
    .o_pc_wr_ld,
    .o_ir_wr_ld,
    .o_alu_r_ld,
    .o_alu_n_ld,
    .o_alu_z_ld,
    .o_alu_a_sel,
    .o_alu_b_sel,
    .o_alu_op_sel,
    .o_datax_wr_ld,
    .o_datay_wr_ld,
    .o_ldst_rd,
    .o_ldst_wr,
    .o_ldst_addr_sel,
    .o_ldst_wrdata_sel
  );


  /*
   * WRITEBACK
   */

  cpu_writeback_control m_cpu_writeback_control (
    .i_clk,
    .i_reset,
    .i_ir_wr,
    .o_rf_write,
    .o_rf_addrw_sel
  );


endmodule

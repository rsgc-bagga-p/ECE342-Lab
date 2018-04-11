module cpu_control
(
  input  i_clk,
  input  i_reset,

  // To Memory
  output        o_pc_rd,
  output        o_ldst_rd,
  output        o_ldst_wr,

  // From Datapath
  input  [15:0] i_ir_dc,
  input  [15:0] i_ir_ex,
  input  [15:0] i_ir_wr,
  input         i_alu_n,
  input         i_alu_z,
  input         i_alu_n_imm,
  input         i_alu_z_imm,

  // To Datapath
  output        o_rf_write,
  output        o_rf_datax_ld,
  output        o_rf_datay_ld,
  output        o_datax_wr_ld,
  output        o_datay_wr_ld,
  output        o_rf_addrw_sel,
  output [2:0]  o_rf_sel,
  output        o_datax_sel,
  output        o_datay_sel,
  output        o_datax_wr_sel,
  output        o_datay_wr_sel,
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
  output			 o_jr_pc_sel,
  output        o_ldst_addr_sel,
  output        o_ldst_wrdata_sel,
  output        o_ir_ex_ld,
  output        o_ir_wr_ld,
  output        o_ir_ex_sel
);


  /*
   * Detecting if a jump instruction is suppose to occur
   */
  logic dc_jump_i;
  logic ex_jump_i;
  logic ex_jump_r;
  detect_jump m_detect_jump (
    .i_ir_dc,
    .i_ir_ex,
    .i_alu_z,
    .i_alu_n,
    //.i_alu_z_imm,
    //.i_alu_n_imm,
    .o_dc_jump_i(dc_jump_i),
    .o_ex_jump_i(ex_jump_i),
    .o_ex_jump_r(ex_jump_r)
  );

  /*
   * Detect if a RAW is occuring between write and execute
   */
  logic fw_rx_ex_wr;
  logic fw_ry_ex_wr;
  detect_raw m_detect_raw_ex_wr (
    .i_ir_curr (i_ir_ex),
    .i_ir_prev (i_ir_wr),
    .fw_rx (fw_rx_ex_wr),
    .fw_ry (fw_ry_ex_wr)
  );
  
  /*
   * Detect if a RAW is occuring between write and decode
   */
  logic fw_rx_dc_wr;
  logic fw_ry_dc_wr;
  detect_raw m_detect_raw_dc_wr (
    .i_ir_curr (i_ir_dc),
    .i_ir_prev (i_ir_wr),
    .fw_rx (fw_rx_dc_wr),
    .fw_ry (fw_ry_dc_wr)
  );

  /*
   * PREFETCH/FETCH
   */
  cpu_prefetch_control m_cpu_prefetch_control (
    .i_dc_jump_i(dc_jump_i),
    .i_ex_jump_i(ex_jump_i),
    .i_ex_jump_r(ex_jump_r),
    .o_pc_sel,
    .o_pc_ld
  );

  cpu_fetch_control m_cpu_fetch_control (
    .i_dc_jump_i(dc_jump_i),
    .i_ex_jump_i(ex_jump_i),
    .i_ex_jump_r(ex_jump_r),
    .i_fw_rx(fw_rx_ex_wr),
    .o_pc_rd,
    .o_pc_addr_sel,
    .o_pc_dc_ld,
	 .o_jr_pc_sel
  );

  /*
   * DECODE
   */

  cpu_decode_control m_cpu_decode_control (
    .i_ex_jump_i(ex_jump_i),
    .i_ex_jump_r(ex_jump_r),
    .i_fw_rx (fw_rx_dc_wr),
    .i_fw_ry (fw_ry_dc_wr),
    .i_ir_dc,
    .o_rf_datax_ld,
    .o_rf_datay_ld,
    .o_datax_sel,
    .o_datay_sel,
    .o_pc_ex_ld,
    .o_ir_ex_ld,
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
    .i_fw_rx (fw_rx_ex_wr),
    .i_fw_ry (fw_ry_ex_wr),
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
    .o_datax_wr_sel,
    .o_datay_wr_sel,
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
    .o_rf_addrw_sel,
    .o_rf_sel
  );


endmodule

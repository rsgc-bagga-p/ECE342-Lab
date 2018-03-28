module cpu
(
  input clk,
  input reset,

  output [15:0] o_pc_addr,
  output o_pc_rd,
  input [15:0] i_pc_rddata,

  output [15:0] o_ldst_addr,
  output o_ldst_rd,
  output o_ldst_wr,
  input [15:0] i_ldst_rddata,
  output [15:0] o_ldst_wrdata,

	output [7:0][15:0] o_tb_regs
);


  // Signals
  logic        rf_write;
  logic        datax_wr_ld;
  logic        datay_wr_ld;
  logic        rf_addrw_sel;
  logic [2:0]  rf_sel;
  logic        alu_n_ld;
  logic        alu_z_ld;
  logic        alu_a_sel;
  logic        alu_b_sel;
  logic        alu_op_sel;
  logic        pc_ld;
  logic        pc_dc_ld;
  logic        pc_ex_ld;
  logic        pc_wr_ld;
  logic [1:0]  pc_sel;
  logic [1:0]  pc_addr_sel;
  logic        ir_ex_ld;
  logic        ir_wr_ld;
  logic        ir_ex_sel;
  logic [15:0] ir_dc;
  logic [15:0] ir_ex;
  logic [15:0] ir_wr;
  logic        alu_n;
  logic        alu_z;
  logic        alu_n_imm;
  logic        alu_z_imm;


  // CPU Control
  cpu_control m_cpu_ctrl (
    .i_clk              (clk),
    .i_reset            (reset),
    .o_mem_rd           (o_mem_rd),
    .o_mem_wr           (o_mem_wr),
    .o_mem_addr_sel     (mem_addr_sel),
    .o_pc_sel           (pc_sel),
    .o_pc_ld            (pc_ld),
    .i_ir               (ir_instrcode),
    .o_ir_ld            (ir_ld),
    .o_rf_sel           (rf_sel),
    .o_rf_write         (rf_write),
    .o_rf_addr_w_sel    (rf_addrw_sel),
    .i_alu_n            (alu_n),
    .i_alu_z            (alu_z),
    .o_alu_n_ld         (alu_n_ld),
    .o_alu_z_ld         (alu_z_ld),
    .o_alu_b_sel        (alu_b_sel),
    .o_alu_op           (alu_op_sel)
  );


  // CPU Datapath
  cpu_datapath m_cpu_dp (
    .i_clk              (clk),
    .i_reset            (reset),
    .i_rf_write         (rf_write),
    .i_datax_wr_ld      (datax_wr_ld),
    .i_datay_wr_ld      (datay_wr_ld),
    .i_rf_addrw_sel     (rf_addrw_sel),
    .i_rf_sel           (rf_sel),
    .i_alu_n_ld         (alu_n_ld),
    .i_alu_z_ld         (alu_z_ld),
    .i_alu_a_sel        (alu_a_sel),
    .i_alu_b_sel        (alu_b_sel),
    .i_alu_op_sel       (alu_op_sel),
    .i_pc_ld            (pc_ld),
    .i_pc_dc_ld         (pc_dc_ld),
    .i_pc_ex_ld         (pc_ex_ld),
    .i_pc_wr_ld         (pc_wr_ld),
    .i_pc_sel           (pc_sel),
    .i_pc_addr_sel      (pc_addr_sel),
    .i_ir_ex_ld         (ir_ex_ld),
    .i_ir_wr_ld         (ir_wr_ld),
    .i_ir_ex_sel        (ir_ex_sel),
    .o_ir_dc            (ir_dc),
    .o_ir_ex            (ir_ex),
    .o_ir_wr            (ir_wr),
    .o_alu_n            (alu_n),
    .o_alu_z            (alu_z),
    .o_alu_n_imm        (alu_n_imm),
    .o_alu_z_imm        (alu_z_imm),
    .i_pc_rddata,
    .i_ldst_rddata,
    .o_pc_addr,
    .o_ldst_addr,
    .o_ldst_wrdata,
    .o_tb_regs,
  );


endmodule

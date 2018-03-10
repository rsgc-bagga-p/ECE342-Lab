module cpu
(
  input i_clk,
  input i_reset,

  // memory bus interface
  output [15:0] o_mem_addr,
  output        o_mem_rd,
  output        o_mem_wr,
  input  [15:0] i_mem_rddata,
  output [15:0] o_mem_wrdata
);


  // Signals
  logic       mem_addr_sel;
  logic       pc_ld;
  logic [1:0] pc_sel;
  logic       ir_ld;
  logic [4:0] ir_instrcode;
  logic       rf_write;
  logic       rf_addrw_sel;
  logic [2:0] rf_sel;
  logic       alu_n_ld;
  logic       alu_z_ld;
  logic       alu_b_sel;
  logic       alu_op_sel;
  logic       alu_n;
  logic       alu_z;


  // CPU Control
  cpu_control m_cpu_ctrl (
    .i_clk,
    .i_reset,
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
    .i_clk,
    .i_reset,
    .i_mem_addr_sel     (mem_addr_sel),
    .i_pc_ld            (pc_ld),
    .i_pc_sel           (pc_sel),
    .i_ir_ld            (ir_ld),
    .i_rf_write         (rf_write),
    .i_rf_addrw_sel     (rf_addrw_sel),
    .i_rf_sel           (rf_sel),
    .i_alu_n_ld         (alu_n_ld),
    .i_alu_z_ld         (alu_z_ld),
    .i_alu_b_sel        (alu_b_sel),
    .i_alu_op_sel       (alu_op_sel),
    .o_ir_instrcode     (ir_instrcode),
    .o_alu_n            (alu_n),
    .o_alu_z            (alu_z),
    .i_mem_rddata       (i_mem_rddata),
    .o_mem_addr         (o_mem_addr),
    .o_mem_wrdata       (o_mem_wrdata)
  );

endmodule

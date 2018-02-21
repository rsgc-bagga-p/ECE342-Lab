module cpu_datapath
(
  input i_clk,
  input i_reset,

  // Control Signals
  input [2:0]  i_mem_addr_sel,

  input        i_pc_ld,
  input [1:0]  i_pc_sel,

  input        i_ir_ld,

  input        i_rf_write,
  input        i_rf_addrw_sel,
  input [2:0]  i_rf_sel,

  input        i_alu_n_ld,
  input        i_alu_z_ld,
  input        i_alu_a_sel,
  input        i_alu_op_sel,

  // Outputs to Control
  output [4:0] o_ir_instrcode,
  output logic o_alu_n,
  output logic o_alu_z,

  // Inputs from Memory
  input [15:0] i_mem_rddata,

  // Outputs to Memory
  output logic [15:0] o_mem_addr,
  output logic [15:0] o_mem_wrdata
);


  // Signals

  logic [15:0] pc;
  logic [15:0] pc_in;
  logic [15:0] pc_out;
  logic [15:0] jmp_pc;

  logic [15:0] ir;
  logic [15:0] ir_in;
  logic [15:0] ir_imm8;
  logic [15:0] ir_imm11;

  logic        rf_write;
  logic [2:0]  rf_addrw;
  logic [2:0]  rf_addrx;
  logic [2:0]  rf_addry;
  logic [15:0] rf_data_in;
  logic [15:0] rf_datax_out;
  logic [15:0] rf_datay_out;

  logic [15:0] alu_op_a;
  logic [15:0] alu_op_b;
  logic [15:0] alu_out;
  logic        alu_n;
  logic        alu_z;


  // Module Instantiations

  // Register File
  regfile #(
    .WIDTH    (16),
    .NUMREGS  (8)
  ) m_regfile (
    .i_clk,
    .i_reset,
    .i_write        (i_rf_write),
    .i_addrw        (rf_addrw),
    .i_addrx        (rf_addrx),
    .i_addry        (rf_addry),
    .i_data_in      (rf_data_in),
    .o_datax_out    (rf_datax_out),
    .o_datay_out    (rf_datay_out)
  );

  // ALU
  alu #(
    .WIDTH    (16)
  ) m_alu (
    .i_op_sel       (i_alu_op_sel),
    .i_op_a         (alu_op_a),
    .i_op_b         (alu_op_b),
    .o_alu_out      (alu_out),
    .o_n            (alu_n),
    .o_z            (alu_z)
  );


  // Sequential Logic

  always_ff @ (posedge i_clk, negedge i_reset) begin

    if (i_reset) begin
      pc <= {'0};
      ir <= {'0};
      o_alu_n <= {'0};
      o_alu_z <= {'0};
    end

    else begin
      if (i_pc_ld) pc <= pc_in;
      if (i_ir_ld) ir <= ir_in;
      if (i_alu_n_ld) o_alu_n <= alu_n;
      if (i_alu_z_ld) o_alu_z <= alu_z;
    end

  end // always_ff


  // Combinational Logic

  assign pc_out = pc + 2;
  assign jmp_pc = pc_out + (ir_imm11 << 1);

  assign ir_imm8 = {{8{ir[15]}},ir[15:8]};
  assign ir_imm11 = {{5{ir[15]}},ir[15:5]};
  assign rf_addrx = ir[7:5];
  assign rf_addry = ir[10:8];
  assign o_ir_instcode = ir[4:0];

  always_comb begin

    case (i_mem_addr_sel)
      0: o_mem_addr = pc;
      1: o_mem_addr = pc_out;
      2: o_mem_addr = rf_datax_out;
      3: o_mem_addr = rf_datay_out;
      4: o_mem_addr = jmp_pc;
      default: o_mem_addr = {'0};
    endcase

    case (i_pc_sel)
      0: pc_in = rf_datax_out;
      1: pc_in = pc_out;
      2: pc_in = jmp_pc;
      default: pc_in = {'0};
    endcase

    case (i_rf_addrw_sel)
      0: rf_addrw = rf_datax_out;
      1: rf_addrw = rf_datay_out;
      default: rf_addrw = {'0};
    endcase

    case (i_rf_sel)
      0: rf_data_in = ir_imm8;
      1: rf_data_in = {ir_imm8[7:0],rf_datax_out[7:0]};
      2: rf_data_in = alu_out;
      3: rf_data_in = pc_out;
      4: rf_data_in = i_mem_rddata;
      5: rf_data_in = rf_datay_out;
      default: rf_data_in = {'0};
    endcase

    case (i_alu_a_sel)
      0: alu_op_a = ir_imm8;
      1: alu_op_a = rf_datay_out;
      default alu_op_a = {'0};
    endcase

  end // always_comb

endmodule

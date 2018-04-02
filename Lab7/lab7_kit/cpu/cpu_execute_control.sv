module cpu_execute_control
(
  input i_clk,
  input i_reset,

  input  [15:0] i_ir_ex,
  input  [15:0] i_ir_wr,
  
  input         i_fw_rx,
  input         i_fw_ry,

  output        o_pc_wr_ld,
  output        o_ir_wr_ld,
  output        o_alu_r_ld,
  output        o_alu_n_ld,
  output        o_alu_z_ld,
  output [1:0]  o_alu_a_sel,
  output [1:0]  o_alu_b_sel,
  output        o_alu_op_sel,
  output        o_datax_wr_ld,
  output        o_datay_wr_ld,
  output        o_ldst_rd,
  output        o_ldst_wr,
  output        o_ldst_addr_sel,
  output        o_ldst_wrdata_sel
);


  // Instruction Encoding for nop
  localparam NOP = 16'h0007; // opcode => 0_0111

  /*************************************************************************
   * Things to take care of:
   * 1: Normal Execution
   * - check the kind of execution needed by instruction (x = don't care)
   *   - x0000          (mv/mvi)                         => propagate Ry
   *   - x0001 -> x0011 (add, sub, cmp/addi, subi, cmpi) => ALU
   *   - x0100 -> x0101 (ld, st)                         => MEM
   *   - x0110          (mvhi)                           => nothing
   *   - x1000 -> x1010 (jr, jzr, jnr/j, jz, jn)         => nothing
   *   - x1100          (callr/call)                     => propagate Rx
   *   - 00111          (nop)                            => nothing
   * 2: Forwarding (RAW)
   * - if previous instruction (ir_wr) has a matching argument with
   *   current instruction (ir_ex), then choose alu_r or ldst_rddata
   *   instead of rf_datax/rf_datay
   * 3: Branching
   * - execute stage does not need to care about jump instructions
   *************************************************************************/


  /*logic prev_rx;
  logic prev_r7;
  logic curr_rx;
  logic curr_ry;
  logic fw_rx;
  logic fw_ry;*/

  logic pc_wr_ld;
  logic ir_wr_ld;
  logic alu_r_ld;
  logic alu_n_ld;
  logic alu_z_ld;
  logic [1:0] alu_a_sel;
  logic [1:0] alu_b_sel;
  logic alu_op_sel;
  logic datax_wr_ld;
  logic datay_wr_ld;
  logic ldst_rd;
  logic ldst_wr;
  logic ldst_addr_sel;
  logic ldst_wrdata_sel;

  assign o_pc_wr_ld = pc_wr_ld;
  assign o_ir_wr_ld = ir_wr_ld;
  assign o_alu_r_ld = alu_r_ld;
  assign o_alu_n_ld = alu_n_ld;
  assign o_alu_z_ld = alu_z_ld;
  assign o_alu_a_sel = alu_a_sel;
  assign o_alu_b_sel = alu_b_sel;
  assign o_alu_op_sel = alu_op_sel;
  assign o_ldst_rd = ldst_rd;
  assign o_ldst_wr = ldst_wr;
  assign o_ldst_addr_sel = ldst_addr_sel;
  assign o_ldst_wrdata_sel = ldst_wrdata_sel;

  assign o_datax_wr_ld = (i_ir_wr[4:0] == NOP) ? 1'd0 : 1'd1;
  assign o_datay_wr_ld = (i_ir_wr[4:0] == NOP) ? 1'd0 : 1'd1;

  always_comb begin

    // Forwarding checks

    // previous instruction writes to Rx
    // x0000->x0010, 00100, 10110
    //prev_rx = (i_ir_wr[3:2] == 2'b00 && i_ir_wr[1:0] != 2'b11) ||
    //          (i_ir_wr[3:2] == 2'b01 && ~i_ir_wr[0]);

    // previous instruction writes to R7
    // x1100
    //prev_r7 = (i_ir_wr[4:0] == 4'b1100);

    // current instruction uses Rx
    // x0001->x0011, does not care about jump instructions
    //curr_rx = (i_ir_ex[3:2] == 2'b00 && i_ir_ex[1:0] != 2'b00);

    // current instruction uses Ry
    // 00000->00100
    //curr_ry = (i_ir_ex[4:3] == 2'b00 && i_ir_ex[2:0] != 3'b111);

    // conflict with Rx
    //fw_rx = (curr_rx) &&
    //        (((prev_rx) && (i_ir_ex[7:5] == i_ir_wr[7:5])) ||
    //         ((prev_r7) && (i_ir_ex[7:5] == 3'd7)));

    // conflict with Ry
    //fw_ry = (curr_ry) &&
    //        (((prev_rx) && (i_ir_ex[10:8] == i_ir_wr[7:5])) ||
    //         ((prev_r7) && (i_ir_ex[10:8] == 3'd7)));

    pc_wr_ld        = 1'd1;
    ir_wr_ld        = 1'd1;
    alu_r_ld        = '0;
    alu_n_ld        = '0;
    alu_z_ld        = '0;
    alu_a_sel       = '0;
    alu_b_sel       = '0;
    alu_op_sel      = '0;
    ldst_rd         = '0;
    ldst_wr         = '0;
    ldst_addr_sel   = '0;
    ldst_wrdata_sel = '0;

    // x0001 -> x0011 (add, sub, cmp/addi, subi, cmpi)
    if (i_ir_ex[3:2] == 2'b00 && i_ir_ex[1:0] != 2'b00) begin
      alu_r_ld   = 1'd1;
      alu_n_ld   = 1'd1;
      alu_z_ld   = 1'd1;
      alu_op_sel = i_ir_ex[1];
      if (i_fw_rx) alu_a_sel = 1'd0;
      else         alu_a_sel = 1'd1;
      if (i_fw_ry) alu_b_sel = 2'd0;
      else         alu_b_sel = i_ir_ex[4] ? 2'd1 : 2'd2;
    end

    // x0100 -> x0100 (ld, st)
    if (i_ir_ex[3:1] == 3'b010) begin
      ldst_rd = ~i_ir_ex[0]; // ld
      ldst_wr = i_ir_ex[0];  // st
      if (i_fw_rx) ldst_addr_sel   = 1'd1;
      if (i_fw_ry) ldst_wrdata_sel = 1'd1;
    end

    // x0111 (nop)
    if (i_ir_ex[3:0] == 4'b0111) begin
      pc_wr_ld = 1'b0;
      ir_wr_ld = 1'b0;
    end

  end


endmodule

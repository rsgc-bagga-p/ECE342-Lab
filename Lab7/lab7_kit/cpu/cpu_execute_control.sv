module cpu_execute_control
(
  input i_clk,
  input i_reset,

  input i_ir_ex,
  input i_ir_wr,

  output o_pc_wr_ld,
  output o_ir_wr_ld,
  output o_alu_r_ld,
  output o_alu_n_ld,
  output o_alu_z_ld,
  output [1:0] o_alu_a_sel,
  output [1:0] o_alu_b_sel,
  output [1:0] o_alu_op_sel,
  output o_ldst_rd,
  output o_ldst_wr
);


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

  // Forwarding check
  // x0000->x0010, x0100, x0110 => Rx
  // x1100 => R7

  // Ry
  // x0000->x00101
  // i_ir_ex[4:3] == 2'b00 & i_ir_ex[2:0] != 3'b111;

  // Rx
  // 01000->01100, x0000->x0011, 00101
  // i_ir_ex[3:2] == 2'b00 & |i_ir_ex[1:0], i_ir_ex[4:0] == 00101, i_ir_ex[4:3] == 2'b01;

  always_comb begin

    // Forwarding checks

    raw_fw_r = (i_ir_wr[3:2] == 2'b00 && i_ir_wr[1:0] != 2'b11) ||
               (i_ir_wr[3:2] == 2'b01 && ~i_ir_wr[0]);

    raw_fw_7 = (i_ir_wr[4:0] == 4'b1100);

    raw_fw_rx = (raw_fw_r) & (i_ir_ex[7:5] == i_ir_wr[7:5]) &&
                (i_ir_ex);

    raw_fw_ry = (i_ir_wr[3:0] == 4'b1100);

    raw_fw_r7 = (raw_fw_7) && (1);

    pc_wr_ld   = '1;
    ir_wr_ld   = '1;
    alu_r_ld   = '0;
    alu_n_ld   = '0;
    alu_z_ld   = '0;
    alu_op_sel = '0;
    ldst_rd    = '0;
    ldst_wr    = '0;

    // x0001 -> x0011 (add, sub, cmp/addi, subi, cmpi)
    if (~(&i_ir_ex[3:2]) && (|i_ir_ex[1:0])) begin
      alu_r_ld   = '1;
      alu_n_ld   = '1;
      alu_z_ld   = '1;
      alu_op_sel = i_ir_ex[1];

      if (raw_fw[0])

      alu_a_sel  = '0;
      alu_b_sel  = '0;
    end

    // x0100 -> x0100 (ld, st)
    if (i_ir_ex[3:1] == 3'b010) begin
      ldst_rd = ~i_ir_ex[0]; // ld
      ldst_wr = i_ir_ex[0];  // st
    end

  end

endmodule

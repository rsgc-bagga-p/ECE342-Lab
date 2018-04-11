module detect_jump (
  input [15:0] i_ir_dc,
  input [15:0] i_ir_ex,
  input        i_alu_z,
  input        i_alu_n,
  input        i_alu_z_imm,
  input        i_alu_n_imm,

  // jump using reg, currently in decode stage, will occur
  output logic o_dc_jump_r,
  // jump using immediate, currently in decode stage, will occur
  output logic o_dc_jump_i,
  // jump using reg, currently in execute stage, will occur
  output logic o_ex_jump_r
);
  logic jump_z;
  logic jump_n;

  always_comb begin
    if (i_ir_ex[3:0] == 4'b0001 | i_ir_ex[3:0] == 4'b0010 |
        i_ir_ex[3:0] == 4'b0011) begin
      jump_z = i_alu_z_imm;
      jump_n = i_alu_n_imm;
    end
    else begin
      jump_z = i_alu_z;
      jump_n = i_alu_n;
    end

    o_dc_jump_r = (i_ir_dc[4:3] == 2'b01 && i_ir_dc[1:0] == 2'b00)
    	| (i_ir_dc[4:3] == 2'b01 && i_ir_dc[0] & jump_z) |
        (i_ir_dc[4:3] == 2'b01 && i_ir_dc[1] & jump_n);

    o_dc_jump_i = (i_ir_dc[4:3] == 2'b11 && i_ir_dc[1:0] == 2'b00)
    	| (i_ir_dc[4:3] == 2'b11 && i_ir_dc[0] & jump_z) |
        (i_ir_dc[4:3] == 2'b11 && i_ir_dc[1] & jump_n);

    o_ex_jump_r = (i_ir_ex[4:3] == 2'b01 && i_ir_ex[1:0] == 2'b00)
    	| (i_ir_ex[4:3] == 2'b01 && i_ir_ex[0] & jump_z) |
        (i_ir_ex[4:3] == 2'b01 && i_ir_ex[1] & jump_n);
  end

endmodule

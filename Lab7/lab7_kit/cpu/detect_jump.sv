module detect_jump (
  input [15:0] i_ir_dc,
  input [15:0] i_ir_ex,
  input        i_alu_z,
  input        i_alu_n,
  input        i_alu_z_imm,
  input        i_alu_n_imm,
  
  // jump using reg, currently in decode stage, will occur
  //output       o_de_jump_r,
  // jump using immediate, currently in decode stage, will occur
  output       o_de_jump_i,
  // jump using reg, currently in execute stage, will occur
  output       o_ex_jump_r
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
    
    //o_de_jump_r = i_ir_dc[4:0] == 5'b01000 | (i_ir_dc[4:0] == 5'b01001 & jump_z) |
    //    (i_ir_dc[4:0] == 5'b01010 & jump_n) | i_ir_dc[4:0] == 5'b01100;
    
    o_de_jump_i = i_ir_dc[4:0] == 5'b11000 | (i_ir_dc[4:0] == 5'b11001 & jump_z) |
        (i_ir_dc[4:0] == 5'b11010 & jump_n) | i_ir_dc[4:0] == 5'b11100;
    
    o_ex_jump_r = i_ir_ex[4:0] == 5'b01000 | (i_ir_ex[4:0] == 5'b01001 & jump_z) |
        (i_ir_ex[4:0] == 5'b01010 & jump_n) | i_ir_ex[4:0] == 5'b01100;
  end
  
  /*
  if exe_instr == add | sub | cmp | addi | subi | cmpi
    jump_z = alu_out_z
    jump_n = alu_out_n
  else
    jump_z = z
    jump_n = n
  
  rfr_jump_r = jr | callr | (jzr & jump_z) | (jnr & jump_n)
  rfr_jump_imm = j | call | jz & jump_z) | (jn & jump_n)
  
  exe_jump_r
  exe_jump_r = exe_instr == j | call | (jz & z) | (jn & n)
  */
endmodule
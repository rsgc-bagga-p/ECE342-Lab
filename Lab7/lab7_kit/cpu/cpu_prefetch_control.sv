module cpu_prefetch_control
(
  // In from detect_jump module
  input i_dc_jump_i,
  input i_ex_jump_i,
  input i_ex_jump_r,
  
  // Out to datapath
  output logic [1:0] o_pc_sel,
  output logic o_pc_ld
);

always_comb begin
  // Default, increment by 2
  o_pc_sel = 2'd0;
  o_pc_ld = 1'd1;
  
  // Look at special cases
  
  // Start from jump instructions furthest along pipeline
  // Jump, using reg, at execute stage
  // jr, jzr, jnr, callr
  if (i_ex_jump_r) begin
    o_pc_sel = 2'd3;
  end
  else if (i_ex_jump_i) begin
    o_pc_sel = 2'd2;
  end
  // Jump, using immediate, at decode stage
  // j, jz, jn, call
  else if (i_dc_jump_i) begin
    o_pc_sel = 2'd1;
  end
end

endmodule

module cpu_fetch_control
(
  // In from detect_jump module
  input i_dc_jump_i,
  input i_ex_jump_r,
  
  // In detect_raw ex to wr
  input i_fw_rx,

  // Out to memory, pc port
  output logic o_pc_rd,

  // Out to datapath
  output logic [1:0] o_pc_addr_sel,
  output logic o_pc_dc_ld,
  output logic o_jr_pc_sel
);

always_comb begin
  // Default, increment by 2
  o_pc_rd = 1'd1;
  o_pc_addr_sel = 2'd0;
  o_pc_dc_ld = 1'd1;
  o_jr_pc_sel = 1'd0;

  // Look at special cases

  // Start from jump instructions furthest along pipeline
  // Jump, using reg, at execute stage
  // jr, jzr, jnr, callr
  if (i_ex_jump_r) begin
    o_pc_addr_sel = 2'd2;
    if (i_fw_rx) o_jr_pc_sel = 1'd1;
  end
  // Jump, using immediate, at decode stage
  // j, jz, jn, call
  else if (i_dc_jump_i) begin
    o_pc_addr_sel = 2'd1;
  end
end

endmodule

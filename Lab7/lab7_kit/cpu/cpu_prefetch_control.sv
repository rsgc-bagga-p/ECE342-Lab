module cpu_prefetch_control
(
  // In from detect_jump module
  input i_de_jump_r,
  input i_ex_jump_i,
  
  // Out to datapath
  output [1:0] o_pc_sel,
  output o_pc_ld
);

always_comb begin
  //o_pc_sel = 2'd0;
  //o_pc_ld = 1'd0;

  // Default, increment by 2
  o_pc_sel = 2'd0;
  o_pc_ld = 1'd1;
end

endmodule

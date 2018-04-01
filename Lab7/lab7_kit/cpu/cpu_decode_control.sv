module cpu_decode_control (
  // In from jump_detect module
  input i_ex_jump_r,
  
  // In from datapath
  input [15:0] i_ir_dc
  
  // Out to datapath
  output o_ir_ex_sel
);

always_comb begin
  
  // Jump using immediate, currently at execute stage, will occur
  // Insert bubble (no-op) into ir_ex
  
  // Default
  i_ir_ex_sel = 1'd0;
end

endmodule

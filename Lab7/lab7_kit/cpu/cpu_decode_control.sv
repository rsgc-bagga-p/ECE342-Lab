module cpu_decode_control (
  // In from jump_detect module
  input i_ex_jump_r,
  
  // In from datapath
  input [15:0] i_ir_dc,
  
  // Out to datapath
  output logic o_rf_datax_ld,
  output logic o_rf_datay_ld,
  output logic o_ir_ex_sel,
  output logic o_pc_ex_ld,
  output logic o_ir_ex_ld
);

always_comb begin
  o_rf_datax_ld = 1'd0;
  o_rf_datay_ld = 1'd0;
  o_ir_ex_sel = 1'd0;
  o_pc_ex_ld = 1'd0;
  o_ir_ex_ld = 1'd0;
  
  // Jump using immediate, currently at execute stage, will occur
  // Insert bubble (no-op) into ir_ex
  if (i_ex_jump_r) begin
    o_ir_ex_sel = 1'd1;
    o_ir_ex_ld = 1'd1;
  end
  
  // Default
  else begin
    o_rf_datax_ld = 1'd1;
    o_rf_datay_ld = 1'd1;
    o_ir_ex_sel = 1'd0;
    o_pc_ex_ld = 1'd1;
    o_ir_ex_ld = 1'd1;
  end
end

endmodule

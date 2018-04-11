module cpu_decode_control (
  // In from jump_detect module
  input i_ex_jump_i,
  input i_ex_jump_r,
  
  // In from detect_raw dc to wr
  input i_fw_rx,
  input i_fw_ry,
  
  // In from datapath
  input [15:0] i_ir_dc,
  
  // Out to datapath
  output logic o_rf_datax_ld,
  output logic o_rf_datay_ld,
  output logic o_datax_sel,
  output logic o_datay_sel,
  output logic o_pc_ex_ld,
  output logic o_ir_ex_ld,
  output logic o_ir_ex_sel
);

always_comb begin
  // Default
  o_rf_datax_ld = 1'd1;
  o_rf_datay_ld = 1'd1;
  o_datax_sel = 1'd0;
  o_datay_sel = 1'd0;
  o_pc_ex_ld = 1'd1;
  o_ir_ex_ld = 1'd1;
  o_ir_ex_sel = 1'd0;

  // Check special cases

  // If RAW forward updated register values
  if (i_fw_rx) o_datax_sel = 1'd1;
  if (i_fw_ry) o_datay_sel = 1'd1;
  
  // Jump using immediate, currently at execute stage, will occur
  // Insert bubble (no-op) into ir_ex
  if (i_ex_jump_i || i_ex_jump_r) begin
    o_ir_ex_sel = 1'd1;
  end
end

endmodule

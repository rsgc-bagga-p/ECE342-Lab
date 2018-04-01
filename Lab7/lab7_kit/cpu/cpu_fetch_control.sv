module cpu_fetch_control
(
  // In from detect_jump module
  input i_de_jump_i,
  input o_ex_jump_r,
  
  // Out to memory, pc port
  output o_pc_rd,
  
  // Out to datapath
  output [1:0] o_pc_addr_sel
);

always_comb begin
  o_pc_rd = 1'd0;
  o_pc_addr_sel = 2'd0;
  
  // Look at special cases
  // Start from instructions furthest along pipeline
  
  // Jump, using reg
  // jr, jzr, jnr, callr
  if (i_ex_jump_r) begin
    o_pc_rd = 1'd1;
    o_pc_addr_sel = 2'd2;
  end
  
  // Jump, using immediate
  // j, jz, jn, call
  else if (i_de_jump_i) begin
    o_pc_rd = 1'd1;
    o_pc_addr_sel = 2'd1;
  end
  
  // Default, increment by 2
  else begin
    o_pc_rd = 1'd1;
    o_pc_addr_sel = 2'd0;
  end
end

endmodule





/*
Read after write
exe stage performs read and rfw stage performs write on same reg

rfw_is_writing = mv | add | sub | ld | mvi | addi | subi | mvhi
rw = rfw_rx

exe_is_reading = mv | add | sub | cmp | ld | st | cmpi | jr | jzr | jnr | callr
same_reg???
get rx, ry from exe stage
if mv | ld
  same_reg = rw == ry ? 1:0
else if jr | jzr | jnr | callr
  same_reg = rw == rx ? 1:0
else
  same_reg = rw == rx & rw == ry

raw = rfw_is_writing & exe_is_reading & same_reg
*/
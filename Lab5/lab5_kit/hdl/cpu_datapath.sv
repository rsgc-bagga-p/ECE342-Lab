module cpu_datapath
(
  input i_clk,
  input i_reset
);

  regfile #(
    .WIDTH    (16),
    .NUMREGS  (8)
  ) m_regfile (
    .i_clk,
    .i_reset,
    .i_write,
    .i_addrw,
    .i_addrx,
    .i_addry,
    .i_data_in,
    .o_datax_out,
    .o_datay_out
  );

  alu #(
    .WIDTH    (16)
  ) m_alu (
    .i_op_sel,
    .i_op_a,
    .i_op_b,
    .o_alu_out,
    .o_n,
    .o_z
  );

endmodule

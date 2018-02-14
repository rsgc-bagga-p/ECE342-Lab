// top-level module

module cpu
(
  input i_clk,
  input i_reset,

  // memory bus interface
  input   [15:0]    o_mem_addr,
  output            o_mem_rd,
  output            o_mem_wr,
  input   [15:0]    i_mem_rddata,
  output  [15:0]    o_mem_wrdata
);

  cpu_control m_cpu_ctrl (
    .*
  );

  cpu_datapath m_cpu_dp (
    .*
  );

endmodule

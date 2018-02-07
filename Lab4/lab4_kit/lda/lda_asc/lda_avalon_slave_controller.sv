module lda_avalon_slave_controller
(
  input i_clk,
  input i_resetn,

  // Avalon Interconnect Signals
  output [31:0] o_readdata,
  input [31:0] i_writedata,
  input i_read,
  input i_write,
  input i_byteenable,
  input i_chipselect,

  // LDA Signals
  output [8:0] o_x0,
  output [8:0] o_x1,
  output [7:0] o_y0,
  output [7:0] o_y1,
  output [2:0] o_color,
  output o_start,
  input i_done
);

  lda_asc_datapath m_lda_asc_datapath (
    .*
  );

  lda_asc_control m_lda_asc_control (
    .*
  );

endmodule

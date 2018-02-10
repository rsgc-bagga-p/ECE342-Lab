module lda_avalon_slave_controller
import lda_asc_pkg::*;
(
  input i_clk,
  input i_reset,

  // Avalon Interconnect Signals
  input   [2:0]     i_address,
  input             i_read,
  input             i_write,
  output  [31:0]    o_readdata,
  input   [31:0]    i_writedata,
  output            o_waitrequest,

  // LDA Signals
  output  [8:0]     o_x0,
  output  [8:0]     o_x1,
  output  [7:0]     o_y0,
  output  [7:0]     o_y1,
  output  [2:0]     o_color,
  output            o_start,
  input             i_done
);

  lda_reg_t dp_rd_sel;
  logic dp_mode_ld;
  logic dp_sp_ld;
  logic dp_ep_ld;
  logic dp_col_ld;
  logic dp_status;
  logic ctrl_mode;

  lda_asc_datapath m_lda_asc_datapath (
    .i_clk,
    .i_reset,

    .o_readdata,
    .i_writedata,

    .i_rd_sel         (dp_rd_sel),
    .i_mode_ld        (dp_mode_ld),
    .i_sp_ld          (dp_sp_ld),
    .i_ep_ld          (dp_ep_ld),
    .i_col_ld         (dp_col_ld),
    .i_status         (dp_status),

    .o_mode           (ctrl_mode),
    .o_x0             (o_x0),
    .o_x1             (o_x1),
    .o_y0             (o_y0),
    .o_y1             (o_y1),
    .o_color          (o_color)
  );

  lda_asc_control m_lda_asc_control (
    .i_clk,
    .i_reset,

    .i_address,
    .i_read,
    .i_write,
    .i_done,

    .i_mode           (ctrl_mode),

    .o_start,
    .o_waitrequest,

    .o_status         (dp_status),
    .o_rd_sel         (dp_rd_sel),
    .o_mode_ld        (dp_mode_ld),
    .o_sp_ld          (dp_sp_ld),
    .o_ep_ld          (dp_ep_ld),
    .o_col_ld         (dp_col_ld)
  );

endmodule

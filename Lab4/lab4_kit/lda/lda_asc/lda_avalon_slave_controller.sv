module lda_avalon_slave_controller
(
  input i_clk,
  input i_reset,

  // Avalon Interconnect Signals
  input   [31:0]    i_address,
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

  import lda_reg_pkg::*;

  assign o_readdata = assign_readdata(
    .rd_sel           (rd_sel),
    .mode             (reg_mode),
    .status           (reg_status),
    .x0               (reg_x0),
    .x1               (reg_x1),
    .y0               (reg_y0),
    .y1               (reg_y1),
    .color            (reg_color)
  );

  logic dp_mode_ld;
  logic dp_sp_ld;
  logic dp_ep_ld;
  logic dp_col_ld;

  logic reg_mode;
  logic reg_status;
  logic [8:0] reg_x0;
  logic [8:0] reg_x1;
  logic [7:0] reg_y0;
  logic [7:0] reg_y1;
  logic [2:0] reg_color;

  lda_asc_datapath m_lda_asc_datapath (
    .i_clk,
    .i_reset,

    .o_readdata,
    .i_writedata,

    .i_mode_ld        (dp_mode_ld),
    .i_sp_ld          (dp_sp_ld),
    .i_ep_ld          (dp_ep_ld),
    .i_col_ld         (dp_col_ld),

    .o_mode           (reg_mode),
    .o_x0             (reg_x0),
    .o_x1             (reg_x1),
    .o_y0             (reg_y0),
    .o_y1             (reg_y1),
    .o_color          (reg_color)
  );

  lda_asc_control m_lda_asc_control (
    .i_clk,
    .i_reset,

    .i_address,
    .i_read,
    .i_write,
    .i_done,

    .i_mode           (reg_mode),

    .o_start,
    .o_waitrequest,

    .o_status         (reg_status),
    .o_mode_ld        (dp_mode_ld),
    .o_sp_ld          (dp_sp_ld),
    .o_ep_ld          (dp_ep_ld),
    .o_col_ld         (dp_col_ld)
  );

endmodule

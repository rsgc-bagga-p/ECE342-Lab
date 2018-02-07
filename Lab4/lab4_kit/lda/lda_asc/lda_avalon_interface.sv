module lda_avalon_interface
(
  input i_clk,
  input i_resetn,

  // Memory-Map Interface
  output [31:0] o_readdata,
  input [31:0] i_writedata,
  input i_read,
  input i_write,
  input [3:0] i_byteenable,
  input i_chipselect,
  output o_waitrequest,

  // Conduit Interface
  output [7:0] o_vga
);

  logic i_reset;
  assign i_reset = ~i_resetn;

  logic [8:0] lda_x0;
  logic [8:0] lda_x1;
  logic [7:0] lda_y0;
  logic [7:0] lda_y1;
  logic [2:0] lda_color;
  logic lda_start;
  logic ctrl_done;
  logic vga_x;
  logic vga_y;
  logic vga_color;
  logic vga_plot;

  lda_avalon_slave_controller m_lda_avalon_salve_controller (
    .i_clk,
    .i_reset,

    .o_readdata,
    .i_writedata,
    .i_read,
    .i_write,
    .i_byteenable,
    .i_chipselect,
    .o_waitrequest,

    .o_x0          (lda_x0),
    .o_x1          (lda_x1),
    .o_y0          (lda_y0),
    .o_y1          (lda_y1),
    .o_color       (lda_color),
    .o_start       (lda_start),
    .i_done        (ctrl_done)
  );

  line_drawing_algorithm m_line_drawing_algorithm (
    .i_clk,
    .i_reset,

    .i_x0          (lda_x0),
    .i_x1          (lda_x1),
    .i_y0          (lda_y0),
    .i_y1          (lda_y1),
    .i_color       (lda_color),
    .i_start       (lda_start),
    .o_done        (ctrl_done),

    .o_x           (vga_x),
    .o_y           (vga_y),
    .o_color       (vga_color),
    .o_plot        (vga_plot)
  );

  vga_adapter #(
    .BITS_PER_CHANNEL(1)
  ) m_vga_adapter (
    .CLOCK_50      (i_clk),
    .VGA_R         (o_vga[0]),
    .VGA_G         (o_vga[1]),
    .VGA_B         (o_vga[2]),
    .VGA_HS        (o_vga[3]),
    .VGA_VS        (o_vga[4]),
    .VGA_SYNC_N    (o_vga[5]),
    .VGA_BLANK_N   (o_vga[6]),
    .VGA_CLK       (o_vga[7]),
    .x             (vga_x),
    .y             (vga_y),
    .color         (vga_color),
    .plot          (vga_plot)
  );

endmodule

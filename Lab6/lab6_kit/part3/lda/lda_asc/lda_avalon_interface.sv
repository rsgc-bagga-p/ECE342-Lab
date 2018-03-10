module lda_avalon_interface
(
  input clk,
  input reset,

  // Memory-Map Interface
  input   [2:0]     avs_s1_address,
  input   [3:0]     avs_s1_byteenable,
  input             avs_s1_read,
  input             avs_s1_write,
  output  [31:0]    avs_s1_readdata,
  input   [31:0]    avs_s1_writedata,
  output            avs_s1_waitrequest,

  // Comment this section out for simulation
  // Conduit Interface
  output  [7:0]     coe_VGA_R_export,
  output  [7:0]     coe_VGA_G_export,
  output  [7:0]     coe_VGA_B_export,
  output            coe_VGA_HS_export,
  output            coe_VGA_VS_export,
  output            coe_VGA_SYNC_N_export,
  output            coe_VGA_BLANK_N_export,
  output            coe_VGA_CLK_export

  // Simulation only
  // synthesis translate_off
  ,
  output [8:0] o_vga_x,
  output [7:0] o_vga_y,
  output [2:0] o_vga_color,
  output o_vga_plot
  // synthesis translate_on
);

  logic [8:0] lda_x0;
  logic [8:0] lda_x1;
  logic [7:0] lda_y0;
  logic [7:0] lda_y1;
  logic [2:0] lda_color;
  logic lda_start;
  logic ctrl_done;
  logic [8:0] vga_x;
  logic [7:0] vga_y;
  logic [2:0] vga_color;
  logic vga_plot;

  // Simulation only
  // synthesis translate_off
  assign o_vga_x = vga_x;
  assign o_vga_y = vga_y;
  assign o_vga_color = vga_color;
  assign o_vga_plot = vga_plot;
  // synthesis translate_on

  lda_avalon_slave_controller m_lda_avalon_slave_controller (
    .i_clk         (clk),
    .i_reset       (reset),

    .i_address     (avs_s1_address),
    .i_byteenable  (avs_s1_byteenable),
    .i_read        (avs_s1_read),
    .i_write       (avs_s1_write),
    .o_readdata    (avs_s1_readdata),
    .i_writedata   (avs_s1_writedata),
    .o_waitrequest (avs_s1_waitrequest),

    .o_x0          (lda_x0),
    .o_x1          (lda_x1),
    .o_y0          (lda_y0),
    .o_y1          (lda_y1),
    .o_color       (lda_color),
    .o_start       (lda_start),
    .i_done        (ctrl_done)
  );

  line_drawing_algorithm m_line_drawing_algorithm (
    .i_clk         (clk),
    .i_reset       (reset),

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
    .clk           (clk),
    .VGA_R         (coe_VGA_R_export),
    .VGA_G         (coe_VGA_G_export),
    .VGA_B         (coe_VGA_B_export),
    .VGA_HS        (coe_VGA_HS_export),
    .VGA_VS        (coe_VGA_VS_export),
    .VGA_SYNC_N    (coe_VGA_SYNC_N_export),
    .VGA_BLANK_N   (coe_VGA_BLANK_N_export),
    .VGA_CLK       (coe_VGA_CLK_export),
    .x             (vga_x),
    .y             (vga_y),
    .color         (vga_color),
    .plot          (vga_plot)
  );

endmodule

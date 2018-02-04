module line_drawing_algorithm
(
  input i_clk,
  inout i_reset,
  
  input [8:0] i_x0,
  input [8:0] i_x1,
  input [7:0] i_y0,
  input [7:0] i_y1,
  input [2:0] i_color,
  
  input i_start,
  
  output o_done,
  
  output [8:0] o_x,
  output [7:0] o_y,
  output [2:0] o_color,
  output o_plot
);

// data to control
logic keep_drawing;

// control to data
logic ld_initial;
logic update_error;
logic update_y;
logic update_x;

logic [1:0] mux_cmp0;

logic mux_alu0;
logic mux_alu1;

lda_datapath m_lda_datapath (
  .i_clk (i_clk),
  .i_reset (i_reset),
  
  // in from UI
  .i_x0 (i_x0),
  .i_x1 (i_x1),
  .i_y0 (i_y0),
  .i_y1 (i_y1),
  .i_color (i_color),
  
  // out to VGA
  .o_x (o_x),
  .o_y (o_y),
  .o_color (o_color),
  
  // in from control
  .i_ld_initial (ld_initial),
  .i_update_error (update_error),
  .i_update_y (update_y),
  .i_update_x (update_x),
  .i_mux_cmp0 (mux_cmp0),
  .i_mux_alu0 (mux_alu0),
  .i_mux_alu1 (mux_alu1),
  
  // out to control
  .o_keep_drawing (keep_drawing)
);


lda_control m_lda_control (
  .i_clk (i_clk),
  .i_reset (i_reset),
  
  // in from UI
  .i_start (i_start),
  
  // out to UI
  .o_done (o_done),
  
  // out to VGA
  .o_plot (o_plot),
  
  // in from data
  .i_keep_drawing (keep_drawing),
  
  // out to data
  .o_ld_initial (ld_initial),
  .o_update_error (update_error),
  .o_update_y (update_y),
  .o_update_x (update_x),
  .o_mux_cmp0 (mux_cmp0),
  .o_mux_alu0 (mux_alu0),
  .o_mux_alu1 (mux_alu1)
);

endmodule

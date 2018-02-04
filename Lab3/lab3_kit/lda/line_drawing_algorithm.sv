module line_drawing_algorithm
(
  input i_clk,
  input i_reset,

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


  lda_datapath m_lda_datapath (



  );


  lda_control m_lda_control (



  );


endmodule

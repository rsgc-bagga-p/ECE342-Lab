module line_drawing_algorithm
(
  input clk,
  inout reset,
  
  input [8:0] i_x0,
  input [8:0] i_x1,
  input [7:0] i_y0,
  input [7:0] i_y1,
  input i_color,
  
  input i_start,
  
  output o_done,
  
  output o_x,
  output o_y,
  output o_color,
  output o_plot
);


  lda_datapath m_lda_datapath (



  );


  lda_control m_lda_control (



  );


endmodule

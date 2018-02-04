module user_interface
(

  input                     i_clk,
  input                     i_reset,

  // input from user
  input  [8:0]              i_val,
  input                     i_setx,
  input                     i_sety,
  input                     i_setcol,
  input                     i_go,

  // input from line drawing algorithm
  input                     i_done,

  // output to line drawing algorithm
  output [8:0]              o_x0,
  output [8:0]              o_x1,
  output [7:0]              o_y0,
  output [7:0]              o_y1,
  output [2:0]              o_color,
  output                    o_start

  // for simulation only
  // synthesis translate_off
  ,
  output  [8:0]             o_xin,
  output  [7:0]             o_yin,
  output  [2:0]             o_cin
  // synthesis translate_on

);


  logic reg_ld;

  ui_datapath m_ui_datapath (
    .i_clk              (i_clk),
    .i_reset            (i_reset),
    .i_reg_ld           (reg_ld),
    .i_val              (i_val),
    .i_setx             (i_setx),
    .i_sety             (i_sety),
    .i_setcol           (i_setcol),

    .o_x0               (o_x0),
    .o_x1               (o_x1),
    .o_y0               (o_y0),
    .o_y1               (o_y1),
    .o_color            (o_color)

    // for simulation only
    // synthesis translate_off
    ,
    .o_xin              (o_xin),
    .o_yin              (o_yin),
    .o_cin              (o_cin)
    // synthesis translate_on
  );


  ui_control m_ui_control (
    .i_clk              (i_clk),
    .i_reset            (i_reset),
    .i_done             (i_done),
    .i_go               (i_go),

    .o_reg_ld           (reg_ld),
    .o_start            (o_start)
  );


endmodule

module ui_datapath
(
  input i_clk,
  input i_reset,

  input i_reg_ld,

  input [8:0] i_val,
  input i_setx,
  input i_sety,
  input i_setcol,

  output logic [8:0] o_xin,
  output logic [7:0] o_yin,
  output logic [3:0] o_cin,
  output logic [8:0] o_x0,
  output logic [8:0] o_x1,
  output logic [7:0] o_y0,
  output logic [7:0] o_y1,
  output logic [2:0] o_color
);

  always_ff @ (posedge i_clk or posedge i_reset) begin

    if (i_reset) begin
      o_xin <= 9'd0;
      o_yin <= 8'd0;
      o_cin <= 3'd0;
      o_x0 <= 9'd0;
      o_x1 <= 9'd0;
      o_y0 <= 8'd0;
      o_y1 <= 8'd0;
      o_color <= 3'd0;
    end

    if (i_setx) o_xin <= i_val[8:0];
    if (i_sety) o_yin <= i_val[7:0];
    if (i_setcol) o_cin <= i_val[2:0];

    if (i_reg_ld) begin
      o_x0 <= o_xin;
      o_x1 <= o_x0;
      o_y0 <= o_yin;
      o_y1 <= o_y0;
      o_color <= o_cin;
    end

  end

endmodule

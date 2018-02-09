module lda_asc_datapath
(
  input i_clk,
  input i_reset,

  output logic [31:0] o_readdata,
  input        [31:0] i_writedata,

  input               i_mode_ld,
  input               i_sp_ld,
  input               i_ep_ld,
  input               i_col_ld,

  output logic        o_mode,
  output logic [8:0]  o_x0,
  output logic [8:0]  o_x1,
  output logic [7:0]  o_y0,
  output logic [7:0]  o_y1,
  output logic [2:0]  o_color
);

  always_ff @ (posedge i_clk or posedge i_reset) begin : assign_regs
    if (i_reset) begin
      o_mode    <=  1'd0;
      o_x0      <=  9'd0;
      o_x1      <=  9'd0;
      o_y0      <=  8'd0;
      o_y1      <=  8'd0;
      o_color   <=  3'd0;
    end
    else begin
      if (i_mode_ld) begin
        o_mode  <=  i_writedata[0];
      end
      if (i_sp_ld) begin
        o_x0    <=  i_writedata[8:0];
        o_y1    <=  i_writedata[16:9];
      end
      if (i_ep_ld) begin
        o_x1    <=  i_writedata[8:0];
        o_y1    <=  i_writedata[16:9];
      end
      if (i_col_ld) begin
        o_color <=  i_writedata[2:0];
      end
    end
  end : assign_regs

endmodule

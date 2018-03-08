module en_reg_n #
(
  parameter WIDTH = 1
)
(
  input i_clk,
  input i_reset,
  input i_en,
  input [WIDTH-1:0] i_data_in,
  output logic [WIDTH-1:0] o_data_out
);

  always_ff @ (posedge i_clk, posedge i_reset) begin
    if (i_reset)
      o_data_out <= {'0};
    else if (i_en)
      o_data_out <= i_data_in;
  end

endmodule

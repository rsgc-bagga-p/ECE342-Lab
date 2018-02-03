module simple_alu #
(
  parameter WIDTH = 2,
  localparam NUMOPS = 2,
  localparam SWIDTH = $clog2(NUMOPS)
)
(
  input [WIDTH-1:0] i_salu_a,
  input [WIDTH-1:0] i_salu_b,
  input [SWIDTH-1:0] i_salu_sel,
  output logic [WIDTH-1:0] o_salu_out
);

  always_comb begin
    case (i_salu_sel)
      0: o_salu_out = i_salu_a + i_salu_b;
      1: o_salu_out = i_salu_a - i_salu_b;
      default: o_salu_out = {WIDTH{1'b0}};
    endcase
  end

endmodule

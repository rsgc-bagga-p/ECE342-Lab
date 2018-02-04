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
  output logic [WIDTH-1:0] o_salu_out,
  output o_salu_of,
  output o_salu_uf
);

  localparam ADD = 0;
  localparam SUB = 1;

  assign o_salu_of = (~i_salu_a[WIDTH-1] | ~i_salu_b[WIDTH-1])
    & (~o_salu_out[WIDTH-1])& (i_salu_sel == ADD);

  assign o_salu_uf = (i_salu_b > i_salu_a) & (i_salu_sel == SUB);

  always_comb begin
    case (i_salu_sel)
      ADD: o_salu_out = i_salu_a + i_salu_b;
      SUB: o_salu_out = i_salu_a - i_salu_b;
      default: o_salu_out = {WIDTH{1'b0}};
    endcase
  end

endmodule

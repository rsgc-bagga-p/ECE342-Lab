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
  output o_overflow,
  output o_underflow
);

  localparam ADD = 0;
  localparam SUB = 1;

  always_comb begin
    case (i_salu_sel)
      ADD: o_salu_out = i_salu_a + i_salu_b;
      SUB: o_salu_out = i_salu_a - i_salu_b;
      default: o_salu_out = {WIDTH{1'b0}};
    endcase
  end

  always_comb begin

    o_overflow = 1'b0;
    o_underflow = 1'b0;

    if (~i_salu_a[WIDTH-1] & ~i_salu_b[WIDTH-1] & i_salu_sel == ADD)
      o_overflow = 1'b1;

    if (i_salu_a[WIDTH-1] & i_salu_b[WIDTH-1] & i_salu_sel == SUB)
      o_underflow = 1'b1;

  end

endmodule

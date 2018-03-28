module alu #
(
  parameter WIDTH = 2
)
(
  input                     i_op_sel,
  input  [WIDTH-1:0]        i_op_a,
  input  [WIDTH-1:0]        i_op_b,
  output logic [WIDTH-1:0]  o_alu_out,
  output                    o_n,
  output                    o_z
);

  // negative and zero flags
  assign o_n = o_alu_out[WIDTH-1];
  assign o_z = ~|o_alu_out;

  // combinational computation
  always_comb begin
    case (i_op_sel)
      0: o_alu_out = i_op_a + i_op_b;
      1: o_alu_out = i_op_a - i_op_b;
      default: o_alu_out = {'0};
    endcase
  end

endmodule

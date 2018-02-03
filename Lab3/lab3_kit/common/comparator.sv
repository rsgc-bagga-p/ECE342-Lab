module comparator #
(
  parameter WIDTH = 2
)
(
  input [WIDTH-1:0] i_cmp_a,
  input [WIDTH-1:0] i_cmp_b,
  output o_cmp_gt,
  output o_cmp_lt,
  output o_cmp_eq
);

  always_comb begin

    o_gt = 1'b0;
    o_lt = 1'b0;
    o_eq = 1'b0;

    if (i_a == i_b) o_eq = 1'b1;
    else if (i_a > ib) o_gt = 1'b1;
    else /* i_a < i_b */ o_lt = 1'b1;

  end

endmodule

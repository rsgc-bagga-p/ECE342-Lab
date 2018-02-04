module comparator #
(
  parameter WIDTH = 2
)
(
  input signed [WIDTH-1:0] i_cmp_a,
  input signed [WIDTH-1:0] i_cmp_b,
  output o_cmp_gt,
  output o_cmp_lt,
  output o_cmp_eq
);

  assign o_cmp_gt = (i_cmp_a > i_cmp_b);
  assign o_cmp_lt = (i_cmp_a < i_cmp_b);
  assign o_cmp_eq = (i_cmp_a == i_cmp_b);

endmodule

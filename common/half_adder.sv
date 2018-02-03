module half_adder
(
  input i_a,
  input i_b,

  output o_sum,
  output o_cout
);

  assign o_sum = i_a ^ i_b;
  assign o_cout = i_a & i_b;

endmodule

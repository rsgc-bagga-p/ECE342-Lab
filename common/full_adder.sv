module full_adder
(
  input i_a,
  input i_b,
  inout i_cin,

  output o_sum,
  output o_cout
);

  assign o_sum = i_a ^ i_b ^ cin;
  assign o_cout = (i_a & i_b) | ((i_a | i_b) & cin);

endmodule

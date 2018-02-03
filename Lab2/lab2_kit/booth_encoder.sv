module booth_encoder
(
  input [1:0] i_q,

  output o_plus,
  output o_minus
);

  assign o_plus = i_q[0] & ~i_q[1];
  assign o_minus = i_q[1] & ~i_q[0];

endmodule

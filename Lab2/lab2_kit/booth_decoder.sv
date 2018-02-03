// Dependencies: full_adder.sv

module booth_decoder
(
  input i_plus,
  input i_minus,
  input i_m,
  input i_pin,
  input i_cin,

  output o_se,
  output o_pout,
  output o_cout
);

  logic mout;
  assign mout = (i_plus & i_m) | (i_minus & ~i_m);
  assign o_se = mout;

  full_adder m_full_adder (
    .i_a(mout),
    .i_b(i_pin),
    .i_cin(i_cin),
    .o_sum(o_pout),
    .o_cout(o_cout)
  );

endmodule

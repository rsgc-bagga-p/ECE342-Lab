module lda_datapath
(


);


simple_alu #(
  .WIDTH  (9),
) m_salu_1 (
  .i_salu_a,
  .i_salu_b,
  .i_salu_sel,
  .o_salu_out
);

simple_alu #(
  .WIDTH  (9),
) m_salu_2 (
  .i_salu_a,
  .i_salu_b,
  .i_salu_sel,
  .o_salu_out
);

module comparator #
(
  .WIDTH (9),
)
(
  .i_cmp_a,
  .i_cmp_b,
  .o_cmp_gt,
  .o_cmp_lt,
  .o_cmp_eq
);
endmodule

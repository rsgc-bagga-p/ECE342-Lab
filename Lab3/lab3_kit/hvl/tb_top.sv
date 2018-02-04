`timescale 100ps/100ps // Makes 50GHz

module tb_top();

  parameter UNIT = "ui";

  generate

    if (UNIT == "ui")
      tb_ui m_tb_ui();

    if (UNIT == "lda")
      tb_lda m_tb_lda();

    if (UNIT == "salu")
      tb_salu m_tb_salu();

    if (UNIT == "cmp")
      tb_cmp m_tb_cmp();

  endgenerate

endmodule

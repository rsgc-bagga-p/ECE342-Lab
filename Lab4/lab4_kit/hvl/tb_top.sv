`timescale 100ps/100ps // Makes 50GHz

module tb_top();

  parameter UNIT = "pass";

  generate

    if (UNIT == "asc")
      tb_asc m_tb_asc();

    if (UNIT == "lda")
      tb_lda m_tb_lda();

  endgenerate

  if (UNIT != "pass" || UNIT != "asc" || UNIT != "lda") begin
      $info("No testbench selected");
      $info("sim.do usage:");
      $info("Modelsim> do sim.do [asc|lda]");
  end

endmodule

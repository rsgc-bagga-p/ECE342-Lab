`timescale 1ns/1ns // Makes 100MHz

module tb_top();

  parameter UNIT = "none";

  generate

    if (UNIT == "lda")
      tb_avlintf m_tb_lda();

  endgenerate

  if (UNIT != "lda") begin
    $info("No testbench selected for sim.do\nusage: Modelsim> do sim.do [lda]");
  end

endmodule

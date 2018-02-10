`timescale 100ps/100ps // Makes 50GHz

module tb_top();

  parameter UNIT = "pass";

  generate

    if (UNIT == "asc")
      tb_asc m_tb_asc();

    if (UNIT == "avl")
      tb_avlintf m_tb_avlintf();

  endgenerate

  if (UNIT != "pass" || UNIT != "asc" || UNIT != "avl") begin
      $info("No testbench selected\nsim.do usage:\nModelsim> do sim.do [asc|avl]");
  end

endmodule

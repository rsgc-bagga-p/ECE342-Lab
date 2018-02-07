`timescale 100ps/100ps // Makes 50GHz

module tb_top();

  parameter UNIT = "pass";

  generate

    if (UNIT != "pass") begin

      if (UNIT == "asc")
        tb_asc m_tb_asc();

      if (UNIT == "lda")
        tb_lda m_tb_lda();

    end

    else begin
      $display("No testbench selected");
      $display("sim.do usage:");
      $display("Modelsim> do sim.do [asc|lda]");
    end

  endgenerate

endmodule

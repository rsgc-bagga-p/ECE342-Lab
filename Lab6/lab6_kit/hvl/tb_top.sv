`timescale 1ns/1ns // Makes 100MHz

module tb_top();

  parameter UNIT = "none";

  generate

    if (UNIT == "bus")
      tb_bus m_tb_bus();

  endgenerate

  if (UNIT != "bus" /*|| UNIT != "pt2"*/ ) begin
    $info("No testbench selected for sim.do\nusage: Modelsim> do sim.do [bus]");
  end

endmodule

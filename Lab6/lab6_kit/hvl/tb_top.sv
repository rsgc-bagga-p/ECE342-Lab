`timescale 1ns/1ns // Makes 100MHz

module tb_top();

  parameter UNIT = "none";
  parameter TFILE = "software/regjump.hex";

  generate

    if (UNIT == "cpu") begin
      tb_cpu m_tb_cpu();
      defparam m_tb_cpu.HEX_FILE = TFILE;
    end

    if (UNIT == "rf")
      tb_rf m_tb_rf();

    if (UNIT == "alu")
      tb_alu m_tb_alu();

  endgenerate

  if (UNIT != "cpu" || UNIT != "rf" || UNIT != "alu") begin
    $info("No testbench selected for sim.do\nusage: Modelsim> do sim.do [cpu|rf|alu]");
  end

endmodule

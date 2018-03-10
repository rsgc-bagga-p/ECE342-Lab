`timescale 1ns/1ns // Makes 100MHz

module tb_bus();

  // Create a 100MHz clock
  logic clk;
  initial clk = '0;
  always #5 clk = ~clk;

  // Create the reset signal and assert it for a few cycles
  logic reset;
  initial begin
    reset = '1;
    @(posedge clk);
    @(posedge clk);
    reset = '0;
  end

  logic [15:0] mem_addr;
  logic        mem_rd;
  logic        mem_wr;
  logic [15:0] mem_wrdata;
  logic [15:0] mem_rddata;

  logic [15:0] mem4k_rddata;
  logic [15:0] mem4k_addr;
  logic        mem4k_wr;
  logic [15:0] mem4k_wrdata;

  logic        ledr_en;
  logic  [8:0] ledr_data_in;

  logic  [8:0] sw_data_out;

  // DUT Instantiation
  module bus (
    .i_clk                (clk),
    .i_reset              (reset),
    // cpu interface
    .i_cpu_mem_addr       (mem_addr),
    .i_cpu_mem_rd         (mem_rd),
    .i_cpu_mem_wr         (mem_wr),
    .i_cpu_mem_wrdata     (mem_wrdata),
    .o_cpu_mem_rddata     (mem_rddata),
    // memory interface
    .i_mem4k_rddata       (mem4k_rddata),
    .o_mem4k_addr         (mem4k_addr),
    .o_mem4k_wr           (mem4k_wr),
    .o_mem4k_wrdata       (mem4k_wrdata),
    // ledr interface
    .o_ledr_en            (ledr_en),
    .o_ledr_data_in       (ledr_data_in),
    // sw interface
    .i_sw_data_out        (sw_data_out)
  );

  initial begin

    int write;
    int addr, value;

    mem_rd = 0;

    // test every single mem4k address with every value
    for (addr = 0; addr <= 16'h0FFF; addr++) begin
      for (value = 0; value <= 16'hFFFF; value++) begin
        for (write = 0; write <= 1; write++) begin
          mem_addr = addr;
          mem_wrdata = value;
          mem_wr = write;
          if (mem4k_wr != mem_wr || mem4k_wrdata != mem_wrdata || mem4k_addr != mem_addr>>1)
          begin
            $display("DUT output did not match Model output during mem4k!");
            $display("DUT result was: addr = %0d, wr = %0d, wrdata = %0d",
                      mem4k_addr, mem4k_wr, mem4k_wrdata);
            $display("Expected result was: addr = %0d, wr = %0d, wrdata = %0d",
                      addr, write, value);
            $stop;
          end
          if (ledr_en != 0) begin
            $display("mem4k affecting other enables");
            $stop;
          end
        end
      end
    end

    // test every single sw address
    sw_data_out = 16'h1234; // magic number
    for (addr = 16'h2000; addr <= 16'h2FFF; addr++) begin
      mem_addr = addr;
      if (mem_rddata != sw_data_out)
      begin
        $display("DUT output did not match Model output during sw!");
        $display("DUT result was: addr = %0d, sw_data = %0d",
                  mem_addr, mem_rddata);
        $display("Expected result was: addr = %0d, sw_data = %0d",
                  addr, sw_data_out);
        $stop;
      end
      if (ledr_en != 0 || mem4k_wr != 0) begin
        $display("sw affecting other enables");
        $stop;
      end
    end

    // test every single ledr address with every value
    for (addr = 16'h3000; addr <= 16'h3FFF; addr++) begin
      for (value = 0; value <= 8'hFF; value++) begin
        for (write = 0; write <= 1; write++) begin
          mem_addr = addr;
          mem_wrdata = value;
          mem_wr = write;
          if (ledr_en != mem_wr || ledr_data_in != mem_wrdata)
          begin
            $display("DUT output did not match Model output during ledr!");
            $display("DUT result was: addr = %0d, wr = %0d, wrdata = %0d",
                      mem_addr, ledr_en, ledr_data_in);
            $display("Expected result was: addr = %0d, wr = %0d, wrdata = %0d",
                      addr, write, value);
            $stop;
          end
          if (mem4k_wr != 0) begin
            $display("ledr affecting other enables");
            $stop;
          end
        end
      end
    end

  end

endmodule

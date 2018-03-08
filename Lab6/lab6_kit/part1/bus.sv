module bus
(
  input i_clk,
  input i_reset,

  // cpu interface
  input        [15:0] i_cpu_mem_addr,
  input               i_cpu_mem_rd,
  input               i_cpu_mem_wr,
  input        [15:0] i_cpu_mem_wrdata,
  output logic [15:0] o_cpu_mem_rddata,

  // memory interface
  input        [15:0] i_mem4k_rddata,
  output logic [15:0] o_mem4k_addr,
  output logic [15:0] o_mem4k_wr,
  output logic [15:0] o_mem4k_wraddr,

  // ledr interface
  output logic        o_ledr_en,
  output logic  [8:0] o_ledr_data_in,

  // sw interface
  input         [8:0] i_sw_data_out
);

  // bus logic
  always_comb begin

    case (i_cpu_mem_addr[15:12])

      o_cpu_mem_rddata        = {'0};

      o_mem4k_addr            = {'0};
      o_mem4k_wr              = {'0};
      o_mem4k_wraddr          = {'0};

      o_ledr_en               = {'0};
      o_ledr_data_in          = {'0};

      0: begin // mem4k
        o_mem4k_addr          = i_cpu_mem_addr >> 1;
        o_mem4k_wr            = i_cpu_mem_wr;
        o_mem4k_wrdata        = i_cpu_mem_wrdata;
        o_cpu_mem_rddata      = i_mem4k_rddata;
      end

      2: begin // sw
        o_cpu_mem_rddata      = i_sw_data_out;
      end

      3: begin // ledr
        o_ledr_en             = i_cpu_mem_wr;
        o_ledr_data_in        = i_cpu_mem_wrdata;
      end

    endcase

  end // always_comb

endmodule

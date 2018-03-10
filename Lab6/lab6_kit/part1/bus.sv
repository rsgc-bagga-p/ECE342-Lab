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
  output logic        o_mem4k_wr,
  output logic [15:0] o_mem4k_wrdata,

  // ledr interface
  output logic        o_ledr_en,
  output logic  [7:0] o_ledr_data_in,

  // sw interface
  input         [7:0] i_sw_data_out
);

  logic [15:0] paddr;
  logic        prd;

  always_ff @ (posedge i_clk or posedge i_reset) begin
    if (i_reset) begin
      paddr <= {'0};
      prd   <= {'0};
    end
    else begin
      paddr <= i_cpu_mem_addr;
      prd   <= i_cpu_mem_rd;
    end
  end

  // bus logic
  always_comb begin

    // signal defaults
    o_cpu_mem_rddata        = {'0};

    o_mem4k_addr            = {'0};
    o_mem4k_wr              = {'0};
    o_mem4k_wrdata          = {'0};

    o_ledr_en               = {'0};
    o_ledr_data_in          = {'0};

    // writes: made in the same cycle
    case (i_cpu_mem_addr[15:12])

      0: begin // mem4k
        o_mem4k_addr          = i_cpu_mem_addr >> 1;
        o_mem4k_wr            = i_cpu_mem_wr;
        o_mem4k_wrdata        = i_cpu_mem_wrdata;
      end

      2: begin // sw
        ; // sw cannot be written to
      end

      3: begin // ledr
        o_ledr_en             = i_cpu_mem_wr;
        o_ledr_data_in        = i_cpu_mem_wrdata[7:0];
      end

      default: ; // do nothing

    endcase

    // reads: bus must switch to read data 1 cycle after read
    case (paddr[15:12])

      0: begin // mem4k
        o_cpu_mem_rddata      = i_mem4k_rddata;
      end

      2: begin // sw
        o_cpu_mem_rddata      = {8'd0,i_sw_data_out};
      end

      3: begin // ledr
        ; // ledr cannot be read from
      end

      default: ; // do nothing

    endcase

  end // always_comb

endmodule

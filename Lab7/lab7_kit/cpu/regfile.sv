module regfile #
(
  parameter WIDTH = 2,
  parameter NUMREGS = 2
)
(
  input i_clk,
  input i_reset,

  input                         i_write,
  input   [$clog2(NUMREGS)-1:0] i_addrw,
  input   [$clog2(NUMREGS)-1:0] i_addrx,
  input   [$clog2(NUMREGS)-1:0] i_addry,
  input   [WIDTH-1:0]           i_data_in,
  output  logic [WIDTH-1:0]     o_datax_out,
  output  logic [WIDTH-1:0]     o_datay_out,
  // make internal regs visible for testbench
  output  [NUMREGS-1:0] [WIDTH-1] o_regs
);

  // internal registers
  logic [NUMREGS-1:0] [WIDTH-1:0] regs;

  assign o_regs = regs;

  // assign outputs
  // this works apparently
  assign o_datax_out = regs[i_addrx];
  assign o_datay_out = regs[i_addry];
  // this doesn't work
  /*
  integer c_i;
  always_comb begin
    for (c_i = 0; c_i < NUMREGS; c_i++) begin
      if (i_addrx == c_i) o_datax_out = regs[c_i];
      if (i_addry == c_i) o_datay_out = regs[c_i];
    end
  end
  */

  // take inputs
  integer s_i;
  always_ff @ (posedge i_clk, posedge i_reset) begin
    if (i_reset) regs <= {'0};
    else if (i_write)
      for (s_i = 0; s_i < NUMREGS; s_i++) begin
        if (i_addrw == s_i) regs[s_i] <= i_data_in;
        else                regs[s_i] <= regs[s_i];
      end
    else regs <= regs;
  end // always_ff

endmodule

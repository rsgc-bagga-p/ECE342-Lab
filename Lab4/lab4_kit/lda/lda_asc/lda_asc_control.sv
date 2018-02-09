module lda_asc_control
(
  input i_clk,
  input i_reset,

  input   [31:0]    i_address,
  input             i_read,
  input             i_write,
  output            i_done,

  input             i_mode,

  output  logic     o_start,
  output  logic     o_waitrequest,

  output  logic     o_status,
  output  logic     o_mode_ld,
  output  logic     o_sp_ld,
  output  logic     o_ep_ld,
  output  logic     o_col_ld
);

  import lda_reg_pkg::*;

  lda_reg_t reg_en;

  // States
  enum int unsigned
  {
    // intial state
    S_WAIT,
    S_RUN
  } state, nextstate;

  // State regs
  always_ff @ (posedge i_clk or posedge i_reset) begin
  	if (i_reset) state <= S_WAIT;
  	else state <= nextstate;
  end

  // State table
  always_comb begin : state_table
    o_start = 1'd0;
    o_status = 1'd0;
    o_waitrequest = 1'd0;

    case (state)
      S_WAIT: begin
        if (i_write && reg_en == GO) begin
          o_start = 1'd1;
          if (i_mode)
            o_status = 1'd1;
          else
            o_waitrequest = 1'd1;
          nextstate = S_RUN;
        end
      end
      S_RUN: begin
        if(i_done) nextstate = S_WAIT;
      end
    endcase
  end : state_table

  // Other combinational logic
  always_comb begin : other_logic
    o_mode_ld   = 1'd0;
    o_sp_ld     = 1'd0;
    o_ep_ld     = 1'd0;
    o_col_ld    = 1'd0;
    rd_sel      = NONE;

    // decode address
    if(i_address >= 32'h0001_1020 && i_address < 32'h0001_1024)
      reg_en = MODE;
    if(i_address >= 32'h0001_1024 && i_address < 32'h0001_1028)
      reg_en = STATUS;
    if(i_address >= 32'h0001_1028 && i_address < 32'h0001_102C)
      reg_en = GO;
    if(i_address >= 32'h0001_102C && i_address < 32'h0001_1030)
      reg_en = START_P;
    if(i_address >= 32'h0001_1030 && i_address < 32'h0001_1034)
      reg_en = END_P;
    if(i_address >= 32'h0001_1034 && i_address < 32'h0001_1038)
      reg_en = COLOR;
    if(i_address >= 32'h0001_1038 || i_address < 32'h0001_1024)
      reg_en = NONE;

    // basic read and write
    if(reg_en != NONE) begin
      if(i_read)
        rd_sel = reg_en;
      if(i_write) begin
        case (reg_en)
          MODE:     o_mode_ld   = 1'd1;
          START_P:  o_sp_ld     = 1'd1;
          END_P:    o_ep_ld     = 1'd1;
          COLOR:    o_col_ld    = 1'd1;
        endcase
      end
    end
  end : other_logic

endmodule

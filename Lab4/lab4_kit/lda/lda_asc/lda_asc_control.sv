module lda_asc_control
import lda_asc_pkg::*;
(
  input i_clk,
  input i_reset,

  input   [2:0]     i_address,
  input             i_read,
  input             i_write,
  input             i_done,

  input             i_mode,

  output  logic     o_start,
  output  logic     o_waitrequest,

  output  logic     o_status,
  output  lda_reg_t o_rd_sel,
  output  logic     o_mode_ld,
  output  logic     o_sp_ld,
  output  logic     o_ep_ld,
  output  logic     o_col_ld
);

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
    nextstate = state;

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
    o_rd_sel    = NONE;
    reg_en      = NONE;

    // decode address
    case (i_address)
      3'b000:  reg_en = MODE;
      3'b001:  reg_en = STATUS;
      3'b010:  reg_en = GO;
      3'b011:  reg_en = START_P;
      3'b100:  reg_en = END_P;
      3'b101:  reg_en = COLOR;
      default: reg_en = NONE;
    endcase

    // basic read and write
    if(i_read)
      o_rd_sel = reg_en;
    if(i_write) begin
      case (reg_en)
        MODE:     o_mode_ld   = 1'd1;
        START_P:  o_sp_ld     = 1'd1;
        END_P:    o_ep_ld     = 1'd1;
        COLOR:    o_col_ld    = 1'd1;
        default:  /* do nothing */  ;
      endcase
    end
  end : other_logic

endmodule

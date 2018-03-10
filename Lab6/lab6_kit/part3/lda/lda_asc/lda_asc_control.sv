module lda_asc_control
import lda_asc_pkg::*;
(
  input i_clk,
  input i_reset,

  input   [2:0]     i_address,
  input   [3:0]     i_byteenable,
  input             i_read,
  input             i_write,
  input             i_done,

  input             i_mode,

  output  logic     o_start,
  output  logic     o_waitrequest,

  output  logic     o_status,
  output  lda_reg_t o_rd_sel,
  output  logic     o_mode_ld,
  output  logic     o_sp_hi_ld,
  output  logic     o_sp_lo_ld,
  output  logic     o_ep_hi_ld,
  output  logic     o_ep_lo_ld,
  output  logic     o_col_ld
);

  lda_reg_t reg_en;
  //lda_reg_t old_en;
  //logic old_write;

  // States
  enum int unsigned
  {
    // intial state
    S_WAIT,
    S_RUN,
    S_PAUSE
  } state, nextstate;

  // State regs
  always_ff @ (posedge i_clk or posedge i_reset) begin
    if (i_reset) state <= S_WAIT;
    else state <= nextstate;

    /*if (i_reset) begin
      old_en <= NONE;
      old_write <= 1'b0;
    end
    else begin
      old_en <= reg_en;
      old_write <= i_write;
    end*/
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
        //if (((old_write && old_en != GO) || !old_write) && (i_write && reg_en == GO)) begin
          o_start = 1'd1;
          if (i_mode) o_status = 1'd1;
          else begin
            o_waitrequest = 1'd1;
            o_status = 1'd1;
          end
          nextstate = S_RUN;
        end
      end
      S_RUN: begin
        if (i_mode) o_status = 1'd1;
        else begin
          o_waitrequest = 1'd1;
          o_status = 1'd1;
        end
        if (i_done) begin
          //nextstate = S_WAIT;
          if (i_mode) nextstate = S_WAIT;
          else nextstate = S_PAUSE;
        end
      end
      S_PAUSE: begin
        nextstate = S_WAIT;
      end
    endcase
  end : state_table

  // Other combinational logic
  always_comb begin : other_logic
    o_mode_ld   = 1'd0;
    o_sp_hi_ld  = 1'd0;
    o_sp_lo_ld  = 1'd0;
    o_ep_hi_ld  = 1'd0;
    o_ep_lo_ld  = 1'd0;
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
    if (i_read) o_rd_sel = reg_en;
    if (i_write) begin
      case (reg_en)
        MODE: begin
          if (i_byteenable == 4'b0011)
            o_mode_ld = 1'd1;
        end
        START_P: begin
          case (i_byteenable)
            4'b0011: o_sp_lo_ld = 1'd1;
            4'b1100: o_sp_hi_ld = 1'd1;
            default: ; // nothing
          endcase
        end
        END_P: begin
          case (i_byteenable)
            4'b0011: o_ep_lo_ld = 1'd1;
            4'b1100: o_ep_hi_ld = 1'd1;
            default: ; // nothing
          endcase
        end
        COLOR: begin
          if (i_byteenable == 4'b0011)
            o_col_ld = 1'd1;
        end
        default:  /* do nothing */  ;
      endcase
    end
  end : other_logic

endmodule

module ui_control
(
  input i_clk,
  input i_reset,

  input i_done,
  input i_go,

  output logic o_reg_ld,
  output logic o_start
);

  enum int unsigned
  {
    // initial state
    S_WAIT,    // wait until lda has finished drawing and asserted i_done
    S_READY,   // i_done is asserted and i_go can now be accepted
    S_LOAD,    // i_go signal has been asserted, load datapath registers
    S_START    // start lda
  } state, nextstate;

  always_ff @ (posedge i_clk or posedge i_reset) begin
    if (i_reset) state <= S_WAIT;
    else state <= nextstate;
  end

  always_comb begin

    nextstate = state;
    o_reg_ld = 1'b0;
    o_start = 1'b0;

    case (state)

      S_WAIT: begin
        // wait for lda to finish drawing and assert i_done
        if (i_done) nextstate <= S_READY;
      end

      S_READY: begin
        // user has asserted go
        if (i_go) nextstate <= S_LOAD;
      end

      S_LOAD: begin
        // load registers
        o_reg_ld = 1'b1;
        nextstate <= S_START;
      end

      S_START: begin
        // start lda
        o_start = 1'b1;
        nextstate <= S_WAIT;
      end

    endcase

  end // always_comb

endmodule

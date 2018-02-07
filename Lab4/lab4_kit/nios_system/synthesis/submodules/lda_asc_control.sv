module lda_asc_control
(
  input i_clk,
  input i_reset


);

  enum int unsigned
  {
    // intial state
    S_WAIT,
    S_START,
    S_RUN,
    S_FINISH
  } state, nextstate;




endmodule

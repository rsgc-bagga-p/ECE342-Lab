module lda_control
(
  input i_clk,
  input i_reset,
  
  // in from UI
  input i_start,
  
  // out to UI
  output logic o_done,
  
  // out to VGA
  output logic o_plot,
  
  // in from data
  input i_keep_drawing,
  
  // out to data
  output logic o_ld_initial,
  output logic o_update_error,
  output logic o_update_y,
  output logic o_update_x,
  output logic [1:0] o_mux_cmp0,
  output logic o_mux_alu0,
  output logic o_mux_alu1
);

// States
enum int unsigned
{
	S_WAIT,
  S_INIT,
  S_LOOP_CHECK,
  S_DRAW
} state, nextstate;

// State regs
always_ff @ (posedge i_clk or posedge i_reset) begin
	if (i_reset) state <= S_WAIT;
	else state <= nextstate;
end

// State table
always_comb begin
	nextstate = state;
	o_done = 1'b0;
  o_plot = 1'b0;
  
  o_ld_initial = 1'b0;
  o_update_error = 1'b0;
  o_update_y = 1'b0;
  o_update_x = 1'b0;
  
  o_mux_cmp0 = 2'd0;
  
  o_mux_alu0 = 1'b0;
  o_mux_alu1 = 1'b0;
	
	case (state)
		S_WAIT: begin
			o_done = 1'b1;
			if (i_start) nextstate = S_INIT;
		end
    S_INIT: begin
      o_ld_initial = 1'b1;
      
      o_mux_cmp0 = 2'd0;
      
      o_mux_alu0 = 1'b0;
      o_mux_alu1 = 1'b0;
      
      nextstate = S_LOOP_CHECK;
    end
    S_LOOP_CHECK: begin
      o_mux_cmp0 = 2'd1;
      nextstate = i_keep_drawing ? S_DRAW : S_WAIT;
    end
    S_DRAW: begin
      o_plot = 1'b1;
      
      o_update_error = 1'b1;
      o_update_y = 1'b1;
      o_update_x = 1'b1;
      
      o_mux_cmp0 = 2'd2;
      
      o_mux_alu0 = 1'b1;
      o_mux_alu1 = 1'b1;
      
      nextstate = S_LOOP_CHECK;
    end
	endcase
end

endmodule

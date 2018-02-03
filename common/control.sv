module control
(
	input clk,
	input reset,

	// Other signals

);

// Declare two objects, 'state' and 'nextstate'
// that are of enum type.
enum int unsigned
{
	// TODO: declare states here

} state, nextstate;

// Clocked always block for making state registers
always_ff @ (posedge clk or posedge reset) begin
	if (reset) state <= ;// TODO: choose initial reset state
	else state <= nextstate;
end

// always_comb replaces always @* and gives compile-time errors instead of warnings
// if you accidentally infer a latch
always_comb begin
	// Set default values for signals here, to avoid having to explicitly
	// set a value for every possible control path through this always block
	nextstate = state;
	o_inc_actual = 1'b0;
	o_dec_guess_count = 1'b1;
	o_update_leds = 1'b0;

	case (state)
		// TODO: complete this
		S_INIT: begin
			o_inc_actual <= 1'b1;
			if (i_enter) nextstate <= S_UPDATE;
		end
		S_UPDATE: begin
			// decrement guess counter
			o_update_leds <= 1'b1;
			o_dec_guess_count <= 1'b1;
			nextstate <= S_WAIT;
		end
		S_WAIT: begin
			if (i_game_over) nextstate <= S_END;
			else if (i_enter) nextstate <= S_UPDATE;
		end
		S_END: begin
			// do nothing
		end
	endcase
end

endmodule

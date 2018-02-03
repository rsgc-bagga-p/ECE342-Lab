module control
(
	input clk,
	input reset,

	// Button input
	input i_enter,

	// Datapath
	output logic o_inc_actual,
	output logic o_dec_guess_count,
	input i_over,
	input i_under,
	input i_equal,
	input i_game_over,

	// LED Control: Setting this to 1 will copy the current
	// values of over/under/equal to the 3 LEDs. Setting this to 0
	// will cause the LEDs to hold their current values.
	output logic o_update_leds
);

// Declare two objects, 'state' and 'nextstate'
// that are of enum type.
enum int unsigned
{
	// TODO: declare states here
	S_INIT, // (initial state) increment actual until i_enter becomes high
	S_UPDATE, // update leds
	S_UPDATE_DONE,
	S_WAIT, // idle until i_enter becomes high
	S_END // gameover
} state, nextstate;

// Clocked always block for making state registers
always_ff @ (posedge clk or posedge reset) begin
	if (reset) state <= S_INIT; // TODO: choose initial reset state
	else state <= nextstate;
end

// always_comb replaces always @* and gives compile-time errors instead of warnings
// if you accidentally infer a latch
always_comb begin
	// Set default values for signals here, to avoid having to explicitly
	// set a value for every possible control path through this always block
	nextstate = state;
	o_inc_actual = 1'b0;
	o_dec_guess_count = 1'b0;
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
			nextstate <= S_UPDATE_DONE;
		end
		S_UPDATE_DONE: begin
			// wait until button is lifted before waiting for next guess
			if (~i_enter) nextstate <= S_WAIT;
		end
		S_WAIT: begin
			// wait for next guess if not gameover
			if (i_game_over) nextstate <= S_END;
			else if (i_enter) nextstate <= S_UPDATE;
		end
		S_END: begin
			// do nothing
		end
	endcase

end

endmodule

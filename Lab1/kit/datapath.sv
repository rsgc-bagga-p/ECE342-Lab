module datapath
(
	input clk,
	input reset,

	// Number entry
	input [7:0] i_guess,

	// Increment actual
	input i_inc_actual,

	// Decrement guesses
	input i_dec_guess_count,

	// Number of guesses
	output logic [2:0] o_guess_count,

	// Comparison result
	output o_over,
	output o_under,
	output o_equal,
	output o_game_over

);

// Represents the output of the register that will hold the
// actual randomly-generated number that needs to be guessed
// by the player.
//
// No registers get created by this statement alone: its use
// on the left-hand-side of an assignment inside an always_ff block
// is what generates the register. This variable then represents
// the Q output of that register.
logic [7:0] actual;

// Implements the datapath diagram from the lab handout.
// This creates the 'actual' register and the logic
// surrounding it.
//
// Note how the inner if statement, and the i_inc_actual signal,
// get mapped to the enable input of the generated register.
//
// By adding 'or posedge reset' to the sensitivity list,
// this turns the reset signal into an asynchronous reset, connected
// directly to the register's aclr input.
//
// If 'or posedge reset' wasn't there, the reset would be synchronous
// and likely implemented as a multiplexer connected to the 'D' input
// with the two inputs being: 0, and the result of actual+1. The mux
// select signal would be driven by the 'reset' signal. Additionally,
// the register's enable input would now need to be a function of both
// i_inc_actual and reset.
//
// The goal of these comments is to get you to think about how the code
// you write maps to actual hardware.
always_ff @ (posedge clk or posedge reset) begin
	if (reset) begin
		actual <= 8'd0;
		o_guess_count <= 3'd7;
	end
	else begin
		if (i_inc_actual) actual <= actual + 8'd1;
		if (i_dec_guess_count) o_guess_count <= o_guess_count - 3'd1;
	end
end

// Generate comparisons.
// These just get implemented as blobs of combinational logic.
assign o_over = i_guess > actual;
assign o_equal = i_guess == actual;
assign o_under = i_guess < actual;
// game_over when player guesses correctly or runs out of guesses
assign o_game_over = o_equal || (o_guess_count == 3'd0);

endmodule

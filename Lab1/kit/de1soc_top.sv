module de1soc_top
(
	// These are the board inputs/outputs required for all the ECE342 labs.
	// Each lab can use the subset it needs -- unused pins will be ignored.

    // Clock pins
    input                     CLOCK_50,

    // Seven Segment Displays
    output      [6:0]         HEX0,
    output      [6:0]         HEX1,
    output      [6:0]         HEX2,
    output      [6:0]         HEX3,
    output      [6:0]         HEX4,
    output      [6:0]         HEX5,

    // Pushbuttons
    input       [3:0]         KEY,

    // LEDs
    output      [9:0]         LEDR,

    // Slider Switches
    input       [9:0]         SW,

    // VGA
    output      [7:0]         VGA_B,
    output                    VGA_BLANK_N,
    output                    VGA_CLK,
    output      [7:0]         VGA_G,
    output                    VGA_HS,
    output      [7:0]         VGA_R,
    output                    VGA_SYNC_N,
    output                    VGA_VS
);

	// Clock signal
	wire clk = CLOCK_50;

	// KEYs are active low, invert them here
	wire reset = ~KEY[0];
	wire enter = ~KEY[1];

	// Number guess input
	wire [7:0] guess = SW[7:0];

	// Datapath
	logic dp_inc_actual;
	logic dp_dec_guess_count;
	logic [2:0] dp_guess_count;
	logic dp_over;
	logic dp_under;
	logic dp_equal;
	logic dp_game_over;
	datapath the_datapath
	(
		.clk(clk),
		.reset(reset),

		.i_guess(guess),

		.i_inc_actual(dp_inc_actual),

		.i_dec_guess_count(dp_dec_guess_count),

		.o_guess_count(dp_guess_count),

		.o_over(dp_over),
		.o_under(dp_under),
		.o_equal(dp_equal),
		.o_game_over(dp_game_over)
	);

	// State Machine
	logic ctrl_update_leds;
	control the_control
	(
		.clk(clk),
		.reset(reset),

		.i_enter(enter),

		.o_inc_actual(dp_inc_actual),
		.o_dec_guess_count(dp_dec_guess_count),
		.i_over(dp_over),
		.i_under(dp_under),
		.i_equal(dp_equal),
		.i_game_over(dp_game_over),

		.o_update_leds(ctrl_update_leds)
	);

	// LED controllers
	led_ctrl ledc_under(clk, reset, dp_under, ctrl_update_leds, LEDR[9]);
	led_ctrl ledc_over(clk, reset, dp_over, ctrl_update_leds, LEDR[0]);
	led_ctrl ledc_equal(clk, reset, dp_equal, ctrl_update_leds, LEDR[4]);

	// Hex Decoders
	hex_decoder hexdec_guess0
	(
		.hex_digit(guess[3:0]),
		.segments(HEX0)
	);

	hex_decoder hexdec_guess1
	(
		.hex_digit(guess[7:4]),
		.segments(HEX1)
	);

	hex_decoder hexdec_guess_count
	(
		.hex_digit(dp_guess_count),
		.segments(HEX5)
	);

	// Turn off the other HEXes
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;

endmodule

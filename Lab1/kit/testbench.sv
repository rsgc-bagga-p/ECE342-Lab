`timescale 100ps/100ps
module testbench();

  //--------------
  // FPGA Signals
  //--------------

  // Clock pins
  wire                      tb_clk;

  // Seven Segment Displays
  wire        [6:0]         tb_hex0;
  wire        [6:0]         tb_hex1;
  wire        [6:0]         tb_hex2;
  wire        [6:0]         tb_hex3;
  wire        [6:0]         tb_hex4;
  wire        [6:0]         tb_hex5;

  // Pushbuttons
  logic       [3:0]         tb_key;

  // LEDs
  wire        [9:0]         tb_ledr;

  // Slider Switches
  logic       [9:0]         tb_sw;

  // VGA
  wire        [7:0]         tb_vga_b;
  wire                      tb_vga_blank_n;
  wire                      tb_vga_clk;
  wire        [7:0]         tb_vga_g;
  wire                      tb_vga_hs;
  wire        [7:0]         tb_vga_r;
  wire                      tb_vga_sync_n;
  wire                      tb_vga_vs;

  //-------------
  // DUT Signals
  //-------------

  // Clock
	wire clk = CLOCK_50;

	// KEYs are active low, invert them here
	wire reset = ~tb_key[0];
	wire enter = ~tb_key[1];

	// Number guess input
	wire [7:0] guess = tb_sw[7:0];

	// Datapath
	logic dp_inc_actual;
	logic dp_dec_guess_count;
	logic [2:0] dp_guess_count;
	logic dp_over;
	logic dp_under;
	logic dp_equal;
	logic dp_game_over;

  // State Machine
  logic ctrl_update_leds;

  //-------------------
  // DUT Instantiation
  //-------------------

  // Datapath
	datapath the_datapath
	(
		.clk(clk),
		.reset(reset),

		.i_guess(guess),

		.i_inc_actual(dp_inc_actual),

		.i_dec_guess_count(dp_dec_guess_count),

		.o_guess_count()

		.o_over(dp_over),
		.o_under(dp_under),
		.o_equal(dp_equal),
		.o_game_over(dp_game_over)
	);

  // Control
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

	// LED Controllers
	led_ctrl ledc_under(clk, reset, dp_under, ctrl_update_leds, tb_ledr[9]);
	led_ctrl ledc_over(clk, reset, dp_over, ctrl_update_leds, tb_ledr[0]);
	led_ctrl ledc_equal(clk, reset, dp_equal, ctrl_update_leds, tb_ledr[4]);

	// Hex Decoders
	hex_decoder hexdec_guess0
	(
		.hex_digit(guess[3:0]),
		.segments(tb_hex0)
	);

	hex_decoder hexdec_guess1
	(
		.hex_digit(guess[7:4]),
		.segments(tb_hex1)
	);

	hex_decoder hexdec_guess_count
	(
		.hex_digit(dp_guess_count),
		.segments(tb_hex5)
	);

	// Turn off the other HEXes
	assign tb_hex2 = '1;
	assign tb_hex3 = '1;
	assign tb_hex4 = '1;

  //-----------
  // Sequences
  //-----------

  // Clock Signal
  initial begin
    clk = 0;
    #1 clk = ~clk;
  end]

  // Stimulus


  //------------
  // Scoreboard
  //------------

endmodule

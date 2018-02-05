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
	
	// Internal wires
	logic [7:0]x,y;
	logic [15:0] int_result;
	
	logic reset;
	assign reset = ~KEY[0];
	
	logic [15:0] out_result;
	
	// Input Register
	always_ff @ (posedge CLOCK_50 or posedge reset) begin
		if (reset) begin
			x <= 0;
			y <= 0;
		end
		else if(SW[9]) x <= SW[7:0];
		else if(~SW[9]) y <= SW[7:0];
	end
	
	wallace_tree wt(x, y, int_result);
	
	// Output Register
	always_ff @ (posedge CLOCK_50 or posedge reset) begin
		if(reset) out_result <= 0;
		else out_result <= int_result;
	end
	
	
	// HEX Display 
	hex_decoder h0
	(
		.hex_digit(out_result[3:0]),
		.segments(HEX0)
	);
	
	hex_decoder h1
	(
		.hex_digit(out_result[7:4]),
		.segments(HEX1)
	);
	
	hex_decoder h2
	(
		.hex_digit(out_result[11:8]),
		.segments(HEX2)
	);
	
	hex_decoder h3
	(
		.hex_digit(out_result[15:12]),
		.segments(HEX3)
	);
	
	assign HEX4 = '1;
	assign HEX5 = '1;
	
	
endmodule
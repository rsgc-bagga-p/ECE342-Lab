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

localparam SCALE = 5;
localparam WIDTH = 1680/SCALE;
localparam HEIGHT = 1050/SCALE;
localparam WIDTH2 = $clog2(WIDTH);
localparam HEIGHT2 = $clog2(HEIGHT);

// VGA adapter and signals
logic [8:0] vga_x;
logic [7:0] vga_y;
logic [2:0] vga_color;
logic vga_plot;

vga_adapter #
(
	.BITS_PER_CHANNEL(1)
)
vga_inst
(
	.CLOCK_50(CLOCK_50),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.x(vga_x),
	.y(vga_y),
	.color(vga_color),
	.plot(vga_plot)
);

// This generates a one-time active-high asynchronous reset
// signal on powerup. You can use it if you need it.
// All the KEY inputs are occupied, so we can't use one as a reset.
logic reset;
logic [1:0] reset_reg;
always_ff @ (posedge CLOCK_50) begin
	reset <= ~reset_reg[0];
	reset_reg <= {1'b1, reset_reg[1]};
end

//
// PUT YOUR UI AND LDA MODULE INSTANTIATIONS HERE
//

logic clk;
assign clk = CLOCK_50;

// connections
logic [8:0]                 lda_x0;
logic [8:0]                 lda_x1;
logic [7:0]                 lda_y0;
logic [7:0]                 lda_y1;
logic [2:0]                 lda_color;
logic                       lda_start;
logic                       ui_done;

user_interface m_user_interface (

  .i_clk                    (clk),
  .i_reset                  (reset),

  // input from user
  .i_val                    (SW[8:0]),
  .i_setx                   (~KEY[0]),
  .i_sety                   (~KEY[1]),
  .i_setcol                 (~KEY[2]),
  .i_go                     (~KEY[3]),

  // input from line drawing algorithm
  .i_done                   (ui_done),

  // output to line drawing algorithm
  .o_x0                     (lda_x0),
  .o_x1                     (lda_x1),
  .o_y0                     (lda_y0),
  .o_y1                     (lda_y1),
  .o_color                  (lda_color),
  .o_start                  (lda_start)

);

line_drawing_algorithm m_line_drawing_algorithm (

  .i_clk                    (clk),
  .i_reset                  (reset),

  // input from user interface
  .i_x0                     (lda_x0),
  .i_x1                     (lda_x1),
  .i_y0                     (lda_y0),
  .i_y1                     (lda_y1),
  .i_color                  (lda_color),
  .i_start                  (lda_start),

  // output to user interface
  .o_done                   (ui_done),

  // output to vga
  .o_x                      (vga_x),
  .o_y                      (vga_y),
  .o_color                  (vga_color),
  .o_plot                   (vga_plot)

);

assign LEDR[0] = ui_done;

logic [4:0][3:0] hex_val;
assign hex_val[0] = SW[9] ? lda_x1[3:0] : lda_x0[3:0];
assign hex_val[1] = SW[9] ? lda_x1[7:4] : lda_x0[7:4];
assign hex_val[2] = SW[9] ? lda_x1[8] : lda_x0[8];
assign hex_val[3] = SW[9] ? lda_y1[3:0] : lda_y0[3:0];
assign hex_val[4] = SW[9] ? lda_y1[7:4] : lda_y0[7:4];

hex_decoder m_hex0 (
  .hex_digit(hex_val[0]),
  .segments(HEX0)
);

hex_decoder m_hex1 (
  .hex_digit(hex_val[1]),
  .segments(HEX1)
);

hex_decoder m_hex2 (
  .hex_digit(hex_val[2]),
  .segments(HEX2)
);

hex_decoder m_hex3 (
  .hex_digit(hex_val[3]),
  .segments(HEX3)
);

hex_decoder m_hex4 (
  .hex_digit(hex_val[4]),
  .segments(HEX4)
);

hex_decoder m_hex5 (
  .hex_digit(lda_color),
  .segments(HEX5)
);

endmodule

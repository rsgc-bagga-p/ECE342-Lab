`timescale 1ns/1ns // Makes 100MHz

module tb_cpu();

// Change this to use a different program!
parameter HEX_FILE = "software/updateledr.hex";

// Create a 100MHz clock
logic clk;
initial clk = '0;
always #5 clk = ~clk;

// Create the reset signal and assert it for a few cycles
logic reset;
initial begin
	reset = '1;
	@(posedge clk);
	@(posedge clk);
	reset = '0;
end

logic [7:0] dut_sw;
logic [7:0] dut_ledr;

// Declare the bus signals, using the CPU's names for them
logic [15:0] cpu_mem_addr;
logic        cpu_mem_rd;
logic        cpu_mem_wr;
logic [15:0] cpu_mem_rddata;
logic [15:0] cpu_mem_wrdata;

// mem4k Signals
logic [15:0] mem4k_addr;
logic [15:0] mem4k_wrdata;
logic        mem4k_wr;
logic [15:0] mem4k_rddata;

// LEDR Signals
logic        ledr_en;
logic  [7:0] ledr_data_in;

// SW Signals
logic  [7:0] sw_data_out;

// CPU Instantiation
cpu m_cpu (
	.i_clk           (clk),
	.i_reset         (reset),

	.o_mem_addr      (cpu_mem_addr),
	.o_mem_rd        (cpu_mem_rd),
	.o_mem_wr        (cpu_mem_wr),
	.i_mem_rddata    (cpu_mem_rddata),
	.o_mem_wrdata    (cpu_mem_wrdata)
);

// LEDR Instantiation
en_reg_n #(
	.WIDTH          (8)
) m_ledr_reg (
	.i_clk          (clk),
	.i_reset        (reset),

	.i_en           (ledr_en),
	.i_data_in      (ledr_data_in),
	.o_data_out     (dut_ledr)
);

// SW Instantiation
en_reg_n #(
	.WIDTH          (8)
) m_sw_reg (
	.i_clk          (clk),
	.i_reset        (reset),

	.i_en           (1'b1),
	.i_data_in      (dut_sw),
	.o_data_out     (sw_data_out)
);

bus m_bus (
	.i_clk              (clk),
	.i_reset            (reset),

	// cpu interface
	.i_cpu_mem_addr     (cpu_mem_addr),
	.i_cpu_mem_rd       (cpu_mem_rd),
	.i_cpu_mem_wr       (cpu_mem_wr),
	.i_cpu_mem_wrdata   (cpu_mem_wrdata),
	.o_cpu_mem_rddata   (cpu_mem_rddata),

	// memory interface
	.i_mem4k_rddata     (mem4k_rddata),
	.o_mem4k_addr       (mem4k_addr),
	.o_mem4k_wr         (mem4k_wr),
	.o_mem4k_wrdata     (mem4k_wrdata),

	// ledr interface
	.o_ledr_en          (ledr_en),
	.o_ledr_data_in     (ledr_data_in),

	// sw interface
	.i_sw_data_out      (sw_data_out)
);

// Create a 4KB memory
logic [15:0] mem [0:2048];

always_ff @ (posedge clk) begin
	// Read logic.
	// For extra compliance, fill readdata with garbage unless
	// rd enable is actually used.
	if (cpu_mem_rd) mem4k_rddata <= mem[mem4k_addr[10:0]];
	else mem4k_rddata <= 16'bx;

	// Write logic
	if (mem4k_wr) mem[mem4k_addr[15:1]] <= mem4k_wrdata;
end

initial begin

	// Initialize memory
	$display("Reading %s", HEX_FILE);
	$readmemh(HEX_FILE, mem);

	// wait for reset
	@(negedge reset);
	@(posedge clk);

	// wait 12 cycles for software initalization
	repeat(12) @(posedge clk);

	// test all values of sw
	for (int sw = 0; sw <= 16'hFF; sw++) begin
		dut_sw = sw;
		// wait 10 cycles for software to run
		repeat(10) @(posedge clk);

		if (dut_ledr != dut_sw) begin
			$display("DUT output did not match Model output!");
			$display("DUT result was: %0d", dut_ledr);
			$display("Expected result was: %0d", dut_sw);
			$stop;
		end
	end

	// finish
	$display("All cases passed!");
	$stop;

end

endmodule

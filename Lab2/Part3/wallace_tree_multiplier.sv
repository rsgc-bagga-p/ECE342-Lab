module wallace_tree
(
	input [7:0] i_a,
	input [7:0] i_b,
	output [15:0] o_p
);

logic [7:0][7:0] pp; //partial product

generate
	genvar row, col;	
	for(row = 0; row < 8; row++) begin : partial_rows
		for(col = 0; col < 8; col++) begin : partial_columns
		
			assign pp[row][col] = i_a[row] & i_b[col];
			
		end
	end
	
endgenerate

// Stage 0
logic [20:0] s0; // sum - stage 0
logic [20:0] co0; // carry out - stage 0

fa fa0_0 (pp[0][1], pp[1][0], 0, s0[0], co0[0]); 
fa fa0_1 (pp[0][2], pp[1][1], pp[2][0], s0[1], co0[1]);
fa fa0_2 (pp[0][3], pp[1][2], pp[2][1], s0[2], co0[2]);
fa fa0_3 (pp[0][4], pp[1][3], pp[2][2], s0[3], co0[3]);
fa fa0_4 (pp[3][1], pp[4][0], 0, s0[4], co0[4]);
fa fa0_5 (pp[0][5], pp[1][4], pp[2][3], s0[5], co0[5]);
fa fa0_6 (pp[3][2], pp[4][1], pp[5][0], s0[6], co0[6]); 
fa fa0_7 (pp[0][6], pp[1][5], pp[2][4], s0[7], co0[7]); 
fa fa0_8 (pp[3][3], pp[4][2], pp[5][1], s0[8], co0[8]); 
fa fa0_9 (pp[0][7], pp[1][6], pp[2][5], s0[9], co0[9]); 
fa fa0_10 (pp[3][4], pp[4][3], pp[5][2], s0[10], co0[10]); 
fa fa0_11 (pp[6][1], pp[7][0], 0, s0[11], co0[11]); 
fa fa0_12 (pp[1][7], pp[2][6], pp[3][5], s0[12], co0[12]); 
fa fa0_13 (pp[4][4], pp[5][3], pp[6][2], s0[13], co0[13]); 
fa fa0_14 (pp[2][7], pp[3][6], pp[4][5], s0[14], co0[14]); 
fa fa0_15 (pp[5][4], pp[6][3], pp[7][2], s0[15], co0[15]); 
fa fa0_16 (pp[3][7], pp[4][6], pp[5][5], s0[16], co0[16]); 
fa fa0_17 (pp[6][4], pp[7][3], 0, s0[17], co0[17]); 
fa fa0_18 (pp[4][7], pp[5][6], pp[6][5], s0[18], co0[18]); 
fa fa0_19 (pp[5][7], pp[6][6], pp[7][5], s0[19], co0[19]);
fa fa0_20 (pp[6][7], pp[7][6], 0, s0[20], co0[20]);

// Stage 1
logic [12:0] s1;
logic [12:0] co1;

fa fa1_0(co0[0], s0[1], 0, s1[0], co1[0]); 
fa fa1_1(co0[1], s0[2], pp[3][0], s1[1], co1[1]); 
fa fa1_2(co0[2], s0[3], s0[4], s1[2], co1[2]); 
fa fa1_3(co0[3], co0[4], s0[5], s1[3], co1[3]); 
fa fa1_4(co0[5], co0[6], s0[7], s1[4], co1[4]); 
fa fa1_5(s0[8], pp[6][0], 0, s1[5], co1[5]); 
fa fa1_6(co0[7], co0[8], s0[9], s1[6], co1[6]); 
fa fa1_7(s0[10], s0[11], 0, s1[7], co1[7]); 
fa fa1_8(co0[9], co0[10], co0[11], s1[8], co1[8]); 
fa fa1_9(s0[12], s0[13], pp[7][1], s1[9], co1[9]); 
fa fa1_10(co0[12], co0[13], s0[14], s1[10], co1[10]); 
fa fa1_11(co0[14], co0[15], s0[16], s1[11], co1[11]); 
fa fa1_12(co0[16], co0[17], s0[18], s1[12], co1[12]); 

// Stage 2
logic [9:0] s2;
logic [9:0] co2;

fa fa2_0(co1[0], s1[1], 0, s2[0], co2[0]); 
fa fa2_1(co1[1], s1[2], 0, s2[1], co2[1]); 
fa fa2_2(co1[2], s1[3], s0[6], s2[2], co2[2]); 
fa fa2_3(co1[3], s1[4], s1[5], s2[3], co2[3]); 
fa fa2_4(co1[4], co1[5], s1[6], s2[4], co2[4]); 
fa fa2_5(co1[6], co1[7], s1[8], s2[5], co2[5]); 
fa fa2_6(co1[8], co1[9], s1[10], s2[6], co2[6]); 
fa fa2_7(co1[10], s1[11], s0[17], s2[7], co2[7]); 
fa fa2_8(co1[11], s1[12], pp[7][4], s2[8], co2[8]); 
fa fa2_9(co1[12], co0[18], s0[19], s2[9], co2[9]);

// Stage 3
logic [10:0] s3;
logic [10:0] co3;

fa fa3_0(co2[0], s2[1], 0, s3[0], co3[0]); 
fa fa3_1(co2[1], s2[2], 0, s3[1], co3[1]); 
fa fa3_2(co2[2], s2[3], 0, s3[2], co3[2]); 
fa fa3_3(co2[3], s2[4], s1[7], s3[3], co3[3]); 
fa fa3_4(co2[4], s2[5], s1[9], s3[4], co3[4]); 
fa fa3_5(co2[5], s2[6], s0[15], s3[5], co3[5]); 
fa fa3_6(co2[6], s2[7], 0, s3[6], co3[6]); 
fa fa3_7(co2[7], s2[8], 0, s3[7], co3[7]); 
fa fa3_8(co2[8], s2[9], 0, s3[8], co3[8]); 
fa fa3_9(co2[9], co0[19], s0[20], s3[9], co3[9]); 
fa fa3_10(co0[20], pp[7][7], 0, s3[10], co3[10]);

// Final Stage
logic [11:0] add_out;
add11 add(co3[10:0], {1'b0,s3[10:1]}, add_out);

assign o_p = {add_out[10:0], s3[0], s2[0], s1[0], s0[0], pp[0][0]};

endmodule

module add11
(
	input [10:0] x,
	input [10:0] y,
	output [11:0] sum
);
	logic [11:0] cin;
	
	assign cin[0] = 1'b0;
	assign sum[11] = cin[11];
	
	genvar i;
	generate
		for (i = 0; i < 11; i++) begin : adders
			fa fa_inst
			(
				.x(x[i]),
				.y(y[i]),
				.cin(cin[i]),
				.s(sum[i]),
				.cout(cin[i+1])
			);
		end
	endgenerate
endmodule

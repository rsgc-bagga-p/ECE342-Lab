module fa
(
	input x, y, cin,
	output s, cout
);

	assign s = x ^ y ^ cin;
	assign cout = x&y | x&cin | y&cin;
endmodule
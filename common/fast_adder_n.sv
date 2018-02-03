module full_adder_n #
(
  parameter WIDTH = 1
)
(
  input [WIDTH-1:0] i_a,
  input [WIDTH-1:0] i_b,
  input i_cin,

  output [WIDTH-1:0] o_sum,
  output o_cout
);

  logic [WIDTH:0] cin;
  assign cin[0] = i_cin;
  assign o_cout = cin[WIDTH];

  integer i;
  for (i = 0; i < WIDTH; i++) begin : full_adders
    assign o_sum = i_a[i] ^ i_b[i] ^ cin[i];
    assign cin[i+1] = (i_a[i] & i_b) | ((i_a | i_b) & cin);
  end

endmodule

module carry_save_multiplier_unsigned_n #
(
  parameter WIDTH = 2
)
(
  input [WIDTH-1:0] i_m,
  input [WIDTH-1:0] i_q,

  output [2*WIDTH-1:0] o_p
);


  logic [WIDTH-1:0] [WIDTH-1:0] csa_out;
  logic [WIDTH-1:0] [WIDTH-1:0] csa_cout;

  logic [WIDTH-1:0] cla_out;
  logic cla_cout;

  genvar i;

  generate

    for (i = 0; i < WIDTH; i++) begin
      assign o_p[i] = csa_out[i][0];
    end

    assign o_p[2*WIDTH-1:WIDTH] = cla_out;

  endgenerate

  genvar row;
  genvar col;

  generate

    for (row = 0; row < WIDTH; row++) begin : csa_row

      for (col = 0; col < WIDTH; col++) begin : csa_col

        logic csa_a;
        logic csa_b;
        logic csa_cin;

        assign csa_a = i_m[col] & i_q[row];

        if (row == 0) begin

          assign csa_b = 1'b0;
          assign csa_cin = 1'b0;

        end

        else begin

          // previous row, same relative column
          assign csa_cin = csa_cout[row-1][col];

          if (col == WIDTH-1) begin
            assign csa_b = 1'b0;
          end
          else begin
            // previous row, next relative column
            assign csa_b = csa_out[row-1][col+1];
          end

        end

        full_adder u_half_adder (
          .i_a(csa_a),
          .i_b(csa_b),
          .i_cin(csa_cin),
          .o_sum(csa_out[row][col]),
          .o_cout(csa_cout[row][col])
        );

      end // csa_col

    end // csa_row

  endgenerate

  // CLA for last row
  carry_lookahead_adder_n #(
    .WIDTH(WIDTH)
  ) m_carry_lookahead_adder_n (
    .i_a({1'b0,csa_out[WIDTH-1][WIDTH-1:1]}),
    .i_b(csa_cout[WIDTH-1]),
    .i_cin(1'b0),
    .o_sum(cla_out),
    .o_cout(cla_cout)
  );

endmodule

// Dependencies: booth_encoder.sv, booth_decoder.sv, full_adder.sv

module booth_multiplier_n #
(

  // MINIMUM WIDTH is 2, will not work properly for WIDTH < 2
  parameter WIDTH = 2

)
(

  // multiplicand
  input [WIDTH-1:0] i_m,

  // multiplier
  input [WIDTH-1:0] i_q,


  // product
  output [2*WIDTH-1:0] o_p

);


  /* booth multiplier signals */

  // sign extend output of every booth decoder unit
  // beginning is not offset
  // ie b_se[WIDTH-1][0] is first b_se of last row
  logic [WIDTH-1:0] [WIDTH-1:0] b_se;

  // output of every booth mutliplier unit
  // beginning is offset by col = row
  // ie b_out[WIDTH-1][WIDTH-1] is first b_out of last row
  logic [WIDTH-1:0] [2*WIDTH-1:0] b_out;

  // carryout of every booth multiplier unit
  // beginning is offset by col = row
  logic [WIDTH-1:0] [2*WIDTH-1:0] b_cout;


  /* initialize variables */

  genvar i;
  genvar j;

  generate


    /* assign output */

    // assign first column to output
    for (i = 0; i < WIDTH; i++) begin : o_p_low
      assign o_p[i] = b_out[i][i];
    end

    // assign last row except first column to output
    for (i = WIDTH; i < 2*WIDTH; i++) begin : o_p_high
      assign o_p[i] = b_out[WIDTH-1][i];
    end


    /* tie unused signals */

    for (i = 0; i < WIDTH; i++) begin : signal_row
      for (j = 0; j < i; j++) begin: signal_col
        assign b_out[i][j] = 1'b0;
        assign b_cout[i][j] = 1'b0;
      end // signal_col
    end //signal_row


  endgenerate


  /* generate booth multiplier */

  genvar row;
  genvar col;

  generate


    for (row = 0; row < WIDTH; row++) begin : booth_row


      // q[i] and q[i-1] inputs of booth encoder
      logic [1:0] be_q;

      // plus output of booth encoder
      logic be_plus;

      // minus output of booth encoder
      logic be_minus;

      if (row == 0) begin
        assign be_q[0] = 1'b0;
      end
      else begin
        assign be_q[0] = i_q[row-1];
      end

      assign be_q[1] = i_q[row];

      booth_encoder u_booth_encoder (
        .i_q(be_q),
        .o_plus(be_plus),
        .o_minus(be_minus)
      );


      for (col = 0; col < 2*WIDTH; col++) begin : booth_col


        if ((col >= row) && (col < row + WIDTH)) begin : booth_decoder_unit

          logic bd_m;
          logic bd_pin;
          logic bd_cin;

          assign bd_m = i_m[col-row];

          if (row == 0) begin
            assign bd_pin = 1'b0;
          end
          else begin
            assign bd_pin = b_out[row-1][col];
          end

          if (col == row) begin
            assign bd_cin = be_minus;
          end
          else begin
            assign bd_cin = b_cout[row][col-1];
          end

          booth_decoder u_booth_decoder (
            .i_plus(be_plus),
            .i_minus(be_minus),
            .i_m(bd_m),
            .i_pin(bd_pin),
            .i_cin(bd_cin),
            .o_se(b_se[row][col-row]),
            .o_pout(b_out[row][col]),
            .o_cout(b_cout[row][col])
          );

        end // booth_decoder_unit


        else
        if (col >= row + WIDTH) begin : sign_extend_unit

          logic se_a;
          logic se_b;
          logic se_cin;

          assign se_a = b_se[row][WIDTH-1];

          if (row == 0) begin
            assign se_b = 1'b0;
          end
          else begin
            assign se_b = b_out[row-1][col];
          end

          assign se_cin = b_cout[row][col-1];

          full_adder u_sign_extend (
            .i_a(se_a),
            .i_b(se_b),
            .i_cin(se_cin),
            .o_sum(b_out[row][col]),
            .o_cout(b_cout[row][col])
          );

        end // sign_extend_unit


        else /* col < row */ begin : no_unit

          // do nothing

        end // no_unit


      end // booth_col


    end // booth_row


  endgenerate


endmodule

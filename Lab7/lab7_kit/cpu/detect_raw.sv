module detect_raw
(
  input  [15:0] i_ir_ex,
  input  [15:0] i_ir_wr,

  output logic fw_rx,
  output logic fw_ry
);

  logic prev_rx;
  logic prev_r7;
  logic curr_rx;
  logic curr_ry;

  always_comb begin

    // Forwarding checks

    // previous instruction writes to Rx
    // x0000->x0010, 00100, 10110
    prev_rx = (i_ir_wr[3:2] == 2'b00 && i_ir_wr[1:0] != 2'b11) ||
              (i_ir_wr[3:2] == 2'b01 && ~i_ir_wr[0]);

    // previous instruction writes to R7
    // x1100
    prev_r7 = (i_ir_wr[4:0] == 4'b1100);

    // current instruction uses Rx
    // x0001->x0011, does not care about jump instructions
    curr_rx = (i_ir_wr[3:2] == 2'b00 && i_ir_wr[1:0] != 2'b00);

    // current instruction uses Ry
    // 00000->00100
    curr_ry = (i_ir_ex[4:3] == 2'b00 && i_ir_ex[2:0] != 3'b111);

    // conflict with Rx
    fw_rx = (curr_rx) &&
            (((prev_rx) && (i_ir_ex[7:5] == i_ir_wr[7:5])) ||
             ((prev_r7) && (i_ir_ex[7:5] == 3'd7)));

    // conflict with Ry
    fw_ry = (curr_ry) &&
            (((prev_rx) && (i_ir_ex[10:8] == i_ir_wr[7:5])) ||
             ((prev_r7) && (i_ir_ex[10:8] == 3'd7)));
  end

endmodule

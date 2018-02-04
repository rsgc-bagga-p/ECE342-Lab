module lda_datapath
(
  input i_clk,
  input i_reset,
  
  // in from UI
  input [8:0] i_x0,
  input [8:0] i_x1,
  input [7:0] i_y0,
  input [7:0] i_y1,
  input [2:0] i_color,
  
  // out to VGA
  output [8:0] o_x,
  output [7:0] o_y,
  output [2:0] o_color,
  
  // in from control
  input i_ld_initial,
  input i_update_error,
  input i_update_y,
  input i_update_x,
  input [1:0] i_mux_cmp0,
  input i_mux_alu0,
  input i_mux_alu1,
  
  // out to control
  output o_keep_drawing
);

logic steep;
logic [9:0] dx;
logic [9:0] dy;
logic x0_gt_x1;
logic [9:0] ystep;
logic [9:0] xstep;

logic [9:0] error;
logic [9:0] x;
logic [9:0] y;

logic [3:0][9:0] alu_a;
logic [3:0][9:0] alu_b;
logic [3:0]      alu_sel;
logic [3:0][9:0] alu_out;

genvar i;
generate
  for (i = 0; i < 4; i++) begin : alu
    simple_alu #(
      .WIDTH  (10)
    ) m_salu (
      .i_salu_a (alu_a[i]),
      .i_salu_b (alu_b[i]),
      .i_salu_sel (alu_sel[i]),
      .o_salu_out (alu_out[i])
    );
  end
endgenerate

logic [2:0][9:0] cmp_a;
logic [2:0][9:0] cmp_b;
logic [2:0]      cmp_gt;
logic [2:0]      cmp_lt;
logic [2:0]      cmp_eq;

generate
  for (i = 0; i < 3; i++) begin : comparator
    comparator #
    (
      .WIDTH (10)
    ) m_cmp (
      .i_cmp_a (cmp_a[i]),
      .i_cmp_b (cmp_b[i]),
      .o_cmp_gt (cmp_gt[i]),
      .o_cmp_lt (cmp_lt[i]),
      .o_cmp_eq (cmp_eq[i])
    );
  end
endgenerate

assign o_keep_drawing = (x0_gt_x1 ? cmp_gt[0] : cmp_lt[0]) | cmp_eq[0];

assign o_x = steep ? y : x;
assign o_y = steep ? x : y;
assign o_color = i_color;

always_comb begin
  // Comparators
  // cmp 0
  case (i_mux_cmp0)
    // S_INIT
    0: begin
      // y1 > y0
      cmp_a[0] = i_y1;
      cmp_b[0] = i_y0;
    end
    // S_LOOP_CHECK
    1: begin
      // compare x, x1
      cmp_a[0] = x;
      cmp_b[0] = steep ? i_y1 : i_x1;
    end
    // S_DRAW
    2: begin
      // signed: error - dy < 0
      // unsigned: error - dy > 511
      cmp_a[0] = alu_out[0];
      cmp_b[0] = 0;
    end
    default: begin
      cmp_a[0] = 0;
      cmp_b[0] = 0;
    end
  endcase
    
  //cmp 1
  // S_INIT
  // x1 > x0
  cmp_a[1] = i_x1;
  cmp_b[1] = i_x0;
  
  // cmp 2
  // S_INIT
  // abs(y1 - y0) - abs(x1 - x0)
  cmp_a[2] = alu_out[0];
  cmp_b[2] = alu_out[1];
  
  // ALUs
  // alu 0
  case (i_mux_alu0)
    // S_INIT
    0: begin
      // abs(y1 - y0)
      // y1 > y0 ? y1 - y0 : y0 - y1
      alu_sel[0] = 1;
      alu_a[0] = cmp_gt[0] ? i_y1 : i_y0;
      alu_b[0] = cmp_gt[0] ? i_y0 : i_y1;
    end
    // S_DRAW
    1: begin
      // error - dy
      alu_a[0] = error;
      alu_b[0] = dy;
      alu_sel[0] = 1;
    end
    default: begin
      alu_a[0] = 0;
      alu_b[0] = 0;
      alu_sel[0] = 0;
    end
  endcase
  
  // alu 1
  case (i_mux_alu1)
    // S_INIT
    0: begin
      // abs(x1 - x0)
      // x1 > x0 ? x1 - x0 : x0 - x1
      alu_sel[1] = 1;
      alu_a[1] = cmp_gt[1] ? i_x1 : i_x0;
      alu_b[1] = cmp_gt[1] ? i_x0 : i_x1;
      end
    // S_DRAW
    1: begin
      // error - dy + dx
      alu_a[1] = alu_out[0];
      alu_b[1] = dx;
      alu_sel[1] = 0;
    end
    default: begin
      alu_a[1] = 0;
      alu_b[1] = 0;
      alu_sel[1] = 0;
    end
  endcase
  
  // alu 2
  // S_DRAW
  // y + ystep
  alu_a[2] = y;
  alu_b[2] = ystep;
  alu_sel[2] = 0;
  
  // alu 3
  // S_DRAW
  // x + xstep
  alu_a[3] = x;
  alu_b[3] = xstep;
  alu_sel[3] = 0;
end

always_ff @ (posedge i_clk or posedge i_reset) begin
  // steep, dx, dy, x0_gt_x1, xstep, ystep
  if (i_reset) begin
    steep <= 0;
    dx <= 0;
    dy <= 0;
    x0_gt_x1 <= 0;
    ystep <= 0;
    xstep <= 0;
  end
  else if (i_ld_initial) begin
    steep <= cmp_gt[2];
    dx <= cmp_gt[2] ? alu_out[0] : alu_out[1];
    dy <= cmp_gt[2] ? alu_out[1] : alu_out[0];
    x0_gt_x1 <= cmp_gt[2] ? ~cmp_gt[0] : ~cmp_gt[1];
    ystep <= (cmp_gt[2] ? cmp_gt[1] : cmp_gt[0]) ? 10'd1 : -10'd1;
    xstep <= (cmp_gt[2] ? cmp_gt[0] : cmp_gt[1]) ? 10'd1 : -10'd1; 
  end
  
  // error
  if (i_reset) begin
    error <= 0;
  end
  else if (i_ld_initial) begin
    error <= (cmp_gt[2] ? alu_out[0] : alu_out[1]) >> 1;
  end
  else if (i_update_error) begin
    // signed: error - dy < 0
    // unsigned: error - dy > 255
    error <= cmp_lt[0] ? alu_out[1] : alu_out[0];
  end
  
  // y
  if (i_reset) begin
    y <= 0;
  end
  else if (i_ld_initial) begin
    y <= cmp_gt[2] ? i_x0 : i_y0;
  end
  else if (i_update_y) begin
    y <= cmp_lt[0] ? alu_out[2] : y;
  end
  
  // x
  if (i_reset) begin
    x <= 0;
  end
  else if (i_ld_initial) begin
    x <= cmp_gt[2] ? i_y0 : i_x0;
  end
  else if (i_update_x) begin
    x <= alu_out[3];
  end
end

endmodule

module lda_datapath
(
  input i_clk,
  input i_reset,
  
  input [8:0] i_x0,
  input [8:0] i_x1,
  input [7:0] i_y0,
  input [7:0] i_y1,
  input i_color,
  
  output o_x,
  output o_y,
  output o_color,

  input i_ld_constants,
  input i_ld_error,
  input i_ld_ystep,
  input i_ld_xstep,
  input i_ld_y,
  input i_ld_x,
  
  output logic o_x0_gt_x1
);

logic steep;
logic dx;
logic dy;

logic [1:0] error;
logic [1:0] ystep;
logic [1:0] xstep;
logic y;
logic x;

logic [3:0][8:0] alu_a;
logic [3:0][8:0] alu_b;
logic [3:0] alu_sel;
logic [3:0][8:0] alu_out;

genvar i;
generate
  for (i = 0; i < 4; i++) begin : alu
    simple_alu #(
      .WIDTH  (9)
    ) m_salu (
      .i_salu_a (alu_a[i]),
      .i_salu_b (alu_b[i]),
      .i_salu_sel (alu_sel[i]),
      .o_salu_out (alu_out[i])
    );
  end
endgenerate

logic [2:0][8:0] cmp_a;
logic [2:0][8:0] cmp_b;
logic [2:0] cmp_gt;
logic [2:0] cmp_lt;
logic [2:0] cmp_eq;

generate
  for (i = 0; i < 3; i++) begin : comparator
    comparator #
    (
      .WIDTH (9)
    ) m_cmp (
      .i_cmp_a (cmp_a[i]),
      .i_cmp_b (cmp_b[i]),
      .o_cmp_gt (cmp_gt[i]),
      .o_cmp_lt (cmp_lt[i]),
      .o_cmp_eq (cmp_eq[i])
    );
  end
endgenerate

always_comb begin
  cmp_a[0] = i_y1;
  cmp_b[0] = i_y0;
  
  case (cmp_gt[0])
    0: begin
      alu_a[0] = i_y0;
      alu_b[0] = i_y1;
    end
    1: begin
      alu_a[0] = i_y1;
      alu_b[0] = i_y0;
    end
  endcase
  
  cmp_a[1] = i_x1;
  cmp_b[1] = i_x0;
  
  case (cmp_gt[1])
    0: begin
      alu_a[1] = i_x0;
      alu_b[1] = i_x1;
    end
    1: begin
      alu_a[1] = i_x1;
      alu_b[1] = i_x0;
    end
  endcase
  
  cmp_a[2] = alu_out[0];
  cmp_b[2] = alu_out[1];
end

always_ff @ (posedge i_clk or posedge i_reset) begin
  // steep, dx, dy
  if (i_reset) begin
    steep <= 0;
    dx <= 0;
    dy <= 0;
    
    o_x0_gt_x1 <= 0;
  end
  else if (i_ld_constants) begin
    steep <= cmp_gt[2];
    dx <= cmp_gt[2] ? alu_out[0] : alu_out[1];
    dy <= cmp_gt[2] ? alu_out[1] : alu_out[0];
    
    o_x0_gt_x1 <= cmp_gt[2] ? ~cmp_gt[0] : ~cmp_gt[1];
  end
  
  // error
  if (i_reset) begin
    error <= 0;
  end
  else if (i_ld_constants) begin
    error <= (cmp_gt[2] ? alu_out[0] : alu_out[1]) >> 1;
  end
  
  // ystep
  if (i_reset) begin
    ystep <= 0;
  end
  else if (i_ld_constants) begin
    ystep <= (cmp_gt[2] ? cmp_gt[1] : cmp_gt[0]) ? 1 : -1;
  end
  
  // xstep
  if (i_reset) begin
    xstep <= 0;
  end
  else if (i_ld_constants) begin
    xstep <= (cmp_gt[2] ? cmp_gt[0] : cmp_gt[1]) ? -1 : 1; 
  end
  
  // y
  if (i_reset) begin
    y <= 0;
  end
  else if (i_ld_constants) begin
    y <= cmp_gt[2] ? i_x0 : i_y0;
  end
  
  // x
  if (i_reset) begin
    x <= 0;
  end
  else if (i_ld_constants) begin
    y <= cmp_gt[2] ? i_y0 : i_x0;
  end
  
end

endmodule

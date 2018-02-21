module cpu_control
(
  input i_clk,
  input i_reset,

  output logic o_mem_rd,
  output logic o_mem_wr,
  output logic [2:0] o_mem_addr_sel,

  output logic [1:0] o_pc_sel,
  output logic o_pc_ld,

  input [4:0] i_ir,
  output logic o_ir_ld,

  output logic [2:0] o_rf_sel,
  output logic o_rf_write,
  output logic o_rf_addr_w_sel,

  input i_alu_n,
  input i_alu_z,
  output logic o_alu_n_ld,
  output logic o_alu_z_ld,
  output logic o_alu_b_sel,
  output logic o_alu_op
);

// States
enum int unsigned
{
  S_START,
  S_EXECUTE,
  S_MEM
} state, nextstate;

// State regs
always_ff @ (posedge i_clk or posedge i_reset) begin
	if (i_reset) state <= S_START;
	else state <= nextstate;
end

// State table
always_comb begin
	nextstate = state;

  o_mem_rd = 1'd0;
  o_mem_wr = 1'd0;
  o_mem_addr_sel = 2'd0;

  o_pc_sel = 1'd0;
  o_pc_ld = 1'd0;

  o_ir_ld = 1'd0;

  o_rf_sel = 3'd0;
  o_rf_write = 1'd0;
  o_rf_addr_w_sel = 1'd0;

  o_alu_n_ld = 1'd0;
  o_alu_z_ld = 1'd0;
  o_alu_b_sel = 1'd0;
  o_alu_op = 1'd0;

  case (state)
    S_START: begin
      nextstate = S_EXECUTE;
      o_mem_rd = 1'd1;
      o_pc_sel = 1'd1;
      o_pc_ld = 1'd1;
      o_ir_ld = 1'd1;
    end
    S_EXECUTE: begin
      case (i_ir[3:0])
        // mv, mvi
        4'b0000: begin
          o_mem_rd = 1'd1;
          o_mem_wr = 1'd0;
          o_mem_addr_sel = 2'd1;

          o_pc_sel = 1'd1;
          o_pc_ld = 1'd1;

          o_ir_ld = 1'd1;

          //o_rf_sel = 3'd0;
          o_rf_write = 1'd1;
          o_rf_addr_w_sel = 1'd0;

          //o_alu_n_ld = 1'd0;
          //o_alu_z_ld = 1'd0;
          //o_alu_b_sel = 1'd0;
          //o_alu_op = 1'd0;

          if (~i_ir[4]) begin
            o_rf_sel = 3'd6;
          end
          else begin
            o_rf_sel = 3'd0;
          end
        end
        // add, addi
        4'b0001: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
        // sub, subi
        4'b0010: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
        // cmp, cmpi
        4'b0011: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
        // ld
        4'b0100: begin
        end
        // st
        4'b0101: begin
        end
        // mvhi
        4'b0110: begin
        end
        // jr, j
        4'b1000: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
        // jzr, jz
        4'b1001: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
        // jnr, jn
        4'b1010: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
        // callr, call
        4'b1100: begin
          if (~i_ir[4]) begin
          end
          else begin
          end
        end
      endcase

    end
    S_MEM: begin

    end
	endcase
end

endmodule

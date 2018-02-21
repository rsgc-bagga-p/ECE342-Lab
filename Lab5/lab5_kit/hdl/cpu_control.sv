module cpu_control
(
  input i_clk,
  input i_reset,
  
  input [15:0] i_mem_rddata,
  output o_mem_rd,
  output o_mem_wr,
  output [1:0] o_mem_addr_sel,
  
  output o_pc_sel,
  output o_pc_ld,
  
  input [15:0] i_ir,
  output o_ir_ld,
  
  output [2:0] o_rf_sel,
  output o_rf_write,
  output o_rf_addr_w_sel,
  
  output o_alu_a_sel,
  
  input i_alu_n,
  input i_alu_z,
  output o_alu_n_ld,
  output o_alu_z_ld
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
  o_alu_a_sel = 1'd0;
  o_alu_n_ld = 1'd0;
  o_alu_z_ld = 1'd0;
  
  case (state)
    S_START: begin
      nextstate = S_EXECUTE;
      o_mem_rd = 1'd1;
      o_pc_sel = 1'd1;
      o_pc_ld = 1'd1;
      o_ir_ld = 1'd1;
    end
    S_EXECUTE: begin
      o_mem_rd = 1'd1;
      o_pc_sel = 1'd0;
      o_pc_ld = 1'd1;
      o_ir_ld = 1'd1;
      o_rf_sel = 3'd0;
      o_rf_write = 1'd0;
      o_rf_addr_w_sel = 1'd0;
      o_alu_a_sel = 1'd0;
      o_alu_n_ld = 1'd0;
      o_alu_z_ld = 1'd0;
      
      case (i_ir[4:0])
        5'b00000: begin
        end
        5'b00001: begin
        end
        5'b00010: begin
        end
        5'b00100: begin
        end
        5'b00101: begin
        end
        5'b10000: begin
        end
        5'b10001: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
        5'b00000: begin
        end
      endcase
      
    end
    S_MEM: begin
      
    end
	endcase
end

endmodule

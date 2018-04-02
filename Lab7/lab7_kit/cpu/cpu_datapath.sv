module cpu_datapath
(
  input i_clk,
  input i_reset,

  // Control Signals
  input         i_rf_write,
  input         i_rf_datax_ld,
  input         i_rf_datay_ld,
  input         i_datax_wr_ld,
  input         i_datay_wr_ld,
  input         i_rf_addrw_sel,
  input  [2:0]  i_rf_sel,
  input         i_datax_sel,
  input         i_datay_sel,

  input         i_alu_r_ld,
  input         i_alu_n_ld,
  input         i_alu_z_ld,
  input  [1:0]  i_alu_a_sel,
  input  [1:0]  i_alu_b_sel,
  input         i_alu_op_sel,

  input         i_pc_ld,
  input         i_pc_dc_ld,
  input         i_pc_ex_ld,
  input         i_pc_wr_ld,
  input  [1:0]  i_pc_sel,
  input  [1:0]  i_pc_addr_sel,

  input         i_ldst_addr_sel,
  input         i_ldst_wrdata_sel,

  input         i_ir_ex_ld,
  input         i_ir_wr_ld,
  input         i_ir_ex_sel,

  // Outputs to Control
  output [15:0] o_ir_dc,
  output [15:0] o_ir_ex,
  output [15:0] o_ir_wr,
  output        o_alu_n,
  output        o_alu_z,
  output        o_alu_n_imm,
  output        o_alu_z_imm,

  // Inputs from Memory
  input  [15:0] i_pc_rddata,
  input  [15:0] i_ldst_rddata,

  // Outputs to Memory
  output [15:0] o_pc_addr,
  output [15:0] o_ldst_addr,
  output [15:0] o_ldst_wrdata,

  // Output for Testbench
  output [7:0][15:0] o_tb_regs
);


  /*************************************************************
   * Five Stage Pipeline, just like in the lab 7 handout
   * -----------------
   * STAGE 1: PREFETCH
   * -----------------
   * This stage takes care of setting up the correct PC
   * for the FETCH stage to use.
   * - multiplexing logic for PC
   * - flopped by PC
   * --------------
   * STAGE 2: FETCH
   * --------------
   * This stage chooses the correct memory address to
   * fetch from in PC_MEM.
   * - multiplexing logic for PC_MEM
   * - flopped by PC_MEM, PC_FC
   * ---------------
   * STAGE 3: DECODE
   * ---------------
   * This stage decodes IR into its useable components and
   * accesses the needed RF values.
   * - multiplexing logic for RF read
   * - flopped by RF, PC_DC, IR_DC
   * ----------------
   * STAGE 4: EXECUTE
   * ----------------
   * This stage does the needed computation in the ALU or
   * accesses the data needed from MEM.
   * - multiplexing logic for ALU and MEM
   * - flopped by ALU_R, ALU_N, ALU_Z, MEM, PC_EX, IR_EX
   * ------------------
   * STAGE 5: WRITEBACK
   * ------------------
   * This stage takes what needs to go back into the registers
   * and writes them back into the RF.
   * - multiplexing logic for RF write
   * - flopped by RF
   *************************************************************/


  /* Parameters */

  // Instruction size in bytes for incrementing PC
  localparam INSTR_SIZE    = 16'd2;

  // Instruction Encoding for nop
  localparam NOP           = 16'h0007; // opcode => 0_0111

  // Register to store PC into for callr
  localparam CALLR_REG     = 3'd7;


  /* Signals */

  // Registers
  logic [15:0] r_pc;
  logic [15:0] r_pc_dc;
  logic [15:0] r_pc_ex;
  logic [15:0] r_pc_wr;
  logic [15:0] r_ir_ex;
  logic [15:0] r_alu_r;
  logic        r_alu_n;
  logic        r_alu_z;
  logic [15:0] r_ir_wr;
  logic [15:0] r_rf_datax;
  logic [15:0] r_rf_datay;
  logic [15:0] r_datax_wr;
  logic [15:0] r_datay_wr;

  // Wires
  logic [2:0]  rf_addrw;
  logic [2:0]  rf_addrx;
  logic [2:0]  rf_addry;
  logic [15:0] rf_data_in;
  logic [15:0] rf_datax_out;
  logic [15:0] rf_datay_out;
  logic [15:0] datax_in;
  logic [15:0] datay_in;

  logic [15:0] alu_op_a;
  logic [15:0] alu_op_b;
  logic [15:0] alu_out;
  logic        alu_n;
  logic        alu_z;

  logic [15:0] pc_addr;
  logic [15:0] ldst_addr;
  logic [15:0] ldst_wrdata;

  logic [15:0] pc_in;
  logic [15:0] pc_nxt;
  logic [15:0] jmp_pc;
  logic [15:0] jmp_pc_nxt;
  logic [15:0] datax_nxt;

  logic [15:0] ir_dc;
  logic [15:0] ir_dc_imm11;
  logic [15:0] ir_ex_in;
  logic [15:0] ir_ex_imm8;
  logic [15:0] ir_wr_imm8;


  /* Assign Outputs */

  assign o_ir_dc       = ir_dc;
  assign o_ir_ex       = r_ir_ex;
  assign o_ir_wr       = r_ir_wr;
  assign o_alu_n       = r_alu_n;
  assign o_alu_z       = r_alu_z;
  assign o_alu_n_imm   = alu_n;
  assign o_alu_z_imm   = alu_z;

  assign o_pc_addr     = pc_addr;
  assign o_ldst_addr   = ldst_addr;
  assign o_ldst_wrdata = ldst_wrdata;


  /* Module Instantiations */

  // Register File
  regfile #(
    .WIDTH    (16),
    .NUMREGS  (8)
  ) m_regfile (
    .i_clk,
    .i_reset,
    .i_write        (i_rf_write),
    .i_addrw        (rf_addrw),
    .i_addrx        (rf_addrx),
    .i_addry        (rf_addry),
    .i_data_in      (rf_data_in),
    .o_datax_out    (rf_datax_out),
    .o_datay_out    (rf_datay_out),
    // for testbench
    .o_regs         (o_tb_regs)
  );

  // ALU
  alu #(
    .WIDTH    (16)
  ) m_alu (
    .i_op_sel       (i_alu_op_sel),
    .i_op_a         (alu_op_a),
    .i_op_b         (alu_op_b),
    .o_alu_out      (alu_out),
    .o_n            (alu_n),
    .o_z            (alu_z)
  );


  /* Sequential Logic */

  always_ff @ (posedge i_clk, posedge i_reset) begin

    if (i_reset) begin
      r_pc       <= '0;
      r_pc_dc    <= '0;
      r_pc_ex    <= '0;
      r_ir_ex    <= '0;
      r_alu_r    <= '0;
      r_alu_n    <= '0;
      r_alu_z    <= '0;
      r_pc_wr    <= '0;
      r_ir_wr    <= '0;
      r_rf_datax <= '0;
      r_rf_datay <= '0;
      r_datax_wr <= '0;
      r_datay_wr <= '0;
    end

    else begin
      /* FETCH */
      if (i_pc_ld)       r_pc       <= pc_in;
      /* DECODE */
      if (i_pc_dc_ld)    r_pc_dc    <= pc_addr;
      if (i_rf_datax_ld) r_rf_datax <= datax_in;
      if (i_rf_datay_ld) r_rf_datay <= datay_in;
      /* EXECUTE */
      if (i_pc_ex_ld)    r_pc_ex    <= r_pc_dc;
      if (i_ir_ex_ld)    r_ir_ex    <= ir_ex_in;
      if (i_alu_r_ld)    r_alu_r    <= alu_out;
      if (i_alu_n_ld)    r_alu_n    <= alu_n;
      if (i_alu_z_ld)    r_alu_z    <= alu_z;
      /* WRITE */
      if (i_pc_wr_ld)    r_pc_wr    <= r_pc_ex;
      if (i_ir_wr_ld)    r_ir_wr    <= r_ir_ex;
      if (i_datax_wr_ld) r_datax_wr <= r_rf_datax;
      if (i_datay_wr_ld) r_datay_wr <= r_rf_datay;
    end

  end


  /* Combinational Logic */

  /*
   * PREFETCH
   */

  // PC Input Logic
  assign pc_nxt = r_pc + INSTR_SIZE;
  assign jmp_pc_nxt = jmp_pc + INSTR_SIZE;
  assign datax_nxt = r_rf_datax + INSTR_SIZE;

  always_comb begin
    case (i_pc_sel)
      0: pc_in = pc_nxt;        // regular operation/callr where Rx is R7
      1: pc_in = jmp_pc_nxt;    // j instruction
      2: pc_in = datax_nxt;     // jr instruction
      default: pc_in = '0;
    endcase
  end
  
  /*
   * FETCH
   */

  // PC_MEM Input Logic
  assign jmp_pc = r_pc + (ir_dc_imm11 << 1);

  always_comb begin
    case (i_pc_addr_sel)
      0: pc_addr = r_pc;
      1: pc_addr = jmp_pc;        // j instructions
      2: pc_addr = r_rf_datax;  // jr instructions
      default: pc_addr = '0;
    endcase
  end

  /*
   * DECODE
   */

  assign ir_dc = i_pc_rddata;
  assign ir_dc_imm11 = {{5{ir_dc[15]}},ir_dc[15:5]};

  // RF Read Logic
  assign rf_addrx = ir_dc[7:5];
  assign rf_addry = ir_dc[10:8];

  // IR Input Logic
  assign ir_ex_in = i_ir_ex_sel ? NOP : ir_dc;
  
  // RF Data Input
  always_comb begin
    case (i_datax_sel)
      0: datax_in <= rf_datax_out;
      1: datax_in <= rf_data_in; // RAW forwarding
      default: datax_in <= '0;
    endcase
    
    case (i_datay_sel)
      0: datay_in <= rf_datay_out;
      1: datay_in <= rf_data_in; // RAW forwarding
      default: datay_in <= '0;
    endcase
  end

  /*
   * EXECUTE
   */

  // ALU Input Logic
  assign ir_ex_imm8 = {{8{r_ir_ex[15]}},r_ir_ex[15:8]};

  always_comb begin
    case (i_alu_a_sel)
      0: alu_op_a = rf_data_in; // RAW forwarding, might need to change to speed up
      1: alu_op_a = r_rf_datax;
      default: alu_op_a = '0;
    endcase
    case (i_alu_b_sel)
      0: alu_op_b = rf_data_in; // RAW forwarding, see above
      1: alu_op_b = ir_ex_imm8;
      2: alu_op_b = r_rf_datay;
      default: alu_op_b = '0;
    endcase
  end

  // MEM Input Logic
  assign ldst_addr = i_ldst_addr_sel ? rf_data_in : r_rf_datay;
  assign ldst_wrdata = i_ldst_wrdata_sel ? rf_data_in : r_rf_datax;

  /*
   * WRITEBACK
   */

  // RF Write Logic
  assign ir_wr_imm8 = {{8{r_ir_wr[15]}},r_ir_wr[15:8]};
  assign rf_addrw = (i_rf_addrw_sel) ? CALLR_REG : r_ir_wr[7:5];

  always_comb begin
    case (i_rf_sel)
      0: rf_data_in = ir_wr_imm8;
      1: rf_data_in = {ir_wr_imm8[7:0],r_datax_wr[7:0]};
      2: rf_data_in = r_alu_r;
      3: rf_data_in = r_pc_wr;
      4: rf_data_in = i_ldst_rddata;
      5: rf_data_in = r_datay_wr;
      default: rf_data_in = '0;
    endcase
  end


endmodule

// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  wire [31:0] PCIn;
  wire [31:0] PCOut;
  wire [31:0] WriteData;
  wire [31:0] MemData;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] ALUResult;
  wire [31:0] ImmGenOut;

  wire [31:0] MUX1Out;
  wire [31:0] MUX2Out;
  wire [31:0] MUX3Out;
  wire [31:0] MUX4Out;
  wire [31:0] MUX5Out;

  wire PCWriteNotCond;
  wire PCWrite;
  wire IorD;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire IRWrite;
  wire PCSource;
  wire [1:0] ALUCtrlop;
  wire [3:0] ALUop;
  wire ALUSrcB;
  wire ALUSrcA;
  wire RegWrite;
  wire bcond;

  wire IR_wire;
  wire MDR_wire;
  wire A_wire;
  wire B_wire;
  wire ALUOut_wire;

  wire isEcall;
  //wire [31:0] x17;

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.
  reg haltFlag;

  assign IR_wire = IR;
  assign MDR_wire = MDR;
  assign A_wire = A;
  assign B_wire = B;
  assign ALUOut_wire = ALUOut;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .PC_control((~becond & PCWriteNotCond) | PCWrite), // input
    .next_pc(PCIn),     // input
    .current_pc(PCOut)   // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(IR_wire[19:15]),          // input
    .rs2(IR_wire[24:20]),          // input
    .rd(IR_wire[11:7]),           // input
    .rd_din(MUX2Out),       // input
    .write_enable(RegWrite),    // input
    .rs1_dout(rs1_dout),     // output
    .rs2_dout(rs2_dout)      // output
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(MUX1Out),         // input
    .din(B_wire),          // input
    .mem_read(MemRead),     // input
    .mem_write(MemWrite),    // input
    .dout(MemData)          // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .part_of_inst(IR_wire[6:0]), // input
    .clk(clk), // input
    .reset(reset), // input
    .PC_write_not_cond(PCWriteNotCond), // output 
    .PC_write(PCWrite), // output
    .i_or_d(IorD), // output
    .mem_read(MemRead), // output
    .mem_write(MemWrite), // output
    .mem_to_reg(MemtoReg), // output
    .IR_write(IRWrite), // output
    .PC_source(PCSource), // output
    .ALU_op(ALUCtrlop), // output 2bit
    .ALU_src_a(ALUSrcA), // output
    .ALU_src_b(ALUSrcB), // output 2bit
    .reg_write(RegWrite), // output
    .is_ecall(isEcall) // output
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR_wire[31:0]),  // input
    .imm_gen_out(ImmGenOut)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(IR_wire[31:0]), // input
    .alu_ctrl_op(ALUCtrlop),  // input
    .alu_op(ALUop)         // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(ALUop),      // input
    .alu_in_1(MUX3Out),    // input  
    .alu_in_2(MUX4Out),    // input
    .alu_result(ALUResult),  // output
    .alu_bcond(bcond)     // output
  );

  MUX2_to_1 #(32) MUX1 (PCOut, ALUOut_wire, IorD, MUX1Out);
  MUX2_to_1 #(32) MUX2 (ALUOut_wire, MDR_wire, MemtoReg, MUX2Out);
  MUX2_to_1 #(32) MUX3 (PCOut, A_wire, ALUSrcA, MUX3Out);
  MUX4_to_1 #(32) MUX4 (B_wire, 4, ImmGenOut, 0, ALUSrcB, MUX4Out);
  MUX2_to_1 #(32) MUX5 (ALUResult, ALUOut_wire, PCSource, MUX5Out);

  always @(posedge clk) begin
    if (reset) begin
      IR <= 0;
      MDR <= 0;
      A <= 0;
      B <= 0;
      ALUOut <= 0;
    end
    else begin
      if(IRWrite) IR <= MemData;
      MDR <= MemData;
      A <= rs1_dout;
      B <= rs2_dout;
      ALUOut <= ALUResult;
    end
  end

  assign is_halted = haltFlag;
  always @(*) begin
    if (isEcall == 1'b1) begin
      haltFlag <= 1'b1;
    end
    else haltFlag <= 1'b0;
  end

endmodule

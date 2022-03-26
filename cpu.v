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

  is_halted = 1'b0;

  /***** Wire declarations *****/

  wire [31:0] PCOut;
  wire [31:0] PCIn;
  wire [31:0] InstMemOut;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] ALUIn;
  wire [31:0] ALUResult;
  wire [31:0] ImmGenOut;
  wire [31:0] PCAdderOut1;
  wire [31:0] PCAdderOut2;
  wire [31:0] PCAdderMuxOut;
  wire [31:0] DataMemOut;
  wire [31:0] DataMemMuxOut;
  wire [31:0] RegData;

  /***** Register declarations *****/

  reg JAL;
  reg JALR;
  reg branch;
  reg bcond;
  reg AluSrc;
  reg RegWrite;
  reg MemWrite;
  reg MemToReg;
  reg MemRead;
  reg PCToReg;
  reg [3:0] ALUop;
  reg isEcall;
  reg [31:0] x17;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(PCIn),     // input
    .current_pc(PCOut)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(PCOut),    // input
    .dout(InstMemOut)     // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (InstMemOut[19:15]),          // input
    .rs2 (InstMemOut[24:20]),          // input
    .rd (InstMemOut[11:7]),           // input
    .rd_din (RegData),       // input
    .write_enable (RegWrite),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),      // output
    .x17 (x17)
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(InstMemOut[6:0]),  // input
    .is_jal(JAL),        // output
    .is_jalr(JALR),       // output
    .branch(branch),        // output
    .mem_read(MemRead),      // output
    .mem_to_reg(MemToReg),    // output
    .mem_write(MemWrite),     // output
    .alu_src(AluSrc),       // output
    .write_enable(RegWrite),     // output
    .pc_to_reg(PCToReg),     // output
    .is_ecall(isEcall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(InstMemOut[31:0]),  // input
    .imm_gen_out(ImmGenOut)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .all_of_inst(InstMemOut[31:0]),  // input
    .alu_op(ALUop)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(ALUop),      // input
    .alu_in_1(rs1_dout),    // input  
    .alu_in_2(ALUIn),    // input
    .alu_result(ALUResult),  // output
    .alu_bcond(bcond)     // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (ALUResult),       // input
    .din (rs2_dout),        // input
    .mem_read (MemRead),   // input
    .mem_write (MemWrite),  // input
    .dout (DataMemOut)        // output
  );

  Adder #(32) PCAdder1 (input [31:0] PCOut, 4'b32, output PCAdderOut1);
  Adder #(32) PCAdder2 (input [31:0] PCOut, input [31:0] ImmGenOut, output PCAdderOut2);

  MUX2_to_1 #(32) PCAdderMux1 (input [31:0] PCAdderOut2, input ((branch & bcond) | JAL), output [31:0] PCAdderMuxOut);
  MUX2_to_1 #(32) PCAdderMux2 (input [31:0] PCAdderMuxOut, input [31:0] ALUResult, input JALR, output [31:0] PCIn);

  MUX2_to_1 #(32) ALUInputMux (input [31:0] rs2_dout, input [31:0] ImmGenOut, input AluSrc, output [31:0] ALUIn);

  MUX2_to_1 #(32) DataMemMux (input [31:0] ALUResult, input [31:0] DataMemOut, input MemToReg, output [31:0] DataMemMuxOut);

  MUX2_to_1 #(32) WriteDataMux (input [31:0] DataMemMuxOut, input [31:0] PCAdderOut1, input PCToReg, output [31:0] RegData);

  always @(isEcall) begin
    if (isEcall == 1'b1 && x17 == 10) begin
      is_halted = 1'b1;
    end
  end

endmodule

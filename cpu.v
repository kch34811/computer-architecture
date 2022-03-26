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

  wire [31:0]PCOut;
  wire [31:0]InstMemOut;
  wire [31:0]rs1_dout;
  wire [31:0]rs2_dout;

  /***** Register declarations *****/

  reg RegWrite;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(),     // input
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
    .rd_din (),       // input
    .write_enable (RegWrite),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout)      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(InstMemOut[6:0]),  // input
    .is_jal(),        // output
    .is_jalr(),       // output
    .branch(),        // output
    .mem_read(),      // output
    .mem_to_reg(),    // output
    .mem_write(),     // output
    .alu_src(),       // output
    .write_enable(RegWrite),     // output
    .pc_to_reg(),     // output
    .is_ecall()       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(),  // input
    .all_of_inst(),   // input
    .imm_gen_out()    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .all_of_inst(),  // input
    .alu_op()         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(),      // input
    .alu_in_1(rs1_dout),    // input  
    .alu_in_2(),    // input
    .alu_result(),  // output
    .alu_bcond()     // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (),      // input
    .clk (),        // input
    .addr (),       // input
    .din (),        // input
    .mem_read (),   // input
    .mem_write (),  // input
    .dout ()        // output
  );
endmodule

// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  wire [31:0] PCOut;
  wire [31:0] PCAdderOut;
  wire [31:0] InstMemOut;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] ImmGenOut;
  wire [31:0] ALUResult;
  wire [31:0] DataMemOut;

  wire MemRead;
  wire MemWrite;
  wire MemToReg; 
  wire AluSrc;
  wire RegWrite;
  wire PCToReg;
  wire [3:0] ALUop;
  wire isJal;
  wire isJalr;
  wire isBranch;

  wire isEcall;
  wire alu_bcond;
  wire pc_src;

  wire [31:0] MUX2Out;
  wire [31:0] MUX3Out;
  wire [31:0] MUX4Out;
  wire [4:0] MUX5Out;
  wire [31:0] MUX6Out;
  wire [31:0] MUX7Out;
  wire [31:0] AdderInMUXOut;
  wire [31:0] ALUInMUXOut;
  wire [31:0] PCMUXOut;
  wire [31:0] PC_target;

  wire [1:0] forward_rs1_op;
  wire [1:0] forward_rs2_op;

  wire rs1_op;
  wire rs2_op;

  wire ControlOp;
  wire PCWrite;
  wire IF_ID_Write;
  wire IF_Flush;
  wire ID_Flush;

  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  reg [31:0] IF_ID_pc;
  /***** ID/EX pipeline registers *****/
  // From the control unit
  //reg ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_is_jal;
  reg ID_EX_is_jalr;
  reg ID_EX_is_branch;
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  reg ID_EX_is_ecall;
  // From others
  reg [31:0] ID_EX_pc;
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [31:0] ID_EX_imm;
  reg [31:0] ID_EX_ALU_ctrl_unit_input;
  reg [4:0] ID_EX_rd;


  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  //reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  reg EX_MEM_is_ecall;
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;


  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  reg MEM_WB_is_ecall;
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;
  
  reg haltFlag;


  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),
    .PC_control (PCWrite),        // input
    .next_pc(PCMUXOut),     // input
    .current_pc(PCOut)   // output
  );

  MUX2_to_1 PCMUX (PCAdderOut, PC_target, alu_bcond || isJal || isJalr, PCMUXOut);
  Adder PCAdder (PCOut, 32'b100, PCAdderOut);
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(PCOut),    // input
    .dout(InstMemOut)     // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset || IF_Flush) begin
      IF_ID_inst <= 0;
    end
    else if (IF_ID_Write) begin
      IF_ID_inst <= InstMemOut;
      IF_ID_pc <= PCOut;
    end
  end

  Ecall_MUX MUX5 (IF_ID_inst[19:15], 5'b10001, isEcall, MUX5Out);

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (MUX5Out),          // input
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (MUX2Out),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout)      // output
  );

  MUX_CONTROL mux_control (
    .rs1 (MUX5Out),
    .rs2 (IF_ID_inst),
    .rd (MEM_WB_rd),
    .rs1_op (rs1_op),
    .rs2_op (rs2_op)
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst[6:0]),  // input
    .mem_read(MemRead),      // output
    .mem_to_reg(MemToReg),    // output
    .mem_write(MemWrite),     // output
    .alu_src(AluSrc),       // output
    .write_enable(RegWrite),  // output
    .pc_to_reg(PCToReg),     // output
    .is_jal(isJal),       // output
    .is_jalr(isJalr),
    .is_branch(isBranch),   // output
    .is_ecall(isEcall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst[31:0]),  // input
    .imm_gen_out(ImmGenOut)    // output
  );

  // ---------- Hazard Detection Unit ----------
  HazardDetectionUnit hazard_detection_unit(
    .mem_read(ID_EX_mem_read),
    .rd(ID_EX_rd),
    .rs1(IF_ID_inst[19:15]),
    .rs2(IF_ID_inst[24:20]),
    .is_ecall(isEcall),
    .is_jal(isJal),
    .is_jalr(isJalr),
    .is_bcond(alu_bcond),
    .PC_write(PCWrite),
    .IF_ID_write(IF_ID_Write),
    .control_op(ControlOp),
    .IF_flush(IF_Flush),
    .ID_flush(ID_Flush)
  );

  MUX2_to_1 MUX6 (rs1_dout, MUX2Out, rs1_op, MUX6Out);
  MUX2_to_1 MUX7 (rs2_dout, MUX2Out, rs2_op, MUX7Out);

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset || ID_Flush) begin
      ID_EX_alu_src <= 0;      // will be used in EX stage
      ID_EX_mem_write <= 0;      // will be used in MEM stage
      ID_EX_mem_read <= 0;       // will be used in MEM stage
      ID_EX_is_jal <= 0;
      ID_EX_is_jalr <= 0;
      ID_EX_is_branch <= 0;
      ID_EX_mem_to_reg <= 0;    // will be used in WB stage
      ID_EX_reg_write <= 0;
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_imm <= 0;
      ID_EX_ALU_ctrl_unit_input <= 0;
      ID_EX_rd <= 0;
      ID_EX_pc <= 0;
    end
    else begin
      // From the control unit
      ID_EX_alu_src <= ControlOp ? 0 : AluSrc;      // will be used in EX stage
      ID_EX_mem_write <= ControlOp ? 0 : MemWrite;      // will be used in MEM stage
      ID_EX_mem_read <= ControlOp ? 0 : MemRead;       // will be used in MEM stage
      ID_EX_is_jal <= ControlOp ? 0 : isJal; 
      ID_EX_is_jalr <= ControlOp ? 0 : isJalr;   
      ID_EX_is_branch <= ControlOp ? 0 : isBranch;     
      ID_EX_mem_to_reg <= ControlOp ? 0 : MemToReg;    // will be used in WB stage
      ID_EX_reg_write <= ControlOp ? 0 : RegWrite;
      ID_EX_is_ecall <= ControlOp ? 0 : (rs1_dout == 32'b1010) && isEcall;
      // From others
      ID_EX_rs1_data <= MUX6Out;
      ID_EX_rs2_data <= MUX7Out;
      ID_EX_imm <= ImmGenOut;
      ID_EX_ALU_ctrl_unit_input <= IF_ID_inst;
      ID_EX_rd <= IF_ID_inst[11:7];
      ID_EX_pc <= IF_ID_pc;
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .all_of_inst(ID_EX_ALU_ctrl_unit_input),  // input
    .alu_op(ALUop)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(ALUop),      // input
    .alu_in_1(MUX3Out),    // input  
    .alu_in_2(ALUInMUXOut),    // input
    .alu_result(ALUResult),  // output
    .alu_bcond(alu_bcond)     // output
  );

  ForwardingUnit forwardUnit(
    .rs1 (ID_EX_ALU_ctrl_unit_input[19:15]),
    .rs2 (ID_EX_ALU_ctrl_unit_input[24:20]),
    .EX_MEM_rd (EX_MEM_rd),
    .MEM_WB_rd (MEM_WB_rd),
    .EX_MEM_reg_write (EX_MEM_reg_write),
    .MEM_WB_reg_write (MEM_WB_reg_write),
    .forward_rs1_op (forward_rs1_op),
    .forward_rs2_op (forward_rs2_op)
  );

  MUX4_to_1 MUX3 (ID_EX_rs1_data, EX_MEM_alu_out, MUX2Out, 32'b0, forward_rs1_op, MUX3Out);
  MUX4_to_1 MUX4 (ID_EX_rs2_data, EX_MEM_alu_out, MUX2Out, 32'b0, forward_rs2_op, MUX4Out);
  MUX2_to_1 AdderInMUX (MUX3Out, ID_EX_pc, ID_EX_is_jal || ID_EX_is_branch, AdderInMUXOut);
  MUX2_to_1 ALUInMUX (MUX4Out, ID_EX_imm, ID_EX_alu_src || ID_EX_is_jal || ID_EX_is_jalr || ID_EX_is_branch, ALUInMUXOut);
  Adder TargetAdder (AdderInMUXOut, ALUInMUXOut << 1, PC_target);

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_write <= 0;     
      EX_MEM_mem_read <= 0;      
      EX_MEM_mem_to_reg <= 0;    
      EX_MEM_reg_write <= 0;     
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
    end
    else begin
      // From the control unit
      EX_MEM_mem_write <= ID_EX_mem_write;     // will be used in MEM stage
      EX_MEM_mem_read <= ID_EX_mem_read;      // will be used in MEM stage
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;    // will be used in WB stage
      EX_MEM_reg_write <= ID_EX_reg_write;     // will be used in WB stage
      EX_MEM_is_ecall <= ID_EX_is_ecall;
      // From others
      EX_MEM_alu_out <= ALUResult;
      EX_MEM_dmem_data <= MUX4Out;
      EX_MEM_rd <= ID_EX_rd;
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (EX_MEM_alu_out),       // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (EX_MEM_mem_read),   // input
    .mem_write (EX_MEM_mem_write),  // input
    .dout (DataMemOut)        // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      MEM_WB_mem_to_reg <= 0;  
      MEM_WB_reg_write <= 0;   
      MEM_WB_is_ecall <= 0;
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 0;
    end
    else begin
      // From the control unit
      MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;   // will be used in WB stage
      MEM_WB_reg_write <= EX_MEM_reg_write;     // will be used in WB stage
      MEM_WB_is_ecall <= EX_MEM_is_ecall;
      // From others
      MEM_WB_mem_to_reg_src_1 <= DataMemOut;
      MEM_WB_mem_to_reg_src_2 <= EX_MEM_alu_out;
      MEM_WB_rd <= EX_MEM_rd;
    end
  end

  MUX2_to_1 MUX2 (MEM_WB_mem_to_reg_src_2, MEM_WB_mem_to_reg_src_1, MEM_WB_mem_to_reg, MUX2Out);

  assign is_halted = haltFlag;
  always @(*) begin
    if (MEM_WB_is_ecall == 1'b1) begin
      haltFlag <= 1'b1;
    end
    else haltFlag <= 1'b0;
  end

endmodule

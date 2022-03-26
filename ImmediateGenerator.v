`include "opcodes.v"

module ImmediateGenerator(input [31:0] part_of_inst, output [31:0] imm_gen_out);
  
  always_comb begin
    case(part_of_inst[6:0])
    // R-type instruction
    `ARITHMETIC : imm_gen_out = {part_of_inst[31:12], 12'b0};

    // I-type instruction
    `ARITHMETIC_IMM : begin 
      if(part_of_inst[14:12]==`FUNCT3_SRL || part_of_inst[14:12]==`FUNCT3_SLL)
        imm_gen_out = {part_of_inst[24]? 27{1'b1} : 27{1'b0}, part_of_inst[24:20]};
      else 
        imm_gen_out = {part_of_inst[31]? 20'b1 : 20'b0, part_of_inst[31:20]};
      end
    `LOAD : imm_gen_out = {part_of_inst[31]? 20{1'b1} : 20{1'b0}, part_of_inst[31:20]};
    `JALR : imm_gen_out = {part_of_inst[31]? 20'b1 : 20'b0, part_of_inst[30:20]};

    // S-type instruction
    `STORE : imm_gen_out = {part_of_inst[31]? 20'b1 : 20'b0, part_of_inst[31:25], part_of_inst[11:7]};

    // B-type instruction
    `BRANCH : imm_gen_out = {part_of_inst[31]? 20'b1:20'b0, part_of_inst[7], part_of_inst[30:25], part_of_inst[11:8], 1'b0};

    // U-type instruction
    //`LUI : imm_gen_out = {part_of_inst[31:12], 12'b0};
    //`AUIPC : imm_gen_out = {part_of_inst[31:12], 12'b0};

    // J-type instruction
    `JAL : imm_gen_out = {part_of_inst[31]? 20'b1:20'b0, part_of_inst[19:12], part_of_inst[19:12], part_of_inst[20], part_of_inst[30:25], part_of_inst[24:21], 1'b0}

    defualt : imm_gen_out = 32'b0;
    endcase
  end  
endmodule
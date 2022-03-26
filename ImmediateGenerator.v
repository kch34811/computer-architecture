`include "opcodes.v"

module ImmediateGenerator(input [6:0] part_of_inst, input [31:0] all_of_inst, output [31:0] imm_gen_out);
  
  case(part_of_inst)

    // R-type instruction
    `ARITHMETIC : imm_gen_out = {all_of_inst[31:12], 12'b0};

    // I-type instruction
    `ARITHMETIC_IMM : begin 
      if(all_of_inst[14:12]==`FUNCT3_SRL||all_of_inst[14:12]==`FUNCT3_SLL)
        imm_gen_out = {all_of_inst[24]? 27'b1 : 27'b0, all_of_inst[24:20]};
      else 
        imm_gen_out = {all_of_inst[31]? 20'b1 : 20'b0, all_of_inst[31:20]};
      end
    `LOAD : imm_gen_out = {all_of_inst[31]? 20'b1 : 20'b0, all_of_inst[31:20]};
    `JALR : imm_gen_out = {all_of_inst[31]? 20'b1 : 20'b0, all_of_inst[30:20]};

    // S-type instruction
    `STORE : imm_gen_out = {all_of_inst[31]? 20'b1 : 20'b0, all_of_inst[31:25], all_of_inst[11:7]};

    // B-type instruction
    `BRANCH : imm_gen_out = {all_of_inst[31]? 20'b1:20'b0, all_of_inst[7], all_of_inst[30:25], all_of_inst[11:8], 1'b0};

    // U-type instruction
    `LUI : imm_gen_out = {all_of_inst[31:12], 12'b0};
    `AUIPC : imm_gen_out = {all_of_inst[31:12], 12'b0};

    // J-type instruction
    `JAL : imm_gen_out = {all_of_inst[31]? 20'b1:20'b0, all_of_inst[19:12], all_of_inst[19:12], all_of_inst[20], all_of_inst[30:25], all_of_inst[24:21], 1'b0}

endmodule
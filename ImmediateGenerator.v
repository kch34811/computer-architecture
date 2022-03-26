`include "opcodes.v"

module ImmediateGenerator(input [6:0] part_of_inst, input [31:0] all_of_inst, output [31:0] imm_gen_out);
  case(part_of_inst)

    // R-type instruction
    `ARITHMETIC : imm_gen_out = {all_of_inst[31:12], 12'b0};

    // I-type instruction
    `ARITHMETIC_IMM : begin 
      if(part_of_inst[])
      end
    `LOAD : imm_gen_out = {all_of_inst[31]? 20'b1 : 20'b0, all_of_inst[31:20]};
    //*check
    `JALR : imm_gen_out = {all_of_inst[31]? 20'b1 : 20'b0, all_of_inst[30:20]};

    // S-type instruction
    `STORE : 

    // B-type instruction
    `BRANCH :

    // U-type instruction
    `LUI :
    `AUIPC :

    // J-type instruction
    `JAL :

endmodule
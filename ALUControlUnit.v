`include "opcodes.v"

module ALUControlUnit (input [31:0] all_of_inst, output reg [3:0] alu_op);

    always @(all_of_inst) begin
        
        reg [6:0] opcode = all_of_inst[6:0];
        reg [6:0] funct7 = all_of_inst[31:25];
        reg [2:0] funct3 = all_of_inst[14:12];

        if (opcode == `ARITHMETIC) begin
            case(funct3)
            3'b000: alu_op = (funct7 == `FUNCT7_SUB) ? 4'b0001 : 4'b0000;

            `FUNCT3_SLL: alu_op = 4'b1010;

            `FUNCT3_XOR: alu_op = 4'b1000;

            `FUNCT3_OR: alu_op = 4'b0101;

            `FUNCT3_AND: alu_op = 4'b0100;

            `FUNCT3_SRL: alu_op = 4'b1011;
            endcase
        end

        if (opcode == `ARITHMETIC_IMM) begin
            case(funct3)
            `FUNCT3_ADD: alu_op = 4'b0000;

            `FUNCT3_XOR: alu_op = 4'b1000;

            `FUNCT3_OR: alu_op = 4'b0101;

            `FUNCT3_AND: alu_op = 4'b0100;

            `FUNCT3_SLL: alu_op = 4'b1010;

            `FUNCT3_SRL: alu_op = 4'b1011;
            endcase
        end

        if (opcode == `LOAD || opcode == `STORE || opcode == `JALR) begin
            alu_op = 4'b0000;
        end

        if (opcode == `BRANCH) begin
            case(funct3)
            `FUNCT3_ADD: alu_op = 4'b0000;

            `FUNCT3_SLL: alu_op = 4'b1010;

            `FUNCT3_XOR: alu_op = 4'b1000;

            `FUNCT3_SRL: alu_op = 4'b1011;
            endcase
    end

endmodule
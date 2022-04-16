`include "opcodes.v"

module ALUControlUnit (input [31:0] all_of_inst, input [1:0] alu_ctrl_op, output reg [3:0] alu_op);
        
    // reg [6:0] opcode = all_of_inst[6:0];
    // reg [6:0] funct7 = all_of_inst[31:25];
    // reg [2:0] funct3 = all_of_inst[14:12];

    always @(all_of_inst) begin
        
        if (alu_ctrl_op == 2'b00) begin
            alu_op = 4'b0000;
        end else if (alu_ctrl_op == 2'b01) begin
            case(all_of_inst[14:12])
            `FUNCT3_ADD: alu_op = 4'b0000;

            `FUNCT3_SLL: alu_op = 4'b1010;

            `FUNCT3_XOR: alu_op = 4'b1000;

            `FUNCT3_SRL: alu_op = 4'b1011;
            endcase
        end else if (alu_ctrl_op == 2'b10) begin
            case(all_of_inst[14:12])
            3'b000: alu_op = (all_of_inst[31:25] == `FUNCT7_SUB) ? 4'b0001 : 4'b0000;

            `FUNCT3_SLL: alu_op = 4'b1010;

            `FUNCT3_XOR: alu_op = 4'b1000;

            `FUNCT3_OR: alu_op = 4'b0101;

            `FUNCT3_AND: alu_op = 4'b0100;

            `FUNCT3_SRL: alu_op = 4'b1011;
            endcase
        end else begin 

            if (all_of_inst[6:0] == `ARITHMETIC) begin
                case(all_of_inst[14:12])
                3'b000: alu_op = (all_of_inst[31:25] == `FUNCT7_SUB) ? 4'b0001 : 4'b0000;

                `FUNCT3_SLL: alu_op = 4'b1010;

                `FUNCT3_XOR: alu_op = 4'b1000;

                `FUNCT3_OR: alu_op = 4'b0101;

                `FUNCT3_AND: alu_op = 4'b0100;

                `FUNCT3_SRL: alu_op = 4'b1011;
                endcase
            end

            if (all_of_inst[6:0] == `ARITHMETIC_IMM) begin
                case(all_of_inst[14:12])
                `FUNCT3_ADD: alu_op = 4'b0000;

                `FUNCT3_XOR: alu_op = 4'b1000;

                `FUNCT3_OR: alu_op = 4'b0101;

                `FUNCT3_AND: alu_op = 4'b0100;

                `FUNCT3_SLL: alu_op = 4'b1010;

                `FUNCT3_SRL: alu_op = 4'b1011;
                endcase
            end

            if (all_of_inst[6:0] == `LOAD || all_of_inst[6:0] == `STORE || all_of_inst[6:0] == `JALR) begin
                alu_op = 4'b0000;
            end

            if (all_of_inst[6:0] == `BRANCH) begin
                case(all_of_inst[14:12])
                `FUNCT3_ADD: alu_op = 4'b0000;

                `FUNCT3_SLL: alu_op = 4'b1010;

                `FUNCT3_XOR: alu_op = 4'b1000;

                `FUNCT3_SRL: alu_op = 4'b1011;
                endcase
            end
        end
    end

endmodule
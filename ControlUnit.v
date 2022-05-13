`include "opcodes.v"

module ControlUnit(input [6:0] part_of_inst,
                   output reg mem_read,
                   output reg mem_to_reg,
                   output reg mem_write,
                   output reg alu_src,
                   output reg write_enable,
                   output reg pc_to_reg,
                   output reg pc_src,
                   output reg is_jal,
                   output reg is_jalr,
                   output reg is_branch,
                   output reg is_ecall);

    always @(part_of_inst) begin
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        mem_write = 1'b0;
        alu_src = 1'b0;
        write_enable = 1'b0;
        pc_to_reg = 1'b0;
        is_jal = 1'b0;
        is_jalr = 1'b0;
        is_branch = 1'b0;
        is_ecall = 1'b0;

        if (part_of_inst == `JAL) begin
            is_jal = 1'b1;
            pc_to_reg = 1'b1;
        end

        if (part_of_inst == `JALR) begin
            is_jalr = 1'b1;
            pc_to_reg = 1'b1;
        end

        if (part_of_inst == `LOAD) begin // opcode == LW/LH/LB
            mem_read = 1'b1;
            mem_to_reg = 1'b1;
        end

        if (part_of_inst == `STORE) begin 
            mem_write = 1'b1;
        end

        if (part_of_inst != `ARITHMETIC && part_of_inst != `BRANCH) begin // opcode Rtype(0110011), SBtype(1100011)
            alu_src = 1'b1;
        end

        if(part_of_inst != `STORE && part_of_inst != `BRANCH) begin
            write_enable = 1'b1;
        end

        if(part_of_inst == `BRANCH) begin
            is_branch = 1'b1;
        end

        if(part_of_inst == `ECALL || part_of_inst == 0) begin
            is_ecall = 1'b1;
        end
    end

endmodule
`include "opcodes.v"

module ControlUnit(input [6:0] part_of_inst,
                   output mem_read,
                   output mem_to_reg,
                   output mem_write,
                   output alu_src,
                   output write_enable,
                   output pc_to_reg,
                   //output alu_op,
                   output is_ecall);

    always @(part_of_inst) begin
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        mem_write = 1'b0;
        alu_src = 1'b0;
        write_enable = 1'b0;
        pc_to_reg = 1'b0;
        //alu_op = 1'b0;
        is_ecall = 1'b0;

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

        if(part_of_inst == `ECALL) begin
            is_ecall = 1'b1;
        end
    end

endmodule
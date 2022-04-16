`include "opcodes.v"

`define INST_FETCH 0
`define INST_DECODE_REG_FETCH 1
`define MEM_ADDR_COMPUTATION 2
`define MEM_ACCESS_READ 3
`define WB_STEP 4
`define MEM_ACCESS_WRITE 5
`define EXECUTION 6
`define R_TYPE_COMPLETION 7
`define BRANCH_COMPLETION 8
`define HALT 9
`define EXECUTION_IMM 10
`define JUMP_IMM 11

module ControlUnit (input [6:0] part_of_inst,
                    input clk,
                    input reset,
                    output reg PC_write_cond,
                    output reg PC_write,
                    output reg i_or_d,
                    output reg mem_read,
                    output reg mem_write,
                    output reg mem_to_reg,
                    output reg IR_write,
                    output reg PC_source,
                    output reg [1:0] ALU_op,
                    output reg ALU_src_a,
                    output reg [1:0] ALU_src_b,
                    output reg reg_write,
                    output reg is_ecall
                    );

    reg [3:0] state;

    always @(posedge clk) begin
        if (reset) begin
            state <= `INST_FETCH;
        end else begin
            if (state == `INST_FETCH) begin
                state <= `INST_DECODE_REG_FETCH;
            end else if (state == `INST_DECODE_REG_FETCH) begin
                if (part_of_inst == `LOAD || part_of_inst == `STORE) begin
                    state <= `MEM_ADDR_COMPUTATION;
                end else if (part_of_inst == `ARITHMETIC) begin
                    state <= `EXECUTION;
                end else if (part_of_inst == `BRANCH) begin
                    state <= `BRANCH_COMPLETION;
                end else if (part_of_inst == `ECALL) begin
                    state <= `HALT;
                end else if (part_of_inst == `ARITHMETIC_IMM) begin
                    state <= `EXECUTION_IMM;
                end else if (part_of_inst == `JALR) begin
                    state <= `JUMP_IMM;
                end
            end else if(state == `MEM_ADDR_COMPUTATION) begin
                if(part_of_inst == `LOAD) begin
                    state <= `MEM_ACCESS_READ;
                end else if(part_of_inst == `STORE) begin
                    state <= `MEM_ACCESS_WRITE;
                end
            end else if (state == `MEM_ACCESS_READ) begin
                state <= `WB_STEP;
            end else if (state == `MEM_ACCESS_WRITE) begin
                state <= `INST_FETCH;
            end else if (state == `EXECUTION) begin
                state <= `R_TYPE_COMPLETION;
            end else if (state == `R_TYPE_COMPLETION) begin
                state <= `INST_FETCH;
            end else if (state == `BRANCH_COMPLETION) begin
                state <= `INST_FETCH;
            end else if (state == `HALT) begin
                state <= `INST_FETCH;
            end else if (state == `EXECUTION_IMM) begin
                state <= `INST_FETCH;
            end else if (state == `JUMP_IMM) begin
                state <= `INST_FETCH;
            end
        end
    end

    always @(state) begin
        PC_write_cond = 1'b0;
        PC_write = 1'b0;
        i_or_d = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        IR_write = 1'b0;
        PC_source = 1'b0;
        ALU_op = 2'b00;
        ALU_src_a = 1'b0;
        ALU_src_b = 2'b00;
        reg_write = 1'b0;
        is_ecall = 1'b0;

        if (state == `INST_FETCH) begin
            mem_read = 1'b1;
            ALU_src_b = 2'b01;
            PC_write = 1'b1;
            IR_write = 1'b1;
        end else if (state == `INST_DECODE_REG_FETCH) begin
            ALU_src_b = 2'b10;
        end else if (state == `MEM_ADDR_COMPUTATION) begin
            ALU_src_a = 1'b1;
            ALU_src_b = 2'b10;
        end else if (state == `MEM_ACCESS_READ) begin
            mem_read = 1'b1;
            i_or_d = 1'b1;
        end else if (state == `WB_STEP) begin
            reg_write = 1'b1;
            mem_to_reg = 1'b1;
        end else if (state == `MEM_ACCESS_WRITE) begin
            mem_write = 1'b1;
            i_or_d = 1'b1;
        end else if (state == `EXECUTION) begin
            ALU_src_a = 1'b1;
            ALU_src_b = 2'b00;
            ALU_op = 2'b10;
        end else if (state == `R_TYPE_COMPLETION) begin
            reg_write = 1'b1;
        end else if (state == `BRANCH_COMPLETION) begin
            ALU_src_a = 1'b1;
            ALU_src_b = 2'b00;
            ALU_op = 2'b01;
            PC_write_cond = 1'b1;
            PC_source = 1'b1;
        end else if (state == `HALT) begin
            is_ecall = 1'b1;
        end else if (state == `ARITHMETIC_IMM) begin
            ALU_src_a = 1'b1;
            ALU_src_b = 2'b10;
            ALU_op = 2'b1;
        end else if (state == `JUMP_IMM) begin
            ALU_src_b = 2'b10;
        end
    end

endmodule
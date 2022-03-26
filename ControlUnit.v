module ControlUnit (input part_of_inst,
                    output reg is_jal,
                    output reg is_jalr,
                    output reg branch,
                    output reg mem_read,
                    output reg mem_to_reg,
                    output reg mem_write,
                    output reg alu_src,
                    output reg write_enable,
                    output reg pc_to_reg,
                    output reg is_call);

    always @(part_of_inst) begin
        is_jal = 1'b0;
        is_jalr = 1'b0;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        mem_write = 1'b0;
        alu_src = 1'b0;
        write_enable = 1'b0;
        pc_to_reg = 1'b0;
        is_call = 1'b0;
        
        if (part_of_inst == `JAL) begin
            is_jar = 1'b1;
            pc_to_reg = 1'b1;
        end
        
        if (part_of_inst == `JALR) begin
            is_jalr = 1'b1;
            pc_to_reg = 1'b1;
        end

        if (part_of_inst == 7'0000011) begin // opcode == LW/LH/LB
            mem_read = 1'b1;
            mem_to_reg = 1'b1;
        end

        if (part_of_inst == 7'b0100011) begin 
            mem_write = 1'b1;
        end

        if (part_of_inst != 7'b0110011 && part_of_inst != 7'b1100011) begin // opcode Rtype(0110011), SBtype(1100011)
            alu_src = 1'b1;
        end

        //branch, write_enable, is_call

    end



endmodule
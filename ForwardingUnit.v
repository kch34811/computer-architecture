module ForwardingUnit(input [6:0] rs1,
                      input [6:0] rs2,
                      input [6:0] EX_MEM_rd,
                      input [6:0] MEM_WB_rd,
                      input EX_MEM_reg_write,
                      input MEM_WB_reg_write,
                      output [1:0] forward_rs1_op,
                      output [1:0] forward_rs2_op
                      );
    
    always @(*) begin
        forward_rs1_op = 2'b00;
        forward_rs2_op = 2'b00;
        if ((MEM_WB_reg_write && MEM_WB_rd != 0)
            && (MEM_WB_rd == rs1)
            && !((EX_MEM_reg_write && EX_MEM_rd != 0) && (EX_MEM_rd == rs1))
        ) begin
            forward_rs1_op = 2'b01;
        end else if(EX_MEM_rd == rs1 && EX_MEM_reg_write) begin
            forward_rs1_op = 2'b01;
        end else if (EX_MEM_rd == rs2 && EX_MEM_reg_write) begin
            forward_rs2_op = 2'b01;
        end else if (MEM_WB_rd == rs1 && MEM_WB_reg_write) begin
            forward_rs1_op = 2'b10;
        end else if (MEM_WB_rd == rs2 && MEM_WB_reg_write) begin
            forward_rs2_op = 2'b10;
        end
    end

endmodule
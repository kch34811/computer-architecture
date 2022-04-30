module ForwardingUnit(input [4:0] rs1,
                      input [4:0] rs2,
                      input [4:0] EX_MEM_rd,
                      input [4:0] MEM_WB_rd,
                      input EX_MEM_reg_write,
                      input MEM_WB_reg_write,
                      output reg [1:0] forward_rs1_op,
                      output reg [1:0] forward_rs2_op
                      );
    
    always @(*) begin
        forward_rs1_op = 2'b00;
        forward_rs2_op = 2'b00;
        if(EX_MEM_rd == rs1 && EX_MEM_reg_write && rs1 != 0) begin
            forward_rs1_op = 2'b01;
        end else if (EX_MEM_rd == rs2 && EX_MEM_reg_write && rs2 != 0) begin
            forward_rs2_op = 2'b01;
        end else if (MEM_WB_rd == rs1 && MEM_WB_reg_write && rs1 != 0) begin
            forward_rs1_op = 2'b10;
        end else if (MEM_WB_rd == rs2 && MEM_WB_reg_write && rs2 != 0) begin
            forward_rs2_op = 2'b10;
        end
    end

endmodule
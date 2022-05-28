module MUX_CONTROL (input [4:0] rs1,
                    input [4:0] rs2,
                    input [4:0] rd,
                    output reg rs1_op,
                    output reg rs2_op);


    always @(*) begin
        rs1_op = 1'b0;
        rs2_op = 1'b0;
        if (rs1 == rd) begin
            //rs1_op = 1'b1;
        end else if (rs2 == rd) begin
            //rs2_op = 1'b1;
        end
    end

endmodule
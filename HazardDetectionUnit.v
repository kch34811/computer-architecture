module HazardDetectionUnit(input mem_read,
                           input [4:0] rd,
                           input [4:0] rs1,
                           input [4:0] rs2,
                           input is_ecall,
                           output reg PC_write,
                           output reg IF_ID_write,
                           output reg control_op
);

    always @(*) begin
        PC_write = 1'b1;
        IF_ID_write = 1'b1;
        control_op = 1'b0;
        if ((mem_read && rd != 0) && ((rd == rs1) || (rd == rs2))) begin
            PC_write = 1'b0;
            IF_ID_write = 1'b0;
            control_op = 1'b1;
        end
        if (is_ecall && rd == 17) begin
            PC_write = 1'b0;
            IF_ID_write = 1'b0;
            control_op = 1'b1;
        end
    end

endmodule
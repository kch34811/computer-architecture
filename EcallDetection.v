module EcallDetection (input [4:0] rd1,
                       input [4:0] rd2,
                       input isEcall,
                       output reg ecall_op
                       );

    always @(*) begin
        ecall_op = 1'b0;
        if ((rd1 == 5'b10001 || rd2 == 5'b10001) && isEcall) begin
            ecall_op = 1'b1;
        end
    end

endmodule
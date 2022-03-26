module ALU #(parameter data_width = 32) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg bcond);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/

always @* begin
	OverflowFlag = 0
    bcond = 0;

	case(FuncCode)
		4'b0000:
			begin
				C = A + B;
                A == B ? bcond = 1 : bcond = 0;
			end
		4'b0001: C = A - B;
		4'b0010: C = A;
		4'b0011: C = ~A;
		4'b0100: C = A & B;
		4'b0101: C = A | B;
		4'b0110: C = ~(A & B);
		4'b0111: C = ~(A | B);
		4'b1000: 
            begin
                C = A ^ B;
                A < B ? bcond = 1 : bcond = 0;
            end
		4'b1001: C = A ^ ~B;
		4'b1010:
            begin
                 C = A << 1;
                 A != B ? bcond = 1 : bcond = 0;
            end
		4'b1011:
            begin
                 C = A >> 1;
                 A >= B ? bcond = 1 : bcond = 0;
            end
		4'b1100: C = A <<< 1;
		4'b1101: 
			begin
				C = A >> 1;
				if(A[15] == 1)
					C[15] = 1;
			end
		4'b1110: C = ~A + 1;
		4'b1111: C = 0;
	endcase
end


endmodule


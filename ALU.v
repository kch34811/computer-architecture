module ALU (
	input [31:0] alu_in_1, 
	input [31:0] alu_in_2, 
	input [3:0] alu_op,
       	output reg [31:0] alu_result,
       	output reg alu_bcond);
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
    alu_bcond = 0;

	case(alu_op)
		4'b0000:
			begin
				alu_result = alu_in_1 + alu_in_2;
                alu_in_1 == alu_in_2 ? alu_bcond = 1 : alu_bcond = 0;
			end
		4'b0001: alu_result = alu_in_1 - alu_in_2;
		4'b0010: alu_result = alu_in_1;
		4'b0011: alu_result = ~alu_in_1;
		4'b0100: alu_result = alu_in_1 & alu_in_2;
		4'b0101: alu_result = alu_in_1 | alu_in_2;
		4'b0110: alu_result = ~(alu_in_1 & alu_in_2);
		4'b0111: alu_result = ~(alu_in_1 | alu_in_2);
		4'b1000: 
            begin
                alu_result = alu_in_1 ^ alu_in_2;
                alu_in_1 < alu_in_2 ? alu_bcond = 1 : alu_bcond = 0;
            end
		4'b1001: alu_result = alu_in_1 ^ ~alu_in_2;
		4'b1010:
            begin
                 alu_result = alu_in_1 << 1;
                 alu_in_1 != alu_in_2 ? alu_bcond = 1 : alu_bcond = 0;
            end
		4'b1011:
            begin
                 alu_result = alu_in_1 >> 1;
                 alu_in_1 >= alu_in_2 ? alu_bcond = 1 : alu_bcond = 0;
            end
		4'b1100: alu_result = alu_in_1 <<< 1;
		4'b1101: 
			begin
				alu_result = alu_in_1 >> 1;
				if(alu_in_1[31] == 1)
					alu_result[31] = 1;
			end
		4'b1110: alu_result = ~alu_in_1 + 1;
		4'b1111: alu_result = 0;
	endcase
end


endmodule


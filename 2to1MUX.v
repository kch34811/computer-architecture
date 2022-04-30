module MUX2_to_1 (input [31:0] A, 
									input [31:0] B, 
									input a, 
									output [31:0] Q);

	assign Q = a ? B : A;

endmodule

module Ecall_MUX (input [4:0] A, 
									input [4:0] B, 
									input a, 
									output [4:0] Q);

	assign Q = a ? B : A;

endmodule
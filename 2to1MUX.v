module MUX2_to_1 (input [31:0] A, 
									input [31:0] B, 
									input a, 
									output [31:0] Q);

	assign Q = a ? B : A;

endmodule
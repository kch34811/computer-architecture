module MUX4_to_1 (input [4:0] A, 
									input [4:0] B, 
									input [4:0] C, 
									input [4:0] D, 
									input [1:0] a, 
									output [4:0] Q);

	assign Q = a[1] ? (a[0] ? D : C) : (a[0] ? B : A);

endmodule
module MUX4_to_1 #(parameter NUM_OF_BIT) (A, B, C, D, a, Q);
	input [NUM_OF_BIT-1:0] A;
	input [NUM_OF_BIT-1:0] B;
  input [NUM_OF_BIT-1:0] C;
	input [NUM_OF_BIT-1:0] D;
	input [1:0] a;
	output [NUM_OF_BIT-1:0] Q;

	assign Q = a[1] ? (a[0] ? D : C) : (a[0] ? B : A);

endmodule
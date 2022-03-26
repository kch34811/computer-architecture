module MUX2_to_1 #(parameter NUM_OF_BIT) (A, B, a, Q);
	input [NUM_OF_BIT-1:0] A;
	input [NUM_OF_BIT-1:0] B;
	input a;
	output [NUM_OF_BIT-1:0] Q;

	assign Q = a ? A : B;

endmodule

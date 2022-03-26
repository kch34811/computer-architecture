module Adder #(parameter NUM) (input_1, input_2, sum);

  input [NUM-1:0] input_1;
  input [NUM-1:0] input_2;
  output [NUM-1:0] sum;

  assign sum = input_1 + input_2;

endmodule
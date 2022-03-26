module PC ( input reset, 
            input clk, 
            input [31:0] next_pc, 
            output reg current_pc);
  
  always@(posedge clk) begin
    if(!reset) current_pc <= 32'b0;
    else current_pc <= next_pc;
  end

endmodule
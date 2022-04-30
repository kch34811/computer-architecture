module PC ( input reset, 
            input clk, 
            input PC_control,
            input [31:0] next_pc, 
            output reg [31:0] current_pc);
  
  always@(posedge clk) begin
    if(reset) current_pc <= 32'b0;
    else begin
      if(PC_control) current_pc <= next_pc;
    end
  end

endmodule
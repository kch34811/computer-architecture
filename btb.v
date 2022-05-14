module BTB (input reset,
            input clk,
            input [31:0] current_pc,
            input [31:0] source_pc,
            input [31:0] target_pc,
            input branch_taken,
            output tag_match,
            output [31:0] target_pc
);

reg [24:0] tag_table[0:31];
reg [31:0] buffer_table[0:31];

wire [4:0] index;
wire [24:0] tag_bit;

assign index = current_pc[6:2];
assign tag_bit = current_pc[31:7];

integer i;

always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            buffer_table[i] = 32'b0;
            tag_table[i] = 24'b0;
    end
end

always @(*) begin
    tag_match = 1'b0;
    target_pc = 32'b0;

    if (tag_table[index] == tag_bit) begin
        tag_match = 1'b1;
        target_pc = buffer_table[index];
    end

    if (branch_taken) begin
        assign index = source_pc[6:2];
        assign tag_bit = source_pc[31:7];

        tag_table[index] = tag_bit;
        buffer_table[index] = target_pc;
    end
end


endmodule
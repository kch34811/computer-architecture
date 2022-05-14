module BTB (input reset,
            input clk,
            input [31:0] current_pc,
            input [31:0] source_pc,
            input [31:0] target_pc,
            input branch_taken,
            output reg tag_match,
            output reg [31:0] target_pc_out
);

reg [24:0] tag_table[0:31];
reg [31:0] buffer_table[0:31];

wire [4:0] index;
wire [24:0] tag_bit;

wire [4:0] temp_index;
wire [24:0] temp_tag_bit;

assign index = current_pc[6:2];
assign tag_bit = current_pc[31:7];

assign temp_index = source_pc[6:2];
assign temp_tag_bit = source_pc[31:7];

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
    target_pc_out = 32'b0;

    if (tag_table[index] == tag_bit) begin
        tag_match = 1'b1;
        target_pc_out = buffer_table[index];
    end

    if (branch_taken) begin
        tag_table[temp_index] = temp_tag_bit;
        buffer_table[temp_index] = target_pc;
    end
end


endmodule
`include "CLOG2.v"
module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 2
               parameter NUM_WAYS = 2 (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,  //?
    output [31:0] dout,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  
  wire [`TAG_SIZE-1:0] addr_tag;
  wire [`INDEX_SIZE-1:0] addr_idx;
  wire [1:0] addr_bo;
  // Reg declarations
  reg [`CACHE_LINE_SIZE-1:0] direct_cache[0:2^`INDEX_SIZE]; 
  
  // About Data Memory
  reg [31:0] DM_din;
  reg [31:0] DM_addr;
  reg DM_mem_read;
  reg DM_mem_write;

  // You might need registers to keep the status.
  assign is_ready = is_data_mem_ready;  

  is_input_valid = 0;
  assign addr_tag = addr[31:8];
  assign addr_idx = addr[7:2];
  assign addr_bo = addr[1:0];

  always @(*) begin                 //check hit
    is_hit = direct_cache[addr_idx][129] && (addr_tag == direct_cache[addr_idx][153:130]);
    if(is_hit && mem_read) begin   //mem_read
      is_output_valid <= 1;
      case (addr_bo)
        2'b00 : dout <= direct_cache[addr_idx][31:0];
        2'b01 : dout <= direct_cache[addr_idx][63:32];
        2'b10 : dout <= direct_cache[addr_idx][95:64];
        2'b11 : dout <= direct_cache[addr_idx][127:96];
      endcase
    end
  end

  always @(posedge clk) begin   //synchronous write
    if(is_hit) begin            //cache hit
      if(mem_write) begin       //Write-hit : Write Back
        is_output_valid <= 0;
        if(direct_cache[addr_idx][128]) begin   //dirty bit = 1
        DM_addr <= {direct_cache[addr_idx][153:130], addr_idx, 2'b00} // ?
        case (addr_bo)
          2'b00 : DM_din <= direct_cache[addr_idx][31:0];
          2'b01 : DM_din <= direct_cache[addr_idx][63:32];
          2'b10 : DM_din <= direct_cache[addr_idx][95:64];
          2'b11 : DM_din <= direct_cache[addr_idx][127:96];
        endcase
        end
        case (addr_bo)
        2'b00 : direct_cache[addr_idx][31:0] <= din;
        2'b01 : direct_cache[addr_idx][63:32] <= din;
        2'b10 : direct_cache[addr_idx][95:64] <= din;
        2'b11 : direct_cache[addr_idx][127:96] <= din;
        endcase
      end 
    end else begin                  //cache miss : Write-allocate
      is_output_valid <= 0;
      direct_cache[153:129] <= {addr_tag, 1'b1};
      direct_cache[128] <= 1'b1;
      case (addr_bo)
        2'b00 : direct_cache[addr_idx][31:0] <= din;
        2'b01 : direct_cache[addr_idx][63:32] <= din;
        2'b10 : direct_cache[addr_idx][95:64] <= din;
        2'b11 : direct_cache[addr_idx][127:96] <= din;
      endcase
    end
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(),
    .addr(DM_addr),
    .mem_read(),
    .mem_write(),
    .din(DM_din),
    // is output from the data memory valid?
    .is_output_valid(),
    .dout(),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule

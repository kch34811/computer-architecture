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
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  
  wire [TAG_SIZE-1:0] addr_tag;
  wire [INDEX_SIZE-1:0] addr_idx;
  wire [1:0] addr_bo;
  // Reg declarations
  reg [] cache_line; 

  // You might need registers to keep the status.
  assign addr_tag = addr[31:8];
  assign addr_idx = addr[7:2];
  assign addr_bo = addr[1:0];

  assign is_ready = is_data_mem_ready;

  //Write Back

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(),
    .addr(),
    .mem_read(),
    .mem_write(),
    .din(),
    // is output from the data memory valid?
    .is_output_valid(),
    .dout(),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule

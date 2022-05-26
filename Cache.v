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
  
  wire [`TAG_SIZE-1:0] addr_tag;
  wire [`INDEX_SIZE-1:0] addr_idx;
  wire [1:0] addr_bo;
  // Reg declarations
  reg [`CACHE_LINE_SIZE-1:0] direct_cache[0:2^`INDEX_SIZE]; 
  
  // About Data Memory
  reg DM_is_input_valid;
  reg [31:0] DM_addr;
  reg DM_mem_read;
  reg DM_mem_write;
  reg [127:0] DM_din;
  reg DM_is_output_valid;
  reg [127:0] DM_dout;
  reg DM_mem_ready;

  // You might need registers to keep the status.
  assign is_ready = is_data_mem_ready;  

  is_input_valid = 0;
  assign addr_tag = addr[31:8];
  assign addr_idx = addr[7:2];
  assign addr_bo = addr[1:0];

  always @(*) begin                                 //asynchronous read
    is_hit = direct_cache[addr_idx][VALID_BIT] && (addr_tag == direct_cache[addr_idx][TAG_BIT]);
    if(mem_read) begin
      if(is_hit) begin                                //cache hit
        is_output_valid <= 1;
        case (addr_bo)
        2'b00 : dout <= direct_cache[addr_idx][BLOCK_0];
        2'b01 : dout <= direct_cache[addr_idx][BLOCK_1];
        2'b10 : dout <= direct_cache[addr_idx][BLOCK_2];
        2'b11 : dout <= direct_cache[addr_idx][BLOCK_3];
        endcase
      end else begin                                  //cache miss 
        if(!direct_cache[addr_idx][VALID_BIT]) begin      //valid = 0
          is_output_valid <= 0;
          DM_mem_read <= 1;
          DM_is_input_valid <= 1;
          DM_addr <= {direct_cache[addr_idx][TAG_BIT], addr_idx, 2'b00};
          if(DM_is_output_valid) begin
            direct_cache[addr_idx][VALID_BIT] <= 1;
            direct_cache[addr_idx][127:0] <= DM_dout;
            case (addr_bo)
              2'b00 : dout <= direct_cache[addr_idx][BLOCK_0];
              2'b01 : dout <= direct_cache[addr_idx][BLOCK_1];
              2'b10 : dout <= direct_cache[addr_idx][BLOCK_2];
              2'b11 : dout <= direct_cache[addr_idx][BLOCK_3];
            endcase
            is_output_valid <= 1;
          end   
        end else begin                                    //valid = 1
          if(direct_cache[addr_idx][DIRTY_BIT]) begin       //dirty = 1
            DM_mem_write <= 1;   
            DM_is_input_valid <= 1;
            DM_addr <= {direct_cache[addr_idx][TAG_BIT], addr_idx, 2'b00};
            DM_din <= direct_cache[addr_idx][127:0];
            direct_cache[addr_idx][DIRTY_BIT] <= 0;

            DM_mem_read <= 1;
            DM_addr <= addr;
            if(DM_is_output_valid) begin
              direct_cache[addr_idx][127:0] <= DM_dout;
            end
            case (addr_bo)
              2'b00 : dout <= direct_cache[addr_idx][BLOCK_0];
              2'b01 : dout <= direct_cache[addr_idx][BLOCK_1];
              2'b10 : dout <= direct_cache[addr_idx][BLOCK_2];
              2'b11 : dout <= direct_cache[addr_idx][BLOCK_3];
            endcase
          end else begin                                    //dirty = 0
            case (addr_bo)
              2'b00 : dout <= direct_cache[addr_idx][BLOCK_0];
              2'b01 : dout <= direct_cache[addr_idx][BLOCK_1];
              2'b10 : dout <= direct_cache[addr_idx][BLOCK_2];
              2'b11 : dout <= direct_cache[addr_idx][BLOCK_3];
            endcase
          end
          is_output_valid <= 1;
        end
        direct_cache[addr_idx][TAG_BIT] <= addr_tag;   //update tag
      end     
    end
  end

  always @(posedge clk) begin                       //synchronous write
    if(mem_write) begin 
      is_output_valid <= 0;                          
      if(is_hit) begin                                //cache hit    
        case (addr_bo)
          2'b00 : direct_cache[addr_idx][BLOCK_0] <= din;
          2'b01 : direct_cache[addr_idx][BLOCK_1] <= din;
          2'b10 : direct_cache[addr_idx][BLOCK_2] <= din;
          2'b11 : direct_cache[addr_idx][BLOCK_3] <= din;
        endcase
        direct_cache[addr_idx][DIRTY_BIT] <= 1;
      end else begin                                 //cache miss
        if(!direct_cache[addr_idx][VALID_BIT]) begin   //valid = 0
          case (addr_bo)
            2'b00 : direct_cache[addr_idx][BLOCK_0] <= din;
            2'b01 : direct_cache[addr_idx][BLOCK_1] <= din;
            2'b10 : direct_cache[addr_idx][BLOCK_2] <= din;
            2'b11 : direct_cache[addr_idx][BLOCK_3] <= din;
          endcase
          direct_cache[addr_idx][VALID_BIT] <= 1;
        end else begin                                 //valid = 1
          if(direct_cache[addr_idx][DIRTY_BIT]) begin    //dirty = 1
            DM_mem_write <= 1;   
            DM_is_input_valid <= 1;
            DM_addr <= {direct_cache[addr_idx][TAG_BIT], addr_idx, 2'b00};
            DM_din <= direct_cache[addr_idx][127:0];
            direct_cache[addr_idx][DIRTY_BIT] <= 0;
            case (addr_bo)
              2'b00 : direct_cache[addr_idx][BLOCK_0] <= din;
              2'b01 : direct_cache[addr_idx][BLOCK_1] <= din;
              2'b10 : direct_cache[addr_idx][BLOCK_2] <= din;
              2'b11 : direct_cache[addr_idx][BLOCK_3] <= din;
            endcase
          end else begin                                //dirty = 0;
            case (addr_bo)
              2'b00 : direct_cache[addr_idx][BLOCK_0] <= din;
              2'b01 : direct_cache[addr_idx][BLOCK_1] <= din;
              2'b10 : direct_cache[addr_idx][BLOCK_2] <= din;
              2'b11 : direct_cache[addr_idx][BLOCK_3] <= din;
            endcase
            direct_cache[addr_idx][DIRTY_BIT] <= 1;
          end
        end
        direct_cache[addr_idx][TAG_BIT] <= addr_tag;  //update tag
      end            
    end
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(DM_is_input_valid),
    .addr(DM_addr),
    .mem_read(DM_mem_read),
    .mem_write(DM_mem_write),
    .din(DM_din),
    // is output from the data memory valid?
    .is_output_valid(DM_is_output_valid),
    .dout(DM_dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule

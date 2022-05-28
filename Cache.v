`include "CLOG2.v"
`include "opcodes.v"
`define not_waiting 0
`define is_waiting 1

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 2,
               parameter NUM_WAYS = 2) (
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
  reg [`CACHE_LINE_SIZE-1:0] direct_cache[0:2**`INDEX_SIZE-1]; 
  
  // About Data Memory
  reg DM_is_input_valid;
  reg [31:0] DM_addr;
  reg DM_mem_read;
  reg DM_mem_write;
  reg [127:0] DM_din;
  wire DM_is_output_valid;
  wire [127:0] DM_dout;

  reg waiting_state;

  reg _is_hit;
  reg [31:0] _dout;
  reg _is_output_valid;


  // You might need registers to keep the status.
  assign is_ready = is_data_mem_ready;

  assign addr_tag = addr[31:8];
  assign addr_idx = addr[7:2];
  assign addr_bo = addr[1:0];

  assign is_hit = 1'b1;
  assign is_output_valid = _is_output_valid;
  assign dout = _dout;

  integer i;

  always @(posedge clk) begin
    if (reset) begin
      for(i = 0; i < 64; i = i + 1)
        direct_cache[i] = 0;
      waiting_state = `not_waiting;
    end
  end
 
  always @(*) begin                                 
    if(waiting_state == `not_waiting) begin
      if(!(mem_read|mem_write)) begin
        _is_output_valid <= 1;
      end else begin
        _is_hit <= direct_cache[addr_idx][`VALID_BIT] && (addr_tag == direct_cache[addr_idx][`TAG_BIT]);
        _is_output_valid <= 1;
      end

      if(mem_read) begin                               //asynchronous read
        if(_is_hit) begin                                //cache hit
          case (addr_bo)
            2'b00 : _dout <= direct_cache[addr_idx][`BLOCK_0];
            2'b01 : _dout <= direct_cache[addr_idx][`BLOCK_1];
            2'b10 : _dout <= direct_cache[addr_idx][`BLOCK_2];
            2'b11 : _dout <= direct_cache[addr_idx][`BLOCK_3];
          endcase
        end else begin                                  //cache miss 
          if(!direct_cache[addr_idx][`VALID_BIT] | !direct_cache[addr_idx][`DIRTY_BIT]) begin      //valid = 0 or dirty = 0
            _is_output_valid <= 0;
            DM_mem_read <= 1;
            DM_is_input_valid <= 1;
            DM_addr <= addr;
            waiting_state <= `is_waiting;
          end else begin                                    
            if(direct_cache[addr_idx][`DIRTY_BIT]) begin       // dirty 1
              DM_mem_write <= 1;   
              DM_is_input_valid <= 1;
              DM_addr <= {direct_cache[addr_idx][`TAG_BIT], addr_idx, 2'b00};
              DM_din <= direct_cache[addr_idx][127:0];
              _is_output_valid <= 0;
              waiting_state <= `is_waiting;              
            end 
          end
        end     
      end
    end
  end

  always @(posedge clk) begin                       //synchronous write
    if(waiting_state == `not_waiting) begin
      if(!(mem_read|mem_write)) begin
        _is_output_valid <= 1;
      end else begin
        _is_hit <= direct_cache[addr_idx][`VALID_BIT] && (addr_tag == direct_cache[addr_idx][`TAG_BIT]);
        _is_output_valid <= 1;
      end
      if(mem_write) begin                       
        if(_is_hit) begin                                //cache hit    
          case (addr_bo)
            2'b00 : direct_cache[addr_idx][`BLOCK_0] <= din;
            2'b01 : direct_cache[addr_idx][`BLOCK_1] <= din;
            2'b10 : direct_cache[addr_idx][`BLOCK_2] <= din;
            2'b11 : direct_cache[addr_idx][`BLOCK_3] <= din;
          endcase
          direct_cache[addr_idx][`DIRTY_BIT] <= 1;
        end else begin                                 //cache miss
          if(!direct_cache[addr_idx][`VALID_BIT]) begin   //valid = 0
            direct_cache[addr_idx][`TAG_BIT] <= addr_tag;
            case (addr_bo)
              2'b00 : direct_cache[addr_idx][`BLOCK_0] <= din;
              2'b01 : direct_cache[addr_idx][`BLOCK_1] <= din;
              2'b10 : direct_cache[addr_idx][`BLOCK_2] <= din;
              2'b11 : direct_cache[addr_idx][`BLOCK_3] <= din;
            endcase
            direct_cache[addr_idx][`VALID_BIT] <= 1;
            direct_cache[addr_idx][`DIRTY_BIT] <= 1;
          end else begin                                 //valid = 1
            if(direct_cache[addr_idx][`DIRTY_BIT]) begin    //dirty = 1
              DM_mem_write <= 1;   
              DM_is_input_valid <= 1;
              DM_addr <= {direct_cache[addr_idx][`TAG_BIT], addr_idx, 2'b00};
              DM_din <= direct_cache[addr_idx][127:0];
              _is_output_valid <= 0;
              waiting_state <= `is_waiting;
            end else begin                                //dirty = 0;
              direct_cache[addr_idx][`TAG_BIT] <= addr_tag;
              case (addr_bo)
                2'b00 : direct_cache[addr_idx][`BLOCK_0] <= din;
                2'b01 : direct_cache[addr_idx][`BLOCK_1] <= din;
                2'b10 : direct_cache[addr_idx][`BLOCK_2] <= din;
                2'b11 : direct_cache[addr_idx][`BLOCK_3] <= din;
              endcase
              direct_cache[addr_idx][`DIRTY_BIT] <= 1;
              _is_output_valid <= 1;
            end
          end
        end            
      end
    end
  end

  always @(is_data_mem_ready) begin
    if(waiting_state == `is_waiting) begin
      if(DM_is_output_valid) begin // read done
        DM_mem_read <= 0;
        direct_cache[addr_idx][`VALID_BIT] <= 1;
        direct_cache[addr_idx][`DIRTY_BIT] <= 0;
        direct_cache[addr_idx][127:0] <= DM_dout;
        case (addr_bo)
          2'b00 : _dout <= direct_cache[addr_idx][`BLOCK_0];
          2'b01 : _dout <= direct_cache[addr_idx][`BLOCK_1];
          2'b10 : _dout <= direct_cache[addr_idx][`BLOCK_2];
          2'b11 : _dout <= direct_cache[addr_idx][`BLOCK_3];
        endcase
        DM_is_input_valid <= 0;
        _is_output_valid <= 1;
        direct_cache[addr_idx][`TAG_BIT] <= addr_tag;
        waiting_state <= `not_waiting;
      end else if (is_data_mem_ready) begin // write done
        if(mem_read && direct_cache[addr_idx][`DIRTY_BIT]) begin
            DM_mem_write <= 0;
            _is_output_valid <= 0;
            DM_mem_read <= 1;
            DM_is_input_valid <= 1;
            DM_addr <= addr;
            waiting_state <= `is_waiting;
        end else begin
          DM_mem_write <= 0;
          case (addr_bo)
            2'b00 : direct_cache[addr_idx][`BLOCK_0] <= din;
            2'b01 : direct_cache[addr_idx][`BLOCK_1] <= din;
            2'b10 : direct_cache[addr_idx][`BLOCK_2] <= din;
            2'b11 : direct_cache[addr_idx][`BLOCK_3] <= din;
          endcase
          direct_cache[addr_idx][`TAG_BIT] <= addr_tag;
          direct_cache[addr_idx][`VALID_BIT] <= 1;
          direct_cache[addr_idx][`DIRTY_BIT] <= 1;      
          DM_is_input_valid <= 0;
          _is_output_valid <= 1;
          waiting_state <= `not_waiting;
        end
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

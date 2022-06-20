module read_mem (input logic clk_i,
                 input logic         rst_ni,
                 if_xif.coproc_mem xif_mem,
                 if_xif.coproc_mem_result xif_mem_result,
                 if_rmem.read_mod read_if               
                 );

  enum logic [1:0] {INIT, READ_MEM, WAIT_MEM_RESP, DONE} state_SN, state_SP;

  logic   mem_valid_SN, mem_valid_SP, last_SN, last_SP;
  logic [31:0]          data_read_DN, data_read_DP;

  assign xif_mem.mem_req.last = 1'b0;
  assign xif_mem.mem_valid = mem_valid_SP;
  assign read_if.rdata = data_read_DP;
  
  
  always_comb begin
    state_SN = state_SP;
    mem_valid_SN = mem_valid_SP;

    read_if.done = 1'b0;
    data_read_DN = data_read_DP;
        
    case (state_SP)
      INIT: begin
        if (read_if.start) begin
          state_SN = READ_MEM;
        end
      end
      

      READ_MEM: begin
        mem_valid_SN = 1'b1;
        state_SN = WAIT_MEM_RESP;
      end

      
      WAIT_MEM_RESP: begin
        if (xif_mem_result.mem_result_valid) begin
          state_SN = DONE;
          data_read_DN = xif_mem_result.mem_result.rdata;
          mem_valid_SN = 1'b0;
        end
          
      end

      DONE: begin
        read_if.done = 1'b1;
        state_SN = INIT;
      end
      

      
    endcase
  end // always_comb


  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      mem_valid_SP <= 1'b0;
      data_read_DP <= 32'd0;
      last_SN <= 1'b0;
      data_read_DP <= 0;

      state_SP = INIT;
    end else begin
      mem_valid_SP <= mem_valid_SN;  
      data_read_DP <= data_read_DN;
      last_SP <= last_SN;
      data_read_DP <= data_read_DN;

      state_SP = state_SN;
    end
      
  end

endmodule

module coproc import custom_instr_pkg::*;
  (
   input clk_i,
   input rst_ni,
   if_xif.coproc_compressed xif_compressed,
   if_xif.coproc_issue xif_issue,
   if_xif.coproc_commit xif_commit,
   if_xif.coproc_mem xif_mem,
   if_xif.coproc_mem_result xif_mem_result,
   if_xif.coproc_result xif_result 
   );

  enum   logic [1:0] {INIT, EXECUTE, MEMORY, WRITEBACK} state_SN, state_SP;
  
  logic [31:0] rd_i;
  logic [4:0]  rd_addr_i;
  logic        mem_needed_i;

  logic        ld_op_SN, ld_op_SP;
  logic        cntb_start_SP, cntb_start_SN, wbits_start_SP, wbits_start_SN;
  
  

  assign xif_compressed.compressed_ready = 1'b0;
  assign xif_compressed.compressed_resp.accept = 1'b0;
  assign xif_compressed.compressed_resp.instr = 1'b0;

  //assign xif_issue.issue_ready = issue_ready_p;
  //assign xif_issue.issue_resp.accept = issue_accept_p; //ready 1 and accept 0 to reject all offloaded instrucitons for now
  //assign xif_issue.issue_resp.writeback = 1'b0;
  assign xif_issue.issue_resp.dualwrite = 1'b0;
  assign xif_issue.issue_resp.dualread = 1'b0;
  assign xif_issue.issue_resp.loadstore = ld_op_SP;
  assign xif_issue.issue_resp.ecswrite = 1'b0;
  assign xif_issue.issue_resp.exc = 1'b0;

  assign xif_result.result.id = 0;
  assign xif_result.result.data = rd_i;
  assign xif_result.result.rd = rd_addr_i;
  assign xif_result.result.we = 0;
  assign xif_result.result.ecsdata = 0;
  assign xif_result.result.ecswe = 0;
  assign xif_result.result.exc = 0;
  assign xif_result.result.exccode = 0;
  

  // hardware for cntb instruction
  cntb cntb_i
    (
     .clk_i (clk_i),
     .rst_ni (rst_ni),
     .rd_o (rd_i),
     .xif_issue (xif_issue),
     .rd_addr_o (rd_addr_i)
     );

  // hardware for stroing bits unaligned after decoding
  wbits wbits_i
    ( .clk_i (clk_i),
      .rst_ni (rst_ni),
      .xif_issue (xif_issue),
      .xif_mem (xif_mem),
      .xif_mem_result (xif_mem_result),
      .mem_needed_o (mem_needed_i)
     );
  
  
  // next_state logic
  always_comb begin
    state_SN = state_SP;
    xif_result.result_valid = 1'b0;

    unique case (state_SP)
      INIT: begin
        if (xif_issue.issue_valid) begin
          case (xif_issue.issue_req.instr[6:0])
        
            OPCODE_CNTB: begin
            
              ld_op_SN = 1'b0;
              
            end

            OPCODE_WBITS: begin
              ld_op_SN = 1'b1;
            end
          endcase // case (xif_issue.issue_req.instr[6:0])

          state_SN = EXECUTE;
        end // if (xif_issue.issue_valid)   
      end // case: INIT
      


      
      EXECUTE: begin
        if (xif_issue.issue_ready) begin//exec stage is done
           
          if (mem_needed_i)
            state_SN = MEMORY;
          else
            state_SN = WRITEBACK;
        end
      end

      MEMORY: begin
        if (!mem_needed_i)
          state_SN = WRITEBACK;
      end

      WRITEBACK: begin
        xif_result.result_valid = 1'b1;
        if (xif_result.result_ready)
          state_SN = EXECUTE;
      end
    endcase
      
  end // always_comb
  
  //Datapath
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      state_SP <= INIT;
      cntb_start_SP <= 0;
      wbits_start_SN <= 0;
      ld_op_SP <= 0;
    end else begin
      state_SP <= state_SN;
      cntb_start_SP <= cntb_start_SN;
      wbits_start_SP <= wbits_start_SN;
      ld_op_SP <= ld_op_SN;
    end
  end
  
  
endmodule

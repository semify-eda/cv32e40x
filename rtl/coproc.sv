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


  logic                      issue_ready_n, issue_ready_p;
  logic                      issue_accept_n, issue_accept_p;
                      
  

  assign xif_compressed.compressed_ready = 1'b0;
  assign xif_compressed.compressed_resp.accept = 1'b0;
  assign xif_compressed.compressed_resp.instr = 1'b0;

  //assign xif_issue.issue_ready = issue_ready_p;
  //assign xif_issue.issue_resp.accept = issue_accept_p; //ready 1 and accept 0 to reject all offloaded instrucitons for now
  assign xif_issue.issue_resp.writeback = 1'b0;
  assign xif_issue.issue_resp.dualwrite = 1'b0;
  assign xif_issue.issue_resp.dualread = 1'b0;
  assign xif_issue.issue_resp.loadstore = 1'b0;
  assign xif_issue.issue_resp.ecswrite = 1'b0;
  assign xif_issue.issue_resp.exc = 1'b0;

  assign xif_mem.mem_req.id = 0;
  assign xif_mem.mem_req.addr = 0;
  assign xif_mem.mem_req.mode = 0;
  assign xif_mem.mem_req.we = 0;
  assign xif_mem.mem_req.be = 0;
  assign xif_mem.mem_req.wdata = 0;
  assign xif_mem.mem_req.last = 0;
  assign xif_mem.mem_req.spec = 0;
  
  assign xif_mem.mem_valid = 1'b0;

  assign xif_result.result_valid = 1'b0;

  assign xif_result.result.id = 0;
  assign xif_result.result.data = 0;
  assign xif_result.result.rd = 0;
  assign xif_result.result.we = 0;
  assign xif_result.result.ecsdata = 0;
  assign xif_result.result.ecswe = 0;
  assign xif_result.result.exc = 0;
  assign xif_result.result.exccode = 0;

  enum                       logic [1:0] {EXECUTE, WRITEBACK} state_SN, state_SP;

  logic                   [31:0]   rd_DI;
  

  custom_ex_stage custom_ex_stage_i
    (
     .clk_i (clk_i),
     .rst_ni (rst_ni),
     .rd_o (rd_DI),
     .xif_issue (xif_issue)
     );
  
  
  // next_state logic
  always_comb begin
    state_SN = state_SP;

    unique case (state_SP)
      
      EXECUTE: begin
        state_SN = WRITEBACK; // only one clk cycle exec
      end

      WRITEBACK: begin
        
      end
    endcase
      
  end // always_comb
  
  //Datapath
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      state_SP <= EXECUTE;
    end else begin
      state_SP <= state_SN;
    end
  end
  
  
endmodule

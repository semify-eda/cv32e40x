module read_sig_instr (input clk_i,
                       input rst_ni,
                       if_xif.coproc_compressed    xif_compressed,
                       if_xif.coproc_issue         xif_issue,
                       if_xif.coproc_commit        xif_commit,
                       if_xif.coproc_mem           xif_mem,
                       if_xif.coproc_mem_result    xif_mem_result,
                       if_xif.coproc_result        xif_result );


  logic                      issue_ready_n, issue_ready_p;
  logic                      issue_accept_n, issue_accept_p;
  logic [31:0]               instr_n, instr_p;
                      
  

  assign xif_compressed.compressed_ready = 1'b0;
  assign xif_compressed.compressed_resp.accept = 1'b0;
  assign xif_compressed.compressed_resp.instr = 1'b0;

  assign xif_issue.issue_ready = 1'b1;
// issue_ready_p;
  assign xif_issue.issue_resp.accept = 1'b1; //issue_accept_p; //ready 1 and accept 0 to reject all offloaded instrucitons for now
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

  assign xif_result.result_valid = 1'b1;

  assign xif_result.result.id = 0;
  assign xif_result.result.data = 0;
  assign xif_result.result.rd = 0;
  assign xif_result.result.we = 0;
  assign xif_result.result.ecsdata = 0;
  assign xif_result.result.ecswe = 0;
  assign xif_result.result.exc = 0;
  assign xif_result.result.exccode = 0;

  always_comb begin
    issue_ready_n = 1'b0;
    issue_accept_n = 1'b0;
    instr_n = xif_issue.issue_req.instr;
    
    if (xif_issue.issue_valid) begin
      issue_ready_n = 1'b1;
      instr_n = instr_p; //store instruction as long as valid is high
                         // cuz it is undefeined as soon as valid is high
      if (instr_p[7:0] == 8'h6f) begin
        issue_accept_n = 1'b1;
        issue_ready_n = 1'b1;
      end
    end        
      
  end
    

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      issue_ready_p <= 1'b0;
      issue_accept_p <= 1'b0;
      instr_p <= 32'h0;
    end else begin
      issue_ready_p <= issue_ready_n;
      issue_accept_p <= issue_accept_n;
      instr_p <= instr_n;      
    end
  end
  
  
endmodule

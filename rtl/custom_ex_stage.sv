module custom_ex_stage import custom_instr_pkg::*;
   (
    input logic         clk_i,
    input logic         rst_ni,
    output logic [31:0] rd_o,
    if_xif.coproc_issue xif_issue
   );     

  always_comb begin
    xif_issue.issue_resp.accept = 1'b0; // rekect instruction incase unknown
    xif_issue.issue_ready = 1'b0;
    
    unique case (xif_issue.issue_req.instr[6:0])
      OPCODE_CNTB: begin
        xif_issue.issue_resp.accept = 1'b1;
        xif_issue.issue_ready = 1'b1;

        
      end
      endcase // unique case (opcode)
  end

endmodule

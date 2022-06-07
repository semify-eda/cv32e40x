module custom_ex_stage import custom_instr_pkg::*;
   (
    input logic         clk_i,
    input logic         rst_ni,
    output logic [31:0] rd_o,
    if_xif.coproc_issue xif_issue,
    output logic [4:0] rd_addr_o
   );    

  logic                 issue_ready_SP, issue_ready_SN;
  logic [31:0]          rd_DP, rd_DN;
  logic [4:0]           rd_addr_DP, rd_addr_DN;

  logic [31:0]          rs0, rs1;
  

  assign xif_issue.issue_ready = issue_ready_SP;
  assign rd_o = rd_DP;
  assign rd_addr_o = rd_addr_DP;

  assign rs0[31:0] = xif_issue.issue_req.rs[0];
  assign rs1[31:0] = xif_issue.issue_req.rs[1];
  
  
  
  always_comb begin
    issue_ready_SN = 1'b0;
    xif_issue.issue_resp.accept = 1'b0;
    xif_issue.issue_resp.writeback = 1'b0;
    rd_addr_DN = rd_addr_DP;
        
    case (xif_issue.issue_req.instr[6:0])
      OPCODE_CNTB: begin
        xif_issue.issue_resp.accept = 1'b1;
        xif_issue.issue_resp.writeback = 1'b1;
        rd_addr_DN = xif_issue.issue_req.instr[11:7];
                
        issue_ready_SN = 1'b1;
      end
      endcase // unique case (opcode)
  end // always_comb

  logic [31:0] top_4_bit, top_3_bit, top_2_bit;
  logic [31:0] top_bits_set [4];
  
  logic [8:0] right_shift;
  

  assign top_4_bit = 32'hF0000000;
  assign top_3_bit = 32'he0000000;
  assign top_2_bit = 32'hc0000000;

  assign top_bits_set[0] = 32'hF0000000;
  

  assign right_shift = 31-rs1;

  genvar      i;
  
  
  //exec  logic for cntb instruction
  always_comb begin
    rd_DN = rd_DP;
    
    if (issue_ready_SP == 0) begin
      if (rs0[rs1] == 1'b1) begin
        // count consecutive 1 bits
    
        
        if ((rs0 & ((top_4_bit)>>right_shift)) == top_4_bit>>right_shift)
          rd_DN = 31'd4;
        else if ((rs0 & ((top_3_bit)>>right_shift)) == top_3_bit>>right_shift)
          rd_DN = 31'd3;
        else if ((rs0 & ((top_2_bit)>>right_shift)) == top_2_bit>>right_shift)
          rd_DN = 31'd2;
        else
          rd_DN = 31'd1;
      end else begin
        rd_DN = 0;
      end
    end
    
  end
  

   always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      issue_ready_SP <= 0;
      rd_DP <= 0;
      rd_addr_DP <= 0;
    end else begin
      rd_DP <= rd_DN;
      issue_ready_SP <= issue_ready_SN;
      rd_addr_DP <= rd_addr_DN;
    end
  end

endmodule

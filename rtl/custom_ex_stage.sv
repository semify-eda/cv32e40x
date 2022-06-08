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
  logic [31:0] top_bits_set [3:0];
  
  logic [6:0] right_shift;
  logic [31:0] result_cntb [3:0];
  
  

  assign right_shift = 31 - rs1;

   genvar      geni;
   generate
     for (geni = 0; geni < 3; geni = geni + 1) begin
       count_bits #(.top_many_bits (geni)) cb
       (
        .rs0_i (rs0),
        .right_shift_i (right_shift),
        .top_bits_set_i (top_bits_set[geni]),
        .result_o (result_cntb[geni])
        );
     end
   endgenerate
 
  
  integer     i;  
  //exec  logic for cntb instruction
  always_comb begin
    rd_DN = rd_DP;
    top_bits_set[0] = 32'hF0000000;

    for (i = 0; i < 3; i = i + 1) begin
      top_bits_set[i + 1] = top_bits_set[0] << (i + 1);
    end
    
    if (issue_ready_SP == 0) begin
      if (rs0[rs1] == 1'b1) begin
        // count consecutive 1 bits
        if ((rs0 & result_cntb[0]) == top_bits_set[0]>>right_shift)
          rd_DN = 32'd4;
        else if ((rs0 & result_cntb[1]) == top_bits_set[1]>>right_shift)
          rd_DN = 32'd3;
        else if ((rs0 & result_cntb[2]) == top_bits_set[2]>>right_shift)
          rd_DN = 32'd2;
        else
          rd_DN = 32'd1;    
      end else if (rs0[rs1] == 1'b0) begin // if (rs0[rs1] == 1'b1)
        // count consecutive 0 bits
        if ((rs0 & result_cntb[0]) == 32'd0)
          rd_DN = 32'd4;
        else if ((rs0 & result_cntb[1]) == 32'd0)
          rd_DN = 32'd3;
        else if ((rs0 & result_cntb[2]) == 32'd0)
          rd_DN = 32'd2;
        else
          rd_DN = 32'd1;   
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

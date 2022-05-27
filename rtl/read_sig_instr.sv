module read_sig_instr (input clk_i,
                       input rst_ni,
                       if_xif.coproc_issue xif_issue );


  //assign xif_issue.issue_ready = 1'b1;

  
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
    end else begin
      if (xif_issue.issue_req != 0)
        $display("xif_issue = %h", xif_issue.issue_req);
      
    end
      
  end

  
endmodule

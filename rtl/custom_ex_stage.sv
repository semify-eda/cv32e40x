module custom_ex_stage import custom_instr_pkg::*;
   (
    input logic         clk_i,
    input logic         rst_ni,
    input logic         issue_valid_i,
    input logic [31:0]  rs1_i,
    input logic [31:0]  rs2_i,
    input logic [6:0]   opcode_i,
    output logic [31:0] rd_o,
    output logic        accept_instr_o,
    output logic issue_ready_o
   );     

  always_comb begin
    accept_instr_o = 1'b0; // rekect instruction incase unknown
    issue_ready_o = 1'b0;
    
    unique case (opcode_i)
      OPCODE_CNTB: begin
        accept_instr_o = 1'b1;
        issue_ready_o = 1'b1;
      end
      endcase // unique case (opcode)
  end

endmodule

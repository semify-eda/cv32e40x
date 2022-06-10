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

  
  logic [31:0] top_bits_set [7:0];
  
  logic [6:0] right_shift_DP, right_shift_DN;
  logic [31:0] result_cntb [7:0];

  enum         logic [1:0]  {INIT, EXEC, DONE} state_SN, state_SP;
  

  assign xif_issue.issue_ready = issue_ready_SP;
  assign rd_o = rd_DP;
  assign rd_addr_o = rd_addr_DP;

  assign rs0[31:0] = xif_issue.issue_req.rs[0];
  assign rs1[31:0] = xif_issue.issue_req.rs[1];

  genvar       geni;
  generate
    for (geni = 0; geni < 7; geni = geni + 1) begin
      count_bits #(.top_many_bits (geni)) cb
                (
                 .rs0_i (rs0),
                 .right_shift_i (right_shift_DP),
                 .top_bits_set_i (top_bits_set[geni]),
                 .result_o (result_cntb[geni])
                 );
    end
  endgenerate


  integer     i;  
  //datapath
  always_comb begin
    rd_DN = rd_DP;
    top_bits_set[0] = 32'hFF000000;
    right_shift_DN = right_shift_DP;
    issue_ready_SN = issue_ready_SP;
    rd_addr_DN = 32'd0;

    state_SN = state_SP;

    xif_issue.issue_resp.writeback = 1'b1;
    xif_issue.issue_resp.accept = 1'b1;
    
    for (i = 0; i < 7; i = i + 1) begin
      top_bits_set[i + 1] = top_bits_set[0] << (i + 1);
    end

    case (state_SP)
      INIT: begin
        if (xif_issue.issue_valid) begin
          right_shift_DN = 31 - rs1;
          rd_DN = 32'd0; // TODO: find better way to set zero

          if (xif_issue.issue_valid && (xif_issue.issue_req.instr[6:0] == OPCODE_CNTB)) begin
            state_SN = EXEC;
            rd_addr_DN = xif_issue.issue_req.instr[11:7];
          end
        end
      end

      EXEC: begin
        state_SN = DONE;
        issue_ready_SN = 1'b1;
        if (rs0[rs1] == 1'b1) begin
          // count consecutive 1 bits
          if (result_cntb[0] == top_bits_set[0]>>right_shift_DP && (right_shift_DP < 25)) begin
            rd_DN += 32'd8;
            right_shift_DN = right_shift_DP + 8;
            if (rs0[31-rd_DN] == 1'b1) begin
              state_SN = EXEC;
              issue_ready_SN = 1'b0;
            end else begin
              state_SN = DONE;
              issue_ready_SN = 1'b1;
            end
          end
          else if (result_cntb[1] == top_bits_set[1]>>right_shift_DP  && (right_shift_DP < 26))
            rd_DN += 32'd7;
          else if (result_cntb[2] == top_bits_set[2]>>right_shift_DP  && (right_shift_DP < 27))
            rd_DN += 32'd6;
          else if (result_cntb[3] == top_bits_set[3]>>right_shift_DP  && (right_shift_DP < 28))
            rd_DN += 32'd5;
          else if (result_cntb[4] == top_bits_set[4]>>right_shift_DP  && (right_shift_DP < 29))
            rd_DN += 32'd4;
          else if (result_cntb[5] == top_bits_set[5]>>right_shift_DP  && (right_shift_DP < 30))
            rd_DN += 32'd3;
          else if (result_cntb[6] == top_bits_set[6]>>right_shift_DP  && (right_shift_DP < 31))
            rd_DN += 32'd2;
          else
            rd_DN += 32'd1;    
        end else if (rs0[rs1] == 1'b0) begin // if (rs0[rs1] == 1'b1)
          // count consecutive 0 bits
          if (result_cntb[0] == 32'd0 && (right_shift_DP < 25)) begin
            rd_DN += 32'd8;
            right_shift_DN = right_shift_DP + 8;
            if (rs0[31-rd_DN] == 1'b0) begin
              state_SN = EXEC;
              issue_ready_SN = 1'b0;
            end else begin
              state_SN = DONE;
              issue_ready_SN = 1'b1;
            end
          end
          else if (result_cntb[1] == 32'd0  && (right_shift_DP < 26))
            rd_DN += 32'd7;
          else if (result_cntb[2] == 32'd0  && (right_shift_DP < 27))
            rd_DN += 32'd6;
          else if (result_cntb[3] == 32'd0  && (right_shift_DP < 28))
            rd_DN += 32'd5;
          else if (result_cntb[4] == 32'd0  && (right_shift_DP < 29))
            rd_DN += 32'd4;
          else if (result_cntb[5] == 32'd0 && (right_shift_DP < 30))
            rd_DN += 32'd3;
          else if (result_cntb[6] == 32'd0 && (right_shift_DP < 31))
            rd_DN += 32'd2;
          else
            rd_DN += 32'd1; 
        end // if (rs0[rs1] == 1'b0)
        
      end // case: EXEC

      DONE: begin
        issue_ready_SN = 1'b0;
        state_SN = INIT;
      end
      
    endcase
      
  end // always_comb

  //state sequential logic
  always_ff @(posedge clk_i, negedge rst_ni) begin
     if (!rst_ni) begin
      state_SP <= INIT;
    end else begin
      state_SP <= state_SN;
    end
  end
  

   always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      issue_ready_SP <= 0;
      rd_DP <= 0;
      rd_addr_DP <= 0;
      right_shift_DP <= 0;
    end else begin
      rd_DP <= rd_DN;
      issue_ready_SP <= issue_ready_SN;
      rd_addr_DP <= rd_addr_DN;
      right_shift_DP <= right_shift_DN;
    end
  end

endmodule

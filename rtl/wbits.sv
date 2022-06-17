module wbits import custom_instr_pkg::*;
  (
   input logic         clk_i,
   input logic         rst_ni,
   input logic start_i,
   if_xif.coproc_issue xif_issue,
   if_xif.coproc_mem xif_mem,
   if_xif.coproc_mem_result xif_mem_result,
   output logic        mem_needed_o,
   output logic done_o
   );



  enum                              logic [1:0] {INIT, EXEC, DONE} state_SN, state_SP;

  logic                             mem_needed_SP, mem_needed_SN;
  // load store signal issue response say that memory acces is needed
  logic                             ls_resp_SN, ld_resp_SP;

  // signal done if done state is reached
  assign done_o = (state_SP==DONE) ? 1'b1 : 1'b0;
  assign mem_needed_o = mem_needed_SP;
  
                                                                                                  
 

  
  always_comb begin
    state_SN = state_SP;
    mem_needed_SN = 1'b0;
    
    case (state_SP)
      INIT: begin
        if (start_i) begin
          state_SN = EXEC;
          
          mem_needed_SN = 1'b1;
        end
      end


      EXEC: begin
        

      end

      DONE: begin
      end
      
    endcase
  end // always_comb
  

  

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_SP <= INIT;
      mem_needed_SP <= 0;
    end else begin
      state_SP <= state_SN;
      mem_needed_SP <= mem_needed_SN;
    end
  end




endmodule

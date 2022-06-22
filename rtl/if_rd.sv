interface if_rd ()
  modport instr_rd ( input rd_i,
                     output rd_o
                     );

  modport coproc_rd ( input rd_o,
                      output rd_i
                      );
endinterface

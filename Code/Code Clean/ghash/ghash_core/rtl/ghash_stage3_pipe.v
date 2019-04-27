module ghash_stage3_pipe
#(
    parameter                                       NB_BLOCK    = 128               ,
    parameter                                       N_BLOCKS    = 2                 ,
    parameter                                       NB_DATA     = N_BLOCKS*NB_BLOCK
)
(
    // OUTPUTS
    output  reg     [ NB_BLOCK-1:0  ]               o_mod_prod  ,
    output  reg     [ NB_BLOCK-1:0  ]               o_feedback  ,
    // INPUTS
    input   wire    [ NB_BLOCK-1:0  ]               i_mod_prod  ,
    input   wire    [ NB_BLOCK-1:0  ]               i_feedback  ,
    input   wire                                    i_valid     ,
    input   wire                                    i_reset     ,
    input   wire                                    i_clock
);

// QUICK INSTANCE: BEGIN
/*
 ghash_stage3_pipe
#(
    .NB_BLOCK       (  ),
    .N_BLOCKS       (  ),
    .NB_DATA        (  )
)
u_ghash_stage3_pipe
(
    .o_mod_prod     (  ),
    .o_feedback     (  ),
    .i_mod_prod     (  ),
    .i_feedback     (  ),
    .i_valid        (  ),
    .i_reset        (  ),
    .i_clock        (  )
);
*/  // QUICK INSTANCE: END

always @( posedge i_clock ) begin
    if ( i_reset )  // cad_ence map_to_mux
    begin
        o_mod_prod  <= { NB_BLOCK{1'b0} }   ;
        o_feedback  <= { NB_BLOCK{1'b0} }   ;
    end else if ( i_valid ) begin
        o_mod_prod  <= i_mod_prod           ;
        o_feedback  <= i_feedback           ;
    end
end

endmodule
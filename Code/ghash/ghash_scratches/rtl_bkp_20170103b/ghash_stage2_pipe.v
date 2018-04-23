module ghash_stage2_pipe
#(
    parameter                                       NB_BLOCK    = 128 ,
    parameter                                       N_BLOCKS    = 2 ,
    parameter                                       NB_DATA     = N_BLOCKS*NB_BLOCK
)
(
    // OUTPUTS
    output      reg     [NB_DATA-1-1:0]             o_prod_even ,
    output      reg     [NB_DATA-1-1:0]             o_prod_odd ,
    output      reg                                 o_stall ,
    // INPUTS
    input       wire    [NB_DATA-1-1:0]             i_prod_even ,
    input       wire    [NB_DATA-1-1:0]             i_prod_odd ,
    input       wire                                i_stall ,
    input       wire                                i_valid ,
    input       wire                                i_reset ,
    input       wire                                i_clock
) ;

    // QUICK INSTANCE: BEGIN
    /*
    ghash_stage2_pipe
    #(
        .NB_BLOCK       (  ) ,
        .N_BLOCKS       (  ) ,
        .NB_DATA        (  )
    )
    u_ghash_stage2_pipe
    (
        .o_prod_even    (  ) ,
        .o_prod_odd     (  ) ,
        .o_stall        (  ) ,
        .i_prod_even    (  ) ,
        .i_prod_odd     (  ) ,
        .i_stall        (  ) ,
        .i_valid        (  ) ,
        .i_reset        (  ) ,
        .i_clock        (  )
    ) ;
    */  // QUICK INSTANCE: END

    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            o_prod_even     <=  { (NB_DATA-1){1'b0} } ;
            o_prod_odd      <=  { (NB_DATA-1){1'b0} } ;
            o_stall         <=  1'b0 ;
        end else if ( i_valid ) begin
            o_prod_even     <=  i_prod_even ;
            o_prod_odd      <=  i_prod_odd ;
            o_stall         <=  i_stall ;
        end
    end

endmodule
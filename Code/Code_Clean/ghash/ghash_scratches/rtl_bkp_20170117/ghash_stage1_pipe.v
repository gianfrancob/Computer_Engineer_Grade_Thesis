module ghash_stage1_pipe
#(
    parameter                                       NB_BLOCK    = 128 ,
    parameter                                       N_BLOCKS    = 2 ,
    parameter                                       NB_DATA     = N_BLOCKS*NB_BLOCK
)
(
    // OUTPUTS
    output      reg     [NB_BLOCK-1:0]              o_h_pow_even ,
    output      reg     [NB_BLOCK-1:0]              o_h_pow_odd ,
    output      reg     [NB_BLOCK-1:0]              o_feedback_mux ,
    output      reg     [NB_BLOCK-1:0]              o_data_x_even ,
    output      reg     [NB_BLOCK-1:0]              o_data_x_odd ,
    output      reg                                 o_stall ,
    // INPUTS
    input       wire    [NB_BLOCK-1:0]              i_feedback_mux ,
    input       wire    [NB_BLOCK-1:0]              i_data_x_even ,
    input       wire    [NB_BLOCK-1:0]              i_data_x_odd ,
    input       wire    [NB_DATA-1:0]               i_h_pow_pair ,
    input       wire                                i_stall ,
    input       wire                                i_valid ,
    input       wire                                i_reset ,
    input       wire                                i_clock
) ;
    // QUICK INSTANCE: BEGIN
    /*
    ghash_stage1_pipe
    #(
        .NB_BLOCK       (  ) ,
        .N_BLOCKS       (  ) ,
        .NB_DATA        (  )
    )
    u_ghash_stage1_pipe
    (
        .o_h_pow_even   (  ) ,
        .o_h_pow_odd    (  ) ,
        .o_feedback_mux (  ) ,
        .o_data_x_even  (  ) ,
        .o_data_x_odd   (  ) ,
        .o_stall        (  ) ,
        .i_feedback_mux (  ) ,
        .i_data_x_even  (  ) ,
        .i_data_x_odd   (  ) ,
        .i_h_pow_pair   (  ) ,
        .i_stall        (  ) ,
        .i_valid        (  ) ,
        .i_reset        (  ) ,
        .i_clock        (  )
    ) ;
    */  // QUICK INSTANCE: END

    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            o_h_pow_even    <=  { NB_BLOCK{1'b0} } ;
            o_h_pow_odd     <=  { NB_BLOCK{1'b0} } ;
            o_feedback_mux  <=  { NB_BLOCK{1'b0} } ;
            o_data_x_even   <=  { NB_BLOCK{1'b0} } ;
            o_data_x_odd    <=  { NB_BLOCK{1'b0} } ;
            o_stall         <=  1'b0 ;
        end else if ( i_valid ) begin
            o_h_pow_even    <=  i_h_pow_pair[1*NB_BLOCK+:NB_BLOCK] ;
            o_h_pow_odd     <=  i_h_pow_pair[0*NB_BLOCK+:NB_BLOCK] ;
            o_feedback_mux  <=  i_feedback_mux ;
            o_data_x_even   <=  i_data_x_even ;
            o_data_x_odd    <=  i_data_x_odd ;
            o_stall         <=  i_stall ;
        end
    end

endmodule
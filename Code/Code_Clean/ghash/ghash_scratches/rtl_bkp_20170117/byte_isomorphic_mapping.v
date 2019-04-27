module byte_isomorphic_mapping
#(
    // PARAMETERS
    parameter                                   NB_DATA = 8         // [HINT] Works only if value is 8
)
(
    // OUTPUTS.
    output      wire        [NB_DATA-1:0]       o_delta ,
    // INPUTS.
    input       wire        [NB_DATA-1:0]       i_q
) ;

    // QUICK_INSTANCE: BEGIN
    /*
    byte_isomorphic_mapping
    #(
        .NB_DATA            (  )    // [HINT] Works only if value is 8
    )
    u_byte_isomorphic_mapping
    (
        .o_delta            (  ) ,
        .i_q                (  )
    ) ;
    */ // QUICK_INSTANCE: END

    // ALGORITHM BEGIN.
    assign o_delta[7]   =   i_q[7] ^                i_q[5]                                                              ;

    assign o_delta[6]   =   i_q[7] ^    i_q[6] ^                i_q[4] ^    i_q[3] ^    i_q[2] ^    i_q[1]              ;

    assign o_delta[5]   =   i_q[7] ^                i_q[5] ^                i_q[3] ^    i_q[2]                          ;

    assign o_delta[4]   =   i_q[7] ^                i_q[5] ^                i_q[3] ^    i_q[2] ^    i_q[1]              ;

    assign o_delta[3]   =   i_q[7] ^    i_q[6] ^                                        i_q[2] ^    i_q[1]              ;

    assign o_delta[2]   =   i_q[7] ^                            i_q[4] ^    i_q[3] ^    i_q[2] ^    i_q[1]              ;

    assign o_delta[1]   =               i_q[6] ^                i_q[4] ^                            i_q[1]              ;

    assign o_delta[0]   =               i_q[6] ^                                                    i_q[1] ^    i_q[0]  ;

endmodule // byte_isomorphic_mapping

module byte_inverse_isomorphic_mapping
#(
    // PARAMETERS
    parameter                                   NB_DATA = 8     // [HINT] Works only if value is 8
)
(
    // OUTPUTS.
    output      wire        [NB_DATA-1:0]       o_inv_delta ,
    // INPUTS.
    input       wire        [NB_DATA-1:0]       i_q
) ;

    // QUICK_INSTANCE: BEGIN
    /*
    byte_inverse_isomorphic_mapping
    #(
        .NB_DATA            (  )    // [HINT] Works only if value is 8
    )
    u_byte_inverse_isomorphic_mapping
    (
        .o_inv_delta        (  ) ,
        .i_q                (  )
    ) ;
    */ // QUICK_INSTANCE: END

    // ALGORITHM BEGIN.
    /*// Inverse Isomorphic Mapping ONLY
    assign o_inv_delta[7]   =   i_q[7] ^    i_q[6] ^    i_q[5] ^                                        i_q[1]          ;

    assign o_inv_delta[6]   =               i_q[6] ^                                        i_q[2]                      ;

    assign o_inv_delta[5]   =               i_q[6] ^    i_q[5] ^                                        i_q[1]          ;

    assign o_inv_delta[4]   =               i_q[6] ^    i_q[5] ^    i_q[4] ^                i_q[2] ^    i_q[1]          ;

    assign o_inv_delta[3]   =                           i_q[5] ^    i_q[4] ^    i_q[3] ^    i_q[2] ^    i_q[1]          ;

    assign o_inv_delta[2]   =   i_q[7] ^                            i_q[4] ^    i_q[3] ^    i_q[2] ^    i_q[1]          ;

    assign o_inv_delta[1]   =                           i_q[5] ^    i_q[4]                                              ;

    assign o_inv_delta[0]   =               i_q[6] ^    i_q[5] ^    i_q[4] ^                i_q[2] ^            i_q[0]  ;
    */

    // Inverse Isomorphic Mapping w/ Affine Transformation
    assign o_inv_delta[0]   =   i_q[7] ^    i_q[6] ^                                        i_q[2] ^    i_q[1] ^    i_q[0]  ;

    assign o_inv_delta[7]   =   i_q[7] ^                                        i_q[3] ^    i_q[2]                          ;

    assign o_inv_delta[6]   =   i_q[7] ^    i_q[6] ^    i_q[5] ^    i_q[4]                                                  ;

    assign o_inv_delta[5]   =   i_q[7] ^                                                    i_q[2]                          ;

    assign o_inv_delta[4]   =   i_q[7] ^                            i_q[4] ^                            i_q[1] ^    i_q[0]  ;

    assign o_inv_delta[3]   =                                                               i_q[2] ^    i_q[1] ^    i_q[0]  ;

    assign o_inv_delta[2]   =               i_q[6] ^    i_q[5] ^    i_q[4] ^    i_q[3] ^    i_q[2]             ^    i_q[0]  ;

    assign o_inv_delta[1]   =   i_q[7] ^                                                                            i_q[0]  ;

endmodule // byte_inverse_isomorphic_mapping
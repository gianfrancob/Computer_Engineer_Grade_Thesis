module gf_2to2_multiplier_with_constant_phi
#(
    // PARAMETERS.
    parameter                                   NB_DATA = 2     // [HINT] Works only if value is 2
)
(
    // OUTPUTS.
    output      wire        [NB_DATA-1:0]       o_x_times_phi ,
    // INPUTS.
    input       wire        [NB_DATA-1:0]       i_x
) ;
    //  QUICK_INSTANCE: BEGIN
    /*
    gf_2to2_multiplier_with_constant_phi
    #(
        .NB_DATA        ( NB_DATA/2 )
    )
    u_gf_2to2_multiplier_with_constant_phi
    (
        .o_x_times_phi  (           ),
        .i_x            (           )
    ) ;
    */ // QUICK_INSTANCE: END

    // ALGORITHM BEGIN
    assign o_x_times_phi[1] = i_x[1] ^  i_x[0]  ;

    assign o_x_times_phi[0] = i_x[1]            ;

endmodule // gf_2to2_multiplier_with_constant_phi

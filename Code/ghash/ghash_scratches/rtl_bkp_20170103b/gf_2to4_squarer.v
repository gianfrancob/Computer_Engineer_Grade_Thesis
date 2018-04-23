module gf_2to4_squarer
#(
    // PARAMETERS
    parameter                                       NB_DATA = 4         // [HINT] Works only if value is 4
)
(
    // OUTPUTS.
    output      wire        [NB_DATA-1:0]           o_xto2,
    // INPUTS.
    input       wire        [NB_DATA-1:0]           i_x
) ;
    // QUICK_INSTANCE: BEGIN
    /*
    gf_2to4_squarer
    #(
        .NB_DATA            (  )    // [HINT] Works only if value is 4
    )
    u_gf_2to4_squarer
    (
        .o_xto2             (  ),
        .i_x                (  )
    );
    */ // QUICK_INSTANCE: END

    // ALGORITHM BEGIN
    assign o_xto2[3]    =   i_x[3]                                      ;

    assign o_xto2[2]    =   i_x[3] ^    i_x[2]                          ;

    assign o_xto2[1]    =               i_x[2] ^    i_x[1]              ;

    assign o_xto2[0]    =   i_x[3] ^                i_x[1] ^    i_x[0]  ;

endmodule // gf_2to4_squarer

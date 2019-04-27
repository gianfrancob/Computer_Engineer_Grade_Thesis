module gf_2to4_multiplier_with_constant_lambda
#(
    // PARAMETERS
    parameter                                     NB_DATA = 4    // [HINT] Works only if value is 4
)
(
    // OUTPUTS.
    output          wire      [NB_DATA-1:0]       o_x_times_lambda,
    // INPUTS.
    input           wire      [NB_DATA-1:0]       i_x
) ;

    // QUICK_INSTANCE: BEGIN
    /*
    gf_2to4_multiplier_with_constant_lambda
    #(
        .NB_DATA            (  )    // [HINT] Works only if value is 4
    )
    u_gf_2to4_multiplier_with_constant_lambda
    (
        .o_x_times_lambda   (  ),
        .i_x                (  )
    );
    */ // QUICK_INSTANCE: END

    // ALGORITHM BEGIN
    assign o_x_times_lambda[3]     =              i_x[2] ^            i_x[0]  ;
    
    assign o_x_times_lambda[2]     =    i_x[3] ^  i_x[2] ^  i_x[1] ^  i_x[0]  ;
    
    assign o_x_times_lambda[1]     =    i_x[3]                                ;
    
    assign o_x_times_lambda[0]     =              i_x[2]                      ;

endmodule // gf_2to4_multiplier_with_constant

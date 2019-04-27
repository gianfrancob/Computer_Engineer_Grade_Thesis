module gf_2to2_multiplier
#(
    // PARAMETERS.
    parameter                                       NB_DATA = 2     // [HINT] Works only if value is 2
)
(
    // OUTPUTS.
    output  wire        [ NB_DATA-1:0   ]           o_prod  ,
    // INPUTS.
    input   wire        [ NB_DATA-1:0   ]           i_x     ,
    input   wire        [ NB_DATA-1:0   ]           i_y
);
// QUICK_INSTANCE: BEGIN
/*
gf_2to2_multiplier
#(
    .NB_DATA    (  )    // [HINT] Works only if value is 2
)
u_gf_2to2_multiplier_h
(
    .o_prod     (  ),
    .i_x        (  ),
    .i_y        (  )
) ;
*/ // QUICK_INSTANCE: END

// ALGORITHM BEGIN.
assign o_prod[1]    =   ( i_x[1] & i_y[1] ) ^   ( i_x[0] & i_y[1] ) ^   ( i_x[1] & i_y[0] )                         ;

assign o_prod[0]    =   ( i_x[1] & i_y[1] ) ^                                                   ( i_x[0] & i_y[0] ) ;

endmodule // gf_2to2_multiplier

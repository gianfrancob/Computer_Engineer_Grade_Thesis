module gf_2to4_multiplicative_inversion
#(
    // PARAMETERS.
    parameter                                   NB_DATA = 4     // [HINT] Works only if value is 4
)
(
    // OUTPUTS.
    output  wire        [ NB_DATA-1:0   ]       o_inv_q ,
    // INTPUTS.
    input   wire        [ NB_DATA-1:0   ]       i_q
) ;
// QUICK_INSTANCE: BEGIN
/*gf_2to4_multiplicative_inversion
#(
    .NB_DATA            (  )   // [HINT] Works only if value is 4
)
u_gf_2to4_multiplicative_inversion
(
    .o_inv_q            (  ),
    .i_q                (  )
);
*/ // QUICK_INSTANCE: END

// ALGORITHM BEGIN
assign o_inv_q[3]   =   (   i_q[3]                                      )   ^
                        (   i_q[3] &    i_q[2] &    i_q[1]              )   ^
                        (   i_q[3] &                            i_q[0]  )   ^
                        (               i_q[2]                          )   ;


assign o_inv_q[2]   =   (   i_q[3] &    i_q[2] &    i_q[1]              )   ^
                        (   i_q[3] &    i_q[2] &                i_q[0]  )   ^
                        (   i_q[3] &                            i_q[0]  )   ^
                        (               i_q[2]                          )   ^
                        (               i_q[2] &    i_q[1]              )   ;

assign o_inv_q[1]   =   (   i_q[3]                                      )   ^
                        (   i_q[3] &    i_q[2] &    i_q[1]              )   ^
                        (   i_q[3] &                i_q[1] &    i_q[0]  )   ^
                        (               i_q[2]                          )   ^
                        (               i_q[2] &                i_q[0]  )   ^
                        (                           i_q[1]              )   ;

assign o_inv_q[0]   =   (   i_q[3] &    i_q[2] &    i_q[1]              )   ^
                        (   i_q[3] &    i_q[2] &                i_q[0]  )   ^
                        (   i_q[3] &                i_q[1]              )   ^
                        (   i_q[3] &                i_q[1] &    i_q[0]  )   ^
                        (   i_q[3] &                            i_q[0]  )   ^
                        (               i_q[2]                          )   ^
                        (               i_q[2] &    i_q[1]              )   ^
                        (               i_q[2] &    i_q[1] &    i_q[0]  )   ^
                        (                           i_q[1]              )   ^
                        (                                       i_q[0]  )   ;

endmodule // gf_2to4_multiplicative_inversion

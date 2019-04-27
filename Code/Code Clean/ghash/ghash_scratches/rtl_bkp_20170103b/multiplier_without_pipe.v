/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : subbytes_block.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: multiplier_without_pipe.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
 the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module multiplier_without_pipe
    #(
      // PARAMETERS.
      parameter                                   NB_DATA       = 64
      )
    (
     // OUTPUTS.
     output reg [2*NB_DATA-2:0] o_data_z ,
     // INPUTS.
     input wire [NB_DATA-1:0] 	i_data_x ,
     input wire [NB_DATA-1:0] 	i_data_y
     ) ;

    // QUICK INSTANCE: BEGIN
    /*
    multiplier_without_pipe
    #(
      // PARAMETERS.
      .NB_DATA  (  )
      )
    u_multiplier_without_pipe
    (
     // OUTPUTS.
     .o_data_z  (  ) ,
     // INPUTS.
     .i_data_x  (  ) ,
     .i_data_y  (  )
     ) ;
      */ // QUICK INSTANCE: END

    // LOCAL PARAMETERS.

    // INTERNAL SIGNALS.
    genvar                      ii ;
    wire [2*NB_DATA-2:0]        a_subprods [NB_DATA-1:0];
    wire [2*NB_DATA-2:0]        b_subprods [NB_DATA-1:0];
    integer                     i ;


    // ALGORITHM BEGIN.

    // First partial product.
    assign  a_subprods[ 0 ]
        = {(2*NB_DATA-1){i_data_x[ 0 ]}} & i_data_y ;
    assign  b_subprods[ 0 ]
        = a_subprods[ 0 ] ;


    // High order partial product generation.
    generate
        for ( ii=1; ii<(NB_DATA); ii=ii+1 )
            begin : genfor_partial_products

                assign  a_subprods[ ii ]
                            = {(2*NB_DATA-1){i_data_x[ ii ]}} & i_data_y ;

                assign  b_subprods[ ii ]
                            = { a_subprods[ ii ], {ii{1'b0}} } ;


            end // genfor_partial_products
    endgenerate


    // Partial product summation.
    always @( * )
    begin : l_xor_tree
        o_data_z
            = {(2*NB_DATA-1){1'b0}} ;
        for ( i=0; i<(NB_DATA); i=i+1 )
            o_data_z
                = o_data_z ^ b_subprods[ i ] ;
    end // l_xor_tree

endmodule // multiplier_without_pipe


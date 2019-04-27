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
 -- $Id: gf_2to128_multiplier_booth1mod_subrem.v 8266 2016-09-15 14:35:11Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_booth1mod_subrem
#(
    // PARAMETERS.
    parameter                                   N_SUBPROD   = 1 ,
    parameter                                   NB_DATA     = 128
)
(
    // OUTPUTS.
    output  reg     [2*NB_DATA-1:0]             o_sub_remainder ,
    // INPUTS.
    input   wire    [N_SUBPROD-1:0]             i_data
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_DATA != 128 ) ;
    localparam      [2*NB_DATA-1:0]             R_X         = { 8'he1, 120'd0, 1'b1, 127'd0 } ;

    // INTERNAL SIGNALS.
    genvar                                      ii ;
    wire            [2*NB_DATA-1:0]             a_subprods [N_SUBPROD-1:0] ;
    integer                                     i ;


    // ALGORITHM BEGIN.

    // First partial product.
    assign  a_subprods[ 0 ]
                = {2*NB_DATA{i_data[ N_SUBPROD-1-0 ]}} & { R_X } ;


    // High order partial product generation.
    generate
        for ( ii=1; ii<N_SUBPROD; ii=ii+1 )
        begin : genfor_partial_products

            assign  a_subprods[ ii ]
                        = {2*NB_DATA{i_data[ N_SUBPROD-1-ii ]}} & { {ii{1'b0}}, R_X[ 2*NB_DATA-1:ii ] } ;

        end // genfor_partial_products
    endgenerate


    // Partial product summation.
    always @( * )
    begin : l_xor_tree
        o_sub_remainder
            = {2*NB_DATA{1'b0}} ;
        for ( i=0; i<N_SUBPROD; i=i+1 )
            o_sub_remainder
                = o_sub_remainder ^ a_subprods[ i ] ;
    end // l_xor_tree


endmodule // gf_2to128_multiplier_booth1

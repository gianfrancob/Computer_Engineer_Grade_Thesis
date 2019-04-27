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
 -- $Id: gf_2to128_multiplier_booth1mod.v 8358 2016-09-20 19:06:45Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_booth1mod
#(
    // PARAMETERS.
    parameter                                   NB_DATA     = 128
)
(
    // OUTPUTS.
    output  reg     [NB_DATA-1:0]               o_data_z ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]               i_data_x ,
    input   wire    [NB_DATA-1:0]               i_data_y
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_DATA != 128 ) ;
    localparam      [NB_DATA-1:0]               R_X         = { 8'he1, 120'd0 } ;

    // INTERNAL SIGNALS.
    genvar                                      ii ;
    integer                                     i ;
    wire            [NB_DATA-1:0]               a_subprods [NB_DATA-1:0] ;
    wire            [2*NB_DATA-1:0]             b_subprods [NB_DATA-1:0] ;
    reg             [2*NB_DATA-1:0]             raw_sum ;
    wire            [2*NB_DATA-1:0]             sub_remainder ;


    // ALGORITHM BEGIN.

    // First partial product.
    assign  a_subprods[ 0 ]
                = ( i_data_x[ NB_DATA-1 ]==1'b0 )? {NB_DATA{1'b0}} : i_data_y ;
    assign  b_subprods[ 0 ]
                = { a_subprods[ 0 ], {NB_DATA{1'b0}} } ;


    // High order partial product generation.
    generate
        for ( ii=1; ii<NB_DATA; ii=ii+1 )
        begin : genfor_partial_products

            assign  a_subprods[ ii ]
                        = {NB_DATA{i_data_x[ NB_DATA-1-ii ]}} & i_data_y ;

            assign  b_subprods[ ii ]
                        = { {ii{1'b0}}, a_subprods[ ii ], {NB_DATA-ii{1'b0}} } ;

        end // genfor_partial_products
    endgenerate


    // Raw partial product sumation.
    always @( * )
    begin : l_xor_tree_raw
        raw_sum
            = {2*NB_DATA{1'b0}} ;
        for ( i=0; i<NB_DATA; i=i+1 )
            raw_sum
                = raw_sum ^ b_subprods[ i ] ;
    end // l_xor_tree_raw


    // Calculate substraction term to perform modulus operation.
    gf_2to128_multiplier_booth1mod_subrem
    #(
        .N_SUBPROD          ( NB_DATA                       ),  // -1 ?
        .NB_DATA            ( NB_DATA                       )
    )
    u_gf_2to128_multiplier_booth1mod_subrem
    (
        .o_sub_remainder    ( sub_remainder                 ),
        .i_data             ( raw_sum[ NB_DATA-1:0 ]        )
    ) ;


    // Final sumation.
    always @( * )
    begin : l_xor_tree
        o_data_z
            = raw_sum[ 2*NB_DATA-1:NB_DATA ] ^ sub_remainder[ 2*NB_DATA-1:NB_DATA ] ;
    end // l_xor_tree


endmodule // gf_2to128_multiplier_booth1

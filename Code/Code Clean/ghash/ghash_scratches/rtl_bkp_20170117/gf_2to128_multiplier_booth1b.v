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
 -- $Id: gf_2to128_multiplier_booth1b.v 10419 2017-01-17 20:41:21Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_booth1b
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
    wire            [NB_DATA-1:0]               a_subprods [NB_DATA-1:0];
    wire            [NB_DATA-1:0]               b_subprods [NB_DATA-1:0];
    wire            [NB_DATA-1:0]               c_subprods [NB_DATA-1:0];
    integer                                     i ;


    // ALGORITHM BEGIN.

    // First partial product.
    assign  a_subprods[ 0 ]
                = ( i_data_x[ NB_DATA-1 ]==1'b0 )? {NB_DATA{1'b0}} : i_data_y ;
    assign  b_subprods[ 0 ]
                = a_subprods[ 0 ] ;
    assign  c_subprods[ 0 ]
                = {NB_DATA{1'b0}} ;


    // High order partial product generation.
    generate
        for ( ii=1; ii<NB_DATA; ii=ii+1 )
        begin : genfor_partial_products

            assign  a_subprods[ ii ]
                        = {NB_DATA{i_data_x[ NB_DATA-1-ii ]}} & i_data_y ;

            assign  b_subprods[ ii ]
                        = { {ii{1'b0}}, a_subprods[ ii ][ NB_DATA-1:ii ] } ;

            assign  c_subprods[ ii ]
                        = 0 ;

        end // genfor_partial_products
    endgenerate
    
    
    
    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( 11                            ),
        .NB_DATA            ( NB_DATA                       )
    )
    u_gf_2to128_multiplier_booth1_subrem
    (
        .o_sub_remainder    ( c_subprods[ 11 ]              ),
        .i_data             ( a_subprods[ 11 ][ 11-1 : 0 ]  )
    ) ;


    // Partial product summation.
    always @( * )
    begin : l_xor_tree
        o_data_z
            = {NB_DATA{1'b0}} ;
        for ( i=0; i<NB_DATA; i=i+1 )
            o_data_z
                = o_data_z ^ b_subprods[ i ] ^ c_subprods[ i ] ;
    end // l_xor_tree


endmodule // gf_2to128_multiplier_booth1

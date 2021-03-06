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
 -- $Id: gf_2to128_multiplier_badpipe.v 10343 2017-01-09 18:17:22Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_badpipe
#(
    // PARAMETERS.
    parameter                                   NB_DATA     = 128
)
(
    // OUTPUTS.
    output  wire    [NB_DATA-1:0]               o_data_z ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]               i_data_x ,
    input   wire    [NB_DATA-1:0]               i_data_y ,
    input   wire                                i_valid ,
    input   wire                                i_reset ,
    input   wire                                i_clock
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_DATA != 128 ) ;
    localparam      [NB_DATA-1:0]               R_X         = { 8'he1, 120'd0 } ;

    // INTERNAL SIGNALS.
    genvar                                      ii ;
    reg             [NB_DATA-1:0]               z_subprods [(NB_DATA+1)-1:0];
    reg             [NB_DATA-1:0]               v_subprods [(NB_DATA+1)-1:0];


    // ALGORITHM BEGIN.

    always @( posedge i_clock )
        if ( i_reset )
            z_subprods[0]
                <= {NB_DATA{1'b0}} ;
        else if ( i_valid )
            z_subprods[0]
                <= {NB_DATA{1'b0}} ;

    always @( posedge i_clock )
        if ( i_reset )
            v_subprods[0]
                <= {NB_DATA{1'b0}} ;
        else if ( i_valid )
            v_subprods[0]
                <= i_data_y ;

    // -----------------------------------------------------
    generate
        for ( ii=0; ii<NB_DATA; ii=ii+1 )
        begin : genfor_partial_products

            always @( posedge i_clock )
                if ( i_reset )
                    z_subprods[ ii+1 ]
                        <= {NB_DATA{1'b0}} ;
                else if ( i_valid )
                    z_subprods[ ii+1 ]
                        <= z_subprods[ ii ] ^ ( {NB_DATA{i_data_x[ NB_DATA-1-ii ]}} & v_subprods[ ii ] ) ;

            always @( posedge i_clock )
                if ( i_reset )
                    v_subprods[ ii+1 ]
                        <= {NB_DATA{1'b0}} ;
                else if ( i_valid )
                    v_subprods[ ii+1 ]
                        <= { 1'b0, v_subprods[ ii ][ NB_DATA-1:1 ] } ^ ( {NB_DATA{v_subprods[ ii ][ 0 ]}} & R_X ) ;

        end // genfor_partial_products
    endgenerate

    assign  o_data_z
                = z_subprods[ NB_DATA ] ;

endmodule // ax_modular_multiplier

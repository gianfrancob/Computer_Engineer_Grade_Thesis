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
 -- $Id: gf_2to128_multiplier_reg.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_reg
#(
    // PARAMETERS.
    parameter                                   NB_DATA     = 128
)
(
    // OUTPUTS.
    output  reg     [NB_DATA-1:0]               o_data_z ,
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
    wire            [NB_DATA-1:0]               z_subprods [(NB_DATA+1)-1:0];
    wire            [NB_DATA-1:0]               v_subprods [(NB_DATA+1)-1:0];
    integer                                     i ;


    // ALGORITHM BEGIN.



    assign  z_subprods[0]
                = {NB_DATA{1'b0}} ;
    assign  v_subprods[0]
                = i_data_y ;

    // -----------------------------------------------------
    generate
        for ( ii=0; ii<NB_DATA; ii=ii+1 )
        begin : genfor_partial_products

            assign  z_subprods[ ii+1 ]
                        = ( i_data_x[ NB_DATA-1-ii ]==1'b0 )?
                            ( z_subprods[ ii ] ) :
                            ( z_subprods[ ii ] ^ v_subprods[ ii ] ) ;

            assign  v_subprods[ ii+1 ]
              = ( v_subprods[ ii ][ 0 ]==1'b0 )?
                ( { 1'b0, v_subprods[ ii ][ NB_DATA-1:1 ] } ) :
                ( { 1'b0, v_subprods[ ii ][ NB_DATA-1:1 ] } ^ R_X ) ;

        end // genfor_partial_products
    endgenerate

    wire   dont_flip = 1 ;

    always @( /*posedge i_clock*/ * )
    begin : l_out_pipe
        if ( i_reset )
            o_data_z
                = {NB_DATA{1'b0}} ;
        else //if ( i_valid )
            if ( dont_flip )
            o_data_z
                = z_subprods[ NB_DATA ] ;
            else
                for ( i=0; i<NB_DATA; i=i+1 )
                    o_data_z[i]
                        = z_subprods[NB_DATA][NB_DATA-1-i] ;
    end // l_out_pipe


/*
    reg    x_clock = 1'b0 ;
    always
        #(50) x_clock = ~x_clock ;
    reg    x_reset = 1'b1 ;
    initial
        #(200) x_reset = 1'b0 ;
    assign  i_data_x = {NB_DATA/2{2'b01}} ;
    assign  i_data_y = {NB_DATA/2{2'b10}} ;
    assign  i_reset  = x_reset ;
    assign  i_clock  = x_clock ;
*/


endmodule // gf_2to128_multiplier_reg


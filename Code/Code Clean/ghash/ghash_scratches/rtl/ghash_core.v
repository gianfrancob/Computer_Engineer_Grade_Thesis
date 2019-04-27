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
 -- $Id: ghash_core.v 8528 2016-09-27 16:37:42Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
 the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ghash_core
#(
    // PARAMETERS.
    parameter                               NB_DATA     = 128
)
(
    // OUTPUTS.
    output  reg     [NB_DATA-1:0]           o_data_y ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]           i_data_x ,
    input   wire    [NB_DATA-1:0]           i_data_x_prev ,
    input   wire    [NB_DATA-1:0]           i_h_key ,
    input   wire                            i_valid ,
    input   wire                            i_reset ,
    input   wire                            i_clock
) ;


    // LOCAL PARAMETERS.
    localparam                              BAD_CONF    = ( NB_DATA != 128 ) ;

    // INTERNAL SIGNALS.
    wire [NB_DATA-1:0]                      x_xor ;
    wire [NB_DATA-1:0]                      data_y ;



   // ALGORITHM BEGIN.


   assign   x_xor
                = i_data_x ^ i_data_x_prev ;

    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA   )
    )
    u_gf_2to128_multiplier
    (
        .o_data_z   ( data_y    ),
        .i_data_x   ( x_xor     ),
        .i_data_y   ( i_h_key   )
    ) ;


    always @( * )
    begin : l_reg_out
        o_data_y
            = data_y ;
    end // l_reg_out


endmodule // ghash_core

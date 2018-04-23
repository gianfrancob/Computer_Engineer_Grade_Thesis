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
 -- $Id: ax_modular_multiplier.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ax_modular_multiplier
#(
    // PARAMETERS.
    parameter                                   NB_BYTE             = 8 ,
    parameter                                   N_ROWS              = 4
)
(
    // OUTPUTS.
    output  wire    [NB_BYTE * N_ROWS -1:0]     o_column ,  // [HINT] Colums are consecutive and column 0 is on MSB (previous version assumed rows were consecutive and first row was on LSB).
    // INPUTS.
    input   wire    [NB_BYTE * N_ROWS -1:0]     i_column
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF            = ( NB_BYTE != 8 ) || ( N_ROWS != 4 ) ;

    // INTERNAL SIGNALS.
    genvar                                      ii ;
    wire            [NB_BYTE * N_ROWS -1:0]     column_x02 ;
    wire            [NB_BYTE * N_ROWS -1:0]     column_x03 ;


    // ALGORITHM BEGIN.

    // {02} x and {03} x product generation.
    // -----------------------------------------------------
    generate
        for ( ii=0; ii<N_ROWS; ii=ii+1 )
        begin : genfor_x02_and_x03_products

            wire    [NB_BYTE-1:0]               ii_s_x03 ;
            wire    [NB_BYTE-1:0]               ii_s_x02 ;
            wire    [NB_BYTE-1:0]               ii_s ;

            assign  ii_s
                        = i_column[ ii*NB_BYTE +: NB_BYTE ] ;

            time_03
            #(
                .NB_BYTE    ( NB_BYTE   )
            )
            u_time_03_ii
            (
                .o_byte     ( ii_s_x03   ),
                .i_byte     ( ii_s       )
            ) ;

            xtime
            #(
                .NB_BYTE    ( NB_BYTE   )
            )
            u_xtime_ii
            (
                .o_byte     ( ii_s_x02   ),
                .i_byte     ( ii_s       )
            ) ;

            assign  column_x03[ ii*NB_BYTE +: NB_BYTE ]
                        = ii_s_x03 ;
            assign  column_x02[ ii*NB_BYTE +: NB_BYTE ]
                        = ii_s_x02 ;

        end // genfor_x02_and_x03_products
    endgenerate

    // Modular product.
    // -----------------------------------------------------
    assign  o_column[3*NB_BYTE+:NB_BYTE]    = column_x02[3*NB_BYTE+:NB_BYTE] ^ column_x03[2*NB_BYTE+:NB_BYTE] ^   i_column[1*NB_BYTE+:NB_BYTE] ^   i_column[0*NB_BYTE+:NB_BYTE] ;
    assign  o_column[2*NB_BYTE+:NB_BYTE]    =   i_column[3*NB_BYTE+:NB_BYTE] ^ column_x02[2*NB_BYTE+:NB_BYTE] ^ column_x03[1*NB_BYTE+:NB_BYTE] ^   i_column[0*NB_BYTE+:NB_BYTE] ;
    assign  o_column[1*NB_BYTE+:NB_BYTE]    =   i_column[3*NB_BYTE+:NB_BYTE] ^   i_column[2*NB_BYTE+:NB_BYTE] ^ column_x02[1*NB_BYTE+:NB_BYTE] ^ column_x03[0*NB_BYTE+:NB_BYTE] ;
    assign  o_column[0*NB_BYTE+:NB_BYTE]    = column_x03[3*NB_BYTE+:NB_BYTE] ^   i_column[2*NB_BYTE+:NB_BYTE] ^   i_column[1*NB_BYTE+:NB_BYTE] ^ column_x02[0*NB_BYTE+:NB_BYTE] ;

endmodule // ax_modular_multiplier

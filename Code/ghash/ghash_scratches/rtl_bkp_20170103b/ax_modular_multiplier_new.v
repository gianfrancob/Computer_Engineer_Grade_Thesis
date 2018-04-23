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
 -- $Id: ax_modular_multiplier_new.v 10397 2017-01-13 19:10:25Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module ax_modular_multiplier_new
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
    wire            [NB_BYTE-1:0]               col0 ;
    wire            [NB_BYTE-1:0]               col1 ;
    wire            [NB_BYTE-1:0]               col2 ;
    wire            [NB_BYTE-1:0]               col3 ;

    wire            [NB_BYTE-1:0]               col01 ;
    wire            [NB_BYTE-1:0]               col12 ;
    wire            [NB_BYTE-1:0]               col23 ;
    wire            [NB_BYTE-1:0]               col30 ;

    wire            [NB_BYTE-1:0]               col012 ;
    wire            [NB_BYTE-1:0]               col123 ;
    wire            [NB_BYTE-1:0]               col230 ;
    wire            [NB_BYTE-1:0]               col301 ;

    wire            [NB_BYTE-1:0]               xtime0 ;
    wire            [NB_BYTE-1:0]               xtime1 ;
    wire            [NB_BYTE-1:0]               xtime2 ;
    wire            [NB_BYTE-1:0]               xtime3 ;


    // ALGORITHM BEGIN.

    // Rewire
    // -----------------------------------------------------
    assign col3     =   i_column[3*NB_BYTE+:NB_BYTE] ;
    assign col2     =   i_column[2*NB_BYTE+:NB_BYTE] ;
    assign col1     =   i_column[1*NB_BYTE+:NB_BYTE] ;
    assign col0     =   i_column[0*NB_BYTE+:NB_BYTE] ;

    assign col01    =   col0 ^ col1 ;
    assign col12    =   col1 ^ col2 ;
    assign col23    =   col2 ^ col3 ;
    assign col30    =   col3 ^ col0 ;

    assign col012   =   col0 ^ col12 ;
    assign col123   =   col1 ^ col23 ;
    assign col230   =   col2 ^ col30 ;
    assign col301   =   col3 ^ col01 ;

    // Xtime
    // -----------------------------------------------------
    xtime_new
    #(
        .NB_BYTE    ( NB_BYTE   )
    )
    u_xtime_new_0
    (
        .o_byte     ( xtime0    ) ,
        .i_byte     ( col01     )
    ) ;

    xtime_new
    #(
        .NB_BYTE    ( NB_BYTE   )
    )
    u_xtime_new_1
    (
        .o_byte     ( xtime1    ) ,
        .i_byte     ( col12     )
    ) ;

    xtime_new
    #(
        .NB_BYTE    ( NB_BYTE   )
    )
    u_xtime_new_2
    (
        .o_byte     ( xtime2    ) ,
        .i_byte     ( col23     )
    ) ;

    xtime_new
    #(
        .NB_BYTE    ( NB_BYTE   )
    )
    u_xtime_new_3
    (
        .o_byte     ( xtime3    ) ,
        .i_byte     ( col30     )
    ) ;

    // Modular product.
    // -----------------------------------------------------
    assign  o_column[3*NB_BYTE+:NB_BYTE]    =   xtime1 ^ col230 ;
    assign  o_column[2*NB_BYTE+:NB_BYTE]    =   xtime2 ^ col301 ;
    assign  o_column[1*NB_BYTE+:NB_BYTE]    =   xtime3 ^ col012 ;
    assign  o_column[0*NB_BYTE+:NB_BYTE]    =   xtime0 ^ col123 ;

endmodule // ax_modular_multiplier
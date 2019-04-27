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
 -- $Id: mixcolumns_block.v 8358 2016-09-20 19:06:45Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the mix column function of the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module mixcolumns_block
#(
    // PARAMETERS.
    parameter                                           NB_BYTE     = 8 ,
    parameter                                           N_BYTES     = 16
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]         o_state ,   // [HINT] Colums are consecutive and column 0 is on MSB (previous version assumed rows were consecutive and first row was on LSB).
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]         i_state
) ;


    // LOCAL PARAMETERS.
    localparam                                          N_COLS      = 4 ;
    localparam                                          N_ROWS      = N_BYTES / N_COLS ;
    localparam                                          BAD_CONF    = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) ;

    // INTERNAL SIGNALS.
    wire            [N_BYTES * NB_BYTE - 1 : 0]         swapped_i_state ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]         swapped_o_state ;
    genvar                                              ii ;


    // ALGORITHM BEGIN.

    // Rewiring row to columns.
    //  common_a1a2b1b2_to_a1b1a2b2_rewire
    //  #(
    //      .NB_SYMBOL              ( NB_BYTE           ),
    //      .N_SYMBOLS_X_WORD       ( N_COLS            ),
    //      .N_WORDS                ( N_ROWS            )
    //  )
    //  u_common_a1a2b1b2_to_a1b1a2b2_rewire_i
    //  (
    //      .o_data_vector_rewired  ( swapped_i_state   ),
    //      .i_data_vector          ( i_state           )
    //  ) ;
    assign  swapped_i_state
                = i_state ;


    // Creating N_BYTES instances of S-Box block.
    generate
        for ( ii=0; ii<N_COLS; ii=ii+1 )
        begin : genfor_mix_columns

            wire    [NB_BYTE*N_ROWS-1:0]                ii_o_column ;
            wire    [NB_BYTE*N_COLS-1:0]                ii_i_column ;

            assign  ii_i_column
                        = swapped_i_state[ ii*N_ROWS*NB_BYTE +: N_ROWS*NB_BYTE ] ;

            ax_modular_multiplier
            #(
                .NB_BYTE                ( NB_BYTE           ),
                .N_ROWS                 ( N_ROWS            )
            )
            u_ax_modular_multiplier
            (
                .o_column               ( ii_o_column       ),
                .i_column               ( ii_i_column       )
            ) ;

            assign  swapped_o_state[ ii*N_ROWS*NB_BYTE +: N_ROWS*NB_BYTE ]
                        = ii_o_column ;

        end // genfor_mix_columns
    endgenerate


    // Rewiring columns to row.
    //  common_a1a2b1b2_to_a1b1a2b2_rewire
    //  #(
    //      .NB_SYMBOL              ( NB_BYTE           ),
    //      .N_SYMBOLS_X_WORD       ( N_COLS            ),
    //      .N_WORDS                ( N_ROWS            )
    //  )
    //  u_common_a1a2b1b2_to_a1b1a2b2_rewire_o
    //  (
    //      .o_data_vector_rewired  ( o_state           ),
    //      .i_data_vector          ( swapped_o_state   )
    //  ) ;
    assign  o_state
                = swapped_o_state ;


endmodule // shiftrows_block

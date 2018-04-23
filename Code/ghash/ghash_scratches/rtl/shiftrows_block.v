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
 -- $Id: shiftrows_block.v 8318 2016-09-19 18:18:34Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the shift row operation of AES cipher
    algorithm. A simple rewire is used to complete the operation.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module shiftrows_block
#(
    // PARAMETERS.
    parameter                                           NB_BYTE             = 8 ,
    parameter                                           N_BYTES             = 16
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]         o_state ,   // [HINT] Colums are consecutive and column 0 is on MSB (previous version assumed rows were consecutive and first row was on LSB).
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]         i_state
) ;


    // LOCAL PARAMETERS.
    localparam                                          N_COLS              = 4 ;
    localparam                                          N_ROWS              = N_BYTES / N_COLS ;
    localparam                                          BAD_CONF            = ( NB_BYTE != 8 ) ;

    // INTERNAL SIGNALS.
    genvar                                              ii ;
    genvar                                              jj ;


    // ALGORITHM BEGIN.

    // Creating N_BYTES instances of S-Box block.
    generate
        for ( ii=0; ii<N_ROWS; ii=ii+1 )
        begin : genfor_shift_rows

            // Local signals.
            wire    [NB_BYTE*N_COLS-1:0]                ii_shifted_row ;
            wire    [NB_BYTE*N_COLS-1:0]                ii_input_row ;

            // Get a row from input state.
            //  assign  ii_input_row
            //              = i_state[ ii*NB_BYTE*N_COLS +: NB_BYTE*N_COLS ] ;
            for ( jj=0; jj<N_ROWS; jj=jj+1)
            begin : genfor_assemble_row
                assign  ii_input_row[ jj*NB_BYTE +: NB_BYTE ]
                            = i_state[ jj*NB_BYTE*N_COLS + ii*NB_BYTE +: NB_BYTE ] ;
            end // genfor_assemble_row

            // Shift row, depending on row index (ii).
            for ( jj=0; jj<N_COLS; jj=jj+1 )
            begin : genfor_shift_a_row
                assign  ii_shifted_row[ ((N_COLS-1-ii+jj)%N_COLS)*NB_BYTE +: NB_BYTE ]
                            = ii_input_row[ (jj)*NB_BYTE +: NB_BYTE ] ;
            end // genfor_shift_a_row

            // Shifted row to global output (state).
            //  assign  o_state[ ii*NB_BYTE*N_COLS +: NB_BYTE*N_COLS ]
            //              = ii_shifted_row ;
            for ( jj=0; jj<N_ROWS; jj=jj+1)
            begin : genfor_split_row
                assign  o_state[ jj*NB_BYTE*N_COLS + ii*NB_BYTE +: NB_BYTE ]
                            = ii_shifted_row[ jj*NB_BYTE +: NB_BYTE ] ;
            end // genfor_split_row

        end // genfor_shift_rows
    endgenerate

endmodule // shiftrows_block

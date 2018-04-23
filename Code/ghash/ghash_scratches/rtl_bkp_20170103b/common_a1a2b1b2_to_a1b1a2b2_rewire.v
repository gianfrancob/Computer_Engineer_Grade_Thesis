/*------------------------------------------------------------------------------
 -- Project     : CL40010
 -------------------------------------------------------------------------------
 -- File        : common_a1a2b1b2_to_a1b1a2b2_rewire.v
 -- Author      : Ramiro R. Lopez
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : 2010-10-12
 --
 -- Rev 0       : Initial release. RRL.
 --
 -- $Id: common_a1a2b1b2_to_a1b1a2b2_rewire.v 10343 2017-01-09 18:17:22Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : .
 -------------------------------------------------------------------------------
 -- Copyright (C) 2009 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

//`timescale  1ns/1ps

module common_a1a2b1b2_to_a1b1a2b2_rewire
#(
    // PARAMETERS.
    parameter                                                   NB_SYMBOL           = 4,
    parameter                                                   N_SYMBOLS_X_WORD    = 3,
    parameter                                                   N_WORDS             = 2
)
(
    // OUTPUTS.
    output  wire    [NB_SYMBOL*N_WORDS*N_SYMBOLS_X_WORD-1:0]    o_data_vector_rewired,
    // INPUTS.
    input   wire    [NB_SYMBOL*N_WORDS*N_SYMBOLS_X_WORD-1:0]    i_data_vector
);

    // For "quick instantiation".
    /*
    common_a1a2b1b2_to_a1b1a2b2_rewire
    #(
        .NB_SYMBOL              (   ),
        .N_SYMBOLS_X_WORD       (   ),
        .N_WORDS                (   )
    )
    u_common_a1a2b1b2_to_a1b1a2b2_rewire
    (
        .o_data_vector_rewired  (   ),
        .i_data_vector          (   )
    );
    */

    // LOCAL PARAMETERS.
    localparam                                                  NB_DATA             = NB_SYMBOL*N_SYMBOLS_X_WORD;


    // INTERNAL SIGNALS.
    genvar                                                      ii;
    genvar                                                      jj;
    wire            [NB_DATA*N_WORDS-1:0]                       data_vector_rewired;



    // ALGORITHM BEGIN.


    // Do rewire: {c[3,2,1,0], b[3,2,1,0], a[3,2,1,0]} --> {c3,b3,a3, c2,b2,a2, c1,b1,a1, c0,b0,a0}
    generate
        for ( ii=0; ii<N_WORDS; ii=ii+1 )
        begin : genfor_rewire_words
            for ( jj=0; jj<N_SYMBOLS_X_WORD; jj=jj+1 )
            begin : genfor_rewire_symbols
                assign  data_vector_rewired[ jj*(N_WORDS*NB_SYMBOL) + NB_SYMBOL*(ii+1) -1 -: NB_SYMBOL ]
                            = i_data_vector[ ii*(NB_DATA) + NB_SYMBOL*(jj+1) -1 -: NB_SYMBOL ];
            end // genfor_rewire_symbols
        end // genfor_rewire_words
    endgenerate


    assign  o_data_vector_rewired
                = data_vector_rewired;


endmodule // common_word_to_symbol_rewire

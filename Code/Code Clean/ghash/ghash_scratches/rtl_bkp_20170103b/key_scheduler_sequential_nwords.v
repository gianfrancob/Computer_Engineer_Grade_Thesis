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
 -- $Id: key_scheduler_sequential_nwords.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module key_scheduler_sequential_nwords
#(
    parameter                                                   N_WORDS             = 4 ,
    parameter                                                   NB_BYTE             = 8 ,
    parameter                                                   N_BYTES_STATE       = 16 ,
    parameter                                                   N_BYTES_KEY         = 32 ,
    parameter                                                   N_ROUNDS            = 14 ,
    parameter                                                   N_BYTES_WORD        = 4 ,
    parameter                                                   NB_WORD             = N_BYTES_WORD * NB_BYTE ,
    parameter                                                   NB_INDEX            = 4 ,   // Should be big enough to count up to N_ROUNDS.
    parameter                                                   COMPLE_CASE_INDEX   = 4
)
(
    output  wire    [N_WORDS*NB_WORD-1:0]                       o_key_word_n_bus ,
    input   wire    [NB_WORD-1:0]                               i_key_word_n_m_1 ,
    input   wire    [N_WORDS*NB_WORD-1:0]                       i_key_word_n_m_nk_bus ,
    input   wire    [NB_INDEX-1:0]                              i_index ,
    input   wire                                                i_valid ,
    input   wire                                                i_reset ,
    input   wire                                                i_clock
) ;


    /* // BEGIN: Quick instance.
    key_scheduler_sequential_nwords
    #(
        .N_WORDS                (   ),
        .NB_BYTE                (   ),
        .N_BYTES_STATE          (   ),
        .N_BYTES_KEY            (   ),
        .N_ROUNDS               (   ),
        .N_BYTES_WORD           (   ),
        .NB_WORD                (   ),
        .NB_INDEX               (   ),
        .COMPLE_CASE_INDEX      (   )
    )
    u_key_scheduler_sequential_nwords
    (
        .o_key_word_n_bus       (   ),
        .i_key_word_n_m_1       (   ),
        .i_key_word_n_m_nk_bus  (   ),
        .i_index                (   ),
        .i_valid                (   ),
        .i_reset                (   ),
        .i_clock                (   )
    ) ;
    // END: Quick instance. */


    // LOCAL PARAMETERS.
    // None so far.

    // INTERNAL SIGNALS.
    genvar                                                      ii ;



    // ALGORITHM BEGIN.


    generate
        for ( ii=0; ii<N_WORDS; ii=ii+1 )
        begin : genfor_schedule_key_word

            wire    [NB_WORD-1:0]                               ii_o_key_word_n ;
            wire    [NB_WORD-1:0]                               ii_i_key_word_n_m_1 ;
            wire    [NB_WORD-1:0]                               ii_i_key_word_n_m_nk ;
            wire    [NB_INDEX-1:0]                              ii_i_index ;

            if ( ii==0 )
            begin : genif_first_element
                assign  ii_i_key_word_n_m_1
                            = i_key_word_n_m_1 ;
            end // genif_first_element
            else
            begin : genelse_first_element
                assign  ii_i_key_word_n_m_1
                            = o_key_word_n_bus[ (N_WORDS-1-ii+1)*NB_WORD +: NB_WORD ] ;
            end // genelse_first_element

            assign  ii_i_key_word_n_m_nk
                        = i_key_word_n_m_nk_bus[ (N_WORDS-1-ii)*NB_WORD +: NB_WORD ] ;
            assign  ii_i_index
                        = i_index + ii[NB_INDEX-1:0] ;  // [HINT] Carry drop intentional.

            key_scheduler_sequential_1word
            #(
                .NB_BYTE            ( NB_BYTE                           ),
                .N_BYTES_STATE      ( N_BYTES_STATE                     ),
                .N_BYTES_KEY        ( N_BYTES_KEY                       ),
                .N_ROUNDS           ( N_ROUNDS                          ),
                .N_BYTES_WORD       ( N_BYTES_WORD                      ),
                .NB_WORD            ( NB_WORD                           ),
                .NB_INDEX           ( NB_INDEX                          ),
                .SIMPLE_CASE        ( ( ii % COMPLE_CASE_INDEX ) != 0   )
            )
            u_key_scheduler_sequential_1word
            (
                .o_key_word_n       ( ii_o_key_word_n                   ),
                .i_key_word_n_m_1   ( ii_i_key_word_n_m_1               ),
                .i_key_word_n_m_nk  ( ii_i_key_word_n_m_nk              ),
                .i_index            ( ii_i_index                        ),
                .i_valid            ( i_valid                           ),
                .i_reset            ( i_reset                           ),
                .i_clock            ( i_clock                           )
            ) ;

            assign  o_key_word_n_bus[ (N_WORDS-1-ii)*NB_WORD    +: NB_WORD ]
                        =  ii_o_key_word_n ;

        end // genfor_schedule_key_word
    endgenerate


endmodule // key_scheduler

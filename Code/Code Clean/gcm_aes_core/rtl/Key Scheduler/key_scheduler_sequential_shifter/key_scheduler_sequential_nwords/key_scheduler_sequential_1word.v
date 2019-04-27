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
 -- $Id: key_scheduler_sequential_1word.v 10369 2017-01-10 18:11:18Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module key_scheduler_sequential_1word
#(
    // PARAMETERS.
    parameter                                                   NB_BYTE             = 8                         ,
    parameter                                                   N_BYTES_STATE       = 16                        ,
    parameter                                                   N_BYTES_KEY         = 32                        ,
    parameter                                                   N_ROUNDS            = 14                        ,
    parameter                                                   N_BYTES_WORD        = 4                         ,
    parameter                                                   NB_WORD             = N_BYTES_WORD * NB_BYTE    ,
    parameter                                                   NB_INDEX            = 4                         ,   // Should be big enough to count up to N_ROUNDS.
    parameter                                                   SIMPLE_CASE         = 0
)
(
    // OUTPUTS.
    output  wire    [ NB_WORD-1:0   ]                           o_key_word_n        ,
    // INPUTS.
    input   wire    [ NB_WORD-1:0   ]                           i_key_word_n_m_1    ,
    input   wire    [ NB_WORD-1:0   ]                           i_key_word_n_m_nk   ,
    input   wire    [ NB_INDEX-1:0  ]                           i_index             ,
    input   wire                                                i_valid             ,
    input   wire                                                i_reset             ,
    input   wire                                                i_clock
) ;

/* // BEGIN: Quick instance.
key_scheduler_sequential_1word
#(
    .NB_BYTE            (   ),
    .N_BYTES_STATE      (   ),
    .N_BYTES_KEY        (   ),
    .N_ROUNDS           (   ),
    .N_BYTES_WORD       (   ),
    .NB_WORD            (   ),
    .NB_INDEX           (   ),
    .SIMPLE_CASE        (   )
)
u_key_scheduler_sequential_1word
(
    .o_key_word_n       (   ),
    .i_key_word_n_m_1   (   ),
    .i_key_word_n_m_nk  (   ),
    .i_index            (   ),
    .i_valid            (   ),
    .i_reset            (   ),
    .i_clock            (   )
) ;
// END: Quick instance. */


generate
    if ( SIMPLE_CASE == 0 ) // cad_ence map_to_mux
    begin : genif_complex_case

        // LOCAL PARAMETERS.
        localparam                                                  N_STATE_WORDS       =   N_BYTES_STATE / N_BYTES_WORD        ;
        localparam                                                  NB_KEY_VECTOR       =   N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)  ;
        localparam                                                  NK                  =   N_BYTES_KEY / N_BYTES_WORD          ;   // 8.
        localparam                                                  BAD_CONF            =   ( NB_BYTE != 8 ) || ( (NK!=4) &&
                                                                                            (NK!=6) && (NK!=8) )                ;
        localparam                                                  NB_INDEX_TEMP_WORD  =   2                                   ;
        localparam      [ NB_INDEX_TEMP_WORD-1:0    ]               SEL_DEF             =   0                                   ;
        localparam      [ NB_INDEX_TEMP_WORD-1:0    ]               SEL_ROT             =   1                                   ;
        localparam      [ NB_INDEX_TEMP_WORD-1:0    ]               SEL_SUB             =   2                                   ;
        localparam                                                  N_OPERATIONS        =   3                                   ;

        // INTERNAL SIGNALS.
        wire            [ NB_WORD-1:0               ]               rcon [ NK-1:0 ]     ;
        reg             [ NB_INDEX_TEMP_WORD-1:0    ]               index_temp_word     ;
        wire            [ N_OPERATIONS*NB_WORD-1:0  ]               temp_word_bus       ;
        wire            [ NB_WORD-1:0               ]               sub_word            ;
        wire            [ NB_WORD-1:0               ]               rot_word            ;
        wire            [ NB_WORD-1:0               ]               rot_word_rcon       ;
        wire            [ NB_WORD-1:0               ]               temp_word           ;


        // ALGORITHM BEGIN.

        // Rcon constant words.
        //======================================================================
        assign  rcon[ 0 ]   = 32'h01_00_00_00   ;
        assign  rcon[ 1 ]   = 32'h02_00_00_00   ;
        assign  rcon[ 2 ]   = 32'h04_00_00_00   ;
        assign  rcon[ 3 ]   = 32'h08_00_00_00   ;
        assign  rcon[ 4 ]   = 32'h10_00_00_00   ;
        assign  rcon[ 5 ]   = 32'h20_00_00_00   ;
        assign  rcon[ 6 ]   = 32'h40_00_00_00   ;
        assign  rcon[ 7 ]   = 32'h80_00_00_00   ;



        // Calculate and index used to select an operation, based on i_index.
        //======================================================================
        always @( * )
        begin : l_calc_temp_index
            if ( ( i_index % NK ) == 0 )    // cad_ence map_to_mux
                index_temp_word = SEL_ROT   ;
            else if ( ( NK > 6 ) && ( ( i_index % NK ) == 4 ) ) // cad_ence map_to_mux
                index_temp_word = SEL_SUB   ;
            else
                index_temp_word = SEL_DEF   ;
        end // l_calc_temp_index



        // Logic that can be required, depending on the key_word_index.
        //======================================================================

        // Sustitution operation.
        //----------------------------------------------------------------------
        subbytes_block
        #(
            .NB_BYTE            ( NB_BYTE               ),
            .N_BYTES            ( N_BYTES_WORD          ),
            .CREATE_OUTPUT_REG  ( 0                     ),
            .USE_LUT            ( 1                     )
        )
        u_subbytes_block
        (
            .o_state            ( sub_word              ),
            .o_valid            ( /*unused*/            ),
            .i_state            ( i_key_word_n_m_1      ),
            .i_valid            ( i_valid               ),
            .i_reset            ( i_reset               ),
            .i_clock            ( i_clock               )
        ) ;

        // Rotation operation of subword and xor with rcon.
        //----------------------------------------------------------------------
        assign  rot_word        = { sub_word[ NB_WORD-NB_BYTE-1 : 0 ], sub_word[ NB_WORD-1 -: NB_BYTE ] }   ;
        assign  rot_word_rcon   = rot_word ^ rcon[ ( i_index / NK ) - 1 ]                                   ; // [FIXME] Check if "( i_index / NK )" synthetizes OK or must be implemented manually.



        // Possibles outcomes are assembled in a bus.
        //======================================================================

        // No special operation case.
        //----------------------------------------------------------------------
        assign  temp_word_bus[ SEL_DEF*NB_WORD +: NB_WORD ] = i_key_word_n_m_1  ;

        // Special case 1 ( ii%NK == 0 ).
        //----------------------------------------------------------------------
        assign  temp_word_bus[ SEL_ROT*NB_WORD +: NB_WORD ] = rot_word_rcon     ;

        // Special case 2 ( NK > 6 && ii%NK==4 ).
        //----------------------------------------------------------------------
        assign  temp_word_bus[ SEL_SUB*NB_WORD +: NB_WORD ] = sub_word          ;



        // Output generation.
        //======================================================================

        // Selection of temp_word.
        assign  temp_word       = temp_word_bus[ index_temp_word*NB_WORD +: NB_WORD ]   ;

        // Xor between temp_word and "n-NK" word.
        assign  o_key_word_n    = temp_word ^ i_key_word_n_m_nk                         ;

    end // genif_complex_case

    else
    begin : genelse_complex_case

        // Xor between temp_word and "n-NK" word.
        assign  o_key_word_n    = i_key_word_n_m_1 ^ i_key_word_n_m_nk                  ;

    end // genelse_complex_case

endgenerate



endmodule // key_scheduler

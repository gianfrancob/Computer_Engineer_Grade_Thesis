/*------------------------------------------------------------------------------
 -- Project     : CL120020
 -------------------------------------------------------------------------------
 -- File        : gctr_function.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gctr_function.v 5101 2017-07-17 17:42:07Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module gctr_function
#(
    // PARAMETERS.
    parameter                                           NB_BLOCK                = 128                   ,
    parameter                                           N_ROUNDS                = 14                    ,
    parameter                                           N_BLOCKS                = 2                     ,
    parameter                                           NB_DATA                 = (N_BLOCKS*NB_BLOCK)   ,
    parameter                                           NB_INC_MODE             = 2                     ,
    parameter                                           STAGES_BETWEEN_REGS     = 1                     ,
    parameter                                           CREATE_REG_LUT          = 0                     ,
    parameter                                           USE_LUT_IN_SUBBYTES     = 1
)
(
    // OUTPUTS.
    output  wire    [ NB_DATA-1:0               ]       o_ciphertext            ,
    output  wire                                        o_valid                 ,
    // INPUTS.
    input   wire    [ NB_DATA-1:0               ]       i_plaintext             ,   // Plaintext words
    input   wire    [ NB_BLOCK*(N_ROUNDS+1)-1:0 ]       i_round_key_vector      ,
    input   wire    [ NB_BLOCK-1:0              ]       i_initial_counter_block ,
    input   wire    [ NB_INC_MODE-1:0           ]       i_rf_static_inc_mode    ,
    input   wire                                        i_rf_mode_gmac          ,
    input   wire                                        i_sop                   ,   // Start of plaintext
    input   wire                                        i_sop_pre               ,   // [HINT] This assumes N_BLOCKS>=2.
    input   wire    [ NB_DATA-1:0               ]       i_pre_block             ,   // [HINT] This assumes N_BLOCKS>=2.
    input   wire                                        i_valid                 ,
    input   wire                                        i_reset                 ,
    input   wire                                        i_clock
) ;

/* BEGIN: Quick instance.
gctr_function
#(
    .NB_BLOCK                   (  ),
    .N_ROUNDS                   (  ),
    .N_BLOCKS                   (  ),
    .NB_DATA                    (  ),
    .NB_INC_MODE                (  ),
    .STAGES_BETWEEN_REGS        (  ),
    .CREATE_REG_LUT             (  ),
    .USE_LUT_IN_SUBBYTES        (  )
)
u_gctr_function
(
    .o_ciphertext               (  ),
    .o_valid                    (  ),
    .i_plaintext                (  ),
    .i_round_key_vector         (  ),
    .i_initial_counter_block    (  ),
    .i_rf_static_inc_mode       (  ),
    .i_rf_mode_gmac             (  ),
    .i_sop                      (  ),
    .i_sop_pre                  (  ),
    .i_pre_block                (  ),
    .i_valid                    (  ),
    .i_reset                    (  ),
    .i_clock                    (  )
) ;
// END: Quick instance. */



// LOCAL PARAMETERS.
localparam                                      NB_BYTE     = 8                                 ;
localparam                                      N_BYTES     = NB_BLOCK / NB_BYTE                ;
localparam                                      BAD_CONF    = ( NB_BLOCK!=128 || N_ROUNDS!=14 ) ;

// INTERNAL SIGNALS.
genvar                                          ii                                      ;
reg         [ NB_BLOCK-1:0  ]                   counter_block_final_d                   ;
wire        [ NB_BLOCK-1:0  ]                   counter_block_array [ N_BLOCKS+1-1:0 ]  ;
wire        [ N_BLOCKS-1:0  ]                   valid_bus                               ; // [HINT] Only bit 0 is used.


// ALGORITHM BEGIN.

// Counter block for first block.
assign  counter_block_array[0]  =   ( i_sop )               ?   // cad_ence map_to_mux
                                    i_initial_counter_block : counter_block_final_d ;

generate
    for ( ii=0; ii<N_BLOCKS; ii=ii+1 )
    begin : genfor_gctr_base

        // Local signals.
        wire    [ NB_BLOCK-1:0  ]               counter_block_ii            ;
        wire    [ NB_BLOCK-1:0  ]               counter_block_ii_next       ;
        wire    [ NB_BLOCK-1:0  ]               ciphered_block_ii           ;
        wire    [ NB_BLOCK-1:0  ]               plaintext_block_ii          ;
        wire    [ NB_BLOCK-1:0  ]               ciphered_counter_block_ii   ; // [HINT] Unused.

        // Get current counter_block.
        assign  counter_block_ii    =   ( i_sop_pre )                           ?
                                        i_pre_block[ii*NB_BLOCK +: NB_BLOCK]    : counter_block_array[ii]   ;

        assign  plaintext_block_ii  =   ( i_sop_pre )       ?   // cad_ence map_to_mux
                                        { NB_BLOCK{1'b0} }  : i_plaintext[ii*NB_BLOCK +: NB_BLOCK]  ;

        // Increment current counter block (to be used by the next round).
        inc32_block
        #(
            .NB_BLOCK               ( NB_BLOCK                  ),
            .NB_MODE                ( NB_INC_MODE               )
        )
        u_inc32_block_ii
        (
            .o_block                ( counter_block_ii_next     ),
            .i_block                ( counter_block_ii          ),
            .i_rf_static_mode       ( i_rf_static_inc_mode      )
        ) ;

        // AES cipher module for xoring with the current counter block.
        aes_round_ladder_xor_data
        #(
            .NB_BYTE                ( NB_BYTE                   ),
            .N_BYTES                ( N_BYTES                   ),
            .N_ROUNDS               ( N_ROUNDS                  ),
            .STAGES_BETWEEN_REGS    ( STAGES_BETWEEN_REGS       ),
            .CREATE_REG_LUT         ( CREATE_REG_LUT            ),
            .USE_LUT                ( USE_LUT_IN_SUBBYTES       )
        )
        u_aes_round_ladder_xor_data__ii
        (
            .o_state                ( ciphered_counter_block_ii ),  // [HINT] Unused outside DUT. Kept for visualisation...
            .o_data                 ( ciphered_block_ii         ),
            .o_valid                ( valid_bus[ ii ]           ),
            .i_state                ( counter_block_ii          ),
            .i_data                 ( plaintext_block_ii        ),
            .i_round_key_vector     ( i_round_key_vector        ),
            .i_rf_mode_gmac         ( i_rf_mode_gmac            ),
            .i_valid                ( i_valid | i_sop_pre       ),
            .i_reset                ( i_reset                   ),
            .i_clock                ( i_clock                   )
        ) ;

        // Calculate current ciphertext.
        assign  o_ciphertext[ii*NB_BLOCK +: NB_BLOCK]   = ciphered_block_ii ;

        // Save incremented counter_block (to use in next round).
        assign  counter_block_array[ii+1]   = counter_block_ii_next ;

    end // genfor_gctr_base
endgenerate


assign  o_valid = valid_bus[0]  ;


// Save last incremented counter_block (to use in the first round).
always @( posedge i_clock )
begin : l_keep_next_cb0
    if ( i_reset )  // cad_ence map_to_mux
        counter_block_final_d   <= { NB_BLOCK{1'b0} }           ;
    else if ( i_valid )
        counter_block_final_d   <= counter_block_array[N_BLOCKS];
end // l_keep_next_cb0


endmodule // gctr_function

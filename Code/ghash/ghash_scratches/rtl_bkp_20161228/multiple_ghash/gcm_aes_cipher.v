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
 -- $Id: gcm_aes_cipher.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gcm_aes_cipher
#(
    // PARAMETERS.
    parameter                                       NB_BLOCK            = 128 ,
    parameter                                       N_BLOCKS            = 2 ,
    parameter                                       LOG2_N_BLOCKS       = 1 ,
    parameter                                       NB_DATA             = (N_BLOCKS*NB_BLOCK) ,
    parameter                                       NB_KEY              = 256 ,
    parameter                                       NB_IV               = 96 ,
    parameter                                       NB_INC_MODE         = 2
)
(
    // OUTPUTS.
    output  wire    [NB_DATA-1:0]                   o_ciphertext_words_y ,
    input   wire    [NB_BLOCK-1:0]                  o_tag ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]                   i_plaintext_words_x ,   // Plaintext words
    input   wire    [NB_KEY-1:0]                    i_rf_static_key ,       // [HINT]: This is semy static. FIXME.
    input   wire    [NB_BLOCK-1:0]                  i_aad ,
    input   wire    [NB_IV-1:0]                     i_iv ,
    input   wire    [NB_BLOCK/2-1:0]                i_length_aad ,
    input   wire    [NB_BLOCK/2-1:0]                i_length_plaintext ,
    input   wire                                    i_sop ,                 // Start of plaintext
    input   wire                                    i_valid ,
    input   wire    [NB_INC_MODE-1:0]               i_rf_static_inc_mode ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;


    /* // BEGIN: Quick instance.
    gcm_aes_cipher
    #(
        .NB_BLOCK               (   ),
        .N_BLOCKS               (   ),
        .NB_DATA                (   ),
        .NB_KEY                 (   ),
        .NB_IV                  (   ),
        .NB_INC_MODE            (   )
    )
    u_gcm_aes_cipher
    (
        .o_ciphertext_words_y   (   ),
        .o_tag                  (   ),
        .i_plaintext_words_x    (   ),
        .i_rf_static_key        (   ),
        .i_aad                  (   ),
        .i_iv                   (   ),
        .i_length_aad           (   ),
        .i_length_plaintext     (   ),
        .i_sop                  (   ),
        .i_valid                (   ),
        .i_rf_static_inc_mode   (   ),
        .i_reset                (   ),
        .i_clock                (   )
    ) ;
    */ // END: Quick instance.


    // LOCAL PARAMETERS.
    localparam                                      NB_BYTE                 = 8 ;
    localparam                                      N_BYTES                 = 16 ;
    localparam                                      N_ROUNDS                = 14 ;
    localparam                                      N_COLS                  = 4 ;
    localparam                                      N_ROWS                  = N_BYTES / N_COLS ;
    localparam                                      STAGES_BETWEEN_REGS     = 3 ;
    localparam                                      NB_STATE                = N_BYTES * NB_BYTE ;   // NB_BLOCK
    localparam                                      N_BYTES_KEY             = /*32*/ NB_KEY / NB_BYTE ;
    localparam                                      BAD_CONF                = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) || ( N_ROUNDS != 14 ) || ( N_BYTES_KEY != 32 ) ;
    localparam                                      DELAY_SOP_GHASG_DATA    = 10 ;  // [FIXME] Calculate...


    // INTERNAL SIGNALS.
    wire            [NB_BLOCK*(N_ROUNDS+1)-1:0]     round_key_vector ;
    wire            [NB_BLOCK-1:0]                  j0 ;
    wire            [NB_BLOCK-1:0]                  initial_counter_block ;
    wire            [NB_BLOCK-1:0]                  hash_subkey_h ;
    wire            [NB_BLOCK-1:0]                  ghash_aad ;
    wire            [NB_BLOCK-1:0]                  ghash_ciphertext ;
    wire            [NB_BLOCK-1:0]                  ghash_length_word ;
    wire            [NB_BLOCK-1:0]                  length_word ;
    wire                                            sop_del ;



    // ALGORITHM BEGIN.

    // =========================================================================
    // J0 GENERATOR.
    // =========================================================================
    j0_generator
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .NB_IV                      ( NB_IV                 )
    )
    u_j0_generator
    (
        .o_j0                       ( j0                    ),
        .i_iv                       ( i_iv                  )
    ) ;


    // =========================================================================
    // FIRST INC32.
    // =========================================================================
    inc32_block
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .NB_MODE                    ( NB_INC_MODE           )
    )
    u_inc32_block_0
    (
        .o_block                    ( initial_counter_block ),
        .i_block                    ( j0                    ),
        .i_rf_static_mode           ( i_rf_static_inc_mode  )
    ) ;


    // =========================================================================
    // KEY SCHEDULER.
    // =========================================================================
    // Create a key schedule from input key, required by AES cypher and hash key.
    key_scheduler
    #(
        .NB_BYTE                    ( NB_BYTE               ),
        .N_BYTES_STATE              ( N_BYTES               ),
        .N_BYTES_KEY                ( N_BYTES_KEY           ),
        .N_ROUNDS                   ( N_ROUNDS              )
    )
    u_key_scheduler
    (
        .o_round_key_vector         ( round_key_vector      ),
        .i_key                      ( i_rf_static_key       ),
        .i_valid                    ( i_valid               ),
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;


    // =========================================================================
    // GCTR FUNCTION for DATA.
    // =========================================================================
    gctr_function_n_blocks
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .N_ROUNDS                   ( N_ROUNDS              ),
        .N_BLOCKS                   ( N_BLOCKS              ),
        .NB_DATA                    ( NB_DATA               ),
        .NB_INC_MODE                ( NB_INC_MODE           )
    )
    u_gctr_function_n_blocks__data
    (
        .o_ciphertext_words_y       ( o_ciphertext_words_y  ),
        .i_plaintext_words_x        ( i_plaintext_words_x   ),
        .i_round_key_vector         ( round_key_vector      ),
        .i_initial_counter_block    ( initial_counter_block ),
        .i_rf_static_inc_mode       ( i_rf_static_inc_mode  ),
        .i_sop                      ( i_sop                 ),
        .i_valid                    ( i_valid               ),
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;
     // .i_skip_bus                 ( 2'b10                 ),  // FIXME: Add...


    // =========================================================================
    // GHASH for TAG.
    // =========================================================================

    // Calculate hash subkey by ciphering the null block with current key schedule.
    aes_round_ladder
    #(
        .NB_BYTE                    ( NB_BYTE               ),
        .N_BYTES                    ( N_BYTES               ),
        .N_ROUNDS                   ( N_ROUNDS              )
    )
    u_aes_round_ladder_ii
    (
        .o_state                    ( hash_subkey_h         ),
        .i_state                    ( {NB_BLOCK{1'b0}}      ),
        .i_round_key_vector         ( round_key_vector      ),
        .i_valid                    ( i_valid               ),
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;

    // GHASH first calculated using AAD.
    ghash_n_blocks
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .N_BLOCKS                   ( 1                     ),
        .LOG2_N_BLOCKS              ( 1                     ),
        .NB_DATA                    ( NB_BLOCK              )
    )
    u_ghash_n_blocks__aad
    (
        .o_data_y                   ( ghash_aad             ),
        .i_data_x_bus               ( i_aad                 ),
        .i_data_x_initial           ( {NB_BLOCK{1'b0}}      ),
        .i_hash_subkey_h            ( hash_subkey_h         ),
        .i_sop                      ( 1'b1                  ),  // Set to 1 since only one block is required.
        .i_valid                    ( i_valid               ),
        .i_skip_bus                 ( 1'b0                  ),  // FIXME: Borrar esta instancia...
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;

    // GHASH for AAD concatenated with ciphertext.
    ghash_n_blocks
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .N_BLOCKS                   ( N_BLOCKS              ),
        .LOG2_N_BLOCKS              ( LOG2_N_BLOCKS         ),
        .NB_DATA                    ( NB_DATA               )
    )
    u_ghash_n_blocks__data
    (
        .o_data_y                   ( ghash_ciphertext      ),
        .i_data_x_bus               ( o_ciphertext_words_y  ),
        .i_data_x_initial           ( ghash_aad             ),
        .i_hash_subkey_h            ( hash_subkey_h         ),
        .i_sop                      ( sop_del               ),
        .i_valid                    ( i_valid               ),
        .i_skip_bus                 ( 2'b10                 ),  // FIXME: Route to top.
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;

    // Delay SOP to trigger GHASH on text after cipher text word is valid (takes into account pipe delay).
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                     ),
        .DELAY                      ( DELAY_SOP_GHASG_DATA  )
    )
    u_common_fix_delay_line_w_valid
    (
        .o_data_out                 ( sop_del               ),
        .i_data_in                  ( i_sop                 ),
        .i_valid                    ( i_valid               ),
        .i_reset                    ( i_reset               ),
        .clock                      ( i_clock               )
    ) ;

    // GHASH calculated for AAD concatenated with ciphertext concatenated with length data.
    ghash_n_blocks
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .N_BLOCKS                   ( 1                     ),
        .LOG2_N_BLOCKS              ( 1                     ),
        .NB_DATA                    ( NB_BLOCK              )
    )
    u_ghash_n_blocks__length
    (
        .o_data_y                   ( ghash_length_word     ),
        .i_data_x_bus               ( ghash_ciphertext      ),
        .i_data_x_initial           ( length_word           ),
        .i_hash_subkey_h            ( hash_subkey_h         ),
        .i_sop                      ( 1'b1                  ),  // Set to 1 since only one block is required.
        .i_valid                    ( i_valid               ),
        .i_skip_bus                 ( 1'b0                  ),  // FIXME: Borrar esta instancia...
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;
    assign  length_word
                = { i_length_aad, i_length_plaintext } ;



    // =========================================================================
    // GCTR for TAG.
    // =========================================================================
    gctr_function_n_blocks
    #(
        .NB_BLOCK                   ( NB_BLOCK              ),
        .N_ROUNDS                   ( N_ROUNDS              ),
        .N_BLOCKS                   ( 1                     ),
        .NB_DATA                    ( NB_BLOCK              ),
        .NB_INC_MODE                ( NB_INC_MODE           )
    )
    u_gctr_function_n_blocks__tag
    (
        .o_ciphertext_words_y       ( o_tag                 ),
        .i_plaintext_words_x        ( ghash_length_word     ),
        .i_round_key_vector         ( round_key_vector      ),
        .i_initial_counter_block    ( j0                    ),
        .i_rf_static_inc_mode       ( i_rf_static_inc_mode  ),
        .i_sop                      ( 1'b1                  ),
        .i_valid                    ( i_valid               ),
        .i_reset                    ( i_reset               ),
        .i_clock                    ( i_clock               )
    ) ;
    // [FIXME] Add a "tag ready" or "new tag" flag.
    // [FIXME] Add FSM to control de enable/valid of each block.
    // [FIXME] Ver que pasa si el tamaño del dato a procesar no es multiplo par de 128. En teoría se rellena con hasta llegar a un paralelismo de 256...
    // [FIXME] Usar siempre el mismo ghash_n_blocks y muxear la entrada para ahorrar gates.


endmodule // aes_round_ladder

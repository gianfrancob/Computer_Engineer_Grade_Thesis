/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : gcm_aes_core_1gctr.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gcm_aes_core_1gctr_2.v 10343 2017-01-09 18:17:22Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gcm_aes_core_1gctr_2
#(
    parameter                                           NB_BLOCK            = 128 ,
    parameter                                           N_BLOCKS            = 2 ,
    parameter                                           LOG2_N_BLOCKS       = 1 ,
    parameter                                           NB_DATA             = (N_BLOCKS*NB_BLOCK) ,
    parameter                                           NB_KEY              = 256 ,
    parameter                                           NB_IV               = 96 ,
    parameter                                           NB_INC_MODE         = 2 ,
    parameter                                           LOG2_NB_DATA_T      = 8 ,   // [HINT]: must the number of bits to remove from i_length_plaintext so it represents the number of clocks for plaintext.
    parameter                                           NB_TIMER            = 10    // [HINT]: Must be big enough to count the number of clock cycles required by plaintext.
)
(
    output  wire    [NB_DATA-1:0]                       o_ciphertext_words_y ,
    output  reg                                         o_fail ,
    output  wire                                        o_sop ,
    output  wire                                        o_valid_text ,
    output  wire    [NB_BLOCK-1:0]                      o_tag ,
    output  wire                                        o_tag_ready ,
    output  wire                                        o_fault_sop_and_keyupdate ,
    input   wire    [NB_DATA-1:0]                       i_plaintext_words_x ,       // Plaintext words
    input   wire    [NB_BLOCK-1:0]                      i_tag ,
    input   wire    [NB_KEY-1:0]                        i_rf_static_key ,           // [HINT]: This is semy static. FIXME.
    input   wire    [NB_BLOCK-1:0]                      i_aad ,                     // [HINT]: This is semy static. FIXME.
    input   wire    [NB_IV-1:0]                         i_iv ,                      // [HINT]: This is semy static. FIXME.
    input   wire    [NB_BLOCK/2-1:0]                    i_length_aad ,              // [HINT]: This is semy static. FIXME.
    input   wire    [NB_BLOCK/2-1:0]                    i_length_plaintext ,        // [HINT]: This is semy static. FIXME.
    input   wire                                        i_sop ,                     // Start of plaintext
    input   wire                                        i_valid_text ,
    input   wire                                        i_valid ,
    input   wire                                        i_update_key ,              // [NOTE] This signal can be double flop synced outside before used.
    input   wire    [NB_INC_MODE-1:0]                   i_rf_static_inc_mode ,      // [FIXME] Add logic so after i_update_key is issued, the key applied to data is swapped with the next sop_i.
    input   wire                                        i_rf_static_encrypt ,
    input   wire                                        i_clear_fault_flags ,
    input   wire                                        i_reset ,
    input   wire                                        i_clock
) ;


    /* // BEGIN: Quick instance.
    gcm_aes_cipher
    #(
        .NB_BLOCK                   (   ),
        .N_BLOCKS                   (   ),
        .NB_DATA                    (   ),
        .NB_KEY                     (   ),
        .NB_IV                      (   ),
        .NB_INC_MODE                (   )
    )
    u_gcm_aes_cipher
    (
        .o_ciphertext_words_y       (   ),
        .o_tag_ready                (   ),
        .o_valid_text               (   ),
        .o_tag                      (   ),
        .o_tag_ready                (   ),
        .o_fault_sop_and_keyupdate  (   ),
        .i_plaintext_words_x        (   ),
        .i_rf_static_key            (   ),
        .i_aad                      (   ),
        .i_iv                       (   ),
        .i_length_aad               (   ),
        .i_length_plaintext         (   ),
        .i_sop                      (   ),
        .i_valid_text               (   ),
        .i_valid                    (   ),
        .i_update_key               (   ),
        .i_rf_static_inc_mode       (   ),
        .i_clear_fault_flags        (   ),
        .i_reset                    (   ),
        .i_clock                    (   )
    ) ;
    // END: Quick instance. */


    // LOCAL PARAMETERS.
    localparam                                          NB_BYTE                 = 8 ;
    localparam                                          N_BYTES                 = 16 ;
    localparam                                          N_ROUNDS                = 14 ;
    localparam                                          N_COLS                  = 4 ;
    localparam                                          N_ROWS                  = N_BYTES / N_COLS ;
    localparam                                          NB_STATE                = N_BYTES * NB_BYTE ;   // NB_BLOCK
    localparam                                          N_BYTES_KEY             = NB_KEY / NB_BYTE ;
    localparam                                          BAD_CONF                = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) || ( N_ROUNDS != 14 ) || ( N_BYTES_KEY != 32 ) ;
    localparam                                          CREATE_REG_LUT          = 1 ;
    localparam                                          GCTR_STAGES_BETWEEN_REGS= 1 ;
    localparam                                          DATA_PROCESS_TIME_AES   = (N_ROUNDS/GCTR_STAGES_BETWEEN_REGS) + 1 + ((N_ROUNDS+1)*CREATE_REG_LUT) ;
    localparam                                          NB_STATE_KEY            = 2 ;
    localparam                                          N_STEPS_KEY             = 4 ;
    localparam                                          LOG2_N_STEPS_KEY        = 3 ;
    localparam                                          NB_TIMER_KEY            = 5 ;
    localparam      [NB_TIMER_KEY-1:0]                  KEY_PROCESS_TIME_SCH_A  = N_ROUNDS - 1 ;
    localparam      [NB_TIMER_KEY-1:0]                  KEY_PROCESS_TIME_SCH_B  = 1 ;
    localparam      [NB_TIMER_KEY-1:0]                  KEY_PROCESS_TIME_AES_A  = N_ROUNDS ;
    localparam      [NB_TIMER_KEY-1:0]                  KEY_PROCESS_TIME_AES_B  = 2 ;
    localparam                                          NB_GHASH_SEL            = 2 ;
    localparam      [NB_GHASH_SEL-1:0]                  GHASH_SEL_DATA          = 0 ;
    localparam                                          NB_STATE_GHASH          = 2 ;


    // INTERNAL SIGNALS.
    reg             [NB_IV-1:0]                         iv_locked ;
    wire            [NB_BLOCK*(N_ROUNDS+1)-1:0]         round_key_vector ;
    reg             [NB_BLOCK*(N_ROUNDS+1)-1:0]         round_key_vector_locked ;
    wire            [NB_BLOCK-1:0]                      j0 ;
    wire            [NB_BLOCK-1:0]                      initial_counter_block ;
    // wire            [NB_BLOCK-1:0]                      hash_subkey_h ;
    reg             [NB_BLOCK-1:0]                      hash_subkey_h_new ;
    reg             [NB_BLOCK-1:0]                      hash_subkey_h_new_d ;
    wire            [NB_BLOCK-1:0]                      hash_subkey_h_locked ;
    wire            [4*NB_DATA-1:0]                     h_power_bus ;
    reg             [4*NB_DATA-1:0]                     h_power_bus_locked ;
    wire            [NB_BLOCK-1:0]                      ghash_ciphertext ;
    reg             [NB_DATA-1:0]                       ghash_i_data_x_bus ;
    wire            [NB_BLOCK-1:0]                      length_word ;
    wire                                                sop_pre ;
    wire                                                sop_i ;
    wire                                                sop_d_a ;
    wire                                                sop_d_b ;
    wire                                                sop_d_b__cipher ;
    wire                                                sop_d_b__decipher ;
    wire                                                sop_d_c ;
    wire                                                muxed_sop ;
    wire            [NB_TIMER_KEY*N_STEPS_KEY-1:0]      timer_bus_key ;
    wire            [N_STEPS_KEY-1:0]                   key_control_bus ;
    wire            [NB_GHASH_SEL-1:0]                  ghash_sel ;
    reg             [NB_GHASH_SEL-1:0]                  ghash_sel_d ;
    wire            [NB_TIMER-1:0]                      length_plaintext_f ;
    wire            [N_BLOCKS-1:0]                      ghash_skip_bus ;
    wire                                                fault_sop_and_keyupdate ;
    wire                                                valid_ghash ;
    wire                                                valid_ghash_d ;
    wire                                                valid_ghash_length ;
    wire                                                valid_ghash_data ;
    wire                                                valid_ghash_data_d ;
    // wire            [NB_BLOCK-1:0]                      j0_tag ;
    reg             [NB_BLOCK-1:0]                      ghash_ciphertext_locked ;
    reg             [NB_BLOCK-1:0]                      j0_tag_new ;
    reg                                                 sop_o_x ;
    wire            [NB_DATA-1:0]                       pre_blocks ;




    // ALGORITHM BEGIN.

    // =========================================================================
    // J0 GENERATOR.
    // =========================================================================

    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 1                         )
    )
    u_common_fix_delay_line_w_valid__0
    (
        .o_data_out                 ( sop_i                     ),
        .i_data_in                  ( i_sop                     ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;
    assign  sop_pre
                = i_sop ;

    // Lock IV at the begin of each plaintext.
    always @( posedge i_clock )
    begin : l_lock_iv
        if ( i_reset )
            iv_locked
                <= {NB_IV{1'b0}} ;
        else if ( i_valid && sop_i )
            iv_locked
                <= i_iv ;
    end // l_lock_iv

    // Generate J0.
    j0_generator
    #(
        .NB_BLOCK                   ( NB_BLOCK                  ),
        .NB_IV                      ( NB_IV                     )
    )
    u_j0_generator
    (
        .o_j0                       ( j0                        ),
        .i_iv                       ( iv_locked                 )
    ) ;


    // =========================================================================
    // FIRST INC32.
    // =========================================================================
    inc32_block
    #(
        .NB_BLOCK                   ( NB_BLOCK                  ),
        .NB_MODE                    ( NB_INC_MODE               )
    )
    u_inc32_block_0
    (
        .o_block                    ( initial_counter_block     ),
        .i_block                    ( j0                        ),
        .i_rf_static_mode           ( i_rf_static_inc_mode      )
    ) ;


    // =========================================================================
    // KEY SCHEDULER AND GHASH SUB-KEY.
    // =========================================================================

    // FSM that enables/disables sub-key generation blocks.
    pulse_sequencer_fsm
    #(
        .NB_STATE                   ( NB_STATE_KEY              ),  // [HINT] Must be 2.
        .N_STEPS                    ( N_STEPS_KEY               ),
        .LOG2_N_STEPS               ( LOG2_N_STEPS_KEY          ),
        .NB_TIMER                   ( NB_TIMER_KEY              )
    )
    u_pulse_sequencer_fsm
    (
        .o_pulse_bus                ( key_control_bus           ),
        .o_state                    ( /*unused*/                ),
        .i_trigger                  ( i_update_key              ),
        .i_limit_time_bus           ( timer_bus_key             ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;
    assign  timer_bus_key
                = { KEY_PROCESS_TIME_AES_B,
                    KEY_PROCESS_TIME_AES_A,
                    KEY_PROCESS_TIME_SCH_B,
                    KEY_PROCESS_TIME_SCH_A } ;

    // Create a key schedule from input key, required by AES cypher and hash key.
    key_scheduler_sequential_shifter
    #(
        .NB_BYTE                    ( NB_BYTE                   ),
        .N_BYTES_STATE              ( N_BYTES                   ),
        .N_BYTES_KEY                ( N_BYTES_KEY               ),
        .N_ROUNDS                   ( N_ROUNDS                  )
    )
    u_key_scheduler_sequential_shifter
    (
        .o_round_key_vector         ( round_key_vector          ),  // [FIXME] Ver que pasa con el cambio de key vs la latencia del AES-round-ladder.
        .i_key                      ( i_rf_static_key           ),
        .i_trigger_schedule         ( i_update_key              ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;

    // Calculate hash subkey by ciphering the null block with current key schedule.
    // [FIXED] Replaced piped version with parallel version to save cells..
    // [FIXME] Tal ves se puede compartir con el bloque de GCTR para el tag.
 // aes_round_ladder_sequential
 // #(
 //     .NB_BYTE                    ( NB_BYTE                   ),
 //     .N_BYTES                    ( N_BYTES                   ),
 //     .N_ROUNDS                   ( N_ROUNDS                  )
 // )
 // u_aes_round_ladder_sequential   //__key
 // (
 //     .o_state                    ( hash_subkey_h             ),
 //     .o_state_ready              ( /*unused*/                ),  // FIXME: usar esto en vez de key_control_bus[ 1+1+1 ]...
 //     .i_state                    ( {NB_BLOCK{1'b0}}          ),
 //     .i_round_key_vector         ( round_key_vector          ),
 //     .i_trigger                  ( key_control_bus[ 1 ]      ),
 //     .i_valid                    ( 1'b1                      ),
 //     .i_reset                    ( i_reset                   ),
 //     .i_clock                    ( i_clock                   )
 // ) ;

    // Calculate higher powers of H-subkey (required by KOA-GHASH).
    subkey_h_powers_generator
    #(
        .NB_DATA                    ( NB_BLOCK                  ),
        .LOG2_NB_DATA               ( LOG2_NB_DATA_T            ),
        .MAX_POWER                  ( /*N_BLOCKS*/8             )
    )
    u_subkey_h_powers_generator
    (
        .o_h_power_bus              ( h_power_bus               ),
        .o_powers_ready             ( /*unused*/                ),
     // .i_subkey_h                 ( hash_subkey_h             ),
        .i_subkey_h                 ( hash_subkey_h_new         ),  // FIXME: Agregar sistema para que se actualize bien ante un cambio del key.
        .i_valid                    ( i_valid                   ),
     // .i_trigger                  ( key_control_bus[ 1+1+1 ]  ),
        .i_trigger                  ( trigger_fixme             ),  // FIXME:
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;
    always @( posedge i_clock )
        hash_subkey_h_new_d
            <= hash_subkey_h_new ;
    assign  trigger_fixme
                = ( hash_subkey_h_new != hash_subkey_h_new_d ) ;

    always @( posedge i_clock )
    begin : l_lock_key_sched
        if ( i_reset )
            round_key_vector_locked
                <= {NB_BLOCK*(N_ROUNDS+1){1'b0}} ;
        else if ( i_valid && sop_i )
            round_key_vector_locked
                <= round_key_vector ;
    end // l_lock_key_sched

    always @( posedge i_clock )
    begin : l_lock_ghash
        if ( i_reset )
            h_power_bus_locked
                <= {NB_DATA{1'b0}} ;
        else if ( i_valid && sop_i )
            h_power_bus_locked
                <= h_power_bus ;  // [FIXME] Ver que pasa con el cambio de key vs la latencia del AES-round-ladder.
    end // l_lock_ghash
    assign  hash_subkey_h_locked
                = h_power_bus_locked[ 0 +: NB_BLOCK ] ;

    // [FIXED] Added alarm latching for detecting if sop_i comes when key_schedule and ghash_subkey are not ready.
    // O puede hacerce que mientras el valid-bus-key!=0, el sop_i se ignore.
    common_flag_check
    #(
        .FAULT_VALUE                ( 1                         )
    )
    u_common_flag_check
    (
        .o_fault                    ( o_fault_sop_and_keyupdate ),
        .i_clear_fault_flag         ( i_clear_fault_flags       ),
        .i_flag_to_check            ( fault_sop_and_keyupdate   ),
        .i_valid                    ( 1'b1                      ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;
    assign  fault_sop_and_keyupdate
                = ( i_update_key | (|key_control_bus) ) & sop_i ;



    // =========================================================================
    // GCTR FUNCTION for DATA.
    // =========================================================================

    // Delay SOP to match first data.
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 1                         )
    )
    u_common_fix_delay_line_w_valid__a
    (
        .o_data_out                 ( sop_d_a                   ),  // [FIXME] Ver si no conviene poner un sop_i en fase con el primer dato y registrar los datos de entrada para evitar problemas de timing en la interface.
        .i_data_in                  ( sop_i                     ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;

    // GCTR function.
    gctr_function_n_blocks_xor_data_shared
    #(
        .NB_BLOCK                   ( NB_BLOCK                  ),
        .N_ROUNDS                   ( N_ROUNDS                  ),
        .N_BLOCKS                   ( N_BLOCKS                  ),
        .NB_DATA                    ( NB_DATA                   ),
        .NB_INC_MODE                ( NB_INC_MODE               ),
        .STAGES_BETWEEN_REGS        ( GCTR_STAGES_BETWEEN_REGS  ),
        .CREATE_REG_LUT             ( CREATE_REG_LUT            )
    )
    u_gctr_function_n_blocks_xor_data_shared
    (
        .o_ciphertext_words_y       ( o_ciphertext_words_y      ),
        .o_valid                    ( x_o_valid_text            ),
        .i_plaintext_words_x        ( i_plaintext_words_x       ),
        .i_round_key_vector         ( round_key_vector_locked   ),
        .i_initial_counter_block    ( initial_counter_block     ),
        .i_rf_static_inc_mode       ( i_rf_static_inc_mode      ),
        .i_sop                      ( sop_d_a                   ),
        .i_sop_pre                  ( sop_i                     ),
        .i_pre_blocks               ( pre_blocks                ),
        .i_valid                    ( i_valid_text              ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;
     // .i_skip_bus                 ( 2'b10                     ),  // FIXME: Add...
    assign  pre_blocks
                = { {NB_BLOCK{1'b0}}, j0 } ;
    always @( posedge i_clock )
    begin
        if ( i_reset )
        begin
            hash_subkey_h_new
                <= {NB_BLOCK{1'b0}} ;
            j0_tag_new
                <= {NB_BLOCK{1'b0}} ;
        end
        else if ( i_valid && sop_d_b__cipher )
        begin
            hash_subkey_h_new
                <= o_ciphertext_words_y[ NB_DATA-1 - 0*NB_BLOCK -: NB_BLOCK ] ;
            j0_tag_new
                <= o_ciphertext_words_y[ NB_DATA-1 - 1*NB_BLOCK -: NB_BLOCK ] ;
        end
    end
    assign  o_valid_text
                = x_o_valid_text & ~sop_d_b__cipher ;

    // Delay SOP to trigger GHASH on text after cipher text word is valid (takes into account GCTR pipe delays).
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( DATA_PROCESS_TIME_AES     )
    )
    u_common_fix_delay_line_w_valid__b_c
    (
        .o_data_out                 ( sop_d_b__cipher           ),
        .i_data_in                  ( sop_i                     ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 1                         )
    )
    u_common_fix_delay_line_w_valid__b_d
    (
        .o_data_out                 ( sop_d_b__decipher         ),
        .i_data_in                  ( sop_d_a                   ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;
    assign  sop_d_b
                = ( i_rf_static_encrypt )? sop_d_b__cipher : sop_d_b__decipher ;
    always @( posedge i_clock )
        if ( i_reset )
            sop_o_x
                <= 1'b0 ;
        else if ( i_valid )
            sop_o_x
                <= sop_d_b__cipher ;
    assign  o_sop
                = ( i_rf_static_encrypt )? sop_d_b : sop_o_x ;



    // =========================================================================
    // GHASH for TAG.
    // =========================================================================

    // Length word assembly.
    assign  length_word
                = { i_length_aad, i_length_plaintext } ;

    assign  muxed_sop
                = ( i_rf_static_encrypt )? sop_d_b : sop_i ;

    assign  muxed_valid_text
                = ( i_rf_static_encrypt )? o_valid_text : i_valid_text ;

    // FSM that generates valid for ghash and monitors i_valid_text.
    gcm_aes_cipher_tag_fsm
    #(
        .NB_TIMER                   ( NB_TIMER                  ),
        .NB_SEL                     ( NB_GHASH_SEL              )
    )
    u_gcm_aes_cipher_tag_fsm
    (
        .o_sel_ghash_in             ( ghash_sel                 ),
        .o_valid_data               ( valid_ghash_data          ),
        .o_valid_data_d             ( valid_ghash_data_d        ),
        .o_valid_length             ( valid_ghash_length        ),
        .o_valid_length_d           ( /*unused*/                ),
        .o_valid_ghash              ( valid_ghash               ),
        .o_valid_ghash_d            ( valid_ghash_d             ),
        .o_valid_tag                ( valid_tag                 ),
        .i_sop_del                  ( muxed_sop                 ),
        .i_length_plaintext         ( length_plaintext_f        ),
        .i_valid_data               ( muxed_valid_text          ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;
    assign  length_plaintext_f
                = i_length_plaintext[ LOG2_NB_DATA_T +: NB_TIMER ] ;
    // [FIXME] Poner checkeo de error si siguen llegando valids luego de recibir un "frame" completo.

    // GHASH input data selection and pipe.
    // GHASH_SEL_AAD   : ghash_i_data_x_bus    <= i_aad ; // This is needed if length_i_aad>128bits.
    always @( posedge i_clock )
    begin : l_mux_ghash_in
        if ( i_reset )
            ghash_i_data_x_bus
                <= {NB_DATA{1'b0}} ;
        else if ( valid_ghash )
            case ( ghash_sel )
                GHASH_SEL_DATA  : ghash_i_data_x_bus    <= ( i_rf_static_encrypt )? o_ciphertext_words_y : i_plaintext_words_x ;
                default         : ghash_i_data_x_bus    <= length_word ;
            endcase
    end // l_mux_ghash_in

    // As data is delayed, so its the selection indicator to generate the skip bus.
    always @( posedge i_clock )
    begin
        if ( i_reset )
            ghash_sel_d     <= {NB_GHASH_SEL{1'b0}} ;
        else if ( valid_ghash )
            ghash_sel_d     <= ghash_sel ;
        else
            ghash_sel_d     <= {NB_GHASH_SEL{1'b0}} ;
    end
    // assign  ghash_skip_bus
    //             = ( ghash_sel_d==0 )? 2'b00 : 2'b10 ;
    assign  ghash_skip_bus
                = ( ghash_sel==0 )? 2'b00 : 2'b10 ;     // Aca tmbien se retrasa uno el skip bus


    // As data is delayed, SOP is delayed as well.
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 1+1-1                       ) // -1 is beacuase ghash_new need sop 1 clock earlier
    )
    u_common_fix_delay_line_w_valid__c
    (
        .o_data_out                 ( sop_d_c                   ),
        .i_data_in                  ( sop_d_b                   ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;

    // GHASH for AAD concatenated with ciphertext.
    // [NOTE] Renamed from ghash_core_koa_parallel to ghash_koa_n_blocks.
    // ghash_koa_n_blocks
    // #(
    //     .NB_BLOCK                   ( NB_BLOCK                  ), 
    //     .N_BLOCKS                   ( N_BLOCKS                  ),
    //     .NB_DATA                    ( NB_DATA                   )
    // )
    // u_ghash_koa_n_blocks
    // (
    //     .o_data_y                   ( ghash_ciphertext          ),
    //     .i_data_x                   ( ghash_i_data_x_bus        ),
    //     .i_data_x_prev              ( i_aad                     ),
    //     .i_h_key_powers             ( h_power_bus_locked        ),
    //     .i_skip_bus                 ( ghash_skip_bus            ),
    //     .i_sop                      ( muxed_sop_ghash           ),
    //     .i_valid                    ( valid_ghash_d             ),
    //     .i_reset                    ( i_reset                   ),
    //     .i_clock                    ( i_clock                   )
    // ) ;
    ghash_wrapper
    #(   
        .NB_BLOCK               ( NB_BLOCK              ),
        .N_BLOCKS               ( N_BLOCKS              ),
        .NB_DATA                ( NB_DATA               ),
        .USE_NEW_GHASH          ( 1                     ),
        .N_H_POW                ( 8                     ),
        .N_MESSEGES             ( 510 )                     // Aca falta declarar un parametro para la cantidad de mensajes
    )
    u_ghash_wrapper
    (
        .o_ghash_ciphertext     ( ghash_ciphertext      ),
        .i_ghash_i_data_x_bus   ( ghash_i_data_x_bus    ),        
        .i_aad                  ( i_aad                 ),                     
        .i_h_power_bus          ( h_power_bus_locked    ),        
        .i_ghash_skip_bus       ( ghash_skip_bus        ),        
        .i_sop_ghash            ( muxed_sop_ghash       ),        
        .i_valid_ghash          ( /*valid_ghash_d*/valid_ghash         ),    // Aca tambien se pone en valid un clock antes para poder tomar el primer mensaje    
        .i_reset                ( i_reset               ),        
        .i_clock                ( i_clock               )        
    );
    assign  muxed_sop_ghash
                = ( i_rf_static_encrypt )? sop_d_c : sop_d_b ;
 // ghash_core_koa_pipe_parallel
 // #(
 //     .NB_BLOCK                   ( NB_BLOCK                  ), 
 //     .N_BLOCKS                   ( N_BLOCKS                  ),
 //     .NB_DATA                    ( NB_DATA                   ) 
 // )
 // u_ghash_core_koa_pipe_parallel
 // (
 //     .o_data_y                   (                           ),
 //     .i_data_x                   ( ghash_i_data_x_bus        ),
 //     .i_data_x_prev              ( i_aad                     ),
 //     .i_h_key_powers             ( h_power_bus_locked        ),
 //     .i_skip_bus                 ( ghash_skip_bus            ),
 //     .i_sop                      ( sop_d_c                   ),
 //     .i_valid                    ( valid_ghash_d             ),
 //     .i_reset                    ( i_reset                   ),
 //     .i_clock                    ( i_clock                   )
 // ) ;
    // FIXME: Revisar la parametrización del skip bus.
    // FIXME: Arreglar la version que cierra timing (ghash_core_koa_pipe_parallel)...



    // =========================================================================
    // GCTR for TAG.
    // =========================================================================
    // [FIXME] Ver que pasa si el tamaño del dato a procesar no es multiplo par de 128. En teoría se rellena hasta llegar a un paralelismo de 256...
    // [FIXME] Usar siempre el mismo ghash_n_blocks y muxear la entrada para ahorrar gates.
    // [FIXME] Ver de modificarlo para que se puedan soportar distintas longitudes de clave dependiendo de una entrada de config.
    // FIXME: Revisar word flipping
    // FIXME: Poner modo "autentication only".
 // aes_round_ladder_sequential
 // #(
 //     .NB_BYTE                    ( NB_BYTE                   ),
 //     .N_BYTES                    ( N_BYTES                   ),
 //     .N_ROUNDS                   ( N_ROUNDS                  )
 // )
 // u_aes_round_ladder_sequential__tag  // FIXME: Intentar usar el GCTR-xor-data.
 // (
 //     .o_state                    ( j0_tag                    ),
 //     .o_state_ready              ( o_tag_ready               ),
 //     .i_state                    ( j0                        ),
 //     .i_round_key_vector         ( round_key_vector          ),
 //     .i_trigger                  ( valid_tag                 ),
 //     .i_valid                    ( 1'b1                      ),
 //     .i_reset                    ( i_reset                   ),
 //     .i_clock                    ( i_clock                   )
 // ) ;
  // Because GHASH has certain latency, the tag ready signal must me delayed acordingly.
  wire valid_tag_delay;
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 9                         )
    )
    u_common_fix_delay_line_w_valid__tag
    (
        .o_data_out                 ( valid_tag_delay           ),
        .i_data_in                  ( valid_tag                 ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;
    assign  o_tag
                = j0_tag_new ^ ghash_ciphertext_locked ;
    always @( posedge i_clock )
        if ( i_reset )
            ghash_ciphertext_locked
                <= {NB_BLOCK{1'b0}} ;
        else if ( i_valid && /*valid_tag*/valid_tag_delay )
            ghash_ciphertext_locked
                <= ghash_ciphertext ;


    always @( posedge i_clock )
    begin : l_fail_flag
        if ( i_reset || sop_i && i_valid )
            o_fail
                <= 1'b0 ;
        else if ( i_valid && o_tag_ready )
            o_fail
                <= ( i_rf_static_encrypt )? 1'b0 : ( o_tag != i_tag ) ;
    end // l_fail_flag



endmodule // aes_round_ladder

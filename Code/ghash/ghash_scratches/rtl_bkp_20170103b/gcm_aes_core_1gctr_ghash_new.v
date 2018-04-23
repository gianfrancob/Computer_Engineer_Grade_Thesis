/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : gcm_aes_core_1gctr_ghash_new.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gcm_aes_core_1gctr_ghash_new.v 10707 2017-02-22 19:01:44Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the GCM-AES algorithm
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 -------------------------------------------------------------------------------
 ------------------------------------------------------------------------------*/

module gcm_aes_core_1gctr_ghash_new
#(
    parameter                                           NB_BLOCK            = 128 ,
    parameter                                           N_BLOCKS            = 2 ,
    parameter                                           LOG2_N_BLOCKS       = 1 ,
    parameter                                           NB_DATA             = (N_BLOCKS*NB_BLOCK) ,
    parameter                                           NB_KEY              = 256 ,
    parameter                                           NB_IV               = 96 ,
    parameter                                           NB_INC_MODE         = 2 ,
    parameter                                           LOG2_NB_DATA_T      = 8 ,       // [HINT]: must the number of bits to remove from i_length_plaintext so it represents the number of clocks for plaintext.
    parameter                                           NB_TIMER            = 10 ,      // [HINT]: Must be big enough to count the number of clock cycles required by plaintext.
    parameter                                           USE_LUT_IN_SUBBYTES = 0 ,
    parameter                                           NB_N_MESSAGES       = 10
)
(
    output  wire    [NB_DATA-1:0]                       o_ciphertext_words_y ,
    output  reg                                         o_fail ,
    output  wire                                        o_sop ,
    output  wire                                        o_valid_text ,
    output  wire    [NB_BLOCK-1:0]                      o_tag ,
    output  reg                                         o_tag_ready ,
    output  wire                                        o_fault_sop_and_keyupdate ,
    input   wire    [NB_DATA-1:0]                       i_plaintext_words_x ,           // Plaintext words
    input   wire    [NB_BLOCK-1:0]                      i_tag ,
    input   wire    [NB_KEY-1:0]                        i_rf_static_key ,               // [HINT]: This is semy static. FIXME.
    input   wire    [NB_DATA-1:0]                       i_rf_static_aad ,               // [HINT]: This is semy static. FIXME.
    input   wire    [NB_IV-1:0]                         i_rf_static_iv ,                // [HINT]: This is semy static. FIXME.
    input   wire    [NB_BLOCK/2-1:0]                    i_rf_static_length_aad ,        // [HINT]: This is semy static. FIXME.
    input   wire    [NB_BLOCK/2-1:0]                    i_rf_static_length_plaintext ,  // [HINT]: This is semy static. FIXME.
    input   wire                                        i_sop ,                         // Start of plaintext
    input   wire                                        i_valid_text ,
    input   wire                                        i_valid ,
    input   wire                                        i_update_key ,                  // [NOTE] This signal can be double flop synced outside before used.
    input   wire    [NB_INC_MODE-1:0]                   i_rf_static_inc_mode ,          // [FIXME] Add logic so after i_update_key is issued, the key applied to data is swapped with the next sop_i.
    input   wire                                        i_rf_mode_gmac ,
    input   wire                                        i_rf_static_encrypt ,
    input   wire                                        i_clear_fault_flags ,
    input   wire                                        i_reset ,
    input   wire                                        i_clock
) ;


    /* // BEGIN: Quick instance.
    gcm_aes_core_1gctr_ghash_new
    #(
        .NB_BLOCK                       (  ),
        .N_BLOCKS                       (  ),
        .NB_DATA                        (  ),
        .NB_KEY                         (  ),
        .NB_IV                          (  ),
        .NB_INC_MODE                    (  ),
        .USE_LUT_IN_SUBBYTES            (  ),
        .NB_N_MESSAGES                  (  )
    )
    u_gcm_aes_core_1gctr_ghash_new
    (
        .o_ciphertext_words_y           (  ),
        .o_fail                         (  ),
        .o_sop                          (  ),
        .o_tag_ready                    (  ),
        .o_valid_text                   (  ),
        .o_tag                          (  ),
        .o_fault_sop_and_keyupdate      (  ),
        .i_plaintext_words_x            (  ),
        .i_tag                          (  ),
        .i_rf_static_key                (  ),
        .i_rf_static_aad                (  ),
        .i_rf_static_iv                 (  ),
        .i_rf_static_length_aad         (  ),
        .i_rf_static_length_plaintext   (  ),
        .i_sop                          (  ),
        .i_valid_text                   (  ),
        .i_valid                        (  ),
        .i_update_key                   (  ),
        .i_rf_static_inc_mode           (  ),
        .i_gmac_mode                    (  ),
        .i_rf_static_encrypt            (  ),
        .i_clear_fault_flags            (  ),
        .i_reset                        (  ),
        .i_clock                        (  )
    ) ;
    // END: Quick instance. */


    // FIXME: Ver "locking" de "IV"


    // LOCAL PARAMETERS.
    localparam                                          NB_BYTE                 = 8 ;
    localparam                                          N_BYTES                 = 16 ;
    localparam                                          N_ROUNDS                = 14 ;
    localparam                                          N_COLS                  = 4 ;
    localparam                                          N_ROWS                  = N_BYTES / N_COLS ;
    localparam                                          NB_STATE                = N_BYTES * NB_BYTE ;
    localparam                                          N_BYTES_KEY             = NB_KEY / NB_BYTE ;
    localparam                                          BAD_CONF                = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) || ( N_ROUNDS != 14 ) || ( N_BYTES_KEY != 32 ) ;
    localparam                                          CREATE_REG_LUT          = 1 ;
    localparam                                          GCTR_STAGES_BETWEEN_REGS= 1 ;
    localparam                                          ALG_SUBBYTES_DELAY      = (USE_LUT_IN_SUBBYTES==1) ?  0 : 1;
    localparam                                          DATA_PROCESS_TIME_AES   = (N_ROUNDS/GCTR_STAGES_BETWEEN_REGS) + 1 + ((N_ROUNDS+1)*CREATE_REG_LUT) + (N_ROUNDS*ALG_SUBBYTES_DELAY) ;
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
    localparam                                          N_BYTES_STATE           = 16 ;
    localparam                                          ROUND_FIRST_DELAY       = 1 ;
    localparam                                          ROUND_MIDDLE_DELAY      = 3 ;
    localparam                                          ROUND_LAST_DELAY        = 3 ;


    // INTERNAL SIGNALS.
    reg             [NB_IV-1:0]                         iv_locked ;
    wire            [NB_BLOCK*(N_ROUNDS+1)-1:0]         round_key_vector ;
    wire            [NB_BLOCK*(N_ROUNDS+1)-1:0]         x_round_key_vector ;
    reg             [NB_BLOCK*(N_ROUNDS+1)-1:0]         round_key_vector_locked ;
    wire            [NB_BLOCK-1:0]                      j0 ;
    wire            [NB_BLOCK-1:0]                      initial_counter_block ;
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
    wire                                                ghash_done ;
    wire                                                ghash_done_posedge ;
    reg             [NB_BLOCK-1:0]                      ghash_ciphertext_locked ;
    reg             [NB_BLOCK-1:0]                      j0_tag_new ;
    reg             [NB_BLOCK-1:0]                      j0_tag_locked ;
    reg                                                 sop_o_x ;
    wire            [NB_DATA-1:0]                       pre_blocks ;
    wire                                                key_sched_ready ;
    wire            [NB_DATA-1:0]                       x_ciphertext_words_y ;
    wire            [NB_N_MESSAGES-1:0]                 n_messages ;
    wire            [NB_N_MESSAGES-1:0]                 n_aad ;




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
    assign  sop_pre = i_sop ;

    // Lock IV at the begin of each plaintext.
    always @( posedge i_clock )
    begin : l_lock_iv
        if ( i_reset )
            iv_locked   <= {NB_IV{1'b0}} ;
        else if ( i_valid && i_sop )
            iv_locked   <= i_rf_static_iv ;
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
    key_update_fsm
    #(
        .NB_STATE                   ( /*3*/4                             ) // Chequear con rami si esta bien
    )
    u_key_update_fsm
    (
        .o_trigger_key_sched_calc   ( x_trigger_key_sched_calc      ),
        .o_trigger_j0_and_h_calc    ( x_trigger_j0_and_h_calc       ),
        .o_trigger_h_powers_calc    ( x_trigger_h_powers_calc       ),
        .o_h_powers_lock            ( x_h_powers_lock               ),
        .o_key_sched_lock           ( x_key_sched_lock              ),
        .o_switch_h_powers          ( x_switch_h_powers             ),
        .o_key_update_done          ( o_key_update_done             ),
        .o_state                    ( /*fixme*/                     ),
        .i_key_update               ( i_update_key                  ),     // FIXME: Usar i_update_key dentro de la FSM.
        .i_key_sched_ready          ( key_sched_ready               ),
        .i_sop_pre                  ( i_sop                         ),
        .i_sop                      ( i_sop                         ),
        .i_sop_ghash                ( muxed_sop_ghash               ),
        .i_h_ready_pre              ( sop_d_b                       ),
        .i_h_ready                  ( sop_o_x                       ),
        .i_h_powers_ready           ( x_h_powers_ready              ),
        .i_key_sched_lock_done      ( key_switcher_loading_done     ),
        .i_valid                    ( i_valid                       ),
        .i_reset                    ( i_reset                       ),
        .i_clock                    ( i_clock                       )
    ) ;

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
        .o_output_ready             ( key_sched_ready           ),
        .i_key                      ( i_rf_static_key           ),
        .i_trigger_schedule         ( x_trigger_key_sched_calc  ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;

    // Calculate hash subkey by ciphering the null block with current key schedule.
    // [FIXED] Replaced piped version with parallel version to save cells..
    // [FIXME] Tal ves se puede compartir con el bloque de GCTR para el tag.
    key_scheduler_switcher
    #(
        .NB_BYTE                 ( NB_BYTE                      ),
        .N_BYTES_STATE           ( N_BYTES_STATE                ),
        .N_ROUNDS                ( N_ROUNDS                     ),
        .ROUND_FIRST_DELAY       ( ROUND_FIRST_DELAY            ),
        .ROUND_MIDDLE_DELAY      ( ROUND_MIDDLE_DELAY           ),
        .ROUND_LAST_DELAY        ( ROUND_LAST_DELAY             ),
        .NB_TIMER                ( NB_TIMER                     ) // [HINT] Must be big enough to count up to ROUND_*_DELAY
    )
    u_key_scheduler_switcher
    (
        .o_round_key_vector      ( x_round_key_vector           ),
        .o_muxing_done           ( /*unused*/                   ),
        .o_loading_done          ( key_switcher_loading_done    ),
        .i_round_key_vector      ( round_key_vector             ),
        .i_trigger_muxing        ( x_trigger_j0_and_h_calc      ) ,
        .i_trigger_loading       ( x_key_sched_lock             ) ,
        .i_valid                 ( i_valid                      ) ,
        .i_reset                 ( i_reset                      ) ,
        .i_clock                 ( i_clock                      )
    ) ;

    // Calculate higher powers of H-subkey (required by KOA-GHASH).
    subkey_h_powers_generator
    #(
        .NB_DATA                    ( NB_BLOCK                  ),
        .LOG2_NB_DATA               ( LOG2_NB_DATA_T            ),
        .MAX_POWER                  ( 8                         )
    )
    u_subkey_h_powers_generator
    (
        .o_h_power_bus              ( h_power_bus               ),
        .o_powers_ready             ( x_h_powers_ready          ),
        .i_subkey_h                 ( hash_subkey_h_new         ),  // FIXME: Agregar sistema para que se actualize bien ante un cambio del key.
        .i_valid                    ( i_valid                   ),
        .i_trigger                  ( x_trigger_h_powers_calc   ),
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
    end // l_lock_key_sched

    always @( posedge i_clock )
    begin : l_lock_ghash
        if ( i_reset )
            h_power_bus_locked
                <= {NB_DATA{1'b0}} ;
        else if ( i_valid && x_switch_h_powers )
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
        .CREATE_REG_LUT             ( CREATE_REG_LUT            ),
        .USE_LUT_IN_SUBBYTES        ( USE_LUT_IN_SUBBYTES       )
    )
    u_gctr_function_n_blocks_xor_data_shared
    (
        .o_ciphertext_words_y       ( x_ciphertext_words_y      ),
        .o_valid                    ( x_o_valid_text            ),
        .i_plaintext_words_x        ( i_plaintext_words_x       ),
        .i_round_key_vector         ( x_round_key_vector        ),
        .i_initial_counter_block    ( initial_counter_block     ),
        .i_rf_static_inc_mode       ( i_rf_static_inc_mode      ),
        .i_rf_mode_gmac             ( i_rf_mode_gmac            ),
        .i_sop                      ( sop_d_a                   ),      // NO TIENE EN CUENTA LA CANTIDAD DE MENSAJES, SOLO VALIDs, POR LO TANTO NO LE PUEDEN LLEGAR MENSAJES CON PARELELISMO 128.
        .i_sop_pre                  ( sop_i                     ),
        .i_pre_blocks               ( pre_blocks                ),
        .i_valid                    ( i_valid_text              ),
        .i_reset                    ( i_reset                   ),
        .i_clock                    ( i_clock                   )
    ) ;
    assign  o_ciphertext_words_y
                = ( sop_d_b__cipher )? {NB_DATA{1'b0}} : x_ciphertext_words_y ;
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
        else if ( i_valid && /*sop_d_b__cipher*/x_h_powers_lock ) // Chequear con rami si esta bien
        begin
            hash_subkey_h_new
                <= x_ciphertext_words_y[ NB_DATA-1 - 0*NB_BLOCK -: NB_BLOCK ] ;
            j0_tag_new
                <= x_ciphertext_words_y[ NB_DATA-1 - 1*NB_BLOCK -: NB_BLOCK ] ;
        end
    end
    assign  o_valid_text
                = x_o_valid_text & ~sop_d_b__cipher ;

    always @( posedge i_clock ) begin
        if ( i_reset )
            j0_tag_locked   <= {NB_BLOCK{1'b0}} ;
        else if ( i_valid && o_key_update_done )
            j0_tag_locked   <= j0_tag_new ;
    end

    // Delay SOP to trigger GHASH on text after cipher text word is valid (takes into account GCTR pipe delays).
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( DATA_PROCESS_TIME_AES-1   )  // Chequear con rami si esta bien
    )
    u_common_fix_delay_line_w_valid__b_c_pre
    (
        .o_data_out                 ( sop_d_b__cipher_pre       ),
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
    u_common_fix_delay_line_w_valid__b_c
    (
        .o_data_out                 ( sop_d_b__cipher           ),
        .i_data_in                  ( sop_d_b__cipher_pre       ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( /*1*//*0*/DATA_PROCESS_TIME_AES-1 )  // Chequear con rami si esta bien
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
                = ( i_rf_static_encrypt )? sop_d_b__cipher : sop_d_b__decipher ;            // GMAC MUX
    always @( posedge i_clock )
        if ( i_reset )
            sop_o_x
                <= 1'b0 ;
        else if ( i_valid ) // GMAC MUX
            sop_o_x
                <= sop_d_b__cipher ;
    assign  o_sop
                = ( i_rf_static_encrypt )? /*sop_d_b*/sop_d_b__cipher_pre : sop_o_x ;  // Chequear con rami si esta bien // GMAC MUX



    // =========================================================================
    // GHASH for TAG.
    // =========================================================================

    // Length word assembly.
    assign  length_word
                = { i_rf_static_length_aad, i_rf_static_length_plaintext } ;

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
                =   i_rf_static_length_plaintext[ LOG2_NB_DATA_T +: NB_TIMER ]  +
                    {i_rf_static_length_plaintext[7]}                           /*+
                    i_rf_static_length_aad[NB_TIMER+8-1:8]                      */;  // Chequear con rami si esta bien
    // [FIXME] Poner checkeo de error si siguen llegando valids luego de recibir un "frame" completo.

    // GHASH input data selection and pipe.
    // GHASH_SEL_AAD   : ghash_i_data_x_bus    <= i_rf_static_aad ; // This is needed if length_i_rf_static_aad>128bits.
    always @( posedge i_clock )
    begin : l_mux_ghash_in
        if ( i_reset )
            ghash_i_data_x_bus
                <= {NB_DATA{1'b0}} ;
        else if ( valid_ghash )
            case ( ghash_sel )
                GHASH_SEL_DATA  : ghash_i_data_x_bus    <= ( i_rf_static_encrypt )? o_ciphertext_words_y : i_plaintext_words_x ; // GMAC MUX ( ojo aca solo hay q aprovechar el mux y poner un &)
                default         : ghash_i_data_x_bus    <= ( !{i_rf_static_length_plaintext[7]} )? length_word : { o_ciphertext_words_y[0*NB_BLOCK+:NB_BLOCK], length_word } ; // Chequear con rami si esta bien // GMAC MUX
            endcase
    end // l_mux_ghash_in


    // As data is delayed, so its the selection indicator to generate the skip bus.
    always @( posedge i_clock )
    begin
        if ( i_reset )
            ghash_sel_d <= {NB_GHASH_SEL{1'b0}} ;
        else if ( valid_ghash )
            ghash_sel_d <= ghash_sel ;
    end

    assign  ghash_skip_bus  = ( ghash_sel_d==0 )        ?
                              2'b00                     :
                                ( !{i_rf_static_length_plaintext[7]} )  ?  // Chequear con rami si esta bien
                                2'b10                                   :
                                2'b00                                   ;


    // As data is delayed, SOP is delayed as well.
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 1                         )
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
    assign n_messages       = i_rf_static_length_plaintext[64-1:8] + 1'b1 ;
    assign n_aad            = i_rf_static_length_aad[64-1:8] ;
    assign muxed_sop_ghash  = ( i_rf_static_encrypt )? /*sop_d_c*//*sop_d_b__cipher_pre*/i_sop : /*sop_d_b*//*sop_d_a*/i_sop ; // Chequear con rami si esta bien
    integer valid_ghash_aad_counter ;
    reg valid_ghash_aad ;
    always @( posedge i_clock ) begin
        if ( i_reset || i_rf_static_length_aad[64-1:8] == 0 )
            valid_ghash_aad  <= 1'b0 ;
        else if ( valid_ghash_aad_counter >= i_rf_static_length_aad[64-1:8] - 1'b1 )
            valid_ghash_aad  <= 1'b0 ;
        else if ( muxed_sop_ghash )
            valid_ghash_aad  <=  1'b1 ;
    end
    always @( posedge i_clock ) begin
        if ( i_reset || i_sop || !valid_ghash_aad )
            valid_ghash_aad_counter <= 1'b0 ;
        else if ( valid_ghash_aad )
            valid_ghash_aad_counter <= valid_ghash_aad_counter + 1'b1 ;
    end

    assign ghash_valid = valid_ghash_aad | muxed_sop_ghash | valid_ghash_d ;
    ghash_wrapper
    #(
        .NB_BLOCK               ( NB_BLOCK                      ),
        .N_BLOCKS               ( N_BLOCKS                      ),
        .NB_DATA                ( NB_DATA                       ),
        .USE_NEW_GHASH          ( 1                             ),
        .N_H_POW                ( 8                             ),
        .NB_N_MESSAGES          ( NB_N_MESSAGES                 )
    )
    u_ghash_wrapper
    (
        .o_ghash_ciphertext     ( ghash_ciphertext              ),
        .o_ghash_done           ( ghash_done                    ),
        .i_ghash_i_data_x_bus   ( ghash_i_data_x_bus            ),
        .i_aad                  ( i_rf_static_aad               ),
        .i_h_power_bus          ( h_power_bus_locked            ),
        .i_ghash_skip_bus       ( ghash_skip_bus                ),
        .i_sop_ghash            ( muxed_sop_ghash               ),
        .i_valid_ghash          ( ghash_valid                   ),
        .i_rf_static_n_messages ( n_messages                    ),
        .i_rf_static_n_aad      ( n_aad                         ),
        .i_reset                ( i_reset                       ),
        .i_clock                ( i_clock                       )

    );
    // FIXME: Revisar la parametrización del skip bus.



    // =========================================================================
    // GCTR for TAG.
    // =========================================================================
    // [FIXME] Ver que pasa si el tamaño del dato a procesar no es multiplo par de 128. En teoría se rellena hasta llegar a un paralelismo de 256...
    // [FIXME] Usar siempre el mismo ghash_n_blocks y muxear la entrada para ahorrar gates.
    // [FIXME] Ver de modificarlo para que se puedan soportar distintas longitudes de clave dependiendo de una entrada de config.
    // FIXME: Revisar word flipping
    // FIXME: Poner modo "autentication only".
    common_posedge_det
    u_common_posedge_det
    (
        .o_posedge      ( ghash_done_posedge    ),
        .o_data_del     (                       ),
        .i_data         ( ghash_done            ),
        .i_valid        ( i_valid               ),
        .i_reset        ( i_reset               ),
        .i_clock        ( i_clock               )
    );
    assign  o_tag   = /*j0_tag_new*/j0_tag_locked ^ ghash_ciphertext_locked ;

    always @( posedge i_clock )
        if ( i_reset )
            ghash_ciphertext_locked
                <= {NB_BLOCK{1'b0}} ;
        else if ( i_valid && ghash_done_posedge )
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


    always @( posedge i_clock )
    begin : l_tag_ready_update
        if ( i_reset )
            o_tag_ready
                <= 1'b0 ;
        else if ( i_valid )
            o_tag_ready
                <= /*valid_tag*/ghash_done_posedge ;  // Chequear con rami si esta bien
    end // l_tag_ready_update

endmodule // gcm_aes_core_1gctr_ghash_new

/*------------------------------------------------------------------------------
 -- Project     : CL120020
 -------------------------------------------------------------------------------
 -- File        : gcm_aes_core.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gcm_aes_core.v 10707 2017-02-22 19:01:44Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the GCM-AES algorithm
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 -------------------------------------------------------------------------------
 ------------------------------------------------------------------------------*/

module gcm_aes_core
#(
    parameter                                           NB_BLOCK                = 128                   ,
    parameter                                           N_BLOCKS                = 2                     ,
    parameter                                           LOG2_N_BLOCKS           = 1                     ,
    parameter                                           NB_DATA                 = (N_BLOCKS*NB_BLOCK)   ,
    parameter                                           NB_KEY                  = 256                   ,
    parameter                                           NB_IV                   = 96                    ,
    parameter                                           NB_INC_MODE             = 2                     ,
    parameter                                           LOG2_NB_DATA_T          = 8                     ,   // [HINT]: must the number of bits to remove from i_length_plaintext so it represents the number of clocks for plaintext.
    parameter                                           NB_TIMER                = 10                    ,   // [HINT]: Must be big enough to count the number of clock cycles required by plaintext.
    parameter                                           USE_LUT_IN_SUBBYTES     = 0                     ,
    parameter                                           NB_N_MESSAGES           = 10                    
    // parameter                                           AAD_MSGS  = 1                         // [FIXME] Revisar especificaciones con gente de framer para ver si hace falta que sea fijo o programable durante ejecuccion.
)
(
    output  wire    [ NB_DATA-1:0       ]               o_ciphertext                    ,
    output  wire                                        o_fail                          ,
    output  wire                                        o_sop                           ,
    output  wire                                        o_valid                         ,
    output  wire    [ NB_BLOCK-1:0      ]               o_tag                           ,
    output  wire                                        o_tag_ready                     ,
    output  wire                                        o_fault_sop_and_keyupdate       ,   // FIXME: Rename. Check other possible pathologically timed input controls.
    input   wire    [ NB_DATA-1:0       ]               i_plaintext                     ,   // Plaintext words
    input   wire    [ NB_BLOCK-1:0      ]               i_tag                           ,
    input   wire                                        i_tag_ready                     ,
    input   wire    [ NB_KEY-1:0        ]               i_rf_static_key                 ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
    input   wire    [ NB_DATA-1:0       ]               i_rf_static_aad                 ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
    input   wire    [ NB_IV-1:0         ]               i_rf_static_iv                  ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
    input   wire    [ NB_BLOCK/2-1:0    ]               i_rf_static_length_aad          ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
    input   wire    [ NB_BLOCK/2-1:0    ]               i_rf_static_length_plaintext    ,   // [HINT]: This is semy static. FIXME. Renombrar y resintetizar
    input   wire                                        i_sop                           ,   // Start of plaintext
    input   wire                                        i_valid                         ,
    input   wire                                        i_enable                        ,
    input   wire                                        i_update_key                    ,   // [NOTE] This signal can be double flop synced outside before used.
    input   wire    [ NB_INC_MODE-1:0   ]               i_rf_static_inc_mode            ,   // [FIXME] Revisar si el modo MAC-SEC requiere algo de esto. Si no, eliminar esta entrada.
    input   wire                                        i_rf_mode_gmac                  ,
    input   wire                                        i_rf_static_encrypt             ,
    input   wire                                        i_clear_fault_flags             ,
    input   wire                                        i_reset                         ,
    input   wire                                        i_clock
) ;


// =============================================================================================================================
// QUICK INSTANCE
// =============================================================================================================================
/*
gcm_aes_core
#(
    .NB_BLOCK                       (  ),
    .N_BLOCKS                       (  ),
    .LOG2_N_BLOCKS                  (  ),
    .NB_DATA                        (  ),
    .NB_KEY                         (  ),
    .NB_IV                          (  ),
    .NB_INC_MODE                    (  ),
    .LOG2_NB_DATA_T                 (  ),
    .NB_TIMER                       (  ),
    .USE_LUT_IN_SUBBYTES            (  ),
    .NB_N_MESSAGES                  (  )
)
u_gcm_aes_core
(
    .o_ciphertext                   (  ),
    .o_fail                         (  ),
    .o_sop                          (  ),
    .o_valid                        (  ),
    .o_tag                          (  ),
    .o_tag_ready                    (  ),
    .o_fault_sop_and_keyupdate      (  ),
    .i_plaintext                    (  ),
    .i_tag                          (  ),
    .i_tag_ready                    (  ),
    .i_rf_static_key                (  ),
    .i_rf_static_aad                (  ),
    .i_rf_static_iv                 (  ),
    .i_rf_static_length_aad         (  ),
    .i_rf_static_length_plaintext   (  ),
    .i_sop                          (  ),
    .i_valid                        (  ),
    .i_enable                       (  ),
    .i_update_key                   (  ),
    .i_rf_static_inc_mode           (  ),
    .i_rf_mode_gmac                 (  ),
    .i_rf_static_encrypt            (  ),
    .i_clear_fault_flags            (  ),
    .i_reset                        (  ),
    .i_clock                        (  )
) ;
*/

// =============================================================================================================================
// LOCAL PARAMETERS
// =============================================================================================================================
localparam                                          NB_BYTE                     =   8               ;
localparam                                          N_BYTES                     =   16              ;
localparam                                          N_ROUNDS                    =   14              ;
localparam                                          N_COLS                      =   4               ;
localparam                                          N_ROWS                      =   N_BYTES/N_COLS  ;
localparam                                          NB_STATE                    =   N_BYTES*NB_BYTE ;
localparam                                          N_BYTES_KEY                 =   NB_KEY/NB_BYTE  ;
localparam                                          NB_STATE_KEY_UP_FSM         =   3               ;
localparam                                          NB_STATE_J0_FSM             =   3               ;
localparam                                          N_STEPS_KEY                 =   4               ;
localparam                                          LOG2_N_STEPS_KEY            =   3               ;
localparam                                          N_H_POW                     =   8               ;
localparam                                          NB_GHASH_SEL                =   2               ;
localparam      [ NB_GHASH_SEL-1:0  ]               GHASH_SEL_DATA              =   0               ;
localparam                                          NB_STATE_GHASH              =   2               ;
localparam                                          N_BYTES_STATE               =   16              ;
localparam                                          ROUND_FIRST_DELAY           =   1               ;
localparam                                          ROUND_MIDDLE_DELAY          =   3               ;
localparam                                          ROUND_LAST_DELAY            =   3               ;
localparam                                          GHASH_SELECT_DATA           =   2'b00           ;
localparam                                          GHASH_SELECT_LENGTH         =   2'b01           ;
localparam                                          GHASH_SELECT_AAD            =   2'b10           ;
localparam                                          CREATE_REG_LUT              =   1               ;
localparam                                          GCTR_STAGES_BETWEEN_REGS    =   1               ;
localparam                                          ALG_SUBBYTES_DELAY          =   ( USE_LUT_IN_SUBBYTES == 1 ) ?  0 : 1   ;
localparam                                          BAD_CONF                    =   ( NB_BYTE       != 8  )                ||
                                                                                    ( N_BYTES       != 16 )                ||
                                                                                    ( N_ROUNDS      != 14 )                ||
                                                                                    ( N_BYTES_KEY   != 32 )                 ;
localparam                                          DATA_PROCESS_TIME_AES       =   ( N_ROUNDS/GCTR_STAGES_BETWEEN_REGS )   +
                                                                                    1 + ( (N_ROUNDS+1)*CREATE_REG_LUT)      +
                                                                                    ( N_ROUNDS*ALG_SUBBYTES_DELAY )         ;



// =============================================================================================================================
// INTERNAL SIGNALS
// =============================================================================================================================
reg     [ NB_IV-1:0                 ]               iv_reg                              ;
wire    [ NB_IV-1:0                 ]               iv                                  ;

wire    [ NB_BLOCK-1:0              ]               j0                                  ;

wire    [ NB_BLOCK-1:0              ]               gctr_initial_ctr                    ;

reg     [ NB_KEY-1:0                ]               key_reg                             ;
wire    [ NB_KEY-1:0                ]               key                                 ;
wire    [ NB_BLOCK*(N_ROUNDS+1)-1:0 ]               key_sched_vector                    ;
wire                                                key_sched_done                      ;

wire    [ NB_BLOCK*(N_ROUNDS+1)-1:0 ]               key_switch_key_sched_vector         ;
wire                                                key_switch_load_done                ;

wire    [ NB_DATA-1:0               ]               pre_block                           ;
reg     [ NB_N_MESSAGES-1:0 ]                       pre_block_calc_delay_reg            ;
wire                                                pre_block_calc_delay                ;

wire                                                i_sop_d                             ;
wire                                                gmac                                ;

wire    [ NB_DATA-1:0               ]               gctr_ciphertext                     ;
wire                                                gctr_o_valid                        ;
wire                                                gctr_trigger_pre_block_ciph         ;
wire                                                gctr_i_sop                          ;
wire                                                gctr_i_sop_pre                      ;
wire                                                gctr_o_sop_output                   ;
wire                                                gctr_o_sop_for_ghash                ;
wire                                                gctr_o_sop_pre                      ;
wire                                                gctr_o_sop                          ;
wire                                                gctr_start                          ;
reg     [ NB_DATA-1:0               ]               gctr_ciphered_pre_block_reg         ;
wire    [ NB_DATA-1:0               ]               gctr_ciphered_pre_block             ;

wire    [ 8*NB_BLOCK-1:0            ]               h_power_vector                      ;
wire                                                h_power_vector_done                 ;
reg     [ NB_BLOCK-1:0              ]               h_hash_subkey_reg                   ;
wire    [ NB_BLOCK-1:0              ]               h_hash_subkey                       ;

wire                                                ctrl_o_trigger_key_sched_vector_calc;
wire                                                ctrl_o_trigger_pre_block_ciph       ;
wire                                                ctrl_o_trigger_h_power_vector_calc  ;
wire                                                ctrl_o_h_hash_subkey_lock           ;
wire                                                ctrl_o_h_powers_done                ;
wire                                                ctrl_o_key_sched_lock               ;
wire                                                ctrl_o_key_sched_done               ;
wire                                                ctrl_o_switch_h_powers              ;
wire                                                ctrl_o_key_update_done              ;
wire                                                ctrl_o_trigger_j0_tag_new_locking   ;

wire    [ NB_TIMER:0                ]               plaintext_length                    ;
wire    [ NB_TIMER-1:0              ]               aad_length                          ;

wire    [ NB_GHASH_SEL-1:0          ]               ctrl_o_ghash_i_data_selector        ;
wire                                                ctrl_o_ghash_valid_add              ;
wire                                                ctrl_o_ghash_i_sop                  ;
wire                                                ctrl_o_ghash_i_valid                ;
wire                                                ctrl_o_gctr_i_sop                   ;
wire                                                ctrl_o_gctr_i_sop_pre               ;
wire                                                ctrl_o_gctr_o_sop                   ;
wire                                                ctrl_o_gctr_o_sop_pre               ;
wire                                                ctrl_o_gctr_triggered_o_sop_pre     ;

wire                                                ghash_o_err_sop_sync                ;
wire    [ NB_BLOCK-1:0              ]               ghash_o_data                        ;
reg     [ NB_BLOCK-1:0              ]               ghash_o_data_locked_reg             ;
wire    [ NB_BLOCK-1:0              ]               ghash_o_data_locked                 ;
wire                                                ghash_done                          ;
reg     [ NB_DATA-1:0               ]               ghash_i_data                        ;
wire                                                ghash_i_valid                       ;
wire    [ 8*NB_BLOCK-1:0            ]               ghash_h_power_vector_locked         ;
reg     [ 8*NB_BLOCK-1:0            ]               ghash_h_power_vector_locked_reg     ;
wire    [ NB_BLOCK-1:0              ]               ghash_h_key_locked                  ;
wire    [ NB_BLOCK-1:0              ]               ghash_lenght_vector                 ;
reg     [ N_BLOCKS-1:0              ]               ghash_skip_bus                      ;
wire                                                ghash_sop                           ;
wire                                                ghash_valid                         ;
wire    [ NB_N_MESSAGES-1:0         ]               ghash_n_messages                    ;
wire    [ NB_N_MESSAGES-1:0         ]               ghash_n_aad                         ;


reg                                                 pre_block_done_reg                  ;
wire                                                pre_block_done                      ;
wire    [ NB_BLOCK-1:0              ]               j0_tag                              ;
wire    [ NB_BLOCK-1:0              ]               j0_tag_locked                       ;

reg     [ NB_BLOCK-1:0              ]               i_tag_locked_reg                    ;
wire    [ NB_BLOCK-1:0              ]               i_tag_locked                        ;
reg     [ NB_BLOCK-1:0              ]               tag_reg                             ;


// =============================================================================================================================
// CONTROL FSMs
// =============================================================================================================================
// Key Update FSM
// -----------------------------------------------------------------------------------------
key_update_fsm
#(
    .NB_STATE                       ( NB_STATE_KEY_UP_FSM                   )
)
u_key_update_fsm
(
    .o_trigger_key_sched_calc       ( ctrl_o_trigger_key_sched_vector_calc  ),
    .o_trigger_pre_block_ciph       ( ctrl_o_trigger_pre_block_ciph         ),
    .o_trigger_h_powers_calc        ( ctrl_o_trigger_h_power_vector_calc    ),
    .o_h_powers_done                ( ctrl_o_h_powers_done                  ),
    .o_key_sched_lock               ( ctrl_o_key_sched_lock                 ),
    .o_key_sched_done               ( ctrl_o_key_sched_done                 ),
    .o_switch_h_powers              ( ctrl_o_switch_h_powers                ),
    .o_key_update_done              ( ctrl_o_key_update_done                ),
    .o_trigger_j0_tag_new_locking   ( ctrl_o_trigger_j0_tag_new_locking     ),
    .o_state                        ( /*unused*/                            ),
    .i_key_update                   ( i_update_key                          ),
    .i_key_sched_ready              ( key_sched_done                        ),
    .i_sop_pre                      ( i_sop /*ctrl_o_gctr_i_sop_pre*/       ),
    .i_sop                          ( i_sop_d /*ctrl_o_gctr_i_sop*/         ),
    .i_tag_ready                    ( o_tag_ready                           ),
    .i_h_ready                      ( ctrl_o_gctr_triggered_o_sop_pre       ),
    .i_h_powers_ready               ( h_power_vector_done                   ),
    .i_key_sched_lock_done          ( key_switch_load_done                  ),
    .i_gctr_o_sop_pre               ( ctrl_o_gctr_o_sop_pre                 ),
    .i_rf_static_encrypt            ( i_rf_static_encrypt                   ),
    .i_valid                        ( i_enable                              ),
    .i_reset                        ( i_reset                               ),
    .i_clock                        ( i_clock                               )
) ;


// GCM AES FSM
// -----------------------------------------------------------------------------------------
// FSM that generates control signals related to GCTR and GHASH
// -----------------------------------------------------------------------------------------
assign  plaintext_length    =   i_rf_static_length_plaintext[ LOG2_NB_DATA_T-1 +: NB_TIMER+1 ];
assign  aad_length          =   i_rf_static_length_aad[ LOG2_NB_DATA_T  +: NB_TIMER]    ;

gcm_aes_fsm
#(
    .NB_TIMER                   ( NB_TIMER                          ),
    .NB_SEL                     ( NB_GHASH_SEL                      ),
    .DATA_PROCESS_TIME_AES      ( DATA_PROCESS_TIME_AES             )
)
u_gcm_aes_fsm
(
    .o_ghash_sel_input          ( ctrl_o_ghash_i_data_selector      ),
    .o_ghash_sop                ( ctrl_o_ghash_i_sop                ),
    .o_ghash_valid_aad          ( ctrl_o_ghash_valid_add            ),
    .o_ghash_valid_data         ( /*unsused*/                       ),
    .o_ghash_valid_length       ( /*unsused*/                       ),
    .o_ghash_valid              ( ctrl_o_ghash_i_valid              ),
    .o_gctr_data_sop            ( ctrl_o_gctr_i_sop                 ),
    .o_gctr_data_sop_pre        ( ctrl_o_gctr_i_sop_pre             ),
    .o_gctr_o_sop_for_ghash     ( /*unsused*/                       ),
    .o_gctr_o_sop               ( ctrl_o_gctr_o_sop                 ),
    .o_gctr_o_sop_pre           ( ctrl_o_gctr_o_sop_pre             ),
    .o_gctr_triggered_o_sop_pre ( ctrl_o_gctr_triggered_o_sop_pre   ),
    .i_sop                      ( i_sop                             ),
    .i_trigger_pre_block        ( gctr_trigger_pre_block_ciph       ),
    .i_length_plaintext         ( plaintext_length                  ),
    .i_length_aad               ( aad_length                        ),
    .i_valid_encrypt            ( o_valid                           ),
    .i_valid_decrypt            ( i_valid                           ),
    .i_rf_static_encrypt        ( i_rf_static_encrypt               ),
    .i_enable                   ( i_enable                          ),
    .i_reset                    ( i_reset                           ),
    .i_clock                    ( i_clock                           )
) ;


// =============================================================================================================================
// BAD SOP FLAG LOGIC
// =============================================================================================================================
// // [FIXED] Added alarm latching for detecting if sop_i comes when key_schedule and ghash_subkey are not ready.
// // O puede hacerce que mientras el valid-bus-key!=0, el sop_i se ignore.
// wire fault_sop_and_keyupdate;
// common_flag_check
// #(
//     .FAULT_VALUE                ( 1                         )
// )
// u_common_flag_check
// (
//     .o_fault                    ( o_fault_sop_and_keyupdate ),
//     .i_clear_fault_flag         ( i_clear_fault_flags       ),
//     .i_flag_to_check            ( fault_sop_and_keyupdate   ),
//     .i_valid                    ( 1'b1                      ),
//     .i_reset                    ( i_reset                   ),
//     .i_clock                    ( i_clock                   )
// ) ;
// assign  fault_sop_and_keyupdate
//             = ( i_update_key | (|key_control_bus) ) & /*sop_i*/i_sop_pre ;

// =============================================================================================================================
// i_sop DELAY
// =============================================================================================================================
// "i_sop" Arrives 1 clk sooner ( because key_scheduler_switcher need it
//  that way ), so here is delayed 1 clk in order to proccess DATA correctly.
common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1             ),
    .DELAY                      ( 1             )
)
u_common_fix_delay_line_w_valid__i_sop_d
(
    .o_data_out                 ( i_sop_d       ),
    .i_data_in                  ( i_sop         ),
    .i_valid                    ( i_enable      ),
    .i_reset                    ( i_reset       ),
    .clock                      ( i_clock       )
) ;

// =============================================================================================================================
// IV LOCKING
// =============================================================================================================================
always @( posedge i_clock )
begin: iv_locking
    if ( i_reset )
        iv_reg  <= { NB_IV{ 1'b0 } }    ;
    else if ( i_enable & i_sop )
        iv_reg  <= i_rf_static_iv       ;
end // iv_locking
assign iv   =   ( i_enable & i_sop )?   // cad_ence map_to_mux
                i_rf_static_iv      : iv_reg    ;


// =============================================================================================================================
// J0 GENERATION
// =============================================================================================================================
j0_generator
#(
    .NB_BLOCK                   ( NB_BLOCK  ),
    .NB_IV                      ( NB_IV     )
)
u_j0_generator
(
    .o_j0                       ( j0        ),
    .i_iv                       ( iv        )
) ;


// =============================================================================================================================
// INCR OPERATION
// =============================================================================================================================
inc32_block
#(
    .NB_BLOCK                   ( NB_BLOCK              ),
    .NB_MODE                    ( NB_INC_MODE           )
)
u_inc32_block
(
    .o_block                    ( gctr_initial_ctr      ),
    .i_block                    ( j0                    ),
    .i_rf_static_mode           ( i_rf_static_inc_mode  )
) ;



// =============================================================================================================================
// KEY SCHEDULE GENERATION
// =============================================================================================================================
// Key "K" locking
// -----------------------------------------------------------------------------------------
always @( posedge i_clock )
begin: key_locking
    if ( i_reset )
        key_reg <=  { NB_KEY{ 1'b0 } }  ;
    else if ( i_enable & i_update_key )
        key_reg <= i_rf_static_key      ;
end // iv_locking
assign key  =   ( i_enable & i_update_key ) ?   // cad_ence map_to_mux
                i_rf_static_key : key_reg   ;

// Create a key schedule from input key, required by AES cypher and hash key.
// -----------------------------------------------------------------------------------------
key_scheduler_sequential_shifter
#(
    .NB_BYTE                    ( NB_BYTE                               ),
    .N_BYTES_STATE              ( N_BYTES                               ),
    .N_BYTES_KEY                ( N_BYTES_KEY                           ),
    .N_ROUNDS                   ( N_ROUNDS                              )
)
u_key_scheduler_sequential_shifter
(
    .o_round_key_vector         ( key_sched_vector                      ),
    .o_output_ready             ( key_sched_done                        ),
    .i_key                      ( key                                   ),
    .i_trigger_schedule         ( ctrl_o_trigger_key_sched_vector_calc  ),
    .i_valid                    ( i_enable                              ),
    .i_reset                    ( i_reset                               ),
    .i_clock                    ( i_clock                               )
) ;


// =============================================================================================================================
// GCTR OPERATION
// =============================================================================================================================
// GCTR Pre-block generation.
// -----------------------------------------------------------------------------------------
// Aplying GCTR over 0^128 and J0 it results in:
// H        = CIPH(0^128) --> (H Hash_Subkey necessary for GHASH)
// J0_Tag   = CIPH(J0)
// -----------------------------------------------------------------------------------------
assign pre_block    =   { { NB_BLOCK{1'b0} }, j0 }  ;

// Key Switching Logic.
// -----------------------------------------------------------------------------------------
// When updating the key K is required, it is necessary to apply a certain logic in order to
// use GCTR Block to generate the new H Hash-Subkey and J0_Tag with the new key_schedule_vector (due to key K change),
// while still continue encrypting plaintext with the older key schedule vector correctly.
// -----------------------------------------------------------------------------------------
key_scheduler_switcher
#(
    .NB_BYTE                 ( NB_BYTE                          ),
    .N_BYTES_STATE           ( N_BYTES_STATE                    ),
    .N_ROUNDS                ( N_ROUNDS                         ),
    .ROUND_FIRST_DELAY       ( ROUND_FIRST_DELAY                ),
    .ROUND_MIDDLE_DELAY      ( ROUND_MIDDLE_DELAY               ),
    .ROUND_LAST_DELAY        ( ROUND_LAST_DELAY                 ),
    .NB_TIMER                ( NB_TIMER                         )   // [HINT] Must be big enough to count up to ROUND_*_DELAY
)
u_key_scheduler_switcher
(
    .o_round_key_vector      ( key_switch_key_sched_vector      ),
    .o_muxing_done           ( /*unused*/                       ),
    .o_loading_done          ( key_switch_load_done             ),
    .i_round_key_vector      ( key_sched_vector                 ),
    .i_trigger_muxing        ( ctrl_o_trigger_pre_block_ciph    ),
    .i_trigger_loading       ( ctrl_o_key_sched_lock            ),
    .i_valid                 ( i_enable                         ),
    .i_reset                 ( i_reset                          ),
    .i_clock                 ( i_clock                          )
) ;

// GCTR Function
// -----------------------------------------------------------------------------------------
common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1                             ),
    .DELAY                      ( 1                             )
)
u_common_fix_delay_line_w_valid__gctr_trigger_pre_block_ciph
(
    .o_data_out                 ( gctr_trigger_pre_block_ciph   ),
    .i_data_in                  ( ctrl_o_trigger_pre_block_ciph ),
    .i_valid                    ( i_enable                      ),
    .i_reset                    ( i_reset                       ),
    .clock                      ( i_clock                       )
) ;


assign gctr_i_sop_pre       =   ctrl_o_gctr_i_sop_pre | gctr_trigger_pre_block_ciph         ;

always @( posedge i_clock )
begin: l_pre_block_calc_delay
    if( i_reset || gctr_i_sop_pre )
        pre_block_calc_delay_reg    <= { NB_N_MESSAGES{1'b0} }                              ;
    else if( i_enable && ( pre_block_calc_delay_reg < DATA_PROCESS_TIME_AES ) )
        pre_block_calc_delay_reg    <= pre_block_calc_delay_reg + 1                         ;
end
assign pre_block_calc_delay =   ( pre_block_calc_delay_reg < DATA_PROCESS_TIME_AES )        ;

assign gmac                 =   i_rf_mode_gmac & ~( gctr_i_sop_pre | pre_block_calc_delay ) ;

assign gctr_i_valid         =   i_valid & ~ctrl_o_ghash_i_sop & ~ctrl_o_ghash_valid_add     ;


// GCTR Block
gctr_function
#(
    .NB_BLOCK                   ( NB_BLOCK                      ),
    .N_ROUNDS                   ( N_ROUNDS                      ),
    .N_BLOCKS                   ( N_BLOCKS                      ),
    .NB_DATA                    ( NB_DATA                       ),
    .NB_INC_MODE                ( NB_INC_MODE                   ),
    .STAGES_BETWEEN_REGS        ( GCTR_STAGES_BETWEEN_REGS      ),
    .CREATE_REG_LUT             ( CREATE_REG_LUT                ),
    .USE_LUT_IN_SUBBYTES        ( USE_LUT_IN_SUBBYTES           )
)
u_gctr_function
(
    .o_ciphertext               ( gctr_ciphertext               ),
    .o_valid                    ( gctr_o_valid                  ),
    .i_plaintext                ( i_plaintext                   ),
    .i_round_key_vector         ( key_switch_key_sched_vector   ),
    .i_initial_counter_block    ( gctr_initial_ctr              ),
    .i_rf_static_inc_mode       ( i_rf_static_inc_mode          ),
    .i_rf_mode_gmac             ( gmac                          ),
    .i_sop                      ( ctrl_o_gctr_i_sop             ),  // NO TIENE EN CUENTA LA CANTIDAD DE MENSAJES, SOLO VALIDs, POR LO TANTO NO LE PUEDEN LLEGAR MENSAJES CON PARELELISMO 128.
    .i_sop_pre                  ( gctr_i_sop_pre                ),
    .i_pre_block                ( pre_block                     ),
    .i_valid                    ( gctr_i_valid                  ),
    .i_reset                    ( i_reset                       ),
    .i_clock                    ( i_clock                       )
) ;


// GCTR Cipher Pre-Block Locking
always @( posedge i_clock )
begin: gctr_ciphered_pre_block_locking
    if( i_reset )
        gctr_ciphered_pre_block_reg <= { NB_DATA{1'b0} }    ;
    else if( /*i_valid*/ i_enable && ctrl_o_trigger_h_power_vector_calc || ctrl_o_gctr_o_sop_pre )
        gctr_ciphered_pre_block_reg <= gctr_ciphertext      ;
end // gctr_ciphered_pre_block_locking
assign gctr_ciphered_pre_block  =   ( i_enable && ctrl_o_trigger_h_power_vector_calc || ctrl_o_gctr_o_sop_pre ) ? // cad_ence map_to_mux
                                    gctr_ciphertext : gctr_ciphered_pre_block_reg                               ;


// =============================================================================================================================
// H POWERS GENERATION
// =============================================================================================================================
always @( posedge i_clock )
begin
    if( i_reset )
        h_hash_subkey_reg   <=  { NB_BLOCK{1'b0} }                                              ;
    else if ( ctrl_o_trigger_h_power_vector_calc )
        h_hash_subkey_reg   <=  gctr_ciphered_pre_block[ (NB_DATA-1)-(0*NB_BLOCK)-:NB_BLOCK ]   ;
end
assign  h_hash_subkey   =   ( ctrl_o_trigger_h_power_vector_calc )  ?
                            gctr_ciphered_pre_block[ (NB_DATA-1)-(0*NB_BLOCK)-:NB_BLOCK ]   : h_hash_subkey_reg ;

// Calculate higher powers of H-subkey (required by GHASH Block -KOA multiplier needs them- ).
subkey_h_powers_generator
#(
    .NB_DATA                    ( NB_BLOCK                              ),
    .LOG2_NB_DATA               ( LOG2_NB_DATA_T                        ),
    .MAX_POWER                  ( 8                                     )
)
u_subkey_h_powers_generator
(
    .o_h_power_bus              ( h_power_vector                        ),
    .o_powers_ready             ( h_power_vector_done                   ),
    .i_subkey_h                 ( h_hash_subkey                         ),
    .i_valid                    ( i_enable                              ),
    .i_trigger                  ( ctrl_o_trigger_h_power_vector_calc    ),
    .i_reset                    ( i_reset                               ),
    .i_clock                    ( i_clock                               )
) ;



// =============================================================================================================================
// GHASH OPERATION
// =============================================================================================================================
// GHASH Inputs Logic
// -----------------------------------------------------------------------------------------
// GHASH H Power vector locking
always @( posedge i_clock )
begin: ghash_h_power_vector_locking
    if( i_reset )
        ghash_h_power_vector_locked_reg <= { N_H_POW*NB_BLOCK{1'b0} };
    else if( i_enable && ctrl_o_switch_h_powers )
        ghash_h_power_vector_locked_reg <= h_power_vector   ;
end // ghash_h_power_vector_locking
assign ghash_h_power_vector_locked  =   ( i_enable && ctrl_o_switch_h_powers )  ?
                                        h_power_vector : ghash_h_power_vector_locked_reg    ;

assign  ghash_h_key_locked      = ghash_h_power_vector_locked[ 0 +: NB_BLOCK ]              ;

assign  ghash_n_messages        = i_rf_static_length_plaintext[NB_BLOCK/2-1:NB_BYTE] + 1'b1 ;   // [HINT] Mismatch intentional, not suposed to be more than (2^10 - 1) msgs
assign  ghash_n_aad             = i_rf_static_length_aad[NB_BLOCK/2-1:NB_BYTE]              ;   // [HINT] Mismatch intentional, not suposed to be more than (2^10 - 1) msgs
assign  ghash_lenght_vector     = { i_rf_static_length_aad, i_rf_static_length_plaintext }  ;

// GHASH Input Data Selection
always @( * )
begin: ghash_i_data_selector_decition
    case( ctrl_o_ghash_i_data_selector )
        GHASH_SELECT_AAD    :   // 2
        begin
            ghash_skip_bus  =   2'b00                           ;
            ghash_i_data    =   i_rf_static_aad                 ;
        end
        GHASH_SELECT_DATA   :   // 0
        begin
            ghash_skip_bus  =   2'b00                           ;
            ghash_i_data    =   ( i_rf_static_encrypt ) ?
                                gctr_ciphertext : i_plaintext   ;
        end
        GHASH_SELECT_LENGTH :   // 1
        begin
            ghash_skip_bus  =   ( !{i_rf_static_length_plaintext[7]} )  ?
                                2'b10 : 2'b00                           ;
            if( i_rf_static_encrypt )
            begin
                ghash_i_data=   ( !{i_rf_static_length_plaintext[7]} )  ?
                                { { NB_BLOCK{1'b0} }, ghash_lenght_vector } : { ghash_lenght_vector, gctr_ciphertext[0*NB_BLOCK+:NB_BLOCK] }    ;   // It should be {data, len_vec}, but GHASH need it in the other order
            end else begin
                ghash_i_data=   ( !{i_rf_static_length_plaintext[7]} )  ?
                                { { NB_BLOCK{1'b0} }, ghash_lenght_vector } : { ghash_lenght_vector, i_plaintext[0*NB_BLOCK+:NB_BLOCK] }        ;   // It should be {data, len_vec}, but GHASH need it in the other order
            end
        end
        default             :
        begin
            ghash_skip_bus  =   2'b00   ;
            ghash_i_data    =   ( i_rf_static_encrypt ) ?
                                gctr_ciphertext : i_plaintext   ;
        end
    endcase
end // ghash_i_data_selector_decition


// GHASH Block
ghash_wrapper
#(
    .NB_BLOCK               ( NB_BLOCK                      ),
    .N_BLOCKS               ( N_BLOCKS                      ),
    .NB_DATA                ( NB_DATA                       ),
    .USE_NEW_GHASH          ( 1                             ),
    .N_H_POW                ( N_H_POW                       ),
    .NB_N_MESSAGES          ( NB_N_MESSAGES                 ),
    .REG_OUTPUT             ( 0                             )
)
u_ghash_wrapper
(
    .o_ghash_ciphertext     ( ghash_o_data                  ),
    .o_ghash_done           ( ghash_done                    ),
    .o_err_sop_sync         ( ghash_o_err_sop_sync          ),
    .i_ghash_i_data_x_bus   ( ghash_i_data                  ),
    .i_aad                  ( i_rf_static_aad               ),
    .i_h_power_bus          ( ghash_h_power_vector_locked   ),
    .i_ghash_skip_bus       ( ghash_skip_bus                ),
    .i_sop_ghash            ( ctrl_o_ghash_i_sop            ),
    .i_valid_ghash          ( ctrl_o_ghash_i_valid          ),
    .i_rf_static_n_messages ( ghash_n_messages              ),
    .i_rf_static_n_aad      ( ghash_n_aad                   ),
    .i_reset                ( i_reset                       ),
    .i_clock                ( i_clock                       )

);



// =============================================================================================================================
// TAG CALCULATION
// =============================================================================================================================
assign j0_tag    = gctr_ciphered_pre_block[ (NB_DATA-1)-(1*NB_BLOCK)-:NB_BLOCK ]    ;


// J0 Tag FSM
j0_tag_fsm
#(
    .NB_STATE                               ( NB_STATE_J0_FSM                       ),   // Must be 3
    .NB_BLOCK                               ( NB_BLOCK                              )
)
u_j0_tag_fsm
(
    .o_j0_tag_locked                        ( j0_tag_locked                         ),
    .i_j0_tag                               ( j0_tag                                ),
    .i_update_key                           ( i_update_key                          ),
    .i_ctrl_o_trigger_h_power_vector_calc   ( ctrl_o_trigger_h_power_vector_calc    ),
    .i_ctrl_o_gctr_o_sop_pre                ( ctrl_o_gctr_o_sop_pre                 ),
    .i_ctrl_o_gctr_triggered_o_sop_pre      ( ctrl_o_gctr_triggered_o_sop_pre       ),
    .i_key_switch_load_done                 ( key_switch_load_done                  ),
    .i_ctrl_o_trigger_j0_tag_new_locking    ( ctrl_o_trigger_j0_tag_new_locking     ),
    .i_reset                                ( i_reset                               ),
    .i_valid                                ( i_enable                              ),
    .i_clock                                ( i_clock                               )
);


always @( posedge i_clock )
begin
    if ( i_reset || (i_enable && i_sop) )
        pre_block_done_reg  <=  1'b0    ;
    else if ( ctrl_o_gctr_o_sop_pre )
        pre_block_done_reg  <=  1'b1    ;
end
assign  pre_block_done  =   (i_enable && i_sop) ?
                            1'b0 : (    (ctrl_o_gctr_o_sop_pre)    ?
                                        1'b1 : pre_block_done_reg)  ;

assign  tag_enable  =   ghash_done & pre_block_done ;
common_posedge_det
u_common_posedge_det_ghash_done_detect
(
    .o_posedge      ( tag_ready     ),
    .o_data_del     ( /*unused*/    ),
    .i_data         ( tag_enable    ),
    .i_valid        ( i_enable      ),
    .i_reset        ( i_reset       ),
    .i_clock        ( i_clock       )
);

always @( posedge i_clock )
begin
    if ( i_reset )
        ghash_o_data_locked_reg <=  { NB_BLOCK{1'b0} }  ;
    else if ( tag_ready )
        ghash_o_data_locked_reg <=  ghash_o_data        ;
end
assign ghash_o_data_locked  =   ( tag_ready )   ?
                                ghash_o_data : ghash_o_data_locked_reg  ;

assign o_tag_ready  =   ( i_rf_static_encrypt ) ?
                        tag_ready   :   ctrl_o_gctr_o_sop_pre  ;

always @( posedge i_clock )
begin: o_tag_locking
    if ( i_reset )
        tag_reg <= { NB_BLOCK{1'b0} }                   ;
    if( ~|ghash_lenght_vector )
        tag_reg <= j0_tag_locked                        ;
    else if( o_tag_ready )
        tag_reg <= j0_tag_locked ^ ghash_o_data_locked  ;
end
assign o_tag    =   ( ~|ghash_lenght_vector )   ?
                    j0_tag_locked : ( o_tag_ready ) ?
                                    j0_tag_locked ^ ghash_o_data_locked : tag_reg  ;



// =============================================================================================================================
// OUUTPUT DATA CALCULATION
// =============================================================================================================================
always @( posedge i_clock )
begin: i_tag_locking
    if ( i_reset )
        i_tag_locked_reg    <= { NB_BLOCK{1'b0} }   ;
    else if ( i_tag_ready )
        i_tag_locked_reg    <= i_tag                ;
end

assign i_tag_locked     =   ( i_tag_ready ) ?
                            i_tag : i_tag_locked_reg    ;

assign o_ciphertext     =   gctr_ciphertext ;

assign o_valid          =   gctr_o_valid & ~ctrl_o_gctr_o_sop_pre & ~ctrl_o_gctr_triggered_o_sop_pre    ;

assign o_sop            =   ctrl_o_gctr_o_sop   ;


assign o_fail           =   ( ~i_rf_static_encrypt && o_tag_ready ) ?   // cad_ence map_to_mux
                            ( o_tag != i_tag_locked ) : 1'b0        ;


endmodule // gcm_aes_core_1gctr_ghash_new

module wrapper
#()
();



// LOCALPARAMETERS.
// ----------------------------------------------------------------------------------------------------
localparam                              NB_BLOCK                =   128                     ;
localparam                              N_BLOCKS                =   2                       ;
localparam                              NB_DATA                 =   N_BLOCKS*NB_BLOCK       ;
localparam                              NB_IV                   =   96                      ;
localparam                              NB_KEY                  =   256                     ;
localparam                              NB_INC_MODE             =   2                       ;
localparam                              USE_LUT_IN_SUBBYTES     =   0                       ;
localparam                              NB_N_MESSAGES           =   10                      ;
localparam                              RUN_TIME                =   4968                      ;

// INTERNAL SIGNALS.
// ----------------------------------------------------------------------------------------------------
wire    [ NB_KEY-1:0        ]           auto_key                           ;
wire    [ NB_DATA-1:0       ]           auto_plaintext                     ;
wire    [ NB_DATA-1:0       ]           auto_aad                           ;
wire    [ NB_IV-1:0         ]           auto_iv                            ;
wire    [ NB_BLOCK/2-1:0    ]           auto_rf_static_aad_length          ;
wire    [ NB_BLOCK/2-1:0    ]           auto_rf_static_plaintext_length    ;
wire                                    auto_sop                           ;
wire                                    auto_valid                         ;
wire                                    auto_key_update                    ;
wire                                    auto_rf_mode_gmac                  ;
wire                                    auto_rf_static_encrypt             ;
wire                                    auto_clear_fault_flags             ;
wire                                    auto_reset                         ;
wire    [ NB_DATA-1:0       ]           auto_expected_ciphertext           ;
wire                                    auto_expected_sop                  ;
wire                                    auto_expected_valid                ;
wire    [ NB_BLOCK-1:0      ]           auto_expected_tag                  ;
wire                                    auto_expected_tag_ready            ;


wire    [ NB_KEY-1:0        ]           auto_key_2                         ;
wire    [ NB_DATA-1:0       ]           auto_plaintext_2                   ;
wire    [ NB_DATA-1:0       ]           auto_aad_2                         ;
wire    [ NB_IV-1:0         ]           auto_iv_2                          ;
wire    [ NB_BLOCK/2-1:0    ]           auto_rf_static_aad_length_2        ;
wire    [ NB_BLOCK/2-1:0    ]           auto_rf_static_plaintext_length_2  ;
wire                                    auto_sop_2                         ;
wire                                    auto_valid_2                       ;
wire                                    auto_key_update_2                  ;
wire                                    auto_rf_mode_gmac_2                ;
wire                                    auto_rf_static_encrypt_2           ;
wire                                    auto_clear_fault_flags_2           ;
wire                                    auto_reset_2                       ;
wire    [ NB_DATA-1:0       ]           auto_expected_ciphertext_2         ;
wire                                    auto_expected_sop_2                ;
wire                                    auto_expected_valid_2              ;
wire    [ NB_BLOCK-1:0      ]           auto_expected_tag_2                ;
wire                                    auto_expected_tag_ready_2          ;


wire    [ NB_KEY-1:0        ]           i_key                               ;
wire    [ NB_DATA-1:0       ]           i_plaintext                         ;
wire    [ NB_DATA-1:0       ]           i_aad                               ;
wire    [ NB_IV-1:0         ]           i_iv                                ;
wire    [ NB_BLOCK/2-1:0    ]           i_rf_static_aad_length              ;
wire    [ NB_BLOCK/2-1:0    ]           i_rf_static_plaintext_length        ;
wire                                    i_sop                               ;
wire                                    i_valid                             ;
wire                                    i_key_update                        ;
wire                                    i_rf_mode_gmac                      ;
wire                                    i_rf_static_encrypt                 ;
wire                                    i_clear_fault_flags                 ;
wire                                    i_reset                             ;
wire    [ NB_DATA-1:0       ]           o_ciphertext                        ;
wire                                    o_fail                              ;
wire                                    o_sop                               ;
wire                                    o_valid                             ;
wire    [ NB_BLOCK-1:0      ]           o_tag                               ;
wire                                    o_tag_ready                         ;
wire                                    o_fault_sop_and_keyupdate           ;
wire                                    i_clock                             ;


// FRAME SELECTION LOGIC.
// ----------------------------------------------------------------------------------------------------

integer input_driver_timer;
always @(posedge i_clock)
begin
    if(i_reset)
        input_driver_timer <= 0;
    else
        input_driver_timer <= input_driver_timer + 1;
end

wire key_update;
assign key_update = (10000 == input_driver_timer);
reg autogen2_sel;


assign i_key                        = (autogen2_sel | key_update) ? auto_key_2              : auto_key                          ;
assign i_plaintext                  = (autogen2_sel) ? auto_plaintext_2                     : auto_plaintext                    ;
assign i_aad                        = (autogen2_sel) ? auto_aad_2                           : auto_aad                          ;
assign i_iv                         = (autogen2_sel) ? auto_iv_2                            : auto_iv                           ;
assign i_rf_static_aad_length       = (autogen2_sel) ? auto_rf_static_aad_length_2          : auto_rf_static_aad_length         ;
assign i_rf_static_plaintext_length = (autogen2_sel) ? auto_rf_static_plaintext_length_2    : auto_rf_static_plaintext_length   ;
assign i_sop                        = (autogen2_sel) ? auto_sop_2                           : auto_sop                          ;
assign i_valid                      = (autogen2_sel) ? auto_valid_2                         : auto_valid                        ;
assign i_key_update                 = (autogen2_sel) ? auto_key_update_2                    : auto_key_update | key_update      ;
assign i_rf_mode_gmac               = (autogen2_sel) ? auto_rf_mode_gmac_2                  : auto_rf_mode_gmac                 ;
assign i_rf_static_encrypt          = (autogen2_sel) ? auto_rf_static_encrypt_2             : auto_rf_static_encrypt            ;
assign i_clear_fault_flags          = (autogen2_sel) ? auto_clear_fault_flags_2             : auto_clear_fault_flags            ;
assign i_reset                      = (autogen2_sel) ? auto_reset_2                         : auto_reset                        ;

// MODULE INSTANTIATION.
// ----------------------------------------------------------------------------------------------------
tb_autogen_gcm_aes
#(
    .NB_BLOCK                       ( NB_BLOCK                          ),
    .N_BLOCKS                       ( N_BLOCKS                          ),
    .NB_DATA                        ( NB_DATA                           ),
    .NB_IV                          ( NB_IV                             ),
    .NB_KEY                         ( NB_KEY                            ),
    .NB_INC_MODE                    ( NB_INC_MODE                       ),
    .USE_LUT_IN_SUBBYTES            ( USE_LUT_IN_SUBBYTES               ),
    .NB_N_MESSAGES                  ( NB_N_MESSAGES                     ),
    .RUN_TIME                       ( RUN_TIME                          )
)
u_tb_autogen_gcm_aes
(
    .o_key                          ( auto_key                          ),
    .o_plaintext                    ( auto_plaintext                    ),
    .o_aad                          ( auto_aad                          ),
    .o_iv                           ( auto_iv                           ),
    .o_rf_static_aad_length         ( auto_rf_static_aad_length         ),
    .o_rf_static_plaintext_length   ( auto_rf_static_plaintext_length   ),
    .o_sop                          ( auto_sop                          ),
    .o_valid                        ( auto_valid                        ),
    .o_key_update                   ( auto_key_update                   ),
    .o_rf_mode_gmac                 ( auto_rf_mode_gmac                 ),
    .o_rf_static_encrypt            ( auto_rf_static_encrypt            ),
    .o_clear_fault_flags            ( auto_clear_fault_flags            ),
    .o_reset                        ( auto_reset                        ),
    .clock                          ( i_clock                           ),
    .o_expected_ciphertext          ( auto_expected_ciphertext          ),
    .o_expected_sop                 ( auto_expected_sop                 ),
    .o_expected_valid               ( auto_expected_valid               ),
    .o_expected_tag                 ( auto_expected_tag                 ),
    .o_expected_tag_ready           ( auto_expected_tag_ready           )
);


tb_autogen_gcm_aes_2
#(
    .NB_BLOCK                       ( NB_BLOCK                          ),
    .N_BLOCKS                       ( N_BLOCKS                          ),
    .NB_DATA                        ( NB_DATA                           ),
    .NB_IV                          ( NB_IV                             ),
    .NB_KEY                         ( NB_KEY                            ),
    .NB_INC_MODE                    ( NB_INC_MODE                       ),
    .USE_LUT_IN_SUBBYTES            ( USE_LUT_IN_SUBBYTES               ),
    .NB_N_MESSAGES                  ( NB_N_MESSAGES                     ),
    .RUN_TIME                       ( RUN_TIME                          )
)
u_tb_autogen_gcm_aes_2
(
    .o_key                          ( auto_key_2                        ),
    .o_plaintext                    ( auto_plaintext_2                  ),
    .o_aad                          ( auto_aad_2                        ),
    .o_iv                           ( auto_iv_2                         ),
    .o_rf_static_aad_length         ( auto_rf_static_aad_length_2       ),
    .o_rf_static_plaintext_length   ( auto_rf_static_plaintext_length_2 ),
    .o_sop                          ( auto_sop_2                        ),
    .o_valid                        ( auto_valid_2                      ),
    .o_key_update                   ( auto_key_update_2                 ),
    .o_rf_mode_gmac                 ( auto_rf_mode_gmac_2               ),
    .o_rf_static_encrypt            ( auto_rf_static_encrypt_2          ),
    .o_clear_fault_flags            ( auto_clear_fault_flags_2          ),
    .o_reset                        ( auto_reset_2                      ),
    .o_expected_ciphertext          ( auto_expected_ciphertext_2        ),
    .o_expected_sop                 ( auto_expected_sop_2               ),
    .o_expected_valid               ( auto_expected_valid_2             ),
    .o_expected_tag                 ( auto_expected_tag_2               ),
    .o_expected_tag_ready           ( auto_expected_tag_ready_2         )
);


// GCM AES CORE.
// ----------------------------------------------------------------------------------------------------
gcm_aes_core
#(
    .NB_BLOCK                       ( NB_BLOCK                                      ),
    .N_BLOCKS                       ( N_BLOCKS                                      ),
    .NB_DATA                        ( NB_DATA                                       ),
    .NB_KEY                         ( NB_KEY                                        ),
    .NB_IV                          ( NB_IV                                         ),
    .NB_INC_MODE                    ( NB_INC_MODE                                   ),
    .USE_LUT_IN_SUBBYTES            ( USE_LUT_IN_SUBBYTES                           ),
    .NB_N_MESSAGES                  ( NB_N_MESSAGES                                 )
)
u_gcm_aes_core_cipher
(
    .o_ciphertext                   ( o_ciphertext                                  ),
    .o_fail                         ( o_fail                                        ),
    .o_sop                          ( o_sop                                         ),
    .o_valid                        ( o_valid                                       ),
    .o_tag                          ( o_tag                                         ),
    .o_tag_ready                    ( o_tag_ready                                   ),
    .o_fault_sop_and_keyupdate      ( o_fault_sop_and_keyupdate                     ),
    .i_plaintext                    ( i_plaintext                                   ),
    .i_tag                          ( /*unused*/                                    ),
    .i_tag_ready                    ( /*unused*/                                    ),
    .i_rf_static_key                ( i_key                                         ),
    .i_rf_static_aad                ( i_aad                                         ),
    .i_rf_static_iv                 ( i_iv                                          ),
    .i_rf_static_length_aad         ( i_rf_static_aad_length                        ),
    .i_rf_static_length_plaintext   ( i_rf_static_plaintext_length                  ),
    .i_sop                          ( i_sop                                         ),
    .i_valid                        ( i_valid                                       ),
    .i_enable                       ( 1'b1                                          ),
    .i_update_key                   ( i_key_update                                  ),
    .i_rf_static_inc_mode           ( tb_i_rf_static_inc_mode                       ),
    .i_rf_mode_gmac                 ( i_rf_mode_gmac                                ),
    .i_rf_static_encrypt            ( i_rf_static_encrypt                           ),
    .i_clear_fault_flags            ( i_clear_fault_flags                           ),
    .i_reset                        ( i_reset                                       ),
    .i_clock                        ( i_clock                                       )
);


always @(posedge i_clock)
begin
    if(auto_reset)
        autogen2_sel <= 0;
    else if((input_driver_timer >= 10000) && (u_gcm_aes_core_cipher.key_switch_load_done))
        autogen2_sel <= 1;
end


endmodule

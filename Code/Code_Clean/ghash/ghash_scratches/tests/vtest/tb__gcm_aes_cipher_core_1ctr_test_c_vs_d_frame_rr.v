module tb__gcm_aes_cipher_core_1ctr_test_c_vs_d_frame_rr(  );    // Test Case 15.

    tb__gcm_aes_core_1ctr_test_standar_vectors
    u_tb__gcm_aes_core_1ctr_test_standar_vectors(  ) ;

    tb__gcm_key_switch_prbs
    u_tb__gcm_key_switch_prbs(  ) ;

    // PARAMETERS.
    parameter                           NB_BLOCK            = 128 ;
    parameter                           N_BLOCKS            = 2 ;
    parameter                           NB_DATA             = (N_BLOCKS*NB_BLOCK) ;
    parameter                           NB_KEY              = 256 ;
    parameter                           NB_IV               = 96 ;
    parameter                           NB_INC_MODE         = 2 ;

    parameter                           SIM_PERIOD_A        = 100 ;
    parameter                           SOP_OFFSET_PART_B   = 50 ;
    parameter                           SOP_OFFSET          = 0 ;

    // OUTPUTS.
    wire            [NB_DATA-1:0]       tb_o_ciphertext_words_y ;
    reg             [NB_DATA-1:0]       tb_o_ciphertext_words_y_d1 ;
    wire                                tb_o_sop ;
    reg                                 tb_o_sop_d1 ;
    wire                                tb_o_valid_text ;
    reg                                 tb_o_valid_text_d1 ;
    wire            [NB_BLOCK-1:0]      tb_o_tag ;
    wire            [NB_DATA-1:0]       tb_A_o_ciphertext_words_y ;
    wire                                tb_A_o_valid_text ;
    wire            [NB_BLOCK-1:0]      tb_A_o_tag ;

    wire            [NB_DATA-1:0]       tb_o_plaintext_words_x ;
    wire                                tb_o_valid_text_decipher ;
    wire                                tb_o_fail ;
    wire            [NB_DATA-1:0]       tb_B_o_plaintext_words_x ;
    wire                                tb_B_o_valid_text_decipher ;
    wire                                tb_B_o_fail ;
    wire            [NB_BLOCK-1:0]      tb_B_o_tag ;

    wire            [NB_DATA-1:0]       tb_A_o_ciphertext_words_y_new ;
    wire                                tb_A_o_valid_text_new ;
    wire            [NB_BLOCK-1:0]      tb_A_o_tag_new ;
    wire            [NB_DATA-1:0]       tb_B_o_plaintext_words_x_new ;
    wire                                tb_B_o_valid_text_decipher_new ;
    wire                                tb_B_o_fail_new ;
    wire            [NB_BLOCK-1:0]      tb_B_o_tag_new ;


    // INPUTS.
    wire            [NB_KEY-1:0]        tb_i_rf_static_key ;
    wire            [NB_BLOCK-1:0]      tb_i_aad ;
    wire            [NB_IV-1:0]         tb_i_iv ;
    wire            [NB_BLOCK/2-1:0]    tb_i_length_aad ;
    wire            [NB_BLOCK/2-1:0]    tb_i_length_plaintext ;
    wire                                tb_i_sop ;
    wire                                tb_i_valid ;
    wire            [NB_INC_MODE-1:0]   tb_i_rf_static_inc_mode ;
    wire                                tb_i_reset ;
    reg                                 tb_i_clock ;
    wire                                tb_i_update_key ;

    wire            [NB_DATA-1:0]       fg_o_data ;
    reg             [NB_DATA-1:0]       fg_o_data_d1 ;
    reg             [NB_DATA-1:0]       fg_o_data_d2 ;
    wire                                fg_o_sop ;
    reg                                 fg_o_sop_d1 ;
    reg                                 fg_o_sop_d2 ;
    reg                                 fg_o_sop_d3 ;
    wire                                fg_o_valid ;
    reg                                 fg_o_valid_d1 ;
    reg                                 fg_o_valid_d2 ;
    reg                                 fg_i_valid          = 1'b0 ;

    integer                             count               = 0 ;

    wire            [NB_DATA-1:0]       expected_out_1      = 128'hacbef20579b4b8ebce889bac8732dad7 ;

    reg             [NB_DATA-1:0]       tb_o_plaintext_words_x_d1 ;
    reg                                 tb_o_sop2_d1 ;
    reg                                 tb_o_sop2_d2 ;

    wire            [NB_DATA-1:0]       tb_o_ciphertext_words_y_2 ;
    wire                                tb_o_sop_2 ;
    wire                                tb_o_valid_text_2 ;
    wire            [NB_BLOCK-1:0]      tb_o_tag_2 ;
    wire            [NB_DATA-1:0]       tb_i_rf_static_key_2 ;
    wire            [NB_DATA-1:0]       tb_i_rf_static_key_new ;

    initial
    begin
        tb_i_clock
            = 1'b0 ;
    end

    always
        #( 50 )  tb_i_clock
                    = ~tb_i_clock ;


    always @( posedge tb_i_clock )
    begin
        count
            <= count + 1 ;
    end



    assign  tb_i_reset
                = ( count == 10 ) || ( count == 11 )/* || ( count == 14000)*/ ;






    // t_frame_gen_plus_2null_valid
    // #(
    //     .NB_FRAME_SIZE              ( 16                        ),
    //     .NB_DATA                    ( NB_DATA                   ),
    //     .MSB_IS_NEWER               ( 0                         )
    // )
    // u_t_frame_gen_plus_2null_valid
    // (
    //     .o_data                     ( fg_o_data                 ),
    //     .o_sof                      ( fg_o_sop                  ),
    //     .o_valid                    ( fg_o_valid                ),
    //     .i_frame_size               ( 16'd510/*16'd520*/                   ),
    //     .i_fas                      ( {48'hf6f6f6282828,208'd0} ),
    //     .i_valid                    ( fg_i_valid                ),
    //     .i_reset                    ( tb_i_reset                ),
    //     .i_clock                    ( tb_i_clock                )
    // ) ;
    t_frame_gen_plus_Nnull_valid
    #(
        .NB_FRAME_SIZE              ( 16                        ),
        .NB_DATA                    ( NB_DATA                   ),
        .MSB_IS_NEWER               ( 0                         ),
        .N_NULL                     ( 60                        )
    )
    u_t_frame_gen_plus_Nnull_valid
    (
        .o_data                     ( fg_o_data                 ),
        .o_sof                      ( fg_o_sop                  ),
        .o_valid                    ( fg_o_valid                ),
        .i_frame_size               ( 16'd510 /*16'd2*/                   ),
        .i_fas                      ( {48'hf6f6f6282828,208'd0} ),
        .i_valid                    ( fg_i_valid                ),
        .i_reset                    ( tb_i_reset                ),
        .i_clock                    ( tb_i_clock                )
    ) ;
    wire                    use_random_valid    = 1'b0 ;
    always @( posedge tb_i_clock )
        fg_i_valid
            <= ( use_random_valid )? $random() : 1'b1 ;  // FIXME.
    assign  tb_i_valid
                = 1'b1 ;
    assign  tb_i_update_key_new
                = ( count == 20 ) || ( count == 4000 ) || ( count == 8000 );

    assign  tb_i_update_key
                = ( count == 20 );


    assign  tb_i_rf_static_key
                = { 128'hfeffe9928665731c6d6a8f9467308308, 128'hfeffe9928665731c6d6a8f9467308308 } ;


    assign  tb_i_rf_static_key_new
                = ( (count < 4000) || (count>=8000) )? { 128'hfeffe9928665731c6d6a8f9467308308, 128'hfeffe9928665731c6d6a8f9467308308 } : 256'd0 ;

    assign  tb_i_rf_static_key_2
                = 256'd0 ;

    assign  tb_i_aad
                = 128'h00000000000000000000000000000000 ;

    assign  tb_i_iv
                = 96'hcafebabefacedbaddecaf888 ;

    assign  tb_i_length_aad
                = 64'd0 ; // 64'h0000000000000080 ;

    assign  tb_i_length_plaintext
                = 510*256 ;
                // = 2*256 ;

    assign  tb_i_sop
                = fg_o_sop ;

    assign  tb_i_rf_static_inc_mode
                = 2'd0 ;



    always @( posedge tb_i_clock )
    begin
        fg_o_valid_d1
            <= fg_o_valid ;
        fg_o_valid_d2
            <= fg_o_valid_d1 ;

        fg_o_data_d1
            <= fg_o_data ;
        fg_o_data_d2
            <= fg_o_data_d1 ;

        fg_o_sop_d1
            <= fg_o_sop ;
        fg_o_sop_d2
            <= fg_o_sop_d1 ;
        fg_o_sop_d3
            <= fg_o_sop_d2 ;
    end



    // MODULE INSTANTIATION.
    gcm_aes_cipher
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   )
    )
    u_gcm_aes_cipher
    (
        .o_ciphertext_words_y       ( tb_o_ciphertext_words_y       ),
        .o_sop                      ( tb_o_sop                      ),
        .o_valid_text               ( tb_o_valid_text               ),
        .o_tag                      ( tb_o_tag                      ),
        .o_tag_ready                (                               ),
        .o_fault_sop_and_keyupdate  (                               ),
        .i_plaintext_words_x        ( fg_o_data_d2                  ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( fg_o_sop_d3                   ),
        .i_update_key               ( tb_i_update_key               ),
        .i_valid_text               ( fg_o_valid_d2                 ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;

    gcm_aes_cipher
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   )
    )
    u_gcm_aes_cipher_2
    (
        .o_ciphertext_words_y       ( tb_o_ciphertext_words_y_2     ),
        .o_sop                      ( tb_o_sop_2                    ),
        .o_valid_text               ( tb_o_valid_text_2             ),
        .o_tag                      ( tb_o_tag_2                    ),
        .o_tag_ready                (                               ),
        .o_fault_sop_and_keyupdate  (                               ),
        .i_plaintext_words_x        ( fg_o_data_d2                  ),
        .i_rf_static_key            ( tb_i_rf_static_key_2          ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( fg_o_sop_d3                   ),
        .i_update_key               ( tb_i_update_key               ),
        .i_valid_text               ( fg_o_valid_d2                 ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;

    gcm_aes_core_1gctr
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   )
    )
    u_gcm_aes_core_1gtr__A_cipher
    (
        .o_ciphertext_words_y       ( tb_A_o_ciphertext_words_y     ),
        .o_fail                     (                               ),
        .o_sop                      ( tb_A_o_sop                    ),
        .o_valid_text               ( tb_A_o_valid_text             ),
        .o_tag                      ( tb_A_o_tag                    ),
        .o_tag_ready                (                               ),
        .o_fault_sop_and_keyupdate  (                               ),
        .i_plaintext_words_x        ( fg_o_data_d2                  ),
        .i_tag                      ( 128'd0                        ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( fg_o_sop_d2                   ),
        .i_update_key               ( tb_i_update_key               ),
        .i_valid_text               ( fg_o_valid_d2                 ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_rf_mode_gmac             ( 0                             ),
        .i_rf_static_encrypt        ( 1'b1                          ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;

    gcm_aes_core_1gctr_ghash_new
    #(
        .NB_BLOCK                       ( NB_BLOCK                      ),
        .N_BLOCKS                       ( N_BLOCKS                      ),
        .NB_DATA                        ( NB_DATA                       ),
        .NB_KEY                         ( NB_KEY                        ),
        .NB_IV                          ( NB_IV                         ),
        .NB_INC_MODE                    ( NB_INC_MODE                   ),
        .USE_LUT_IN_SUBBYTES            ( 0                             )
    )
    u_gcm_aes_core_1gtr__A_cipher_new
    (
        .o_ciphertext_words_y           ( tb_A_o_ciphertext_words_y_new ),
        .o_fail                         (                               ),
        .o_sop                          ( tb_A_o_sop_new                ),
        .o_valid_text                   ( tb_A_o_valid_text_new         ),
        .o_tag                          ( tb_A_o_tag_new                ),
        .o_tag_ready                    (                               ),
        .o_fault_sop_and_keyupdate      (                               ),
        .i_plaintext_words_x            ( fg_o_data_d2                  ),
        .i_tag                          ( 128'd0                        ),
        .i_rf_static_key                ( tb_i_rf_static_key_new        ),
        .i_rf_static_aad                ( tb_i_aad                      ),
        .i_rf_static_iv                 ( tb_i_iv                       ),
        .i_rf_static_length_aad         ( tb_i_length_aad               ),
        .i_rf_static_length_plaintext   ( tb_i_length_plaintext         ),
        .i_sop                          ( fg_o_sop_d2                   ),
        .i_update_key                   ( tb_i_update_key_new           ),
        .i_valid_text                   ( fg_o_valid_d2                 ),
        .i_valid                        ( tb_i_valid                    ),
        .i_rf_static_inc_mode           ( tb_i_rf_static_inc_mode       ),
        .i_rf_mode_gmac                 ( 0                             ),
        .i_rf_static_encrypt            ( 1'b1                          ),
        .i_clear_fault_flags            ( (count== 5)                   ),
        .i_reset                        ( tb_i_reset                    ),
        .i_clock                        ( tb_i_clock                    )
    ) ;
    assign  comp__A_chipher_o_ciphertext_words_y    = ( tb_o_ciphertext_words_y == tb_A_o_ciphertext_words_y ) || ( tb_o_valid_text==1'b0 && tb_A_o_valid_text==1'b0 ) ;
    assign  comp__A_chipher_o_sop                   = ( tb_o_sop                == tb_A_o_sop                ) ;
    assign  comp__A_chipher_o_valid_text            = ( tb_o_valid_text         == tb_A_o_valid_text         ) ;
    assign  comp__A_chipher_o_tag                   = ( tb_o_tag                == tb_A_o_tag                ) ;

    assign  comp__A_ghash_ciphertext_words          = ( tb_o_ciphertext_words_y == tb_A_o_ciphertext_words_y_new) ;
    assign  comp__A_ghash_o_sop                     = ( tb_o_sop                == tb_A_o_sop_new               ) ;
    assign  comp__A_ghash_o_valid_text              = ( tb_o_valid_text         == tb_A_o_valid_text_new        ) ;
    assign  comp__A_ghash_o_tag                     = ( tb_o_tag                == tb_A_o_tag_new               ) ;

    assign  comp__A_ghash_ciphertext_words_2        = ( tb_o_ciphertext_words_y_2 == tb_A_o_ciphertext_words_y_new) ;
    assign  comp__A_ghash_o_sop_2                   = ( tb_o_sop_2                == tb_A_o_sop_new               ) ;
    assign  comp__A_ghash_o_valid_text_2            = ( tb_o_valid_text_2         == tb_A_o_valid_text_new        ) ;
    assign  comp__A_ghash_o_tag_2                   = ( tb_o_tag_2                == tb_A_o_tag_new               ) ;


    always @( posedge tb_i_clock )
    begin
        tb_o_ciphertext_words_y_d1
            <= tb_o_ciphertext_words_y ;
        tb_o_sop_d1
            <= tb_o_sop ;
        tb_o_valid_text_d1
            <= tb_o_valid_text ;
    end



    gcm_aes_decipher
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .LOG2_N_BLOCKS              ( 1                             ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   ),
        .LOG2_NB_DATA_T             ( 8                             ),
        .NB_TIMER                   ( 10                            )
    )
    u_gcm_aes_decipher
    (
        .o_plaintext_words_x        ( tb_o_plaintext_words_x        ),
        .o_sop                      ( tb_o_sop2                     ),
        .o_valid_text               ( tb_o_valid_text_decipher      ),
        .o_fail                     ( tb_o_fail                     ),
        .i_ciphertext_words_y       ( tb_o_ciphertext_words_y_d1    ),
        .i_tag                      ( tb_o_tag                      ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( tb_o_sop_d1                   ),
        .i_update_key               ( tb_i_update_key               ),
        .i_valid_text               ( tb_o_valid_text_d1            ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;
    gcm_aes_core_1gctr
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   )
    )
    u_gcm_aes_core_1gctr__B_decipher
    (
        .o_ciphertext_words_y       ( tb_B_o_plaintext_words_x      ),
        .o_fail                     ( tb_B_o_fail                   ),
        .o_sop                      ( tb_B_o_sop2                   ),
        .o_valid_text               ( tb_B_o_valid_text_decipher    ),
        .o_tag                      ( tb_B_o_tag                    ),
        .o_tag_ready                (                               ),
        .o_fault_sop_and_keyupdate  (                               ),
        .i_plaintext_words_x        ( tb_o_ciphertext_words_y_d1    ),
        .i_tag                      ( /*tb_o_tag*/tb_A_o_tag        ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( tb_o_sop                      ),
        .i_update_key               ( tb_i_update_key               ),
        .i_valid_text               ( tb_o_valid_text_d1            ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_rf_mode_gmac             ( 0                             ),
        .i_rf_static_encrypt        ( 1'b0                          ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;
    gcm_aes_core_1gctr_ghash_new
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   )
    )
    u_gcm_aes_core_1gctr_ghash_new__B_decipher
    (
        .o_ciphertext_words_y           ( tb_B_o_plaintext_words_x_new  ),
        .o_fail                         ( tb_B_o_fail_new               ),
        .o_sop                          ( tb_B_o_sop2_new               ),
        .o_valid_text                   ( tb_B_o_valid_text_decipher_new),
        .o_tag                          ( tb_B_o_tag_new                ),
        .o_tag_ready                    (                               ),
        .o_fault_sop_and_keyupdate      (                               ),
        .i_plaintext_words_x            ( tb_A_o_ciphertext_words_y_new ),
        .i_tag                          ( tb_A_o_tag_new                ),
        .i_rf_static_key                ( tb_i_rf_static_key            ),
        .i_rf_static_aad                ( tb_i_aad                      ),
        .i_rf_static_iv                 ( tb_i_iv                       ),
        .i_rf_static_length_aad         ( tb_i_length_aad               ),
        .i_rf_static_length_plaintext   ( tb_i_length_plaintext         ),
        .i_sop                          ( tb_A_o_sop_new                ),
        .i_update_key                   ( tb_i_update_key               ),
        .i_valid_text                   ( tb_A_o_valid_text_new         ),
        .i_valid                        ( tb_i_valid                    ),
        .i_rf_static_inc_mode           ( tb_i_rf_static_inc_mode       ),
        .i_rf_mode_gmac                 ( 0                             ),
        .i_rf_static_encrypt            ( 1'b0                          ),
        .i_clear_fault_flags            ( (count== 5)                   ),
        .i_reset                        ( tb_i_reset                    ),
        .i_clock                        ( tb_i_clock                    )
    ) ;
    assign  comp__B_o_plaintext_words_x         = ( tb_o_plaintext_words_x      == tb_B_o_plaintext_words_x         ) || ( tb_o_valid_text_decipher==1'b0 && tb_B_o_valid_text_decipher==1'b0 ) ;
    assign  comp__B_o_fail                      = ( tb_o_fail                   == tb_B_o_fail                      ) ;
    assign  comp__B_o_sop2                      = ( tb_o_sop2                   == tb_B_o_sop2                      ) ;
    assign  comp__B_o_valid_text_decipher       = ( tb_o_valid_text_decipher    == tb_B_o_valid_text_decipher       ) ;

    assign  comp__B_ghash_o_plaintext_words_x   = ( tb_o_plaintext_words_x      == tb_B_o_plaintext_words_x_new     ) || ( tb_o_valid_text_decipher==1'b0 && tb_B_o_valid_text_decipher_new==1'b0 ) ;
    assign  comp__B_ghash_o_fail                = ( tb_o_fail                   == tb_B_o_fail_new                  ) ;
    assign  comp__B_ghash_o_sop2                = ( tb_o_sop2                   == tb_B_o_sop2_new                  ) ;
    assign  comp__B_ghash_o_valid_text_decipher = ( tb_o_valid_text_decipher    == tb_B_o_valid_text_decipher_new   ) ;



    always @( posedge tb_i_clock )
    begin
        if ( tb_o_valid_text_decipher )
        begin
            tb_o_plaintext_words_x_d1
                <= tb_o_plaintext_words_x ;
        end
        if ( tb_o_sop2 )
            tb_o_sop2_d1
                <= 1'b1 ;
        else if ( tb_o_valid_text_decipher )
            tb_o_sop2_d1
                <= 1'b0 ;
        if ( tb_o_valid_text_decipher )
            tb_o_sop2_d2
                <= tb_o_sop2_d1 ;
    end



    assign  comp_1
                = ( u_gcm_aes_cipher.hash_subkey_h == expected_out_1 ) ;



    t_frame_check
    #(
        .NB_FRAME_SIZE              ( 16                        ),
        .NB_DATA                    ( 256                       ),
        .MSB_IS_NEWER               ( 0                         )
    )
    u_t_frame_check
    (
        .o_lock                     ( comp_2                    ),
        .i_data                     ( tb_o_plaintext_words_x_d1 ),
        .i_sof                      ( tb_o_sop2_d1              ),
        .i_fas                      ( {48'hf6f6f6282828,208'd0} ),
        .i_valid                    ( tb_o_valid_text_decipher  ),
        .i_reset                    ( tb_i_reset                ),
        .i_clock                    ( tb_i_clock                )
    ) ;


    t_frame_check
    #(
        .NB_FRAME_SIZE              ( 16                        ),
        .NB_DATA                    ( 256                       ),
        .MSB_IS_NEWER               ( 0                         )
    )
    u_t_frame_check__1gctr_new
    (
        .o_lock                     ( prbs_lock_new                     ),
        .i_data                     ( tb_B_o_plaintext_words_x_new      ),
        .i_sof                      ( tb_B_o_sop2_new                   ),
        .i_fas                      ( {48'hf6f6f6282828,208'd0}         ),
        .i_valid                    ( tb_B_o_valid_text_decipher_new    ),
        .i_reset                    ( tb_i_reset                        ),
        .i_clock                    ( tb_i_clock                        )
    ) ;



  /*  always @( posedge tb_i_clock )
    begin
        if ( count == 510*30 )
        begin
            $stop(  ) ;
        end
    end
*/

endmodule // t_gf_multiplier_gcm_spec

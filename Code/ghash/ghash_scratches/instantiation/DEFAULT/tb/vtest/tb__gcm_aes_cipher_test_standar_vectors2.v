module tb__gcm_aes_cipher_test_standar_vectors2(  ) ;    // Test Case 15.

    // PARAMETERS.
    parameter                           NB_BLOCK            = 128 ;
    parameter                           N_BLOCKS            = 2 ;
    parameter                           NB_DATA             = (N_BLOCKS*NB_BLOCK) ;
    parameter                           NB_KEY              = 256 ;
    parameter                           NB_IV               = 96 ;
    parameter                           NB_INC_MODE         = 2 ;

    parameter                           SIM_PERIOD_A        = 600 ;
    parameter                           SOP_OFFSET_PART_B   = /*400*/960 ;
    parameter                           SOP_OFFSET          = 0 ;

    // OUTPUTS.
    wire            [NB_DATA-1:0]       tb_o_ciphertext_words_y ;
    wire            [NB_DATA-1:0]       tbc_o_ciphertext_words_y ;
    wire                                tb_o_valid_text ;
    wire            [NB_BLOCK-1:0]      tb_o_tag ;
    wire            [NB_BLOCK-1:0]      tbc_o_tag ;
    wire            [NB_BLOCK-1:0]      tbd_o_tag ;
                                                     
    wire            [NB_DATA-1:0]       tb_o_plaintext_words_x ;
    wire            [NB_DATA-1:0]       tbd_o_plaintext_words_x ;
    wire                                tb_o_valid_text_decipher ;
    wire                                tb_o_fail ;

    // INPUTS.
    reg             [NB_DATA-1:0]       tb_i_plaintext_words_x ;
    wire            [NB_KEY-1:0]        tb_i_rf_static_key ;
    wire            [NB_BLOCK-1:0]      tb_i_aad ;
    wire            [NB_IV-1:0]         tb_i_iv ;
    wire            [NB_BLOCK/2-1:0]    tb_i_length_aad ;
    wire            [NB_BLOCK/2-1:0]    tb_i_length_plaintext ;
    wire                                tb_i_sop ;
    wire                                tb_i_valid ;
    wire                                tb_i_valid_text ;
    wire            [NB_INC_MODE-1:0]   tb_i_rf_static_inc_mode ;
    wire                                tb_i_reset ;
    reg                                 tb_i_clock ;
    
    integer                             count               = 0 ;

    wire            [NB_BLOCK-1:0]      expected_out_1 ;
    wire            [NB_BLOCK-1:0]      expected_out_2 ;
    wire            [NB_BLOCK-1:0]      expected_out_3 ;
    wire            [NB_BLOCK-1:0]      expected_out_4 ;


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
                = ( count == 0 ) || ( count == 1 )  ;

    assign  tb_i_valid
                = 1'b1 ;
    assign  tb_i_valid_text
                = ( count==(SOP_OFFSET+1+SOP_OFFSET_PART_B+0*SIM_PERIOD_A) ) || ( count==(SOP_OFFSET+2+SOP_OFFSET_PART_B+0*SIM_PERIOD_A) )
                ||( count==(SOP_OFFSET+1+SOP_OFFSET_PART_B+1*SIM_PERIOD_A) ) || ( count==(SOP_OFFSET+3+SOP_OFFSET_PART_B+1*SIM_PERIOD_A) )
                ||( count==(SOP_OFFSET+1+SOP_OFFSET_PART_B+2*SIM_PERIOD_A) ) || ( count==(SOP_OFFSET+4+SOP_OFFSET_PART_B+2*SIM_PERIOD_A) ) ;

    always @( * )
        tb_i_plaintext_words_x
            = ( count==(SOP_OFFSET+1+SOP_OFFSET_PART_B+0*SIM_PERIOD_A) || count==(SOP_OFFSET+1+SOP_OFFSET_PART_B+1*SIM_PERIOD_A) || count==(SOP_OFFSET+1+SOP_OFFSET_PART_B+2*SIM_PERIOD_A) ) ?
                { 128'h86a7a9531534f7da2e4c303d8a318a72, 128'hd9313225f88406e5a55909c5aff5269a } :
              ( count==(SOP_OFFSET+2+SOP_OFFSET_PART_B+0*SIM_PERIOD_A) || count==(SOP_OFFSET+3+SOP_OFFSET_PART_B+1*SIM_PERIOD_A) || count==(SOP_OFFSET+4+SOP_OFFSET_PART_B+2*SIM_PERIOD_A) ) ?
                { 128'hb16aedf5aa0de657ba637b391aafd255, 128'h1c3c0c95956809532fcf0e2449a6b525 } :
                256'd0 ;

    assign  tb_i_rf_static_key
                = ( count < SOP_OFFSET+3*SIM_PERIOD_A+SOP_OFFSET_PART_B )                           ?    
                { 128'hfeffe9928665731c6d6a8f9467308308, 128'hfeffe9928665731c6d6a8f9467308308 }    : 
                { 128'hfeffe9928665731c6d6a8f9467308307, 128'hfeffe9928665731c6d6a8f9467308307 }    ;

    assign  tb_i_aad
                = 128'h00000000000000000000000000000000 ;

    assign  tb_i_iv
                = 96'hcafebabefacedbaddecaf888 ;

    assign  tb_i_length_aad
                = 64'h0000000000000000 ;

    assign  tb_i_length_plaintext
                = 64'h0000000000000200 ;

    assign  tb_i_sop
                = ( count == SOP_OFFSET+0*SIM_PERIOD_A+SOP_OFFSET_PART_B ) || ( count == SOP_OFFSET+1*SIM_PERIOD_A+SOP_OFFSET_PART_B )
                || ( count == SOP_OFFSET+2*SIM_PERIOD_A+SOP_OFFSET_PART_B ) || ( count == SOP_OFFSET+3*SIM_PERIOD_A+SOP_OFFSET_PART_B ) ;

    assign  tb_i_rf_static_inc_mode
                = 2'd0 ;

    assign  expected_out_1
                = 128'hacbef20579b4b8ebce889bac8732dad7 ;
    assign  expected_out_2
                = 128'h530f8afbc74536b9a963b4f1c4cb738b ;
    assign  expected_out_3
                = 128'hcea7403d4d606b6e074ec5d3baf39d18 ;
    assign  expected_out_4
                = 128'hd0d1c8a799996bf0265b98b5d48ab919 ;



    // MODULE INSTANTIATION.


    gcm_aes_cipher
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   ),
        .LOG2_NB_DATA_T             ( 8                             ),
        .NB_TIMER                   ( 10                            )
    )
    u_gcm_aes_cipher
    (
        .o_ciphertext_words_y       ( tb_o_ciphertext_words_y       ),
        .o_sop                      ( tb_o_sop                      ),
        .o_valid_text               ( tb_o_valid_text               ),
        .o_tag                      ( tb_o_tag                      ),
        .o_tag_ready                ( tb_o_tag_ready                ),
        .o_fault_sop_and_keyupdate  ( tb_o_fault_sop_and_keyupdate  ),
        .i_plaintext_words_x        ( tb_i_plaintext_words_x        ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( tb_i_sop                      ),
        .i_update_key               ( (count==10)                   ),
        .i_valid_text               ( tb_i_valid_text               ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;
    gcm_aes_core
    #(
        .NB_BLOCK                   ( NB_BLOCK                      ),
        .N_BLOCKS                   ( N_BLOCKS                      ),
        .LOG2_N_BLOCKS              ( 2                             ),
        .NB_DATA                    ( NB_DATA                       ),
        .NB_KEY                     ( NB_KEY                        ),
        .NB_IV                      ( NB_IV                         ),
        .NB_INC_MODE                ( NB_INC_MODE                   ),
        .LOG2_NB_DATA_T             ( 8                             ),
        .NB_TIMER                   ( 10                            )
    )
    u_gcm_aes_core__c
    (
        .o_ciphertext_words_y       ( tbc_o_ciphertext_words_y      ),
        .o_fail                     ( tbc_o_fail                    ),
        .o_sop                      ( tbc_o_sop                     ),
        .o_valid_text               ( tbc_o_valid_text              ),
        .o_tag                      ( tbc_o_tag                     ),
        .o_tag_ready                ( tbc_o_tag_ready               ),
        .o_fault_sop_and_keyupdate  ( tbc_o_fault_sop_and_keyupdate ),
        .i_plaintext_words_x        ( tb_i_plaintext_words_x        ),
        .i_tag                      (  128'd0                       ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( tb_i_sop                      ),
        .i_valid_text               ( tb_i_valid_text               ),
        .i_valid                    ( tb_i_valid                    ),
        .i_update_key               ( (count==10)                   ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_rf_static_encrypt        ( 1'b1                          ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;
    assign  comp_c__tb_o_ciphertext_words_y         = ( tb_o_ciphertext_words_y      == tbc_o_ciphertext_words_y      ) ;     
    assign  comp_c__tb_o_sop                        = ( tb_o_sop                     == tbc_o_sop                     ) ;
    assign  comp_c__tb_o_valid_text                 = ( tb_o_valid_text              == tbc_o_valid_text              ) ;
    assign  comp_c__tb_o_tag                        = ( tb_o_tag                     == tbc_o_tag                     ) ;
    assign  comp_c__tb_o_tag_ready                  = ( tb_o_tag_ready               == tbc_o_tag_ready               ) ;
    assign  comp_c__tb_o_fault_sop_and_keyupdate    = ( tb_o_fault_sop_and_keyupdate == tbc_o_fault_sop_and_keyupdate ) ;



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
        .o_sop                      ( tb_o_sop_decipher             ),
        .o_valid_text               ( tb_o_valid_text_decipher      ),
        .o_fail                     ( tb_o_fail                     ),
        .i_ciphertext_words_y       ( tb_o_ciphertext_words_y       ),
        .i_tag                      ( tb_o_tag                      ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( tb_o_sop                      ),
        .i_update_key               ( (count==10)                   ),
        .i_valid_text               ( tb_o_valid_text               ),
        .i_valid                    ( tb_i_valid                    ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;
    gcm_aes_core
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
    u_gcm_aes_core__d
    (
        .o_ciphertext_words_y       ( tbd_o_plaintext_words_x       ),
        .o_fail                     ( tbd_o_fail                    ),
        .o_sop                      ( tbd_o_sop                     ),
        .o_valid_text               ( tbd_o_valid_text              ),
        .o_tag                      ( tbd_o_tag                     ),
        .o_tag_ready                ( tbd_o_tag_ready               ),
        .o_fault_sop_and_keyupdate  ( tbd_o_fault_sop_and_keyupdate ),
        .i_plaintext_words_x        ( tb_o_ciphertext_words_y       ),
        .i_tag                      ( tb_o_tag                      ),
        .i_rf_static_key            ( tb_i_rf_static_key            ),
        .i_aad                      ( tb_i_aad                      ),
        .i_iv                       ( tb_i_iv                       ),
        .i_length_aad               ( tb_i_length_aad               ),
        .i_length_plaintext         ( tb_i_length_plaintext         ),
        .i_sop                      ( tb_o_sop                      ),
        .i_valid_text               ( tb_o_valid_text               ),
        .i_valid                    ( tb_i_valid                    ),
        .i_update_key               ( (count==10)                   ),
        .i_rf_static_inc_mode       ( tb_i_rf_static_inc_mode       ),
        .i_rf_static_encrypt        ( 1'b0                          ),
        .i_clear_fault_flags        ( (count== 5)                   ),
        .i_reset                    ( tb_i_reset                    ),
        .i_clock                    ( tb_i_clock                    )
    ) ;                                   
    assign  comp_d__tb_o_ciphertext_words_y         = ( tb_o_plaintext_words_x          == tbd_o_plaintext_words_x       ) ;
    assign  comp_d__tb_o_fail                       = ( tb_o_fail                       == tbd_o_fail                    ) ;
    assign  comp_d__tb_o_sop                        = ( tb_o_sop_decipher               == tbd_o_sop                     ) ;
    assign  comp_d__tb_o_valid_text                 = ( tb_o_valid_text_decipher        == tbd_o_valid_text              ) ;


    assign  comp_1
                = ( u_gcm_aes_cipher.hash_subkey_h == expected_out_1 ) ;
    assign  comp_2                                   
                = ( tb__gcm_aes_cipher_test_standar_vectors.u_gcm_aes_cipher.u_ghash_koa_n_blocks.o_data_y == 128'h4db870d37cb75fcb46097c36230d1612 ) ;
    assign  comp_3
                =  ( tb_o_ciphertext_words_y == { 128'h643a8cdcbfe5c0c97598a2bd2555d1aa, 128'h522dc1f099567d07f47f37a32a84427d } )
                || ( tb_o_ciphertext_words_y == { 128'hc5f61e6393ba7a0abcc9f662898015ad, 128'h8cb08e48590dbb3da7b08b1056828838 } ) ;
    assign  comp_4
                = ( tb_o_tag == 128'hb094dac5d93471bdec1a502270e3cc6c ) ;
    assign  comp_5                                       
                =  ( tb_o_plaintext_words_x == { 128'h86a7a9531534f7da2e4c303d8a318a72, 128'hd9313225f88406e5a55909c5aff5269a } )
                || ( tb_o_plaintext_words_x == { 128'hb16aedf5aa0de657ba637b391aafd255, 128'h1c3c0c95956809532fcf0e2449a6b525 } ) ;
    assign  comp_6
                = ( tb_o_fail == 1'b0 ) ;



    always @( posedge tb_i_clock )
    begin
        if ( count == SIM_PERIOD_A*6 )
        begin
            if ( comp_1 & comp_2 & comp_3 & comp_4 ) 
                $display("TEST PASSED!") ;
            else
                $display("TEST FAILED :(") ;
            $stop(  ) ;
        end
    end



    wire    [NB_BLOCK-1:0]                      test_check_1 ;
    ghash_core
    #(
        .NB_DATA        ( NB_BLOCK                              )
    )
    u_ghash_core_1
    (
        .o_data_y       ( test_check_1                          ),
        .i_data_x       ( 128'h522dc1f099567d07f47f37a32a84427d ),
        .i_data_x_prev  ( 128'd0                                ),
        .i_h_key        ( expected_out_1                        ),
        .i_valid        ( tb_i_valid                            ),
        .i_reset        ( tb_i_reset                            ),
        .i_clock        ( tb_i_clock                            )
    ) ;
    wire    [NB_BLOCK-1:0]                      test_check_2 ;
    ghash_core
    #(
        .NB_DATA        ( NB_BLOCK                              )
    )
    u_ghash_core_2
    (
        .o_data_y       ( test_check_2                          ),
        .i_data_x       ( 128'h643a8cdcbfe5c0c97598a2bd2555d1aa ),
        .i_data_x_prev  ( test_check_1                          ),
        .i_h_key        ( expected_out_1                        ),
        .i_valid        ( tb_i_valid                            ),
        .i_reset        ( tb_i_reset                            ),
        .i_clock        ( tb_i_clock                            )
    ) ;
    wire    [NB_BLOCK-1:0]                      test_check_3 ;
    ghash_core
    #(
        .NB_DATA        ( NB_BLOCK                              )
    )
    u_ghash_core_3
    (
        .o_data_y       ( test_check_3                          ),
        .i_data_x       ( 128'h8cb08e48590dbb3da7b08b1056828838 ),
        .i_data_x_prev  ( test_check_2                          ),
        .i_h_key        ( expected_out_1                        ),
        .i_valid        ( tb_i_valid                            ),
        .i_reset        ( tb_i_reset                            ),
        .i_clock        ( tb_i_clock                            )
    ) ;
    wire    [NB_BLOCK-1:0]                      test_check_4 ;
    ghash_core
    #(
        .NB_DATA        ( NB_BLOCK                              )
    )
    u_ghash_core_4
    (
        .o_data_y       ( test_check_4                          ),
        .i_data_x       ( 128'hc5f61e6393ba7a0abcc9f662898015ad ),
        .i_data_x_prev  ( test_check_3                          ),
        .i_h_key        ( expected_out_1                        ),
        .i_valid        ( tb_i_valid                            ),
        .i_reset        ( tb_i_reset                            ),
        .i_clock        ( tb_i_clock                            )
    ) ;
    wire    [NB_BLOCK-1:0]                      test_check_5 ;
    ghash_core
    #(
        .NB_DATA        ( NB_BLOCK                              )
    )
    u_ghash_core_5
    (
        .o_data_y       ( test_check_5                          ),
        .i_data_x       ( 128'h00000000000000000000000000000200 ),
        .i_data_x_prev  ( test_check_4                          ),
        .i_h_key        ( expected_out_1                        ),
        .i_valid        ( tb_i_valid                            ),
        .i_reset        ( tb_i_reset                            ),
        .i_clock        ( tb_i_clock                            )
    ) ;



endmodule // t_gf_multiplier_gcm_spec

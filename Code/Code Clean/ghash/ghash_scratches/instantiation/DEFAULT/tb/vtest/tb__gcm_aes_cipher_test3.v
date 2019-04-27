module tb__gcm_aes_cipher_test3(  );

    // PARAMETERS.
    parameter                           NB_BLOCK            = 128 ;
    parameter                           N_BLOCKS            = 2 ;
    parameter                           NB_DATA             = (N_BLOCKS*NB_BLOCK) ;
    parameter                           NB_KEY              = 256 ;
    parameter                           NB_IV               = 96 ;
    parameter                           NB_INC_MODE         = 2 ;

    // OUTPUTS.
    wire            [NB_DATA-1:0]       tb_o_ciphertext_words_y ;
    wire            [NB_BLOCK-1:0]      tb_o_tag ;
    // INPUTS.
    reg             [NB_DATA-1:0]       tb_i_plaintext_words_x ;
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
    
    integer                             count               = 0 ;

    wire            [NB_BLOCK-1:0]      expected_out_1 ;
    wire            [NB_BLOCK-1:0]      expected_out_2 ;


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
                = ( count == 0 ) || ( count == 1 ) ;

    assign  tb_i_valid
                = 1'b1 ;

    initial tb_i_plaintext_words_x
                = { 128'h00000000000000000000000000000000, 128'h00112233445566778899aabbccddeeff } ;

    initial
        force   tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[0].u_round_block_ii.i_state
                    = 128'h00112233445566778899aabbccddeeff ;

    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_a_subbytes ;
    wire    [128-1:0]   state_a_subbytes_exp ;
    assign  state_a_subbytes
                    = tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_a_subbytes ;
    assign  state_a_subbytes_exp
                    = 128'h63cab7040953d051cd60e0e7ba70e18c ;
    assign  comp_a_subbytes
                    = ( state_a_subbytes == state_a_subbytes_exp ) ;
    // ---------------------------------------------------------------------------------------------------------



    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_b_shiftrows ;
    wire    [128-1:0]   state_b_shiftrows_exp ;
    assign  state_b_shiftrows
                    = tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_b_shiftrows ;
    assign  state_b_shiftrows_exp
                    = 128'h6353e08c0960e104cd70b751bacad0e7 ;
    assign  comp_b_shiftrows
                    = ( state_b_shiftrows == state_b_shiftrows_exp ) ;
    // ---------------------------------------------------------------------------------------------------------



    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_c_mixcolumns ;
    wire    [128-1:0]   state_c_mixcolumns_exp ;
    assign  state_c_mixcolumns
                    = tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_c_mixcolumns ;
    assign  state_c_mixcolumns_exp
                    = 128'h5f72641557f5bc92f7be3b291db9f91a ;
    assign  comp_c_mixcolumns
                    = ( state_c_mixcolumns == state_c_mixcolumns_exp ) ;
    // ---------------------------------------------------------------------------------------------------------



    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_d_addroundkey ;
    wire    [128-1:0]   state_d_addroundkey_exp ;
    assign  state_d_addroundkey
                    = tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_d_addroundkey ;
    assign  state_d_addroundkey_exp
                    = 128'h4f63760643e0aa85efa7213201a4e705 ;
    assign  comp_d_addroundkey
                    = ( state_d_addroundkey == state_d_addroundkey_exp ) ;
    // ---------------------------------------------------------------------------------------------------------
 


    // =================================================================================================================================
    // ROUND KEY CHECK.
    // =================================================================================================================================


    // ---------------------------------------------------------------------------------------------------------
    genvar              ii ;
    wire    [128-1:0]   key_dut [15-1:0] ;
    wire    [128-1:0]   key_exp [15-1:0] ;
    wire    [15-1:0]    key_match ;

    assign  key_exp[ 0] =128'h000102030405060708090a0b0c0d0e0f ;
    assign  key_exp[ 1] =128'h101112131415161718191a1b1c1d1e1f ;
    assign  key_exp[ 2] =128'ha573c29fa176c498a97fce93a572c09c ;
    assign  key_exp[ 3] =128'h1651a8cd0244beda1a5da4c10640bade ;
    assign  key_exp[ 4] =128'hae87dff00ff11b68a68ed5fb03fc1567 ;
    assign  key_exp[ 5] =128'h6de1f1486fa54f9275f8eb5373b8518d ;
    assign  key_exp[ 6] =128'hc656827fc9a799176f294cec6cd5598b ;
    assign  key_exp[ 7] =128'h3de23a75524775e727bf9eb45407cf39 ;
    assign  key_exp[ 8] =128'h0bdc905fc27b0948ad5245a4c1871c2f ;
    assign  key_exp[ 9] =128'h45f5a66017b2d387300d4d33640a820a ;
    assign  key_exp[10] =128'h7ccff71cbeb4fe5413e6bbf0d261a7df ;
    assign  key_exp[11] =128'hf01afafee7a82979d7a5644ab3afe640 ;
    assign  key_exp[12] =128'h2541fe719bf500258813bbd55a721c0a ;
    assign  key_exp[13] =128'h4e5a6699a9f24fe07e572baacdf8cdea ;
    assign  key_exp[14] =128'h24fc79ccbf0979e9371ac23c6d68de36 ;

    generate
        for ( ii=0; ii<15; ii=ii+1 )
        begin : genfor_key_check
            assign  key_dut[ii]
                        = tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_key_scheduler.o_round_key_vector[ii*128+:128] ;
            assign  key_match[ii]
                        = key_dut[ii]==key_exp[ii] ;
        end // genfor_key_check
    endgenerate
    // ---------------------------------------------------------------------------------------------------------





    assign  tb_i_rf_static_key
             // = { 128'h000102030405060708090a0b0c0d0e0f,
             //     128'h101112131415161718191a1b1c1d1e1f } ;
                = 256'd0 ;

    assign  tb_i_aad
                = 128'h00000000000000000000000000000000 ;

    assign  tb_i_iv
                = 96'h000000000000000000000000 ;

    assign  tb_i_length_aad
                = 64'h0000000000000000 ;

    assign  tb_i_length_plaintext
                = 64'h0000000000000000 ;

    assign  tb_i_sop
                = 1'b1 ;

    assign  tb_i_rf_static_inc_mode
                = 2'd0 ;

    assign  expected_out_1
                = 128'hdc95c078a2408989ad48a21492842087 ;
    assign  expected_out_2
                = 128'h530f8afbc74536b9a963b4f1c4cb738b ;



    // MODULE INSTANTIATION.
    gcm_aes_cipher
    #(
        .NB_BLOCK               ( NB_BLOCK                  ),
        .N_BLOCKS               ( N_BLOCKS                  ),
        .NB_DATA                ( NB_DATA                   ),
        .NB_KEY                 ( NB_KEY                    ),
        .NB_IV                  ( NB_IV                     ),
        .NB_INC_MODE            ( NB_INC_MODE               )
    )
    u_gcm_aes_cipher
    (
        .o_ciphertext_words_y   ( tb_o_ciphertext_words_y   ),
        .o_tag                  ( tb_o_tag                  ),
        .i_plaintext_words_x    ( tb_i_plaintext_words_x    ),
        .i_rf_static_key        ( tb_i_rf_static_key        ),
        .i_aad                  ( tb_i_aad                  ),
        .i_iv                   ( tb_i_iv                   ),
        .i_length_aad           ( tb_i_length_aad           ),
        .i_length_plaintext     ( tb_i_length_plaintext     ),
        .i_sop                  ( tb_i_sop                  ),
        .i_valid                ( tb_i_valid                ),
        .i_rf_static_inc_mode   ( tb_i_rf_static_inc_mode   ),
        .i_reset                ( tb_i_reset                ),
        .i_clock                ( tb_i_clock                )
    ) ;


    assign  comp_1
                = ( u_gcm_aes_cipher.hash_subkey_h == expected_out_1 ) ;
    assign  comp_2
                = ( tb__gcm_aes_cipher_test3.u_gcm_aes_cipher.u_gctr_function_n_blocks__tag.genfor_gctr_base[0].u_aes_round_ladder_ii.o_state == expected_out_2) ;



    always @( posedge tb_i_clock )
    begin
        if ( count == 100 )
        begin
            if ( comp_1 & comp_2 ) 
                $display("TEST PASSED!") ;
            else
                $display("TEST FAILED :(") ;
            $stop(  ) ;
        end
    end


endmodule // t_gf_multiplier_gcm_spec

module tb__gcm_aes_cipher_test1(  );

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
        force   tb__gcm_aes_cipher_test1.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[0].u_round_block_ii.i_state
                    = 128'h00112233445566778899aabbccddeeff ;

    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_a_subbytes ;
    wire    [128-1:0]   state_a_subbytes_exp ;
    assign  state_a_subbytes
                    = tb__gcm_aes_cipher_test1.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_a_subbytes ;
    assign  state_a_subbytes_exp
                    = 128'h63cab7040953d051cd60e0e7ba70e18c ;
    assign  comp_a_subbytes
                    = ( state_a_subbytes == state_a_subbytes_exp ) ;
    // ---------------------------------------------------------------------------------------------------------



    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_b_shiftrows ;
    wire    [128-1:0]   state_b_shiftrows_exp ;
    assign  state_b_shiftrows
                    = tb__gcm_aes_cipher_test1.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_b_shiftrows ;
    assign  state_b_shiftrows_exp
                    = 128'h6353e08c0960e104cd70b751bacad0e7 ;
    assign  comp_b_shiftrows
                    = ( state_b_shiftrows == state_b_shiftrows_exp ) ;
    // ---------------------------------------------------------------------------------------------------------



    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_c_mixcolumns ;
    wire    [128-1:0]   state_c_mixcolumns_exp ;
    assign  state_c_mixcolumns
                    = tb__gcm_aes_cipher_test1.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_c_mixcolumns ;
    assign  state_c_mixcolumns_exp
                    = 128'h5f72641557f5bc92f7be3b291db9f91a ;
    assign  comp_c_mixcolumns
                    = ( state_c_mixcolumns == state_c_mixcolumns_exp ) ;
    // ---------------------------------------------------------------------------------------------------------



    // ---------------------------------------------------------------------------------------------------------
    wire    [128-1:0]   state_d_addroundkey ;
    wire    [128-1:0]   state_d_addroundkey_exp ;
    assign  state_d_addroundkey
                    = tb__gcm_aes_cipher_test1.u_gcm_aes_cipher.u_gctr_function_n_blocks__data.genfor_gctr_base[0].u_aes_round_ladder_ii.genfor_aes_rounds[1].u_round_block_ii.state_d_addroundkey ;
    assign  state_d_addroundkey_exp
                    = 128'h4f63760643e0aa85efa7213201a4e705 ;
    assign  comp_d_addroundkey
                    = ( state_d_addroundkey == state_d_addroundkey_exp ) ;
    // ---------------------------------------------------------------------------------------------------------




    assign  tb_i_rf_static_key
             // = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f ;
                = { 128'h101112131415161718191a1b1c1d1e1f,
                    128'h000102030405060708090a0b0c0d0e0f } ;

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
                = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e ;
    assign  expected_out_2
                = 128'h58e2fccefa7e3061367f1d57a4e7455a ;



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
                = ( tb_o_ciphertext_words_y[NB_BLOCK-1:0] == expected_out_2) ;



endmodule // t_gf_multiplier_gcm_spec

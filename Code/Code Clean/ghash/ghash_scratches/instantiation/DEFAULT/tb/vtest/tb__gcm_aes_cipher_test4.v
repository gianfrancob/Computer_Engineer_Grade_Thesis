module tb__gcm_aes_cipher_test4(  );    // Test Case 14.

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
                = ( count == 0 ) || ( count == 1 ) ;

    assign  tb_i_valid
                = 1'b1 ;

    initial tb_i_plaintext_words_x
                = { 256'd0 } ;







    assign  tb_i_rf_static_key
                = 256'd0 ;

    assign  tb_i_aad
                = 128'h00000000000000000000000000000000 ;

    assign  tb_i_iv
                = 96'h000000000000000000000000 ;

    assign  tb_i_length_aad
                = 64'h0000000000000000 ;

    assign  tb_i_length_plaintext
                = 64'h0000000000000080 ;

    assign  tb_i_sop
                = 1'b1 ;

    assign  tb_i_rf_static_inc_mode
                = 2'd0 ;

    assign  expected_out_1
                = 128'hdc95c078a2408989ad48a21492842087 ;
    assign  expected_out_2
                = 128'h530f8afbc74536b9a963b4f1c4cb738b ;
    assign  expected_out_3
                = 128'hcea7403d4d606b6e074ec5d3baf39d18 ;
    assign  expected_out_4
                = 128'hd0d1c8a799996bf0265b98b5d48ab919 ;



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
                = ( tb__gcm_aes_cipher_test4.u_gcm_aes_cipher.u_gctr_function_n_blocks__tag.genfor_gctr_base[0].u_aes_round_ladder_ii.o_state == expected_out_2) ;
    assign  comp_3
                = ( tb_o_ciphertext_words_y[ NB_BLOCK-1:0 ] == expected_out_3 ) ;
    assign  comp_4
                = ( tb_o_tag == expected_out_4 ) ;



    always @( posedge tb_i_clock )
    begin
        if ( count == 100 )
        begin
            if ( comp_1 & comp_2 & comp_3 & comp_4 ) 
                $display("TEST PASSED!") ;
            else
                $display("TEST FAILED :(") ;
            $stop(  ) ;
        end
    end


endmodule // t_gf_multiplier_gcm_spec

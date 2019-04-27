module tb__gcm_aes_cipher(  ) ;

    // PARAMETERS.
    parameter                                       NB_BLOCK            = 128 ;
    parameter                                       N_BLOCKS            = 2 ;
    parameter                                       NB_DATA             = (N_BLOCKS*NB_BLOCK) ;
    parameter                                       NB_KEY              = 256 ;
    parameter                                       NB_IV               = 96 ;
    parameter                                       NB_INC_MODE         = 2 ;

    // INTERNAL SIGNALS.
    integer                                         count               = 0 ;
    wire                                            tb_i_valid ;
    wire                                            tb_i_reset ;
    reg                                             tb_i_clock ;

    wire            [NB_DATA-1:0]                   tb_o_ciphertext_words_y ;
    wire            [NB_BLOCK-1:0]                  tb_o_tag ;
    reg             [NB_DATA-1:0]                   tb_i_plaintext_words_x ;
    reg             [NB_KEY-1:0]                    tb_i_rf_static_key ;
    reg             [NB_BLOCK-1:0]                  tb_i_aad ;
    reg             [NB_IV-1:0]                     tb_i_iv ;
    wire            [NB_BLOCK/2-1:0]                tb_i_length_aad ;
    wire            [NB_BLOCK/2-1:0]                tb_i_length_plaintext ;
    wire                                            tb_i_sop ;
    wire            [NB_INC_MODE-1:0]               tb_i_rf_static_inc_mode ;


    initial
    begin
        tb_i_clock
            <= 1'b0 ;
    end

    always
        #( 5 )  tb_i_clock
                    = ~tb_i_clock ;


    always @( posedge tb_i_clock )
    begin
        if ( tb_i_valid )
            count
                <= count + 1 ;
    end


    assign  tb_i_reset
                = ( count == 2 ) ;

    assign  tb_i_valid
                = 1'b1 ;


    always @( posedge tb_i_clock )
        if ( tb_i_valid )
            tb_i_plaintext_words_x
                <= { $random(), $random(), $random(), $random(),
                     $random(), $random(), $random(), $random() } ;

    initial
        tb_i_rf_static_key 
            = { $random(), $random(), $random(), $random(),
                $random(), $random(), $random(), $random() } ;

    initial
        tb_i_aad
            = { $random(), $random(), $random(), $random() } ;

    initial
        tb_i_iv
            = { $random(), $random(), $random() } ;

    assign  tb_i_length_aad
                = 64'h80 ;
    assign  tb_i_length_plaintext
                = 64'd80 ;
    assign  tb_i_sop
                = ( ( count %100 ) == 0 ) ;
    assign  tb_i_rf_static_inc_mode
                = 2'd0 ;



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



endmodule // t_gf_multiplier_gcm_spec

module tb__ghash_test3(  );

    // PARAMETERS.
    localparam                      NB_BLOCK    = 128 ;
    localparam                      N_BLOCKS    = 2 ;
    localparam                      NB_DATA     = 256 ;

    // OUTPUTS.
    wire    [NB_BLOCK-1:0]          tb_o_data_y ;
    // INPUTS.
    reg     [NB_DATA-1:0]           tb_i_data_x_bus ;
    wire    [NB_BLOCK-1:0]          tb_i_hash_subkey_h ; // subkey "H"
    wire                            tb_i_valid ;
    wire    [N_BLOCKS-1:0]          tb_i_skip_bus ;
    wire                            tb_i_reset ;
    reg                             tb_i_clock ;
    wire    [NB_BLOCK-1:0]          expected_out ;
    integer                         count       = 0 ;


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
        count
            <= count + 1 ;
    end



    assign  tb_i_reset
                = ( count == 0 ) || ( count == 1 ) ;

    assign  tb_i_valid
                = 1'b1 ;

    always @( * )
        case ( ( count % 3 ) )
            0   :   tb_i_data_x_bus = { 128'he3aa212f2c02a4e035c17e2329aca12e, 128'h42831ec2217774244b7221b784d0d49c } ;
            1   :   tb_i_data_x_bus = { 128'h1ba30b396a0aac973d58e091473f5985, 128'h21d514b25466931c7d8f6a5aac84aa05 } ;
            2   :   tb_i_data_x_bus = { 128'h00000000000000000000000000000000, 128'h00000000000000000000000000000200 } ;
        endcase

    assign  tb_i_hash_subkey_h
                = 128'hb83b533708bf535d0aa6e52980d53b78 ;

    assign  expected_out
               = 128'h7f1b32b81b820d02614f8895ac1d4eac ;

    assign  tb_i_sop
                = ( ( count % 3 ) == 0 ) ;

    assign  tb_i_skip_bus
                = { ( ( count % 3 ) == 2 ), 1'b0 } ;



    // MODULE INSTANTIATION.
    ghash_n_blocks
    #(
        .NB_BLOCK           ( NB_BLOCK                  ),
        .N_BLOCKS           ( N_BLOCKS                  ),
        .NB_DATA            ( NB_DATA                   )
    )
    u_ghash_n_blocks
    (
        .o_data_y           ( tb_o_data_y               ),
        .i_data_x_bus       ( tb_i_data_x_bus           ),
        .i_data_x_initial   ( 128'd0                    ),
        .i_hash_subkey_h    ( tb_i_hash_subkey_h        ),
        .i_sop              ( tb_i_sop                  ),
        .i_valid            ( tb_i_valid                ),
        .i_skip_bus         ( tb_i_skip_bus             ),
        .i_reset            ( tb_i_reset                ),
        .i_clock            ( tb_i_clock                )
    ) ;


    assign  comp
                = ( expected_out == tb_o_data_y ) ;



    wire    [128-1:0]       data_0 ;
    ghash_core
    #(
        .NB_DATA            ( NB_BLOCK                              )
    )
    u_ghash_core_0
    (
        .o_data_y           ( data_0                                ),
        .i_data_x           ( 128'h42831ec2217774244b7221b784d0d49c ),
        .i_data_x_prev      ( 128'd0                                ),
        .i_h_key            ( tb_i_hash_subkey_h                    ),
        .i_valid            ( tb_i_valid                            ),
        .i_reset            ( tb_i_reset                            ),
        .i_clock            ( tb_i_clock                            )
    ) ;

    wire    [128-1:0]       data_1 ;
    ghash_core
    #(
        .NB_DATA            ( NB_BLOCK                              )
    )
    u_ghash_core_1
    (
        .o_data_y           ( data_1                                ),
        .i_data_x           ( 128'he3aa212f2c02a4e035c17e2329aca12e ),
        .i_data_x_prev      ( data_0                                ),
        .i_h_key            ( tb_i_hash_subkey_h                    ),
        .i_valid            ( tb_i_valid                            ),
        .i_reset            ( tb_i_reset                            ),
        .i_clock            ( tb_i_clock                            )
    ) ;

    wire    [128-1:0]       data_2 ;
    ghash_core
    #(
        .NB_DATA            ( NB_BLOCK                              )
    )
    u_ghash_core_2
    (
        .o_data_y           ( data_2                                ),
        .i_data_x           ( 128'h21d514b25466931c7d8f6a5aac84aa05 ),
        .i_data_x_prev      ( data_1                                ),
        .i_h_key            ( tb_i_hash_subkey_h                    ),
        .i_valid            ( tb_i_valid                            ),
        .i_reset            ( tb_i_reset                            ),
        .i_clock            ( tb_i_clock                            )
    ) ;

    wire    [128-1:0]       data_3 ;
    ghash_core
    #(
        .NB_DATA            ( NB_BLOCK                              )
    )
    u_ghash_core_3
    (
        .o_data_y           ( data_3                                ),
        .i_data_x           ( 128'h1ba30b396a0aac973d58e091473f5985 ),
        .i_data_x_prev      ( data_2                                ),
        .i_h_key            ( tb_i_hash_subkey_h                    ),
        .i_valid            ( tb_i_valid                            ),
        .i_reset            ( tb_i_reset                            ),
        .i_clock            ( tb_i_clock                            )
    ) ;

    wire    [128-1:0]       data_4 ;
    ghash_core
    #(
        .NB_DATA            ( NB_BLOCK                              )
    )
    u_ghash_core_4
    (
        .o_data_y           ( data_4                                ),
        .i_data_x           ( 128'h00000000000000000000000000000200 ),
        .i_data_x_prev      ( data_3                                ),
        .i_h_key            ( tb_i_hash_subkey_h                    ),
        .i_valid            ( tb_i_valid                            ),
        .i_reset            ( tb_i_reset                            ),
        .i_clock            ( tb_i_clock                            )
    ) ;
    
    
    assign  comp_1
                = ( expected_out == data_4 ) ;


endmodule // t_gf_multiplier_gcm_spec

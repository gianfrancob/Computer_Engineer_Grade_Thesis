module tb__ghash_test2(  );

    // PARAMETERS.
    localparam                      NB_BLOCK    = 128 ;
    localparam                      N_BLOCKS    = 2 ;
    localparam                      NB_DATA     = 256 ;

    // OUTPUTS.
    wire    [NB_BLOCK-1:0]          o_data ;
    // INPUTS.
    wire    [NB_BLOCK-1:0]          i_data_x ;
    wire    [NB_BLOCK-1:0]          i_data_key ; // subkey "H"
    reg     [NB_BLOCK-1:0]          i_data_x_prev;
    wire                            i_valid ;
    wire                            i_reset ;
    reg                             i_clock ;
    wire    [NB_BLOCK-1:0]          expected_out ;
    wire    [NB_BLOCK-1:0]          data_length ;
    integer                         count       = 0 ;


    initial
    begin
        i_clock
            <= 1'b0 ;
    end

    always
        #( 5 )  i_clock
                    = ~i_clock ;


    always @( posedge i_clock )
    begin
        count
            <= count + 1 ;
    end



    assign  i_reset
                = ( count == 2 ) ;

    assign  i_valid
                = 1'b1 ;

    assign  i_data_x
                = 128'h0388dace60b6a392f328c2b971b2fe78 ;

    assign  i_data_key
                = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e ;

    assign  data_length
               = {120'd0, 8'h80} ;

    assign  expected_out
               = 128'hf38cbb1ad69223dcc3457ae5b6b0f885 ;

   assign   i_sop
                = ( ( count % 10 ) == 0 ) ;



    // MODULE INSTANTIATION.
    ghash_n_blocks
    #(
        .NB_BLOCK           ( NB_BLOCK                  ),
        .N_BLOCKS           ( N_BLOCKS                  ),
        .NB_DATA            ( NB_DATA                   )
    )
    u_ghash_n_blocks
    (
        .o_data_y           ( o_data                    ),
        .i_data_x_bus       ( {data_length, i_data_x }  ),
        .i_data_x_initial   ( 128'd0                    ),
        .i_hash_subkey_h    ( i_data_key                ),
        .i_skip_bus         ( 2'b00                     ),
        .i_sop              ( i_sop                     ),
        .i_valid            ( i_valid                   ),
        .i_reset            ( i_reset                   ),
        .i_clock            ( i_clock                   )
    ) ;


    assign  comp
               = ( expected_out == o_data ) ;



endmodule // t_gf_multiplier_gcm_spec

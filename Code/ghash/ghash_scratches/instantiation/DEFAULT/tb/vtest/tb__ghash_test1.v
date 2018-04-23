module tb__ghash_test1(  );

    // PARAMETERS.
    localparam                      NB_DATA = 128 ;

    // OUTPUTS.
    wire    [NB_DATA-1:0]           o_data ;
    // INPUTS.
    wire    [NB_DATA-1:0]           i_data_x ;
    wire    [NB_DATA-1:0]           i_data_key ; // subkey "H"
    reg     [NB_DATA-1:0]           i_data_x_prev;
    wire                            i_valid ;
    wire                            i_reset ;
    reg                             i_clock ;
    wire    [NB_DATA-1:0]           expected_out ;
    wire    [NB_DATA-1:0]           data_length ;
    wire    [NB_DATA-1:0]           o_data2 ;
    reg     [NB_DATA-1:0]           count = 0 ;
    wire    [NB_DATA-1:0]           count_m ;
    reg     [NB_DATA-1:0]           shifter     = 1 ;


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
        shifter
            <= { shifter[0], shifter[NB_DATA-1:1] } ;
    end
    assign  count_m
                = count - 10 ;


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


    always @( posedge i_clock )
    begin
        if ( i_reset )
            i_data_x_prev
                <= 0;
        else if ( i_valid )
            i_data_x_prev
                <= o_data;
    end



    // assign i_data_x_prev = o_data;

    // MODULE INSTANTIATION.
    ghash_core
    #(
        .NB_DATA        ( NB_DATA                   )
    )
    u_ghash_core
    (
        .o_data_y       ( o_data                    ),
        .i_data_x       ( i_data_x                  ),
        .i_data_x_prev  ( /*i_data_x_prev*/128'd0   ),
        .i_h_key        ( i_data_key                ), // subkey "H"
        .i_valid        ( i_valid                   ),
        .i_reset        ( i_reset                   ),
        .i_clock        ( i_clock                   )
    );

    ghash_core
    #(
        .NB_DATA        ( NB_DATA                   )
    )
    u_ghash_core_2
    (
        .o_data_y       ( o_data2                   ),
        .i_data_x       ( data_length               ),
        .i_data_x_prev  ( o_data                    ),
        .i_h_key        ( i_data_key                ) , // subkey "H"
        .i_valid        ( i_valid                   ),
        .i_reset        ( i_reset                   ),
        .i_clock        ( i_clock                   )
     );


    assign  comp
               = ( expected_out == o_data2 ) ;


    function automatic [NB_DATA-1:0]    f_flip_bits ;
        input   [NB_DATA-1:0]           fi_data ;
        reg     [NB_DATA-1:0]           temp ;
        integer                         i ;
        begin
            for ( i=0; i<NB_DATA; i=i+1 )
                temp[ NB_DATA-1-i ]
                    = fi_data[ i ] ;
            f_flip_bits
                = temp ;
        end
    endfunction

endmodule // t_gf_multiplier_gcm_spec

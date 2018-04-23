module tb__gf_2to128_multiplier_booth1modmod(  );

    // PARAMETERS.
    localparam                          NB_DATA = 128 ;


    // INTERNAL SIGNALS.
    wire    [NB_DATA-1:0]               a__data_x ;
    wire    [NB_DATA-1:0]               a__data_y ;
    wire    [NB_DATA-1:0]               a__data_z ;
    wire    [NB_DATA-1:0]               a__data_z_booth ;
    wire    [NB_DATA-1:0]               b__data_x ;
    wire    [NB_DATA-1:0]               b__data_y ;
    wire    [NB_DATA-1:0]               b__data_z ;
    wire    [NB_DATA-1:0]               b__data_z_booth ;
    wire    [NB_DATA-1:0]               c__data_x ;
    wire    [NB_DATA-1:0]               c__data_y ;
    wire    [NB_DATA-1:0]               c__data_z ;
    wire    [NB_DATA-1:0]               c__data_z_booth ;
    wire    [NB_DATA-1:0]               d__data_x ;
    wire    [NB_DATA-1:0]               d__data_y ;
    wire    [NB_DATA-1:0]               d__data_z ;
    wire    [NB_DATA-1:0]               d__data_z_booth ;
    wire    [NB_DATA-1:0]               e__data_x ;
    wire    [NB_DATA-1:0]               e__data_y ;
    wire    [NB_DATA-1:0]               e__data_z ;
    wire    [NB_DATA-1:0]               e__data_z_booth ;
    wire    [NB_DATA-1:0]               f__data_x ;
    wire    [NB_DATA-1:0]               f__data_y ;
    wire    [NB_DATA-1:0]               f__data_z ;
    wire    [NB_DATA-1:0]               f__data_z_booth ;
    wire    [NB_DATA-1:0]               a__xor ;
    wire    [NB_DATA-1:0]               b__xor ;
    wire    [NB_DATA-1:0]               c__xor ;
    wire    [NB_DATA-1:0]               d__xor ;
    wire    [NB_DATA-1:0]               e__xor ;
    wire    [NB_DATA-1:0]               f__xor ;

    reg                                 tb_i_clock  = 1'b0 ;
    reg     [NB_DATA-1:0]               count       = 0 ;
    wire    [NB_DATA-1:0]               count_m ;
    reg     [NB_DATA-1:0]               shifter_1   = 128'd1 ;
    reg     [NB_DATA-1:0]               shifter_2   = { 104'd0, {24{1'b1}}} ;
    reg     [NB_DATA-1:0]               rand_1      = 0 ;
    reg     [NB_DATA-1:0]               rand_2      = 0 ;



    always
        #( 50 )  tb_i_clock
                    = ~tb_i_clock ;


    always @( posedge tb_i_clock )
    begin
        count
            <= count + 1 ;
        shifter_1
            <= { shifter_1[0], shifter_1[NB_DATA-1:1] } ;
        shifter_2
            <= { shifter_2[0], shifter_2[NB_DATA-1:1] } ;
        rand_1
            <= { $random(), $random(), $random(), $random() } ;
        rand_2
            <= { $random(), $random(), $random(), $random() } ;
    end
    assign  count_m
                = count - 10 ;


    // DUT Input mapping.
    // =====================================================================

    assign  a__data_x
                = 128'h0388dace60b6a392f328c2b971b2fe78 ;
    assign  a__data_y
                = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e ;


    assign  b__data_x
                = shifter_1 ;
    assign  b__data_y
                = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e ;


    assign  c__data_x
                = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e ;
    assign  c__data_y
                = shifter_2 ;


    assign  d__data_x
                = 128'h8000_0000_0000_0000_0000_0000_0000_0000 ;
    assign  d__data_y
                = {128{1'd1}} ;


    assign  e__data_x
                = {128{1'd1}} ;
    assign  e__data_y
                = 128'h8000_0000_0000_0000_0000_0000_0000_0000 ;


    assign  f__data_x
                = rand_1 ;
    assign  f__data_y
                = rand_2 ;



    // DUT Connections.
    // =====================================================================

    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier__a
    (
        .o_data_z   ( a__data_z         ),
        .i_data_y   ( a__data_y         ),
        .i_data_x   ( a__data_x         )
    ) ;
    gf_2to128_multiplier_booth1mod
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier_booth1mod__a
    (
        .o_data_z   ( a__data_z_booth   ),
        .i_data_y   ( a__data_y         ),
        .i_data_x   ( a__data_x         )
    ) ;
    assign  a__comp
                = ( a__data_z == a__data_z_booth ) ;


    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier__b
    (
        .o_data_z   ( b__data_z         ),
        .i_data_y   ( b__data_y         ),
        .i_data_x   ( b__data_x         )
    ) ;
    gf_2to128_multiplier_booth1mod
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier_booth1mod__b
    (
        .o_data_z   ( b__data_z_booth   ),
        .i_data_y   ( b__data_y         ),
        .i_data_x   ( b__data_x         )
    ) ;
    assign  b__comp
                = ( b__data_z == b__data_z_booth ) ;


    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier__c
    (
        .o_data_z   ( c__data_z         ),
        .i_data_y   ( c__data_y         ),
        .i_data_x   ( c__data_x         )
    ) ;
    gf_2to128_multiplier_booth1mod
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier_booth1mod__c
    (
        .o_data_z   ( c__data_z_booth   ),
        .i_data_y   ( c__data_y         ),
        .i_data_x   ( c__data_x         )
    ) ;
    assign  c__comp
                = ( c__data_z == c__data_z_booth ) ;


    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier__d
    (
        .o_data_z   ( d__data_z         ),
        .i_data_y   ( d__data_y         ),
        .i_data_x   ( d__data_x         )
    ) ;
    gf_2to128_multiplier_booth1mod
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier_booth1mod__d
    (
        .o_data_z   ( d__data_z_booth   ),
        .i_data_y   ( d__data_y         ),
        .i_data_x   ( d__data_x         )
    ) ;
    assign  d__comp
                = ( d__data_z == d__data_z_booth ) ;


    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier__e
    (
        .o_data_z   ( e__data_z         ),
        .i_data_y   ( e__data_y         ),
        .i_data_x   ( e__data_x         )
    ) ;
    gf_2to128_multiplier_booth1mod
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier_booth1mod__e
    (
        .o_data_z   ( e__data_z_booth   ),
        .i_data_y   ( e__data_y         ),
        .i_data_x   ( e__data_x         )
    ) ;
    assign  e__comp
                = ( e__data_z == e__data_z_booth ) ;


    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier__f
    (
        .o_data_z   ( f__data_z         ),
        .i_data_y   ( f__data_y         ),
        .i_data_x   ( f__data_x         )
    ) ;
    gf_2to128_multiplier_booth1mod
    #(
        .NB_DATA    ( NB_DATA           )
    )
    u_gf_2to128_multiplier_booth1mod__f
    (
        .o_data_z   ( f__data_z_booth   ),
        .i_data_y   ( f__data_y         ),
        .i_data_x   ( f__data_x         )
    ) ;
    assign  f__comp
                = ( f__data_z == f__data_z_booth ) ;


    assign  a__xor  = ( a__data_z ^ a__data_z_booth ) ;
    assign  b__xor  = ( b__data_z ^ b__data_z_booth ) ;
    assign  c__xor  = ( c__data_z ^ c__data_z_booth ) ;
    assign  d__xor  = ( d__data_z ^ d__data_z_booth ) ;
    assign  e__xor  = ( e__data_z ^ e__data_z_booth ) ;
    assign  f__xor  = ( f__data_z ^ f__data_z_booth ) ;




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

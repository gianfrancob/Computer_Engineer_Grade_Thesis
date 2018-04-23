module tb_ghash_new_architecture2();
    localparam                              NB_BLOCK    = 128;
    localparam                              N_BLOCKS    = 2;
    localparam                              NB_DATA     = N_BLOCKS*NB_BLOCK;
    localparam                              H_POW       = 8;

    wire    [H_POW*NB_BLOCK-1:0]            h_key_powers;
    wire    [NB_DATA-1:0]                   i_data;
    wire    [NB_BLOCK-1:0]                  o_data_ghash_control;
    wire    [NB_BLOCK-1:0]                  o_data_ghash_n_blocks;
    wire    [NB_BLOCK-1:0]                  o_data_ghash_koa_n_blocks;
    wire    [NB_BLOCK-1:0]                  o_data_ghash_new;
    wire    [NB_BLOCK-1:0]                  o_data_ghash_new_pipe;
    wire    [NB_BLOCK-1:0]                  h_key;
    wire                                    reset;
    wire    [N_BLOCKS-1:0]                  skip_bus;
    reg                                     clock;
    wire                                    valid;
    wire                                    sop;
    integer                                 count;
    reg     [NB_BLOCK-1:0]                  count2;

    initial begin
        count   <= 0;
        count2  <= 128'd0;
        clock   <= 1'b0;
    end

    always #5 clock <= ~clock;

    always @( posedge clock ) begin
        count   <= count+1;
        count2  <= count2+128'd2;
    end

    assign h_key = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;

    assign i_data = /*( count > 500 ) ? 256'b0 : */{ count2+1, count2 };

    assign valid_control =  ( ( count >= 15) && ( count < 529 ) ) && ( count != 300) && ( count != 400) // 15 + 510 = 525
                    || ( count >= 552) && (count < 752 ) || ( count >= 760) && ( count < 1071 );
    assign valid2 = ( count >= 15) && ( count <= 52 );
    // assign valid_new_arch_pipe = ( ( count >= 15) && ( count < 540 )  )&& ( count != 300) && ( count != 400)
    //                 || ( count >= 552) && (count < 752 ) || ( count >= 760) && ( count < 1090 );
    assign valid_new_arch_pipe = ( ( count >= 15) && ( count < 529 ) ) && ( count != 300) && ( count != 400) // 15 + 510 = 525
                    || ( count >= 552) && (count < 752 ) || ( count >= 760) && ( count < 1071 );
    assign valid2 = ( count >= 15) && ( count <= 52 );
    assign valid_random = ( count == $random );
    assign sop_random   = ( count == $random );

    assign reset = ( count == 1 );
    assign reset_control  = ( count == 1);

    assign sop = ( count == 15 ) /*|| ( count == 22 ) */|| ( count == 550 ) || ( count == 552 );
    assign sop_control = ( count == 16 ) /*|| ( count == 26 ) */|| ( count == 550 ) || ( count == 552 );
    // assign sop_control = sop;

    assign skip_bus = ( count == 528 ) ? 2'b10 : 2'b00;
    assign skip_bus_arch = ( count == 528 ) ? 1'b1 : 1'b0;

    h_key_power_table
    #(
        .NB_BLOCK       ( NB_BLOCK  ) ,
        .N_BLOCKS       ( H_POW  ) ,
        .NB_DATA        ( H_POW*NB_BLOCK   ) 
    )
    u_h_key_power_table
    (
        // OUTPUTS.
        .o_h_key_powers ( h_key_powers    ) ,
        // INPUTS   
        .i_h_key        ( h_key   ) ,
        .i_clock        ( clock            )
    ) ; 

    ghash_n_blocks2
    #(
        .NB_BLOCK           (  NB_BLOCK ),
        .N_BLOCKS           (  N_BLOCKS ),
        .NB_DATA            (  NB_DATA )
    )
    u_ghash_n_blocks2
    (
        .o_data_y           ( o_data_ghash_control  ),
        .i_data_x_bus       ( i_data  ),
        .i_data_x_initial   ( 128'hffff0000   ),
        .i_hash_subkey_h    ( h_key   ),
        .i_sop              (  sop_control ),
        .i_valid            (  valid_control/*1'b1*/ ),
        .i_skip_bus         (  skip_bus ),
        .i_reset            (  reset_control ),
        .i_clock            (  clock )
    );
    
    ghash_n_blocks
    #(
        .NB_BLOCK           (  NB_BLOCK ),
        .N_BLOCKS           ( N_BLOCKS  ),
        .NB_DATA            ( NB_DATA  )
    )
    u_ghash_n_blocks
    (
        .o_data_y           (  o_data_ghash_n_blocks ),
        .i_data_x_bus       ( i_data  ),
        .i_data_x_initial   ( 128'hffff0000  ),
        .i_hash_subkey_h    (  h_key ),
        .i_sop              (  sop_control ),
        .i_valid            (  valid_control ),
        .i_skip_bus         (  skip_bus ),
        .i_reset            (  reset_control ),
        .i_clock            (   clock)
    ) ;

    ghash_koa_n_blocks
    #(
        // PARAMETERS.
        .NB_BLOCK   ( NB_BLOCK ) ,   // [HINT] Any value different to 128 is not valid 
        .N_BLOCKS   ( N_BLOCKS ) ,
        .NB_DATA    ( NB_DATA ) 
    )
    u_ghash_koa_n_blocks
    (
        // OUTPUTS.
        .o_data_y       ( o_data_ghash_koa_n_blocks ) ,
        // INPUTS.  
        .i_data_x       ( i_data ) ,
        .i_data_x_prev  ( 128'hffff0000 ) ,
        .i_h_key_powers ( h_key_powers[0+:NB_DATA] ) ,
        .i_skip_bus     ( skip_bus ) ,
        .i_sop          ( sop_control ) ,
        .i_valid        ( valid_control ) ,
        .i_reset        ( reset_control ) ,
        .i_clock        ( clock )
    ) ;
    

    ghash_new_architecture
    #(
        // PARAMETERS
        .NB_BLOCK       ( NB_BLOCK ),
        .N_BLOCKS       ( N_BLOCKS ),
        .NB_DATA        ( NB_DATA ),
        .N_H_POW        ( H_POW )
    )
    u_ghash_new_architecture
    (
        // OUTPUTS
        .o_data_y       ( o_data_ghash_new ),
        // INPUTS
        .i_data_x       ( i_data ),
        .i_aad          ( 128'hffff0000 ),
        .i_h_key_powers ( h_key_powers ),
        .i_skip_bus     ( 2'b00 ),
        .i_sop          ( sop ),
        .i_valid        ( valid2 ),
        .i_reset        ( reset ),
        .i_clock        ( clock )
    );

    ghash_new_arch_pipelined
    #(
        // PARAMETERS
        .NB_BLOCK       ( NB_BLOCK  ),
        .N_BLOCKS       ( N_BLOCKS  ),
        .NB_DATA        ( NB_DATA   ),
        .N_H_POW        ( H_POW     ),
        .N_MESSEGES     ( 511       )
    )
    u_ghash_new_arch_pipelined
    (
        // OUTPUTS
        .o_data_y       ( o_data_ghash_new_pipe ),
        // INPUTS
        .i_data_x       ( i_data ),
        .i_aad          (128'hffff0000 ),
        .i_h_key_powers ( h_key_powers ),
        .i_skip_bus     ( skip_bus_arch ),
        .i_sop          ( sop/*sop_control*/ ),
        .i_valid        ( valid_new_arch_pipe/*1'b1*//*valid_control*/ ),
        .i_reset        ( reset/*reset_control*/ ),
        .i_clock        ( clock )
    );
    
endmodule

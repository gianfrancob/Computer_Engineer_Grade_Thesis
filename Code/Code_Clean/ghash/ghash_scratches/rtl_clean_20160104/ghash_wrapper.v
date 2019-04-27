module ghash_wrapper
#(   
    parameter                                       NB_BLOCK        = 128,
    parameter                                       N_BLOCKS        = 2,
    parameter                                       NB_DATA         = N_BLOCKS*NB_BLOCK,
    parameter                                       USE_NEW_GHASH   = 1,
    parameter                                       N_H_POW         = 8,
    parameter                                       N_MESSEGES      = 510
)
(
    // OUTPUTS
    output      wire    [NB_BLOCK-1:0]              o_ghash_ciphertext,
    output      wire                                o_ghash_done,
    // INPUTS       
    input       wire    [NB_DATA-1:0]               i_ghash_i_data_x_bus,
    input       wire    [NB_BLOCK-1:0]              i_aad,             
    input       wire    [N_H_POW*NB_BLOCK-1:0]      i_h_power_bus,
    input       wire    [N_BLOCKS-1:0]              i_ghash_skip_bus,
    input       wire                                i_sop_ghash,
    input       wire                                i_valid_ghash,
    input       wire                                i_reset,
    input       wire                                i_clock
);

    // QUICK INSTANCE: BEGIN
    /*
    ghash_wrapper
    #(   
        .NB_BLOCK               (  ),
        .N_BLOCKS               (  ),
        .NB_DATA                (  ),
        .USE_NEW_GHASH          (  ),
        .N_H_POW                (  )
    )
    u_ghash_wrapper
    (
        .o_ghash_ciphertext     (  ),
        .o_ghash_done           (  ),
        .i_ghash_i_data_x_bus   (  ),        
        .i_aad                  (  ),                     
        .i_h_power_bus          (  ),        
        .i_ghash_skip_bus       (  ),        
        .i_sop_ghash            (  ),        
        .i_valid_ghash          (  ),        
        .i_reset                (  ),        
        .i_clock                (  )        
    );
    */
    // QUICK INSTANCE: END

    generate
        if ( USE_NEW_GHASH == 1) begin
            ghash_new_arch_pipelined
            #(
                // PARAMETERS
                .NB_BLOCK       ( NB_BLOCK              ),
                .N_BLOCKS       ( N_BLOCKS              ),
                .NB_DATA        ( NB_DATA               ),
                .N_H_POW        ( N_H_POW               ),
                .N_MESSEGES     ( N_MESSEGES            )
            )
            u_ghash_new_arch_pipelined
            (
                // OUTPUTS
                .o_data_y       ( o_ghash_ciphertext    ),
                .o_ghash_done   ( o_ghash_done          ),
                // INPUTS
                .i_data_x       ( i_ghash_i_data_x_bus  ),
                .i_aad          ( i_aad                 ),
                .i_h_key_powers ( i_h_power_bus         ),
                .i_skip_bus     ( i_ghash_skip_bus[1]   ),
                .i_sop          ( i_sop_ghash           ),
                .i_valid        ( i_valid_ghash         ),
                .i_reset        ( i_reset               ),
                .i_clock        ( i_clock               )
            );
        end else if ( USE_NEW_GHASH == 2 ) begin
            ghash_koa_n_blocks2
            #(
                .NB_BLOCK                   ( NB_BLOCK                  ), 
                .N_BLOCKS                   ( N_BLOCKS                  ),
                .NB_DATA                    ( NB_DATA                   )
            )
            u_ghash_koa_n_blocks2
            (
                .o_data_y                   ( o_ghash_ciphertext        ),
                .i_data_x                   ( i_ghash_i_data_x_bus      ),
                .i_data_x_prev              ( i_aad                     ),
                .i_h_key_powers             ( i_h_power_bus[0+:NB_DATA] ),
                .i_skip_bus                 ( i_ghash_skip_bus          ),
                .i_sop                      ( i_sop_ghash               ),
                .i_valid                    ( i_valid_ghash             ),
                .i_reset                    ( i_reset                   ),
                .i_clock                    ( i_clock                   )
            ) ;
            assign o_ghash_done = 1'b1;
        end else if ( USE_NEW_GHASH == 0 ) begin
            ghash_koa_n_blocks
            #(
                .NB_BLOCK                   ( NB_BLOCK                  ), 
                .N_BLOCKS                   ( N_BLOCKS                  ),
                .NB_DATA                    ( NB_DATA                   )
            )
            u_ghash_koa_n_blocks
            (
                .o_data_y                   ( o_ghash_ciphertext        ),
                .i_data_x                   ( i_ghash_i_data_x_bus      ),
                .i_data_x_prev              ( i_aad                     ),
                .i_h_key_powers             ( i_h_power_bus[0+:NB_DATA] ),
                .i_skip_bus                 ( i_ghash_skip_bus          ),
                .i_sop                      ( i_sop_ghash               ),
                .i_valid                    ( i_valid_ghash             ),
                .i_reset                    ( i_reset                   ),
                .i_clock                    ( i_clock                   )
            ) ;
            assign o_ghash_done = 1'b1;
        end
    endgenerate    

endmodule
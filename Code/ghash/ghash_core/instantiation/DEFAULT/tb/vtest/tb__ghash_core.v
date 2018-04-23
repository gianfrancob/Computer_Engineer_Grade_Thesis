module tb__ghash_core();

localparam                                  NB_BLOCK        = 128               ;
localparam                                  N_BLOCKS        = 2                 ;
localparam                                  NB_DATA         = N_BLOCKS*NB_BLOCK ;
localparam                                  N_H_POW         = 8                 ;
localparam                                  NB_N_MESSAGES   = 10                ;


// MISC TB'S VARIABLES
// ----------------------------------------------------------------------------------------------------------------------------------------
integer                                             count                       ;
integer                                             valid_count                 ;
wire    [ NB_BLOCK-1:0          ]                   aad_0, aad_1, aad_2, aad_3  ;
wire    [ NB_BLOCK-1:0          ]                   dat_0, dat_1, dat_2, dat_3  ;
wire    [ NB_BLOCK-1:0          ]                   length_word                 ;

// MISC MODULUES' INPUTS
// ----------------------------------------------------------------------------------------------------------------------------------------
wire    [ NB_DATA-1:0           ]                   tb_h_key                    ;
wire    [ NB_BLOCK-1:0          ]                   tb_o_data_ghash_control     ;
reg     [ NB_DATA-1:0           ]                   tb_i_data_control           ;
reg     [ NB_BLOCK-1:0          ]                   tb_i_data_x_initial_control ;
wire                                                tb_sop_control              ;
wire                                                tb_valid_control            ;
wire    [ N_BLOCKS-1:0          ]                   tb_skip_bus_control         ;
wire                                                tb_reset_control            ;
wire    [ NB_BLOCK-1:0          ]                   tb_o_data_y                 ;
wire                                                tb_o_ghash_done             ;
reg     [ NB_DATA-1:0           ]                   tb_i_data_x                 ;
wire    [ N_H_POW*NB_BLOCK-1:0  ]                   tb_h_key_powers             ;
wire    [ N_BLOCKS-1:0          ]                   tb_skip_bus                 ;
wire                                                tb_i_sop                    ;
wire                                                tb_i_valid                  ;
wire    [ NB_N_MESSAGES-1:0     ]                   tb_i_rf_static_n_messages   ;
wire    [ NB_N_MESSAGES-1:0     ]                   tb_i_rf_static_n_aad        ;
wire                                                tb_i_reset                  ;
reg                                                 tb_i_clock                  ;

initial begin
    tb_i_clock                          <= 1'b0                         ;
    count                               <= 0                            ;
    valid_count                         <= 0                            ;
end

always #(5) tb_i_clock                  <= ~tb_i_clock                  ;

always @( posedge tb_i_clock )  count   <= count + 1                    ;

always @( posedge tb_i_clock )
begin
    if( count < 11 )
        valid_count <= 0            ;
    else
        // if( count == 5*UPDATE_KEY_DELAY+4 )
        //     valid_count <= valid_count  ;
        // else
            valid_count <= valid_count+1;
end

assign tb_i_rf_static_n_messages        = 10'd11  + 10'd1                                        ;
assign tb_i_rf_static_n_aad             = 10'd2                                                 ; // d512 -> h0000000000000200
assign tb_sop_control                   = ( count == 10 )                                       ;
assign tb_i_sop                         = ( count == 10 )                                       ;
assign tb_valid_control                 = ( count >= 11 ) & ( count <= 24 ) ;
assign tb_i_valid_text                  = ( count >= 10 ) & ( count <= 24 ) ;
assign tb_i_valid                       = 1'b1                                                  ;
assign tb_reset_control                 = ( count == 2 )                                        ;
assign tb_i_reset                       = ( count == 2 )                                        ;
assign tb_skip_bus_control              = ( count == 25) ? 2'b10 : 2'b00                        ;//2'b00                                                 ;
assign tb_skip_bus                      = ( count == 25) ? 2'b10 : 2'b00                        ;


// STREAM INPUTS
// ----------------------------------------------------------------------------------------------------------------------------------------
assign tb_h_key                         = 128'hACBEF20579B4B8EBCE889BAC8732DAD7 ;

assign aad_0                            = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ;
assign aad_1                            = 128'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB ;
assign aad_2                            = 128'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC ;
assign aad_3                            = 128'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ;

assign dat_0                            = 128'h00000000000000000000000000000000 ;
assign dat_1                            = 128'h11111111111111111111111111111111 ;
assign dat_2                            = 128'h22222222222222222222222222222222 ;
assign dat_3                            = 128'h33333333333333333333333333333333 ;

assign length_word                      = { 64'd512, 64'd512 }                  ;


always @( * )
begin
    if( ( count == 11 ) || ( count == 16 ) || ( count == 21 ) )
    begin
        tb_i_data_x_initial_control      <= 128'd0          ;
        tb_i_data_control                <= { aad_0, aad_1 };
        tb_i_data_x                      <= { aad_0, aad_1 };
    end
    else if( ( count == 12 ) || ( count == 17 ) || ( count == 22 ) )
    begin
        tb_i_data_x_initial_control      <= 128'd0          ;
        tb_i_data_control                <= { aad_2, aad_3 };
        tb_i_data_x                      <= { aad_2, aad_3 };
    end
    else if( ( count == 13 ) || ( count == 18 ) || ( count == 23 ) )
    begin
        tb_i_data_x_initial_control      <= 128'd0          ;
        tb_i_data_control                <= { dat_0, dat_1 };
        tb_i_data_x                      <= { dat_0, dat_1 };
    end
    else if( ( count == 14 ) || ( count == 19 ) || ( count == 24 ) )
    begin
        tb_i_data_x_initial_control      <= 128'd0                  ;
        tb_i_data_control                <= { dat_2, dat_3 }        ;
        tb_i_data_x                      <= { dat_2, dat_3 }        ;
    end
    else if( ( count == 15 ) || ( count == 20 ) || ( count == 25 ) )
    begin
        tb_i_data_x_initial_control      <= 128'd0                  ;
        tb_i_data_control                <= { 128'd0, length_word } ;
        tb_i_data_x                      <= { 128'd0, length_word } ;
    end
    else
    begin
        tb_i_data_x_initial_control      <= 128'd0  ;
        tb_i_data_control                <= 256'd0  ;
        tb_i_data_x                      <= 256'd0  ;
    end
end

h_key_power_table
#(
    .NB_BLOCK       ( NB_BLOCK          ),
    .N_BLOCKS       ( N_H_POW           ),
    .NB_DATA        ( N_H_POW*NB_BLOCK  )
)
u_h_key_power_table
(
    .o_h_key_powers ( tb_h_key_powers   ),
    .i_h_key        ( tb_h_key          ),
    .i_clock        ( tb_i_clock        )
) ;

ghash_n_blocks2
#(
    .NB_BLOCK           (  NB_BLOCK                     ),
    .N_BLOCKS           (  N_BLOCKS                     ),
    .NB_DATA            (  NB_DATA                      )
)
u_ghash_n_blocks2
(
    .o_data_y           ( tb_o_data_ghash_control       ),
    .i_data_x_bus       ( tb_i_data_control             ),
    .i_data_x_initial   ( tb_i_data_x_initial_control   ),
    .i_hash_subkey_h    ( tb_h_key                      ),
    .i_sop              ( tb_sop_control                ),
    .i_valid            ( tb_valid_control              ),
    .i_skip_bus         ( tb_skip_bus_control           ),
    .i_reset            ( tb_reset_control              ),
    .i_clock            ( tb_i_clock                    )
);

ghash_core
#(
    //  PARAMETERS
    .NB_BLOCK               ( NB_BLOCK                  ),
    .N_BLOCKS               ( N_BLOCKS                  ),
    .NB_DATA                ( NB_DATA                   ),
    .N_H_POW                ( N_H_POW                   ),
    .NB_N_MESSAGES          ( NB_N_MESSAGES             )
)
u_ghash_core
(
    .o_data_y               ( tb_o_data_y               ),
    .o_ghash_done           ( tb_o_ghash_done           ),
    .i_data_x               ( tb_i_data_x               ),
    // .i_aad                  (  ),
    .i_h_key_powers         ( tb_h_key_powers           ),
    .i_skip_bus             ( tb_skip_bus               ),
    .i_sop                  ( tb_i_sop                  ),
    .i_valid                ( tb_i_valid                ),
    .i_rf_static_n_messages ( tb_i_rf_static_n_messages ),
    .i_rf_static_n_aad      ( tb_i_rf_static_n_aad      ),
    .i_reset                ( tb_i_reset                ),
    .i_clock                ( tb_i_clock                )
) ;

endmodule

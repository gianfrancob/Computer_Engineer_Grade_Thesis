module tb__ghash_core_vs_ghash_core_koa
();

	// PARAMETERS.
	localparam 						NB_BLOCK    = 128 ;
    localparam                      N_BLOCKS    = 2 ;
    localparam                      NB_DATA     = NB_BLOCK*N_BLOCKS ;

     // OUTPUTS.
    wire    [NB_BLOCK-1:0]          tb_o_data_y_KOA ;
    wire    [NB_BLOCK-1:0]          tb_o_data_y_N_BLK ;
    // INPUTS.
    reg     [NB_DATA-1:0]           tb_i_data_x_bus ;
    reg     [NB_BLOCK-1:0]          tb_i_data_key ; // subkey "H"
    wire    [NB_DATA-1 :0]          tb_o_h_key_powers ;
    wire    [N_BLOCKS-1:0]          tb_i_skip_bus ;
    wire                            tb_i_valid ;
    wire                            tb_i_reset ;
    wire                            tb_i_sop ;
    reg                             tb_i_clock ;
    wire    [NB_BLOCK-1:0]          data_length ;
    integer                         count = 0 ;
    reg		[NB_BLOCK-1:0]			tb_o_data_y_N_BLK_reg ;
    reg     [NB_BLOCK-1:0]          tb_o_data_y_N_BLK_reg0;

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

    always @( posedge tb_i_clock )
    begin
        if ( ( count % 3 ) ) begin
            tb_i_data_x_bus 
            	= { {$random,$random,$random,$random},
            		{$random,$random,$random,$random} } ;
            tb_i_data_key
                = {$random,$random,$random,$random} ;
        end
    end

    assign  tb_i_sop
    	= ( ( count % 300 ) == 0 )  || ( count == 2 );

    assign tb_i_skip_bus 
        = ( ( count % 305) == 1 ) ? 2'b10 : 2'b00 ;

	// MODULE INSTANTIATION.
    h_key_power_table
    #(
        .NB_BLOCK       ( NB_BLOCK  ) ,
        .N_BLOCKS       ( N_BLOCKS  ) ,
        .NB_DATA        ( NB_DATA   ) 
    )
    u_h_key_power_table
    (
        // OUTPUTS.
        .o_h_key_powers ( tb_o_h_key_powers     ) ,
        // INPUTS   
        .i_h_key        ( tb_i_data_key		    ) ,
        .i_clock        ( tb_i_clock            )
    ) ; 

	ghash_core_koa_pipe_parallel
    #(
        // PARAMETERS.
        .NB_BLOCK   ( NB_BLOCK ) ,   // [HINT] Any value different to 128 is not valid 
        .N_BLOCKS   ( N_BLOCKS ) ,
        .NB_DATA    ( NB_DATA  ) 
    )
    u_ghash_core_koa_pipe_parallel
    (
        // OUTPUTS.
        .o_data_y       ( tb_o_data_y_KOA 	) ,
        // INPUTS.  
        .i_data_x       ( tb_i_data_x_bus 	) ,
        .i_data_x_prev  ( 128'b0 			) ,
        .i_h_key_powers ( tb_o_h_key_powers	) ,
        .i_skip_bus     ( tb_i_skip_bus 	) ,
        .i_sop          ( tb_i_sop 			) ,
        .i_valid        ( tb_i_valid 		) ,
        .i_reset        ( {tb_i_reset, tb_i_reset} 		) ,
        .i_clock        ( tb_i_clock 		)
    ) ;

    ghash_n_blocks
    #(
        .NB_BLOCK           ( NB_BLOCK ) ,
        .N_BLOCKS           ( N_BLOCKS ) ,
        .NB_DATA            ( NB_DATA  )
    )
    u_ghash_n_blocks
    (
        .o_data_y           ( tb_o_data_y_N_BLK ) ,
        .i_data_x_bus       ( tb_i_data_x_bus 	) ,
        .i_data_x_initial   ( 128'b0 			) ,
        .i_hash_subkey_h    ( tb_i_data_key  	) ,
        .i_sop              ( tb_i_sop 			) ,
        .i_valid            ( tb_i_valid 		) ,
        .i_skip_bus			( tb_i_skip_bus		) ,
        .i_reset            ( tb_i_reset 		) ,
        .i_clock            ( tb_i_clock 		)
    ) ;

    always @(posedge tb_i_clock) begin
    	tb_o_data_y_N_BLK_reg0 <= tb_o_data_y_N_BLK ;
        tb_o_data_y_N_BLK_reg <= tb_o_data_y_N_BLK_reg0 ;
    end

    wire comp;
    assign comp = tb_o_data_y_N_BLK_reg == tb_o_data_y_KOA;
 endmodule
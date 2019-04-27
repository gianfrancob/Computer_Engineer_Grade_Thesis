module gcm_aes_wrapper
#(
    // PARAMETERS
    parameter                                           NB_BLOCK            = 128 ,
    parameter                                           N_BLOCKS            = 2 ,
    parameter                                           LOG2_N_BLOCKS       = 1 ,
    parameter                                           NB_DATA             = (N_BLOCKS*NB_BLOCK) ,
    parameter                                           NB_KEY              = 256 ,
    parameter                                           NB_IV               = 96 ,
    parameter                                           NB_INC_MODE         = 2 ,
    parameter                                           LOG2_NB_DATA_T      = 8 ,       // [HINT]: must the number of bits to remove from i_length_plaintext so it represents the number of clocks for plaintext.
    parameter                                           NB_TIMER            = 10 ,      // [HINT]: Must be big enough to count the number of clock cycles required by plaintext.
    parameter                                           USE_LUT_IN_SUBBYTES = 0 ,
    parameter                                           NB_N_MESSAGES       = 10
)
(
    // OUTPUTS.
    output  wire    [NB_DATA-1:0]                       o_data ,                        // Output Data
    output  wire                                        o_valid ,                       // Output Valid
    output  wire                                        o_start ,                       // First word of the output packet
    output  wire                                        o_last ,                        // Last word of the output packet
    output  wire                                        o_tag_ready ,                   // T strobe
    output  wire    [NB_BLOCK-1:0]                      o_tag ,                         // GCM Tag
    // INPUTS.
    input   wire    [NB_DATA-1:0]                       i_data ,                        // Input Data
    input   wire    [NB_KEY-1:0]                        i_key ,                         // AES Encryption Key
    input   wire    [NB_IV-1:0]                         i_iv ,                          // Init Vector
    input   wire                                        i_start ,                       // First word of the packet
    input   wire                                        i_last ,                        // Last  word of the packet
    input   wire                                        i_valid ,                       // Clock Enable
    input   wire                                        i_gmac ,                        // GMAC mode
    input   wire                                        i_encrypt ,                     // Encrypt mode if 1, Decrypt mode if 0
    input   wire                                        i_reset ,                       // async reset
    input   wire                                        i_clock                         // Core clock
);


    // QUICK INSTANCE: BEGIN
    /*
    gcm_aes_wrapper
    u_gcm_aes_wrapper
    (
        .o_data                             (  ),   // Output Data
        .o_valid                            (  ),   // Output Valid
        .o_start                            (  ),   // First word of the output packet
        .o_last                             (  ),   // Last word of the output packet
        .o_tag_ready                        (  ),   // T strobe
        .o_tag                              (  ),   // GCM Tag
        .i_data                             (  ),   // Input Data
        .i_key                              (  ),   // AES Encryption Key
        .i_iv                               (  ),   // Init Vector
        .i_start                            (  ),   // First word of the packet
        .i_last                             (  ),   // Last  word of the packet
        .i_valid                            (  ),   // Clock Enable
        .i_gmac                             (  ),   // GMAC mode
        .i_encrypt                          (  ),   // Encrypt mode if 1, Decrypt mode if 0
        .i_reset                            (  ),   // async reset
        .i_clock                            (  )    // Core clock
    );
    */ // QUICK INSTANCE: END

    // LOCAL VARIABLES
    reg     [NB_DATA-1:0]                   old_key ;
    wire                                    update_key ;
    wire    [NB_BLOCK/2 -1:0]               length_plaintext ;
    wire    [NB_BLOCK/2 -1:0]               length_aad ;
    wire    [NB_DATA-1:0]                   aad ;
    integer                                 count_in, count_out ;

    // ALGORITHM BEGIN
    always @( posedge i_clock ) begin
        if ( i_reset )
            old_key     <= { NB_DATA{1'b0} } ;
        else if ( i_start )
            old_key     <= i_key ;
    end
    assign update_key   = ( old_key != i_key ) ;

    assign length_aad       = 256*0;
    assign length_plaintext = 256*100;

    always @( posedge i_clock ) begin
        if ( i_reset | i_start )
            count_in    <= 0 ;
        else if ( i_valid )
            count_in    <= count_in + 1 ;
    end
    assign aad  = ( count_in <= length_aad[NB_BLOCK/2 -1:8]) ?  i_data : { NB_DATA{1'b0} } ;

    always @( posedge i_clock ) begin
        if ( i_reset | i_start )
            count_out   <= 0 ;
        else if ( o_valid )
            count_out   <= count_out + 1 ;
    end
    assign o_start = ( o_valid & (count_out == 0) );
    assign o_last  = ( count_out == length_plaintext - 1) ;
    // Core Instantiation
    gcm_aes_core_1gctr_ghash_new
    #(
        .NB_BLOCK                       ( NB_BLOCK                  ),
        .N_BLOCKS                       ( N_BLOCKS                  ),
        .NB_DATA                        ( NB_DATA                   ),
        .NB_KEY                         ( NB_KEY                    ),
        .NB_IV                          ( NB_IV                     ),
        .NB_INC_MODE                    ( NB_INC_MODE               ),
        .USE_LUT_IN_SUBBYTES            ( USE_LUT_IN_SUBBYTES       ),
        .NB_N_MESSAGES                  ( NB_N_MESSAGES             )
    )
    u_gcm_aes_core_1gctr_ghash_new
    (
        .o_ciphertext_words_y           ( o_data                    ),
        .o_fail                         ( /*unsused*/               ),
        .o_sop                          ( /*unsused*/               ),
        .o_tag_ready                    ( o_tag_ready               ),
        .o_valid_text                   ( o_valid                   ),
        .o_tag                          ( o_tag                     ),
        .o_fault_sop_and_keyupdate      ( /*unsused*/               ),
        .i_plaintext_words_x            ( i_data                    ),
        .i_tag                          ( /*unsused*/               ),
        .i_rf_static_key                ( i_key                     ),
        .i_rf_static_aad                ( aad                       ),
        .i_rf_static_iv                 ( i_iv                      ),
        .i_rf_static_length_aad         ( length_aad                ),
        .i_rf_static_length_plaintext   ( length_plaintext          ),
        .i_sop                          ( i_start                   ),
        .i_valid_text                   ( i_valid                   ),
        .i_valid                        ( 1'b1                      ),
        .i_update_key                   ( update_key                ),
        .i_rf_static_inc_mode           ( 2'd0                      ),
        .i_rf_static_encrypt            ( i_encrypt                 ),
        .i_clear_fault_flags            ( 2'd0                      ),
        .i_reset                        ( i_reset                   ),
        .i_clock                        ( i_clock                   )
    );

endmodule
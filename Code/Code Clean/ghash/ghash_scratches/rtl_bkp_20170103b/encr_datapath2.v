//% ----------------------------------------------------------------------------
//% Project     : M200
//% ----------------------------------------------------------------------------
//% \class encr_datapath
//% \ingroup TBD
//% \author Fernando Romero
//% \date Sep 7, 2016
//% Originator  : Clariphy Argentina S.A.
//%
//% Rev 0       : Initial release.
//%
//% $Id: encr_datapath2.v 10705 2017-02-22 16:36:01Z gbarbiani $
//% ----------------------------------------------------------------------------
//% Description :
//% Contains all blocks necesary to perform frame dissambling, payload encryption/ decryption
//% and frame reassembling.
//%
//% \image html encr_datapath.png
//% ----------------------------------------------------------------------------
//% \copyright Copyright (C) 2015 ClariPhy Argentina S.A.  All rights reserved
//% ----------------------------------------------------------------------------
module encr_datapath2
#(
    // PARAMETERS.
    parameter                                           NB_DATA                  =  256        ,
    parameter                                           NB_INIT_VECTOR           =  96         ,
    parameter                                           NB_ENCR_OVERHEAD         =  64         ,
    parameter                                           NB_TAG                   =  128        ,
    parameter                                           NB_ROW                   =  2          ,
    parameter                                           NB_ADDRESS               =  3          ,
    parameter                                           NB_ENCR_MODE_WIDTH       =  8          ,
    parameter                                           NB_COUNTER               =  16         ,
    parameter                                           NB_AAD                   =  512

)
(
    // OUTPUTS:
    // Data interface
    output wire    [NB_DATA                - 1 : 0 ]    o_data                                 ,
    output wire                                         o_valid                                ,
    output wire                                         o_sof                                  ,
    output wire                                         o_core_idle                            ,
    // Data to control block
    output wire    [NB_TAG                 - 1 : 0 ]    o_tag                                  ,
    output wire                                         o_tstrobe                              ,
    output wire    [NB_ENCR_OVERHEAD       - 1 : 0 ]    o_encr_oh                              ,
    output wire                                         o_encr_oh_rdy                          ,
    output wire    [NB_ROW                 - 1 : 0 ]    o_encr_oh_index                        ,
    output wire                                         o_qlast                                , // for single cycle
    output wire                                         o_qstart                               , // for single cycle
    output wire                                         o_start_single_cycle                   , // for single cycle
    output wire    [NB_DATA                - 1 : 0 ]    o_single_cycle_data                    , // for single cycle
    output wire                                         o_encr_oh_req                          ,
    output wire    [NB_COUNTER             - 1 : 0 ]    o_rf_static_overflow_counter           ,
    output wire    [NB_COUNTER             - 1 : 0 ]    o_rf_static_underflow_counter          ,
    input wire     [4*NB_ENCR_OVERHEAD     - 1 : 0 ]    i_encr_oh                              ,

    // INPUTS:
    // From control block
    input wire                                          i_single_cycle_start                   , // for single cycle
    input wire                                          i_single_cycle_last                    , // for single cycle
    input wire                                          i_single_cycle_data_valid              , // for single cycle
    input wire     [NB_DATA                - 1 : 0 ]    i_single_cycle_data                    , // for single cycle
    // Data interface
    input wire     [NB_DATA                - 1 : 0 ]    i_data                                 ,
    input wire                                          i_valid                                ,
    input wire                                          i_sof                                  ,
    // Configurations
    input wire     [NB_DATA                - 1 : 0 ]    i_key                                  ,
    input wire     [NB_INIT_VECTOR         - 1 : 0 ]    i_init_vector                          ,
    input wire     [NB_AAD                 - 1 : 0 ]    i_aad                                  ,

    // RF's
    input wire                                          i_rf_static_enable                     ,
    input wire     [NB_ENCR_MODE_WIDTH     - 1 : 0 ]    i_rf_static_mode                       ,
    input wire                                          i_rf_static_in_boot_up                 ,
    // CLOCKS & RESETS.
    input wire                                          i_clock                                ,
    input wire                                          i_reset                                ,
    input wire                                          i_async_reset
);
    // LOCAL PARAMETERS
    localparam                                          NB_FRAME_OH              =      128    ;
    localparam                                          NB_DATA_VALID            =      8      ;
    localparam                                          START_ADDRESS            =      9      ;
    localparam                                          NB_START_ADDRESS         =      4      ;
    localparam                                          CONST_1                  =      1      ;
    localparam                                          NB_SR                    =      4      ;

    // INTERNAL SIGNALS
    wire            [NB_DATA               - 1 : 0 ]    core_data_in                           ;
    wire            [NB_DATA               - 1 : 0 ]    core_data_out                          ;
    wire            [NB_DATA               - 1 : 0 ]    reassemble_data                        ;
    wire                                                core_input_start                       ;
    wire                                                core_input_last                        ;
    wire                                                core_output_start                      ;
    wire                                                core_output_last                       ;
    wire                                                core_chip_enable                       ;
    wire            [NB_DATA               - 1 : 0 ]    core_key                               ;
    wire            [NB_INIT_VECTOR        - 1 : 0 ]    core_iv                                ;
    wire            [NB_FRAME_OH           - 1 : 0 ]    frame_oh                               ;
    reg             [NB_SR                 - 1 : 0 ]    payload_data_valid                     ;
    wire                                                reassemble_valid                       ;
    reg             [NB_SR                 - 1 : 0 ]    sof_sr                                 ;
    reg             [NB_SR                 - 1 : 0 ]    valid_sr                               ;
    wire                                                insert_aad                             ;
    wire                                                enable_valid                           ;
    wire                                                authenticate_only                      ;
    wire                                                encrypt_decrypt                        ;
    wire                                                resync                                 ;
    wire                                                bypass                                 ;
    wire                                                sof_and_valid                          ;
    reg                                                 cen_during_last_fec                    ;
    reg                                                 cen_during_encrypt                     ;
    reg                                                 qstart_d                               ;
    reg                                                 qstop_to_qstart                        ;
    reg                                                 valid_d                                ;
    reg            [NB_SR                  - 1 : 0 ]    insert_aad_sr                          ;
    wire                                                reassemble_sof                         ;
    wire                                                core_idle                              ;
    wire                                                reassemble_vld                         ;

	wire                                                gmac                                   ;
    always @(posedge i_clock)
    begin
        if(i_reset || !i_rf_static_enable)
            cen_during_last_fec <= 1'b 0;
        else
        begin
            if(core_input_start && i_valid)
                cen_during_last_fec <= 1'b 1;
            else if(i_sof)
                cen_during_last_fec <= 1'b 0;
        end
    end

    always @(posedge i_clock)
    begin
        if(i_reset || !i_rf_static_enable)
        begin
            cen_during_encrypt <= 1'b 0;
            qstop_to_qstart <= 1'b 0;
        end
        else
        begin
            if(core_input_last && valid_d)
                cen_during_encrypt <= 1'b 1;
            else if(core_output_last && valid_d)
            begin
                cen_during_encrypt <= 1'b 0;
                qstop_to_qstart <= 1'b 1;
            end
            else if (qstart_d && valid_d)
               qstop_to_qstart <= 1'b 0;
        end
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            qstart_d <= 1'b 0;
        else
        begin
            if(valid_d && i_rf_static_enable)
                qstart_d <= core_output_start;
        end
    end


    assign bypass            = |i_rf_static_mode[3:0];
    assign authenticate_only = ( (~i_rf_static_mode[0]) & i_rf_static_mode[1] ) | ( (~i_rf_static_mode[2]) & i_rf_static_mode[3] ) | ~bypass;
    assign encrypt_decrypt   = i_rf_static_mode[0];
    assign gmac              = ( (~i_rf_static_mode[0]) & i_rf_static_mode[1] ) | ( (~i_rf_static_mode[2]) & i_rf_static_mode[3] ); //borism


	assign enable_valid      = i_valid & i_rf_static_enable;
    assign sof_and_valid     = i_valid & i_sof;
    assign o_core_idle       = core_idle;

    // Frame Disassembler
    frame_disassembler
    u_frame_disassembler
    (
        .o_payload_data                    ( core_data_in                           ),
        .o_start                           ( core_input_start                       ),
        .o_last                            ( core_input_last                        ),
        .o_cen                             ( core_chip_enable                       ),
        .o_key                             ( core_key                               ),
        .o_init_vector                     ( core_iv                                ),
        .o_frame_oh                        ( frame_oh                               ),
        .o_resync                          ( resync                                 ),
        .o_encr_oh                         ( o_encr_oh                              ),
        .o_encr_oh_rdy                     ( o_encr_oh_rdy                          ),
        .o_encr_oh_row                     ( o_encr_oh_index                        ),
        .o_core_idle                       ( core_idle                              ),
        .o_insert_add                      ( insert_aad                             ),
        .i_data                            ( i_data                                 ),
        .i_valid                           ( enable_valid                           ),
        .i_sof                             ( sof_and_valid                          ),
        .i_key                             ( i_key                                  ),
        .i_aad                             ( i_aad                                  ),
        .i_init_vector                     ( i_init_vector                          ),
        .i_clock                           ( i_clock                                ),
        .i_reset                           ( i_reset                                )

    );

    //**************************************************
    // SOF & VALID delay.
    //**************************************************
    reg                     sof_d;

    always @(posedge i_clock)
    begin
        if( i_reset || !i_rf_static_enable)
            sof_d <= 1'b0;
        else
            sof_d <= i_sof;
    end

    always @(posedge i_clock)
    if(i_reset || !i_rf_static_enable)
        valid_d <= 1'b0;
    else begin
        valid_d <= i_valid;
    end

    //**************************************************
    // Input data Selection for normal op or single cycle
    //**************************************************
    wire                                                start                      ;
    wire                                                last                       ;
    wire                                                cen                        ;
    wire                                                cen_to_aes                 ;
    wire            [NB_DATA               - 1 : 0 ]    data_in                    ;

    assign start    = (i_rf_static_in_boot_up || core_idle) ? i_single_cycle_start      : core_input_start  ;
    assign last     = (i_rf_static_in_boot_up || core_idle) ? i_single_cycle_last       : core_input_last   ;
    assign cen      = (i_rf_static_in_boot_up             ) ? i_single_cycle_data_valid : core_chip_enable  ;
    assign data_in  = (i_rf_static_in_boot_up || i_single_cycle_data_valid) ? i_single_cycle_data  : core_data_in      ;

    assign cen_to_aes = ( cen | (cen_during_last_fec & valid_d) )& i_rf_static_enable;

    // AES Core
  //   GCM3LP_256
  //   u_GCM3LP_256_inst
  //   (
  //       .clk                               ( i_clock                                                        ),
  //       .cen                               ( cen_to_aes                                                     ),
  //       .reset                             ( i_async_reset                                                  ),
  //       .encrypt                           ( encrypt_decrypt                                                ),
  //       .gmac                              ( gmac                                                           ),
  //       .start                             ( start                                                          ),
  //       .last                              ( last                                                           ),
  //       .D                                 ( data_in                                                        ),
  //       .IV                                ( i_init_vector                                                  ),
  //       .Key                               ( i_key                                                          ),
  //       .Qstart                            ( core_output_start                                              ),
  //       .Qlast                             ( core_output_last                                               ),
  //       .Q                                 ( core_data_out                                                  ),
  //       .Tstrobe                           ( o_tstrobe                                                      ),
  //       .T                                 ( o_tag                                                          )
  //   );

    wire core_output_valid ;
    gcm_aes_wrapper
    u_gcm_aes_wrapper
    (
        .o_data                             ( core_data_out      ), // Output Data
        .o_valid                            ( core_output_valid  ), // Output Valid
        .o_start                            ( core_output_start  ), // First word of the output packet
        .o_last                             ( core_output_last   ), // Last word of the output packet
        .o_tag_ready                        ( o_tstrobe          ), // T strobe
        .o_tag                              ( o_tag              ), // GCM Tag
        .i_data                             ( data_in            ), // Input Data
        .i_key                              ( i_key              ), // AES Encryption Key
        .i_iv                               ( i_init_vector      ), // Init Vector
        .i_start                            ( start              ), // First word of the packet
        .i_last                             ( last               ), // Last  word of the packet
        .i_valid                            ( cen_to_aes         ), // Clock Enable
        .i_gmac                             ( gmac               ), // GMAC mode
        .i_encrypt                          ( encrypt_decrypt    ), // Encrypt mode if 1, Decrypt mode if 0
        .i_reset                            ( i_async_reset      ), // async reset
        .i_clock                            ( i_clock            ), // Core clock
    );



    assign o_qlast              = core_output_last  ;
    assign o_qstart             = core_output_start ;
    assign o_start_single_cycle = core_input_last   ;
    assign o_single_cycle_data  = core_data_out     ;


    reg [3*NB_DATA -1 : 0]                          data_sr;

    always @(posedge i_clock)
    begin
        if(i_rf_static_enable)
            data_sr <= {data_sr[2*NB_DATA-1 : 0], core_data_in};
    end

    encr_frame_reassembler
    u_encr_frame_reassembler
    (
        .o_data                            ( o_data                                 ),
        .o_valid                           ( o_valid                                ),
        .o_sof                             ( o_sof                                  ),
        .o_encr_oh_req                     ( o_encr_oh_req                          ),
        .o_rf_static_overflow_counter      ( o_rf_static_overflow_counter           ),
        .o_rf_static_underflow_counter     ( o_rf_static_underflow_counter          ),
        .i_payload_data                    ( reassemble_data                        ),
        .i_payload_data_valid              (  reassemble_valid                      ),
        .i_encription_oh                   ( i_encr_oh                              ),
        .i_frame_oh                        ( frame_oh                               ),
        .i_sof                             ( reassemble_sof                         ),
        .i_valid                           ( /*reassemble_vld*/ /* valid_sr[2]*/ core_output_valid         ), // Revisar!
        .i_resync                          ( resync                                 ),
        .i_qlast                           ( core_output_last                       ),
        .i_rf_static_start_address         ( START_ADDRESS[NB_START_ADDRESS-1 :0]   ),
        .i_rf_static_enable                ( i_rf_static_enable                     ),
        .i_clock                           ( i_clock                                ),
        .i_reset                           ( i_reset                                )
    );

    wire                                    data_valid;

    assign data_valid       = (((core_chip_enable || cen_during_encrypt)& valid_d) & (~qstop_to_qstart)) ;

    assign reassemble_data  = (authenticate_only) ? data_sr[3*NB_DATA-1 -: NB_DATA] : core_data_out;
    assign reassemble_valid = (authenticate_only) ? payload_data_valid[2] & (~(insert_aad_sr[2] | insert_aad_sr[1])) : data_valid ;
    assign reassemble_sof   = sof_sr[2] ;
    assign reassemble_vld   = (authenticate_only) ? valid_sr[2] : valid_d ;

    //**************************************************
    // Payload data valid shift
    //**************************************************

    always @(posedge i_clock)
    begin
        if(i_reset || !i_rf_static_enable)
            sof_sr <= {NB_SR{1'b0}};
        else if( valid_d || authenticate_only )
        begin
            sof_sr <= {sof_sr[NB_SR -2 : 0 ], sof_d};
        end
    end

    //**************************************************
    // Input valid shift
    //**************************************************

    always @(posedge i_clock)
    begin
        if(i_reset || !i_rf_static_enable)
            valid_sr <= {NB_SR{1'b0}};
        else
        begin
            valid_sr <= {valid_sr[NB_SR -2 : 0 ], valid_d};
        end
    end

    //**************************************************
    // Payload valid shift
    //**************************************************

    always @(posedge i_clock)
    begin
        if(i_reset || !i_rf_static_enable)
            payload_data_valid <= {NB_SR{1'b0}};
        else
        begin
            payload_data_valid <= {payload_data_valid[NB_SR -2 : 0 ], core_chip_enable};
        end
    end

    //**************************************************
    // AAD insertion flag
    //**************************************************
    always @(posedge i_clock)
    begin
        if(i_reset ||  !i_rf_static_enable)
            insert_aad_sr <= {NB_SR{1'b0}};
        else
        begin
            insert_aad_sr <= {insert_aad_sr[NB_SR -2 : 0 ], insert_aad};
        end
    end


endmodule

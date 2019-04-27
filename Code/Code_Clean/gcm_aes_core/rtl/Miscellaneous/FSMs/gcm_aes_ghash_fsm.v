/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : gcm_aes_ghash_fsm.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gcm_aes_ghash_fsm.v 5233 2017-07-24 18:30:30Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gcm_aes_ghash_fsm
#(
    parameter                                       NB_TIMER                = 10    ,
    parameter                                       NB_SEL                  = 2     ,
    parameter                                       DATA_PROCESS_TIME_AES   = 44
)
(
    output  wire    [ NB_SEL-1:0    ]               o_sel_ghash_in          ,
    output  wire                                    o_sop_ghash             ,
    output  reg                                     o_data_sop_pre          ,
    output  reg                                     o_data_sop              ,
    output  wire                                    o_valid_aad             ,
    output  reg                                     o_valid_aad_d           ,
    output  wire                                    o_valid_data            ,
    output  reg                                     o_valid_data_d          ,
    output  wire                                    o_valid_length          ,
    output  reg                                     o_valid_length_d        ,
    output  wire                                    o_valid_ghash           ,
    output  reg                                     o_valid_ghash_d         ,
    output  reg                                     o_valid_tag             ,
    output  wire                                    o_gctr_o_sop_for_ghash  ,
    output  wire                                    o_gctr_o_sop            ,
    output  wire                                    o_gctr_o_sop_pre        ,
    input   wire                                    i_sop                   ,
    input   wire                                    i_gctr_o_sop            ,
    input   wire                                    i_trigger_pre_block     ,
    input   wire    [ NB_TIMER-1:0  ]               i_length_plaintext      ,
    input   wire    [ NB_TIMER-1:0  ]               i_length_aad            ,
    input   wire                                    i_valid_encrypt         ,
    input   wire                                    i_valid_decrypt         ,
    input   wire                                    i_rf_static_encrypt     ,
    input   wire                                    i_enable                ,
    input   wire                                    i_reset                 ,
    input   wire                                    i_clock
) ;

// =================================================================================================
// QUICK INSTANCE
// =================================================================================================
/*
gcm_aes_ghash_fsm
#(
    .NB_TIMER               (  ),
    .NB_SEL                 (  ),
    .DATA_PROCESS_TIME_AES  (  )
)
u_gcm_aes_ghash_fsm
(
    .o_sel_ghash_in         (  ),
    .o_sop_ghash            (  ),
    .o_data_sop             (  ),
    .o_data_sop_pre         (  ),
    .o_valid_aad            (  ),
    .o_valid_data           (  ),
    .o_valid_data_d         (  ),
    .o_valid_length         (  ),
    .o_valid_length_d       (  ),
    .o_valid_ghash          (  ),
    .o_valid_ghash_d        (  ),
    .o_valid_tag            (  ),
    .o_gctr_o_sop_for_ghash (  ),
    .o_gctr_o_sop           (  ),
    .o_gctr_o_sop_pre       (  ),
    .i_sop                  (  ),
    .i_gctr_o_sop           (  ),
    .i_trigger_pre_block    (  ),
    .i_length_plaintext     (  ),
    .i_length_aad           (  ),
    .i_valid_encrypt        (  ),
    .i_valid_decrypt        (  ),
    .i_rf_static_encrypt    (  ),
    .i_enable               (  ),
    .i_reset                (  ),
    .i_clock                (  )
) ;
*/
// END: Quick Instance.


// =================================================================================================
// LOCAL PARAMETERS.
// =================================================================================================

// =================================================================================================
// INTERNAL SIGNALS.
// =================================================================================================
wire                                            timer_aad_done          ;
wire                                            timer_aad_pre_done      ;
reg             [ NB_TIMER-1:0  ]               timer_aad               ;
wire            [ NB_TIMER-1:0  ]               length_aad_m1           ;
wire            [ NB_TIMER-1:0  ]               length_aad_m2           ;

reg                                             data_sop                ;
wire                                            data_valid              ;
wire                                            timer_done              ;
wire                                            timer_pre_done          ;
reg             [ NB_TIMER-1:0  ]               timer                   ;
wire            [ NB_TIMER-1:0  ]               length_plaintext_m1     ;
reg                                             extra_valid             ;



// =================================================================================================
// ALGORITHM BEGIN.
// =================================================================================================


// AAD
//--------------------------------------------------------------------------------------------------
always @( posedge i_clock )
begin : l_timer_aad_update
    if ( i_reset || (i_enable && i_sop) )     // cad_ence map_to_mux
        timer_aad   <= { NB_TIMER{1'b0} }   ;
    else if ( i_enable && ~timer_aad_done && i_valid_decrypt )//&& ( ~|i_length_aad/*i_length_plaintext*/ /*|| (i_rf_static_encrypt && i_valid) || ~i_rf_static_encrypt */) )
        timer_aad   <= timer_aad + 1'b1     ;
end // l_timer_aad_update

assign  length_aad_m1           =   ( i_length_aad > 1 )   ?   // cad_ence map_to_mux
                                    i_length_aad - 1'b1 :   { NB_TIMER{1'b0} }  ;   // [HINT] Mismatch and carry drop intentional.

assign  length_aad_m2           =   ( i_length_aad > 2 )   ?   // cad_ence map_to_mux
                                    i_length_aad - 2'b10 :  { NB_TIMER{1'b0} };   // [HINT] Mismatch and carry drop intentional.

assign  timer_aad_pre_done      =   ( timer_aad == length_aad_m1 )  ;

assign  timer_aad_done          =   ( timer_aad == i_length_aad )   ;

assign  timer_aad_pre_done_pre  =   ( timer_aad == length_aad_m2 )  ;


always @( posedge i_clock )
    o_data_sop_pre  <=   timer_aad_pre_done_pre;


always @( posedge i_clock )
    o_data_sop      <=   timer_aad_pre_done  ;


assign  o_valid_aad     = ~timer_aad_done & i_valid_decrypt;

always @( posedge i_clock )
begin : l_del_aad_valid
    if ( i_reset )  // cad_ence map_to_mux
        o_valid_aad_d   <= 1'b0         ;
    else if ( i_enable )
        o_valid_aad_d   <= o_valid_aad  ;
end // l_del_aad_valid


// DATA
//--------------------------------------------------------------------------------------------------
always @( * )
begin
    if ( ~|i_length_aad )
        data_sop    = i_sop                 ;
    else if ( i_rf_static_encrypt )
        data_sop    = i_gctr_o_sop          ;
    else
        data_sop    = timer_aad_pre_done    ;
end

assign  data_valid  =   ( i_rf_static_encrypt )   ?
                        i_valid_encrypt : i_valid_decrypt   ;


always @( posedge i_clock )
begin : l_timer_update
    if ( i_reset || (i_enable && data_sop) )    // cad_ence map_to_mux
        timer   <= { NB_TIMER{1'b0} }   ;
    else if ( i_enable && !timer_done && data_valid )
        timer   <= timer + 1'b1         ;
end // l_timer_update


assign  length_plaintext_m1 =   ( |i_length_plaintext )     ?   // cad_ence map_to_mux
                                i_length_plaintext - 1'b1   : i_length_plaintext    ;   // [HINT] Mismatch and carry drop intentional.

assign  timer_pre_done      =   ( timer == length_plaintext_m1 )  ;

assign  timer_done          =   ( timer == i_length_plaintext )   ;


always @( posedge i_clock )
begin : l_extra_valid
    if ( i_reset )  // cad_ence map_to_mux
        extra_valid     <= 1'b0                         ;
    else if ( i_enable )
        extra_valid     <= timer_pre_done & ( ( ~|i_length_plaintext & data_sop) | data_valid );
end // l_extra_valid

assign  o_valid_data    = ~timer_done & data_valid  ;

always @( posedge i_clock )
begin : l_del_data_valid
    if ( i_reset )  // cad_ence map_to_mux
        o_valid_data_d  <= 1'b0         ;
    else if ( i_enable )
        o_valid_data_d  <= o_valid_data ;
end // l_del_data_valid


// LENGTH
//--------------------------------------------------------------------------------------------------
assign  o_valid_length      = extra_valid       ;

always @( posedge i_clock )
begin : l_del_length_valid
    if ( i_reset )  // cad_ence map_to_mux
        o_valid_length_d    <= 1'b0             ;
    else if ( i_enable )
        o_valid_length_d    <= o_valid_length   ;
end // l_del_length_valid


// GENERAL
//--------------------------------------------------------------------------------------------------
assign  o_sop_ghash         =   i_sop;

assign  o_valid_ghash       =   o_sop_ghash | o_valid_aad | o_valid_data | o_valid_length   ;

always @( posedge i_clock )
begin : l_del_vld
    if ( i_reset )  // cad_ence map_to_mux
        o_valid_ghash_d <= 1'b0             ;
    else if ( i_enable )
        o_valid_ghash_d <= o_valid_ghash    ;
end // l_del_vld

assign  o_sel_ghash_in  = { o_valid_aad, extra_valid }  ;

always @( posedge i_clock )
begin : l_vld_tag
    if ( i_reset )  // cad_ence map_to_mux
        o_valid_tag     <= 1'b0             ;
    else if ( i_enable )
        o_valid_tag     <= o_valid_length_d ;
end // l_vld_tag

common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1                         ),
    .DELAY                      ( DATA_PROCESS_TIME_AES-1   )
)
u_common_fix_delay_line_w_valid__gctr_o_sop_for_ghash
(
    .o_data_out                 ( o_gctr_o_sop_for_ghash    ),
    .i_data_in                  ( o_data_sop                ),
    .i_valid                    ( i_enable                  ),
    .i_reset                    ( i_reset                   ),
    .clock                      ( i_clock                   )
) ;

common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1                         ),
    .DELAY                      ( 1                         )
)
u_common_fix_delay_line_w_valid__gctr_o_sop
(
    .o_data_out                 ( o_gctr_o_sop              ),
    .i_data_in                  ( o_gctr_o_sop_for_ghash    ),
    .i_valid                    ( i_enable                  ),
    .i_reset                    ( i_reset                   ),
    .clock                      ( i_clock                   )
) ;

wire                                        gctr_sop_pre    ;
assign gctr_sop_pre =   o_data_sop_pre | i_trigger_pre_block;
common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1                         ),
    .DELAY                      ( DATA_PROCESS_TIME_AES     )
)
u_common_fix_delay_line_w_valid__gctr_o_sop_pre
(
    .o_data_out                 ( o_gctr_o_sop_pre          ),
    .i_data_in                  ( gctr_sop_pre              ),
    .i_valid                    ( i_enable                  ),
    .i_reset                    ( i_reset                   ),
    .clock                      ( i_clock                   )
) ;
endmodule // gcm_aes_ghash_fsm
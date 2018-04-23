/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : gcm_aes_fsm.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gcm_aes_fsm.v 5166 2017-07-20 18:15:14Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gcm_aes_fsm
#(
    parameter                                       NB_TIMER                = 10    ,
    parameter                                       NB_SEL                  = 2     ,
    parameter                                       DATA_PROCESS_TIME_AES   = 44
)
(
    output  wire    [ NB_SEL-1:0    ]               o_ghash_sel_input               ,
    output  wire                                    o_ghash_sop                     ,
    output  wire                                    o_ghash_valid_aad               ,
    output  wire                                    o_ghash_valid_data              ,
    output  wire                                    o_ghash_valid_length            ,
    output  wire                                    o_ghash_valid                   ,
    output  wire                                    o_gctr_data_sop                 ,
    output  wire                                    o_gctr_data_sop_pre             ,
    output  wire                                    o_gctr_o_sop_for_ghash          ,
    output  wire                                    o_gctr_o_sop                    ,
    output  wire                                    o_gctr_o_sop_pre                ,
    output  wire                                    o_gctr_triggered_o_sop_pre      ,
    input   wire                                    i_sop                           ,
    input   wire                                    i_trigger_pre_block             ,
    input   wire    [ NB_TIMER-1:0  ]               i_length_plaintext              ,
    input   wire    [ NB_TIMER-1:0  ]               i_length_aad                    ,
    input   wire                                    i_valid_encrypt                 ,
    input   wire                                    i_valid_decrypt                 ,
    input   wire                                    i_rf_static_encrypt             ,
    input   wire                                    i_enable                        ,
    input   wire                                    i_reset                         ,
    input   wire                                    i_clock
) ;

// =================================================================================================
// QUICK INSTANCE
// =================================================================================================
/*
gcm_aes_fsm
#(
    .NB_TIMER                   (  ),
    .NB_SEL                     (  ),
    .DATA_PROCESS_TIME_AES      (  )
)
u_gcm_aes_fsm
(
    .o_ghash_sel_input          (  ),
    .o_ghash_sop                (  ),
    .o_ghash_valid_aad          (  ),
    .o_ghash_valid_data         (  ),
    .o_ghash_valid_length       (  ),
    .o_ghash_valid              (  ),
    .o_gctr_data_sop            (  ),
    .o_gctr_data_sop_pre        (  ),
    .o_gctr_triggered_o_sop_pre (  ),
    .o_gctr_o_sop_for_ghash     (  ),
    .o_gctr_o_sop               (  ),
    .o_gctr_o_sop_pre           (  ),
    .i_sop                      (  ),
    .i_trigger_pre_block        (  ),
    .i_length_plaintext         (  ),
    .i_length_aad               (  ),
    .i_valid_encrypt            (  ),
    .i_valid_decrypt            (  ),
    .i_rf_static_encrypt        (  ),
    .i_enable                   (  ),
    .i_reset                    (  ),
    .i_clock                    (  )
) ;
*/
// END: Quick Instance.


// =================================================================================================
// LOCAL PARAMETERS.
// =================================================================================================

// =================================================================================================
// INTERNAL SIGNALS.
// =================================================================================================
reg                                             o_gctr_data_sop_pre_reg     ;
wire                                            gctr_sop_pre                ;
reg             [ NB_TIMER-1:0  ]               valid_ctr_reg               ;
wire            [ NB_TIMER-1:0  ]               valid_ctr                   ;
reg             [ NB_TIMER-1:0  ]               valid_ciph_ctr_reg          ;
wire            [ NB_TIMER-1:0  ]               valid_ciph_ctr              ;
wire            [ 1:0           ]               fsm_case                    ;
wire                                            data_valid                  ;
reg                                             aad_done_pre                ;
reg                                             aad_done                    ;
reg                                             aad_done_reg                ;
reg                                             gctr_i_sop_pre              ;
reg                                             gctr_i_sop_pre_d            ;
reg                                             gctr_i_sop_pre_reg          ;
reg                                             gctr_i_sop                  ;
reg                                             gctr_i_sop_d                ;
reg                                             aad_ptx_done                ;
wire                                            length_word_extra_valid     ;
reg                                             length_word_extra_valid_reg ;
wire                                            ciph_done                   ;


// =================================================================================================
// ALGORITHM BEGIN.
// =================================================================================================
// MISC.
//--------------------------------------------------------------------------------------------------
always @( posedge i_clock )
begin
    if( i_reset || (i_enable && i_sop) || aad_ptx_done )
        valid_ctr_reg   <= { NB_TIMER{1'b0} }   ;
    else if ( i_enable && i_valid_decrypt )
        valid_ctr_reg   <= valid_ctr_reg + 1'b1     ;
end
assign  valid_ctr   =   ( i_enable && i_valid_decrypt )  ?
                        (valid_ctr_reg + 1) : valid_ctr_reg ;

assign  fsm_case    =   { |i_length_aad, |i_length_plaintext }  ;
always @( * )
begin
    case ( fsm_case )
        2'b00   :
        begin
            aad_done_pre    = 1'b0              ;
            aad_done        = 1'b1              ;
            gctr_i_sop_pre  = i_enable & i_sop  ;
            gctr_i_sop      = 1'b0              ;
        end
        2'b10   :
        begin
            aad_done_pre    = ( valid_ctr == i_length_aad - 1'b1 )                  ;
            aad_done        = ( valid_ctr >= i_length_aad )                         ;
            gctr_i_sop_pre  = ( valid_ctr == i_length_aad ) & ~gctr_i_sop_pre_d     ;
            gctr_i_sop      = 1'b0                                                  ;
        end
        2'b01   :
        begin
            aad_done_pre    = 1'b0                                                  ;
            aad_done        = 1'b1                                                  ;
            gctr_i_sop_pre  = ( valid_ctr == i_length_aad ) & ~gctr_i_sop_pre_d     ;
            gctr_i_sop      = ( valid_ctr == i_length_aad + 1'b1 ) & ~gctr_i_sop_d  ;
        end
        2'b11   :
        begin
            aad_done_pre    = ( valid_ctr == i_length_aad - 1'b1 )                  ;
            aad_done        = ( valid_ctr >= i_length_aad )                         ;
            gctr_i_sop_pre  = ( valid_ctr == i_length_aad ) & ~gctr_i_sop_pre_d     ;
            gctr_i_sop      = ( valid_ctr == i_length_aad + 1'b1 ) & ~gctr_i_sop_d  ;
        end
        default :
        begin
            aad_done_pre    = ( valid_ctr == i_length_aad - 1'b1 )                  ;
            aad_done        = ( valid_ctr >= i_length_aad )                         ;
            gctr_i_sop_pre  = ( valid_ctr == i_length_aad ) & ~gctr_i_sop_pre_d     ;
            gctr_i_sop      = ( valid_ctr == i_length_aad + 1'b1 ) & ~gctr_i_sop_d  ;
        end
    endcase
    aad_ptx_done            = ( valid_ctr == i_length_aad + i_length_plaintext )    ;
end

always @( posedge i_clock )
begin
    if ( i_reset || (i_enable && i_sop) )
        gctr_i_sop_pre_d    <=  1'b0    ;
    else if ( gctr_i_sop_pre )
        gctr_i_sop_pre_d    <=  1'b1    ;
end

always @( posedge i_clock )
begin
    if ( i_reset || (i_enable && i_sop) )
        gctr_i_sop_d    <=  1'b0    ;
    else if ( gctr_i_sop )
        gctr_i_sop_d    <=  1'b1    ;
end

always @( posedge i_clock )
begin
    if( i_reset || (i_enable && i_sop) || ciph_done )
        valid_ciph_ctr_reg   <= { NB_TIMER{1'b0} }   ;
    else if ( i_enable && i_valid_encrypt )
        valid_ciph_ctr_reg   <= valid_ciph_ctr_reg + 1'b1     ;
end
assign  valid_ciph_ctr      =   ( i_enable && i_valid_encrypt )  ?
                                (valid_ciph_ctr_reg + 1) : valid_ciph_ctr_reg ;

always @( posedge i_clock ) gctr_i_sop_pre_reg  <=  gctr_i_sop_pre  ;

assign  ciph_done           =   (|i_length_plaintext)   ?
                                ( valid_ciph_ctr == i_length_plaintext ) : gctr_i_sop_pre_reg   ;
// GHASH SOP
//--------------------------------------------------------------------------------------------------
assign  o_ghash_sop         =   i_sop   ;

// AAD
//--------------------------------------------------------------------------------------------------
always @( posedge i_clock ) aad_done_reg    <=  aad_done    ;

assign  o_ghash_valid_aad   = ~aad_done_reg & i_valid_decrypt   ;

// LENGTH WORD
//--------------------------------------------------------------------------------------------------
assign  length_word_extra_valid =   (i_rf_static_encrypt)   ?
                                    ciph_done : aad_ptx_done    ;

always @( posedge i_clock ) length_word_extra_valid_reg <= length_word_extra_valid  ;

assign  o_ghash_valid_length    =   (|i_length_plaintext)   ?
                                    length_word_extra_valid_reg : length_word_extra_valid   ;

// GCTR I_SOP
//--------------------------------------------------------------------------------------------------
assign  o_gctr_data_sop_pre    =   gctr_i_sop_pre  ;
assign  o_gctr_data_sop        =   gctr_i_sop      ;


// DATA
//--------------------------------------------------------------------------------------------------
assign  data_valid          =   ( i_rf_static_encrypt )   ?
                                i_valid_encrypt : i_valid_decrypt   ;

assign  o_ghash_valid_data  = ~aad_ptx_done & data_valid    ;

// GCTR O_SOP
//--------------------------------------------------------------------------------------------------
assign  gctr_sop_pre        =   gctr_i_sop_pre | i_trigger_pre_block;
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

common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1                         ),
    .DELAY                      ( DATA_PROCESS_TIME_AES     )
)
u_common_fix_delay_line_w_valid__gctr_o_sop
(
    .o_data_out                 ( o_gctr_o_sop              ),
    .i_data_in                  ( gctr_i_sop                ),
    .i_valid                    ( i_enable                  ),
    .i_reset                    ( i_reset                   ),
    .clock                      ( i_clock                   )
) ;

common_fix_delay_line_w_valid
#(
    .NB_DATA                    ( 1                             ),
    .DELAY                      ( DATA_PROCESS_TIME_AES         )
)
u_common_fix_delay_line_w_valid__gctr_triggered_o_sop_pre
(
    .o_data_out                 ( o_gctr_triggered_o_sop_pre    ),
    .i_data_in                  ( i_trigger_pre_block           ),
    .i_valid                    ( i_enable                      ),
    .i_reset                    ( i_reset                       ),
    .clock                      ( i_clock                       )
) ;

// GENERAL
//--------------------------------------------------------------------------------------------------
assign  o_ghash_valid       =   o_ghash_sop | o_ghash_valid_aad | o_ghash_valid_data | o_ghash_valid_length   ;

assign  o_ghash_sel_input   =   { o_ghash_valid_aad, o_ghash_valid_length }  ;

endmodule
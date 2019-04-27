/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : subbytes_block.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gcm_aes_cipher_tag_fsm.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gcm_aes_cipher_tag_fsm
#(
    parameter                                       NB_TIMER        = 4 ,
    parameter                                       NB_SEL          = 2
)
(
    output  wire    [NB_SEL-1:0]                    o_sel_ghash_in ,
    output  wire                                    o_valid_data ,
    output  reg                                     o_valid_data_d ,
    output  wire                                    o_valid_length ,
    output  reg                                     o_valid_length_d ,
    output  wire                                    o_valid_ghash ,
    output  reg                                     o_valid_ghash_d ,
    output  reg                                     o_valid_tag ,
    input   wire                                    i_sop_del ,
    input   wire    [NB_TIMER-1:0]                  i_length_plaintext ,
    input   wire                                    i_valid_data ,
    input   wire                                    i_valid ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;

    /* // BEGIN: Quick Instance.
    gcm_aes_cipher_tag_fsm
    #(
        .NB_TIMER           ( 4 ),
        .NB_SEL             ( 2 )
    )
    u_gcm_aes_cipher_tag_fsm
    (
        .o_sel_ghash_in     (   ),
        .o_valid_data       (   ),
        .o_valid_length     (   ),
        .o_valid_tag        (   ),
        .i_sop_del          (   ),
        .i_length_plaintext (   ),
        .i_valid_data       (   ),
        .i_valid            (   ),
        .i_reset            (   ),
        .i_clock            (   )
    ) ;
    */ // END: Quick Instance.


    // LOCAL PARAMETERS.
    localparam      [NB_SEL-1:0]                    SEL_DATA            = 0 ;
    localparam      [NB_SEL-1:0]                    SEL_LENGTH          = 1 ;


    // INTERNAL SIGNALS.
    wire                                            timer_done ;
    wire                                            timer_pre_done ;
    reg             [NB_TIMER-1:0]                  timer ;
    wire            [NB_TIMER-1:0]                  length_plaintext_m1 ;
    reg                                             extra_valid ;




    // ALGORITHM BEGIN.


    // Timer update.
    always @( posedge i_clock )
    begin : l_timer_update
        if ( i_reset || (i_valid && i_sop_del) )
            timer
                <= {NB_TIMER{1'b0}} ;
        else if ( i_valid && i_valid_data && !timer_done )
            timer
                <= timer + 1'b1 ;
    end // l_timer_update

    assign  length_plaintext_m1
                = i_length_plaintext - 1'b1 ;   // [HINT] Mismatch and carry drop intentional.

    assign  timer_pre_done
                = ( timer == length_plaintext_m1 ) ;

    assign  timer_done
                = ( timer == i_length_plaintext ) ;



    always @( posedge i_clock )
    begin : l_extra_valid
        if ( i_reset )
            extra_valid
                <= 1'b0 ;
        else if ( i_valid )
            extra_valid
                <= ( timer_pre_done & i_valid_data ) ;
    end // l_extra_valid



    assign  o_valid_data
                = ~timer_done & i_valid_data ;

    always @( posedge i_clock )
    begin : l_del_data_valid
        if ( i_reset )
            o_valid_data_d
                <= 1'b0 ;
        else if ( i_valid )
            o_valid_data_d
                <= o_valid_data ;
    end // l_del_data_valid


    assign  o_valid_length
                = extra_valid ;

    always @( posedge i_clock )
    begin : l_del_length_valid
        if ( i_reset )
            o_valid_length_d
                <= 1'b0 ;
        else if ( i_valid )
            o_valid_length_d
                <= o_valid_length ;
    end // l_del_length_valid


    assign  o_valid_ghash
                = o_valid_data | o_valid_length ;


    always @( posedge i_clock )
    begin : l_del_vld
        if ( i_reset )
            o_valid_ghash_d
                <= 1'b0 ;
        else if ( i_valid )
            o_valid_ghash_d
                <= o_valid_ghash ;
    end // l_del_vld


    assign  o_sel_ghash_in
                = ( extra_valid )? SEL_LENGTH : SEL_DATA ;


    always @( posedge i_clock )
    begin : l_vld_tag
        if ( i_reset )
            o_valid_tag
                <= 1'b0 ;
        else if ( i_valid )
            o_valid_tag
                <= o_valid_length_d ;
    end // l_vld_tag


endmodule // enable_load_sequencer_fsm

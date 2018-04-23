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
 -- $Id: aes_round_ladder_sequential.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module aes_round_ladder_sequential
#(
    parameter                                               NB_BYTE             = 8 ,
    parameter                                               N_BYTES             = 16 ,
    parameter                                               N_ROUNDS            = 14
)
(
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]             o_state ,
    output  reg                                             o_state_ready ,
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]             i_state ,
    input   wire    [N_BYTES*NB_BYTE*(N_ROUNDS+1)-1:0]      i_round_key_vector ,
    input   wire                                            i_trigger ,
    input   wire                                            i_valid ,
    input   wire                                            i_reset ,
    input   wire                                            i_clock
) ;

    /* // BEGIN: Quick instance.
    aes_round_ladder_sequential
    #(
        .NB_BYTE            ( NB_BYTE   ),
        .N_BYTES            ( N_BYTES   ),
        .N_ROUNDS           ( N_ROUNDS  )
    )
    u_aes_round_ladder_sequential
    (
        .o_state            (   ),
        .i_state            (   ),
        .i_round_key_vector (   ),
        .i_trigger          (   ),
        .i_valid            ( i_valid   ),
        .i_reset            ( i_reset   ),
        .i_clock            ( i_clock   )
    ) ;
    // END: Quick instance */


    // LOCAL PARAMETERS.
    localparam                                              N_COLS              = 4 ;
    localparam                                              N_ROWS              = N_BYTES / N_COLS ;
    localparam                                              NB_STATE            = N_BYTES * NB_BYTE ;
    localparam                                              NB_TIMER            = 5 ;   // [HINT] Must be big enough to count to N_ROUNDS+1 ;
    localparam                                              BAD_CONF            = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) || ( N_ROUNDS != 14 ) ;


    // INTERNAL SIGNALS.
    wire                                                    triggered ;
    wire                                                    last_stage_flag ;
    reg             [NB_STATE*(N_ROUNDS+1)-1:0]             round_key_shifter ;
    wire            [NB_STATE-1:0]                          round_key ;
    reg             [NB_STATE-1:0]                          state_in ;
    wire            [NB_STATE-1:0]                          state_out ;
    reg             [NB_TIMER-1:0]                          timer ;


    // ALGORITHM BEGIN.


    always @( posedge i_clock )
        if ( i_reset || ( i_valid && i_trigger ) )
            round_key_shifter
                <= i_round_key_vector ;
        else if ( i_valid && triggered )
            round_key_shifter
                <= { {NB_STATE{1'b0}}, round_key_shifter[ (N_ROUNDS+1)*NB_STATE - 1 : NB_STATE ] } ;
    assign  round_key
                = round_key_shifter[ 0 +: NB_STATE ] ;


    always @( posedge i_clock )
        if ( i_reset )
            state_in
                <= i_state ;
        else if ( i_valid && i_trigger )
            state_in
                <= i_state /* ^ i_round_key_vector[ 0 +: NB_STATE ] */ ;
        else if ( i_valid && triggered )
            state_in
                <= ( timer==0 )? ( i_state ^ i_round_key_vector[ 0 +: NB_STATE ] ) : state_out ;


    always @( posedge i_clock )
        if ( i_reset || ( i_valid && i_trigger ) )
            timer
                <= {NB_TIMER{1'b0}} ;
        else if ( i_valid && triggered )
            timer
                <= timer + 1'b1 ;
    assign  triggered
                = timer <= (N_ROUNDS) ;
    assign  last_stage_flag
                = timer == (N_ROUNDS) ;


    round_block_sequential
    #(
        .NB_BYTE            ( NB_BYTE           ),
        .N_BYTES            ( N_BYTES           ),
        .CREATE_REG_LUT     ( 0                 )
    )
    u_round_block_sequential
    (
        .o_state            ( state_out         ),
        .i_state            ( state_in          ),
        .i_round_key        ( round_key         ),
        .i_last_stage_flag  ( last_stage_flag   ),
        .i_valid            ( i_valid           ),
        .i_reset            ( i_reset           ),
        .i_clock            ( i_clock           )
    ) ;


    assign  o_state
                = state_in ;


    always @( posedge i_clock )
        if ( i_reset )
            o_state_ready
                <= 1'b0 ;
        else if ( i_valid )
            o_state_ready
                <= last_stage_flag ;


endmodule // aes_round_ladder

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
 -- $Id: aes_round_ladder_xor_data_sequential.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module aes_round_ladder_xor_data_sequential
#(
    // PARAMETERS.
    parameter                                               NB_BYTE             = 8 ,
    parameter                                               N_BYTES             = 16 ,
    parameter                                               N_ROUNDS            = 14 ,
    parameter                                               STAGES_BETWEEN_REGS = /*3*/ 1
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]             o_state ,
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]             o_data ,
    output  wire                                            o_valid ,
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]             i_state ,
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]             i_data ,
    input   wire    [N_BYTES*NB_BYTE*(N_ROUNDS+1)-1:0]      i_round_key_vector ,
    input   wire                                            i_valid ,   // [HINT]: Used only if create_out_reg==1.
    input   wire                                            i_reset ,   // [HINT]: Used only if create_out_reg==1.
    input   wire                                            i_clock     // [HINT]: Used only if create_out_reg==1.
) ;


    // LOCAL PARAMETERS.
    localparam                                              N_COLS              = 4 ;
    localparam                                              N_ROWS              = N_BYTES / N_COLS ;
    localparam                                              NB_STATE            = N_BYTES * NB_BYTE ;
    localparam                                              BAD_CONF            = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) || ( N_ROUNDS != 14 ) ;

    // INTERNAL SIGNALS.
    genvar                                                  ii ;
    wire    [NB_STATE*(N_ROUNDS+1+1)-1:0]                   round_states ;
    wire    [(N_ROUNDS+1+1)-1:0]                            valid_bus ;
    wire    [NB_STATE*(N_ROUNDS+1+1)-1:0]                   data_bus ;


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
                <= i_state ^ i_round_key_vector[ 0 +: NB_STATE ] ;
        else if ( i_valid && triggered )
            state_in
                <= state_out ;




    round_block_sequential
    #(
        .NB_BYTE            ( NB_BYTE           ),
        .N_BYTES            ( N_BYTES           ),
        .ROUND_INDEX        ( 1                 ),
        .FIRST_ROUND_INDEX  ( 0                 ),
        .LAST_ROUND_INDEX   ( N_ROUNDS          ),
        .CREATE_REG_LUT     ( 0                 ),
        .CREATE_REG_OUT     ( 0                 )
    )
    u_round_block_sequential
    (
        .o_state            ( state_out         ),
        .i_state            ( state_in          ),
        .i_round_key        ( round_key         ),
        .i_valid            ( i_valid           ),
        .i_reset            ( i_reset           ),
        .i_clock            ( i_clock           )
    ) ;


endmodule // aes_round_ladder

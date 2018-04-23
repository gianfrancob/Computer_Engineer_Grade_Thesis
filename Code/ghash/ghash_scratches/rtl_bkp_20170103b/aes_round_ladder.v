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
 -- $Id: aes_round_ladder.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module aes_round_ladder
#(
    // PARAMETERS.
    parameter                                               NB_BYTE             = 8 ,
    parameter                                               N_BYTES             = 16 ,
    parameter                                               N_ROUNDS            = 14 ,
    parameter                                               STAGES_BETWEEN_REGS = 1 ,
    parameter                                               CREATE_REG_LUT      = 0
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]             o_state ,
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]             i_state ,
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


    // ALGORITHM BEGIN.

    assign  round_states[ 0*NB_STATE +: NB_STATE ]
                = i_state ;


    // Creating N_BYTES instances of S-Box block.
    generate
        for ( ii=0; ii<N_ROUNDS+1; ii=ii+1 )
        begin : genfor_aes_rounds

            wire    [NB_STATE-1:0]                          ii_o_state ;
            wire    [NB_STATE-1:0]                          ii_i_state ;
            wire    [NB_STATE-1:0]                          ii_i_round_key ;

            assign  ii_i_state
                        = round_states[ (ii+0)*NB_STATE +: NB_STATE ] ;
            assign  ii_i_round_key
                        = i_round_key_vector[ (ii+0)*NB_STATE +: NB_STATE ] ;

            round_block
            #(
                .NB_BYTE            ( NB_BYTE                                       ),
                .N_BYTES            ( N_BYTES                                       ),
                .ROUND_INDEX        ( ii                                            ),
                .FIRST_ROUND_INDEX  ( 0                                             ),
                .LAST_ROUND_INDEX   ( N_ROUNDS                                      ),
                .CREATE_REG_LUT     ( CREATE_REG_LUT                                ),
                .CREATE_REG_OUT     ( ((N_ROUNDS-ii)%STAGES_BETWEEN_REGS==0)? 1 : 0 )
            )
            u_round_block_ii
            (
                .o_state            ( ii_o_state                                    ),
                .i_state            ( ii_i_state                                    ),
                .i_round_key        ( ii_i_round_key                                ),
                .i_valid            ( i_valid                                       ),
                .i_reset            ( i_reset                                       ),
                .i_clock            ( i_clock                                       )
            ) ;

            assign  round_states[ (ii+1)*NB_STATE +: NB_STATE ]
                        = ii_o_state ;

        end // genfor_aes_rounds
    endgenerate

    assign  o_state
                = round_states[ (N_ROUNDS+1)*NB_STATE +: NB_STATE ] ;

endmodule // aes_round_ladder

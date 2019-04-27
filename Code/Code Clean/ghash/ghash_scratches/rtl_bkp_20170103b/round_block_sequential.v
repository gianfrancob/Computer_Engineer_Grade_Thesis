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
 -- $Id: round_block_sequential.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements a round of the AES cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module round_block_sequential
#(
    // PARAMETERS.
    parameter                                       NB_BYTE             = 8 ,
    parameter                                       N_BYTES             = 16 ,
    parameter                                       CREATE_REG_LUT      = 0     // [HINT] Only 0 and 1 are legal values.
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]     o_state ,
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]     i_state ,
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]     i_round_key ,
    input   wire                                    i_last_stage_flag ,
    input   wire                                    i_valid ,                   // [HINT]: Used only if create_out_reg==1.
    input   wire                                    i_reset ,                   // [HINT]: Used only if create_out_reg==1.
    input   wire                                    i_clock                     // [HINT]: Used only if create_out_reg==1.
) ;


    // LOCAL PARAMETERS.
    localparam                                      N_COLS      = 4 ;
    localparam                                      N_ROWS      = N_BYTES / N_COLS ;
    localparam                                      BAD_CONF    = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) ;

    // INTERNAL SIGNALS.
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_a_subbytes ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_b_shiftrows ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_c_mixcolumns ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_d_muxed ;


    // ALGORITHM BEGIN.

    // Sub Bytes operation. Output can be registered.
    //------------------------------------------------------------------
    subbytes_block
    #(
        .NB_BYTE            ( NB_BYTE               ),
        .N_BYTES            ( N_BYTES               ),
        .CREATE_OUTPUT_REG  ( CREATE_REG_LUT        )
    )
    u_subbytes_block
    (
        .o_state            ( state_a_subbytes      ),
        .i_state            ( i_state               ),
        .i_valid            ( i_valid               ),
        .i_reset            ( i_reset               ),
        .i_clock            ( i_clock               )
    ) ;

    // Shift Rows operation. Implemented using a simple rewire.
    //------------------------------------------------------------------
    shiftrows_block
    #(
        .NB_BYTE            ( NB_BYTE               ),
        .N_BYTES            ( N_BYTES               )
    )
    u_shiftrows_block
    (
        .o_state            ( state_b_shiftrows     ),
        .i_state            ( state_a_subbytes      )
    ) ;

    // Mix Columns operation. It is skipped in the last round.
    //------------------------------------------------------------------
    mixcolumns_block
    #(
        .NB_BYTE            ( NB_BYTE               ),
        .N_BYTES            ( N_BYTES               )
    )
    u_mixcolumns_block
    (
        .o_state            ( state_c_mixcolumns    ),
        .i_state            ( state_b_shiftrows     )
    ) ;

    // Skipping mix columns on last stage.
    assign  state_d_muxed
                = ( i_last_stage_flag )? state_b_shiftrows : state_c_mixcolumns ;

    // Add Round Key operation.
    //------------------------------------------------------------------
    assign  o_state
                = state_d_muxed ^ i_round_key ;


endmodule // round_block

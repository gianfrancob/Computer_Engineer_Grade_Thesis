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
 -- $Id: round_block.v 10153 2016-12-20 21:21:26Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements a round of the AES cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module round_block
#(
    // PARAMETERS.
    parameter                                       NB_BYTE             = 8 ,
    parameter                                       N_BYTES             = 16 ,
    parameter                                       ROUND_INDEX         = 1 ,
    parameter                                       FIRST_ROUND_INDEX   = 0 ,
    parameter                                       LAST_ROUND_INDEX    = 14 ,
    parameter                                       CREATE_REG_LUT      = 0 ,   // [HINT] Only 0 and 1 are legal values.
    parameter                                       CREATE_REG_OUT      = 0     // [HINT] Only 0 and 1 are legal values.
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]     o_state ,
 // output  wire                                    o_valid ,
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]     i_state ,
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]     i_round_key ,
    input   wire                                    i_valid ,   // [HINT]: Used only if create_out_reg==1.
    input   wire                                    i_reset ,   // [HINT]: Used only if create_out_reg==1.
    input   wire                                    i_clock     // [HINT]: Used only if create_out_reg==1.
) ;


    // LOCAL PARAMETERS.
    localparam                                      N_COLS      = 4 ;
    localparam                                      N_ROWS      = N_BYTES / N_COLS ;
    localparam                                      BAD_CONF    = ( NB_BYTE != 8 ) || ( N_BYTES != 16 ) ;

    // INTERNAL SIGNALS.
    genvar                                          ii ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_a_subbytes ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_b_shiftrows ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_c_mixcolumns ;
    wire            [N_BYTES * NB_BYTE - 1 : 0]     state_d_addroundkey ;


    // ALGORITHM BEGIN.


    // Creating N_BYTES instances of S-Box block.
    generate
        if ( ROUND_INDEX == FIRST_ROUND_INDEX )
        begin : genif_first_round

            // In the first round, only a Add Round Key operation is performed.
            //------------------------------------------------------------------
            assign  state_a_subbytes
                        = {N_BYTES*NB_BYTE{1'b0}} ;
            assign  state_b_shiftrows
                        = {N_BYTES*NB_BYTE{1'b0}} ;
            assign  state_c_mixcolumns
                        = {N_BYTES*NB_BYTE{1'b0}} ;
            assign  state_d_addroundkey
                        = i_state ^ i_round_key ;

        end // genif_first_round
        else
        begin : genelse_not_first_round

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
            if ( ROUND_INDEX == LAST_ROUND_INDEX )
            begin : genif_not_last_round
                assign  state_c_mixcolumns
                            = state_b_shiftrows ;
            end // genif_not_last_round
            else
            begin : genelse_not_last_round
                // mixcolumns_block
                // #(
                //     .NB_BYTE            ( NB_BYTE               ),
                //     .N_BYTES            ( N_BYTES               )
                // )
                // u_mixcolumns_block
                // (
                //     .o_state            ( state_c_mixcolumns    ),
                //     .i_state            ( state_b_shiftrows     )
                // ) ;
                 mixcolumns_block_new
                #(
                    .NB_BYTE            ( NB_BYTE               ),
                    .N_BYTES            ( N_BYTES               )
                )
                u_mixcolumns_block_new
                (
                    .o_state            ( state_c_mixcolumns    ),
                    .i_state            ( state_b_shiftrows     )
                ) ;
            end // genelse_not_last_round

            // Add Round Key operation.
            //------------------------------------------------------------------
            assign  state_d_addroundkey
                        = state_c_mixcolumns ^ i_round_key ;

        end // genelse_not_first_round
    endgenerate


    // Conditional output register for data.
    common_fix_delay_line_w_valid
    #(
        .NB_DATA            ( NB_BYTE * N_BYTES     ),
        .DELAY              ( CREATE_REG_OUT        )
    )
    u_common_fix_delay_line_w_valid
    (
        .o_data_out         ( o_state               ),
        .i_data_in          ( state_d_addroundkey   ),
        .i_valid            ( i_valid               ),
        .i_reset            ( i_reset               ),
        .clock              ( i_clock               )
    ) ;


 // // Conditional output register for valid
 // common_fix_delay_line_w_valid
 // #(
 //     .NB_DATA            ( 1                     ),
 //     .DELAY              ( CREATE_REG_OUT        )
 // )
 // u_common_fix_delay_line_w_valid__vld
 // (
 //     .o_data_out         ( o_valid               ),
 //     .i_data_in          ( i_valid               ),
 //     .i_valid            ( 1'b1                  ),
 //     .i_reset            ( i_reset               ),
 //     .clock              ( i_clock               )
 // ) ;


endmodule // round_block

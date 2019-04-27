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
 -- $Id: key_update_fsm.v 10703 2017-02-22 16:18:36Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module key_update_fsm
#(
    parameter                                       NB_STATE        = 4     // [HINT] Must be 4. Added as parameter for routing state to stack.
)
(
    output  reg                                     o_trigger_key_sched_calc ,
    output  reg                                     o_trigger_j0_and_h_calc ,
    output  reg                                     o_trigger_h_powers_calc ,
    output  reg                                     o_h_powers_lock ,
    output  reg                                     o_key_sched_lock ,
    output  reg                                     o_switch_h_powers ,
    output  reg                                     o_key_update_done ,

    output  wire    [NB_STATE-1:0]                  o_state ,

    input   wire                                    i_key_update ,
    input   wire                                    i_key_sched_ready ,
    input   wire                                    i_sop_pre ,
    input   wire                                    i_sop ,
    input   wire                                    i_sop_ghash ,
    input   wire                                    i_h_ready_pre ,
    input   wire                                    i_h_ready ,
    input   wire                                    i_h_powers_ready ,
    input   wire                                    i_key_sched_lock_done ,
    input   wire                                    i_valid ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;

    /* // BEGIN: Quick Instance.
    key_update_fsm
    #(
        .NB_STATE                   (  ) ,  // [HINT] Must be 3. Added as parameter for routing state to stack.
    )
    u_key_update_fsm
    (
        .o_trigger_key_sched_calc   (  ) ,
        .o_state                    (  ) ,
        .i_update_key               (  ) ,
        .i_key_sched_ready          (  ) ,
        .i_sop_pre                  (  ) ,
        .i_h_ready                  (  ) ,
        .i_h_powers_ready           (  ) ,
        .i_valid                    (  ) ,
        .i_reset                    (  ) ,
        .i_clock                    (  )
    ) ;
    */ // END: Quick Instance.


    // LOCAL PARAMETERS.
    localparam      [NB_STATE-1:0]                  ST_0_WAIT_KEY_UPDATE        = 0 ;
    localparam      [NB_STATE-1:0]                  ST_1_WAIT_KEY_SCHED_READY   = 1 ;
    localparam      [NB_STATE-1:0]                  ST_2_WAIT_SOP_PRE           = 2 ;
    localparam      [NB_STATE-1:0]                  ST_3_WAIT_H_READY_PRE       = 3 ;
    localparam      [NB_STATE-1:0]                  ST_4_WAIT_H_READY           = 4 ;
    localparam      [NB_STATE-1:0]                  ST_5_WAIT_H_POWER_CALC      = 5 ;
    localparam      [NB_STATE-1:0]                  ST_6_WAIT_SOP_B             = 6 ;
    localparam      [NB_STATE-1:0]                  ST_7_WAIT_SOP_C             = 7 ;
    localparam      [NB_STATE-1:0]                  ST_8_WAIT_KEY_LOAD_DONE     = 8 ;


    // INTERNAL SIGNALS.
    reg             [NB_STATE-1:0]                  state ;
    reg             [NB_STATE-1:0]                  state_next ;





    // ALGORITHM BEGIN.


    // State update.
    always @( posedge i_clock )
    begin : l_state_update
        if ( i_reset )
            state
                <= ST_0_WAIT_KEY_UPDATE ;
        else if ( i_valid )
            state
                <= state_next ;
    end // l_state_update


    // Next state and output calculation.
    always @( * )
    begin : l_next_state_and_o_calc

        state_next                      = ST_0_WAIT_KEY_UPDATE ;
        o_trigger_key_sched_calc        = 1'b0 ;
        o_trigger_j0_and_h_calc         = 1'b0 ;
        o_trigger_h_powers_calc         = 1'b0 ;
        o_h_powers_lock                 = 1'b0 ;
        o_key_sched_lock                = 1'b0 ;
        o_switch_h_powers               = 1'b0 ;
        o_key_update_done               = 1'b0 ;

        case ( state )

            ST_0_WAIT_KEY_UPDATE :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next      = ST_1_WAIT_KEY_SCHED_READY ; // Chequear con rami si esta bien
                    default     :   state_next      = ST_0_WAIT_KEY_UPDATE ;
                endcase
                o_trigger_key_sched_calc    = i_key_update ;
            end // l_st_init

            ST_1_WAIT_KEY_SCHED_READY :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next      = ST_1_WAIT_KEY_SCHED_READY ;
                    6'b01????   :   state_next      = ST_2_WAIT_SOP_PRE ;
                    default     :   state_next      = ST_1_WAIT_KEY_SCHED_READY ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
            end // l_st_init

            ST_2_WAIT_SOP_PRE :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next      = ST_1_WAIT_KEY_SCHED_READY ;
                    6'b0?1???   :   state_next      = ST_3_WAIT_H_READY_PRE ;
                    default     :   state_next      = ST_2_WAIT_SOP_PRE ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
                o_trigger_j0_and_h_calc      = i_sop_pre ;
            end // l_st_init

            ST_3_WAIT_H_READY_PRE :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    7'b1??????  :   state_next  = ST_1_WAIT_KEY_SCHED_READY ;
                    7'b0??1???  :   state_next  = ST_4_WAIT_H_READY ;
                    default     :   state_next  = ST_3_WAIT_H_READY_PRE ;
                endcase
                o_trigger_key_sched_calc    = i_key_update ;
                o_h_powers_lock             = i_h_ready_pre ;
            end // l_st_init

            ST_4_WAIT_H_READY :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next   = ST_1_WAIT_KEY_SCHED_READY ;
                    6'b0??1??   :   state_next   = ST_5_WAIT_H_POWER_CALC ;
                    default     :   state_next   = ST_4_WAIT_H_READY ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
                o_trigger_h_powers_calc      = i_h_ready ;
            end // l_st_init

            ST_5_WAIT_H_POWER_CALC :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next   = ST_1_WAIT_KEY_SCHED_READY ;
                    6'b0???1?   :   state_next   = ST_6_WAIT_SOP_B ;
                    default     :   state_next   = ST_5_WAIT_H_POWER_CALC ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
            end // l_st_init

            ST_6_WAIT_SOP_B :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next   = ST_1_WAIT_KEY_SCHED_READY ;
                    6'b0????1   :   state_next   = /*ST_7_WAIT_SOP_C*/ST_8_WAIT_KEY_LOAD_DONE ;
                    default     :   state_next   = ST_6_WAIT_SOP_B ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
                o_key_sched_lock             = i_sop ;
                o_switch_h_powers            = i_sop/*_ghash*/ ;
            end // l_st_init

            ST_7_WAIT_SOP_C :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop, i_sop_ghash} )
                    7'b1??????  :   state_next   = ST_1_WAIT_KEY_SCHED_READY ;
                    7'b0?????1  :   state_next   = ST_8_WAIT_KEY_LOAD_DONE ;
                    default     :   state_next   = ST_7_WAIT_SOP_C ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
                // o_switch_h_powers            = i_sop_ghash ;
            end // l_st_init

            ST_8_WAIT_KEY_LOAD_DONE :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop, i_key_sched_lock_done} )
                    7'b1??????  :   state_next   = ST_1_WAIT_KEY_SCHED_READY ;
                    7'b0?????1  :   state_next   = ST_0_WAIT_KEY_UPDATE ;
                    default     :   state_next   = ST_8_WAIT_KEY_LOAD_DONE ;
                endcase
                o_trigger_key_sched_calc     = i_key_update ;
                o_key_update_done            = i_key_sched_lock_done ;
            end // l_st_init

            default :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )
                    6'b1?????   :   state_next      = ST_1_WAIT_KEY_SCHED_READY ;
                    default     :   state_next      = ST_0_WAIT_KEY_UPDATE ;
                endcase
                o_trigger_key_sched_calc    = i_key_update ;
            end // l_st_init

        endcase
    end // l_next_state_and_o_calc

    assign  o_state
                = state ;

endmodule // enable_load_sequencer_fsm

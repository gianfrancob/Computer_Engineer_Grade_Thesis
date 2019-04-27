/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : key_update_fsm.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: key_update_fsm.v 10703 2017-02-22 16:18:36Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module controlles the logic to be aplyed
 -- when i_update_key is triggered
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module key_update_fsm
#(
    parameter                                       NB_STATE                    =   3
)
(
    output  reg                                     o_trigger_key_sched_calc        ,
    output  reg                                     o_trigger_pre_block_ciph        ,
    output  reg                                     o_trigger_h_powers_calc         ,
    output  reg                                     o_h_hash_subkey_lock            ,
    output  reg                                     o_h_powers_done                 ,
    output  reg                                     o_key_sched_lock                ,
    output  reg                                     o_key_sched_done                ,
    output  reg                                     o_switch_h_powers               ,
    output  reg                                     o_key_update_done               ,
    output  reg                                     o_trigger_j0_tag_new_locking    ,
    output  wire    [ NB_STATE-1:0  ]               o_state                         ,
    input   wire                                    i_key_update                    ,
    input   wire                                    i_key_sched_ready               ,
    input   wire                                    i_sop_pre                       ,
    input   wire                                    i_sop                           ,
    input   wire                                    i_tag_ready                     ,
    input   wire                                    i_h_ready_pre                   ,
    input   wire                                    i_h_ready                       ,
    input   wire                                    i_h_powers_ready                ,
    input   wire                                    i_key_sched_lock_done           ,
    input   wire                                    i_gctr_o_sop_pre                ,
    input   wire                                    i_rf_static_encrypt             ,
    input   wire                                    i_valid                         ,
    input   wire                                    i_reset                         ,
    input   wire                                    i_clock
) ;


/* // BEGIN: Quick Instance.
key_update_fsm
#(
    .NB_STATE                       (  )    // Must be 3
)
u_key_update_fsm
(
    .o_trigger_key_sched_calc       (  ),
    .o_trigger_pre_block_ciph       (  ),
    .o_trigger_h_powers_calc        (  ),
    .o_h_hash_subkey_lock           (  ),
    .o_h_powers_done                (  ),
    .o_key_sched_lock               (  ),
    .o_key_sched_done               (  ),
    .o_switch_h_powers              (  ),
    .o_key_update_done              (  ),
    .o_trigger_j0_tag_new_locking   (  ),
    .o_state                        (  ),
    .i_key_update                   (  ),
    .i_key_sched_ready              (  ),
    .i_sop_pre                      (  ),
    .i_sop                          (  ),
    .i_sop_ghash                    (  ),
    .i_h_ready_pre                  (  ),
    .i_h_ready                      (  ),
    .i_h_powers_ready               (  ),
    .i_key_sched_lock_done          (  ),
    .i_gctr_o_sop_pre               (  ),
    .i_rf_static_encrypt                      (  ),
    .i_valid                        (  ),
    .i_reset                        (  ),
    .i_clock
) ;
*/ // END: Quick Instance.


// LOCAL PARAMETERS.
localparam      [ NB_STATE-1:0  ]               ST_0_WAIT_KEY_UPDATE        = 0 ;
localparam      [ NB_STATE-1:0  ]               ST_1_WAIT_KEY_SCHED_READY   = 1 ;
localparam      [ NB_STATE-1:0  ]               ST_2_WAIT_SOP_PRE           = 2 ;
localparam      [ NB_STATE-1:0  ]               ST_3_WAIT_H_READY           = 3 ;
localparam      [ NB_STATE-1:0  ]               ST_4_WAIT_H_POWER_CALC      = 4 ;
localparam      [ NB_STATE-1:0  ]               ST_5_WAIT_SOP               = 5 ;
localparam      [ NB_STATE-1:0  ]               ST_6_WAIT_KEY_LOAD_DONE     = 6 ;
localparam      [ NB_STATE-1:0  ]               ST_7_WAIT_GCTR_O_SOP_PRE    = 7 ;


// INTERNAL SIGNALS.
reg             [ NB_STATE-1:0  ]               state       ;
reg             [ NB_STATE-1:0  ]               state_next  ;


// ALGORITHM BEGIN.

// State update.
always @( posedge i_clock )
begin : l_state_update
    if ( i_reset )  // cad_ence map_to_mux
        state   <= ST_0_WAIT_KEY_UPDATE ;
    else if ( i_valid )
        state   <= state_next           ;
end // l_state_update


// Next state and output calculation.
always @( * )
begin : l_next_state_and_o_calc

    state_next                      = ST_0_WAIT_KEY_UPDATE  ;
    o_trigger_key_sched_calc        = 1'b0                  ;
    o_trigger_pre_block_ciph        = 1'b0                  ;
    o_trigger_h_powers_calc         = 1'b0                  ;
    o_h_hash_subkey_lock            = 1'b0                  ;
    o_h_powers_done                 = 1'b0                  ;
    o_key_sched_lock                = 1'b0                  ;
    o_key_sched_done                = 1'b0                  ;
    o_switch_h_powers               = 1'b0                  ;
    o_key_update_done               = 1'b0                  ;
    o_trigger_j0_tag_new_locking    = 1'b0                  ;

    case ( state )  // cad_ence map_to_mux

        ST_0_WAIT_KEY_UPDATE:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next  = ST_1_WAIT_KEY_SCHED_READY ; // Chequear con rami si esta bien
                default     :   state_next  = ST_0_WAIT_KEY_UPDATE      ;
            endcase
            o_trigger_key_sched_calc        = i_key_update  ;
            o_trigger_pre_block_ciph        = 1'b0          ;
            o_trigger_h_powers_calc         = 1'b0          ;
            o_h_hash_subkey_lock            = 1'b0          ;
            o_h_powers_done                 = 1'b0          ;
            o_key_sched_lock                = 1'b0          ;
            o_key_sched_done                = 1'b0          ;
            o_switch_h_powers               = 1'b0          ;
            o_key_update_done               = 1'b0          ;
            o_trigger_j0_tag_new_locking    = 1'b0          ;
        end // l_st_init

        ST_1_WAIT_KEY_SCHED_READY:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next  = ST_1_WAIT_KEY_SCHED_READY ;
                6'b01????   :   state_next  = ST_2_WAIT_SOP_PRE         ;
                default     :   state_next  = ST_1_WAIT_KEY_SCHED_READY ;
            endcase
            o_trigger_key_sched_calc        = i_key_update      ;
            o_trigger_pre_block_ciph        = 1'b0              ;
            o_trigger_h_powers_calc         = 1'b0              ;
            o_h_hash_subkey_lock            = 1'b0              ;
            o_h_powers_done                 = 1'b0              ;
            o_key_sched_lock                = 1'b0              ;
            o_key_sched_done                = i_key_sched_ready ; // 05-06-2017
            o_switch_h_powers               = 1'b0              ;
            o_key_update_done               = 1'b0              ;
            o_trigger_j0_tag_new_locking    = 1'b0              ;
        end // l_st_init

        ST_2_WAIT_SOP_PRE:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next  = ST_1_WAIT_KEY_SCHED_READY ;
                6'b0?1???   :   state_next  = ST_3_WAIT_H_READY /*ST_3_WAIT_H_READY_PRE*/ ;
                default     :   state_next  = ST_2_WAIT_SOP_PRE         ;
            endcase
            o_trigger_key_sched_calc        = i_key_update  ;
            o_trigger_pre_block_ciph        = i_sop_pre     ;
            o_trigger_h_powers_calc         = 1'b0          ;
            o_h_hash_subkey_lock            = 1'b0          ;
            o_h_powers_done                 = 1'b0          ;
            o_key_sched_lock                = 1'b0          ;
            o_key_sched_done                = 1'b0          ;
            o_switch_h_powers               = 1'b0          ;
            o_key_update_done               = 1'b0          ;
            o_trigger_j0_tag_new_locking    = 1'b0          ;
        end // l_st_init

        ST_3_WAIT_H_READY:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next  = ST_1_WAIT_KEY_SCHED_READY ;
                6'b0??1??   :   state_next  = ST_4_WAIT_H_POWER_CALC    ;
                default     :   state_next  = ST_3_WAIT_H_READY         ;
            endcase
            o_trigger_key_sched_calc        = i_key_update  ;
            o_trigger_pre_block_ciph        = 1'b0          ;
            o_trigger_h_powers_calc         = i_h_ready     ;
            o_h_hash_subkey_lock            = 1'b0          ;
            o_h_powers_done                 = 1'b0          ;
            o_key_sched_lock                = 1'b0          ;
            o_key_sched_done                = 1'b0          ;
            o_switch_h_powers               = 1'b0          ;
            o_key_update_done               = 1'b0          ;
            o_trigger_j0_tag_new_locking    = 1'b0          ;
        end // l_st_init

        ST_4_WAIT_H_POWER_CALC:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next  = ST_1_WAIT_KEY_SCHED_READY ;
                6'b0???1?   :   state_next  = ST_5_WAIT_SOP/*_B*/           ;
                default     :   state_next  = ST_4_WAIT_H_POWER_CALC    ;
            endcase
            o_trigger_key_sched_calc        = i_key_update      ;
            o_trigger_pre_block_ciph        = 1'b0              ;
            o_trigger_h_powers_calc         = 1'b0              ;
            o_h_hash_subkey_lock            = 1'b0              ;
            o_h_powers_done                 = i_h_powers_ready  ;
            o_key_sched_lock                = 1'b0              ;
            o_key_sched_done                = 1'b0              ;
            o_switch_h_powers               = 1'b0              ;
            o_key_update_done               = 1'b0              ;
            o_trigger_j0_tag_new_locking    = 1'b0              ;
        end // l_st_init

        ST_5_WAIT_SOP:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next   = ST_1_WAIT_KEY_SCHED_READY;
                6'b0????1   :   state_next   = ST_6_WAIT_KEY_LOAD_DONE/*ST_7_WAIT_SOP_C*/ ;
                default     :   state_next   = ST_5_WAIT_SOP/*_B*/          ;
            endcase
            o_trigger_key_sched_calc        = i_key_update  ;
            o_trigger_pre_block_ciph        = 1'b0          ;
            o_trigger_h_powers_calc         = 1'b0          ;
            o_h_hash_subkey_lock            = 1'b0          ;
            o_h_powers_done                 = 1'b0          ;
            o_key_sched_lock                = i_sop         ;
            o_key_sched_done                = 1'b0          ;
            o_switch_h_powers               = i_sop         ; //i_sop_ghash
            o_key_update_done               = 1'b0          ;
            o_trigger_j0_tag_new_locking    = 1'b0          ;
        end // l_st_init

        ST_6_WAIT_KEY_LOAD_DONE:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop, i_key_sched_lock_done} )   // cad_ence map_to_mux
                7'b1??????  :   state_next   = ST_1_WAIT_KEY_SCHED_READY;
                7'b0?????1  :   state_next   = ST_7_WAIT_GCTR_O_SOP_PRE ;
                default     :   state_next   = ST_6_WAIT_KEY_LOAD_DONE  ;
            endcase
            o_trigger_key_sched_calc        = i_key_update  ;
            o_trigger_pre_block_ciph        = 1'b0          ;
            o_trigger_h_powers_calc         = 1'b0          ;
            o_h_hash_subkey_lock            = 1'b0          ;
            o_h_powers_done                 = 1'b0          ;
            o_key_sched_lock                = 1'b0          ;
            o_key_sched_done                = 1'b0          ;
            o_switch_h_powers               = 1'b0          ;
            o_key_update_done               = (i_rf_static_encrypt & i_key_sched_lock_done) | (~i_rf_static_encrypt & i_tag_ready)  ;
            o_trigger_j0_tag_new_locking    = 1'b0          ;
        end // l_st_init

        ST_7_WAIT_GCTR_O_SOP_PRE:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop, i_key_sched_lock_done, i_gctr_o_sop_pre} )   // cad_ence map_to_mux
                8'b1??????? :   state_next   = ST_1_WAIT_KEY_SCHED_READY;
                8'b0??????1 :   state_next   = ST_0_WAIT_KEY_UPDATE     ;
                default     :   state_next   = ST_7_WAIT_GCTR_O_SOP_PRE  ;
            endcase
            o_trigger_key_sched_calc        = i_key_update      ;
            o_trigger_pre_block_ciph        = 1'b0              ;
            o_trigger_h_powers_calc         = 1'b0              ;
            o_h_hash_subkey_lock            = 1'b0              ;
            o_h_powers_done                 = 1'b0              ;
            o_key_sched_lock                = 1'b0              ;
            o_key_sched_done                = 1'b0              ;
            o_switch_h_powers               = 1'b0              ;
            o_key_update_done               = 1'b0              ;
            o_trigger_j0_tag_new_locking    = i_gctr_o_sop_pre  ;
        end // l_st_init

        default:
        begin
            casez ( {i_key_update, i_key_sched_ready, i_sop_pre, i_h_ready, i_h_powers_ready, i_sop} )  // cad_ence map_to_mux
                6'b1?????   :   state_next      = ST_1_WAIT_KEY_SCHED_READY ;
                default     :   state_next      = ST_0_WAIT_KEY_UPDATE      ;
            endcase
            o_trigger_key_sched_calc        = i_key_update  ;
            o_trigger_pre_block_ciph        = 1'b0          ;
            o_trigger_h_powers_calc         = 1'b0          ;
            o_h_hash_subkey_lock            = 1'b0          ;
            o_h_powers_done                 = 1'b0          ;
            o_key_sched_lock                = 1'b0          ;
            o_key_sched_done                = 1'b0          ;
            o_switch_h_powers               = 1'b0          ;
            o_key_update_done               = 1'b0          ;
            o_trigger_j0_tag_new_locking    = 1'b0          ;
        end // l_st_init

    endcase
end // l_next_state_and_o_calc

assign  o_state = state ;

endmodule // enable_load_sequencer_fsm

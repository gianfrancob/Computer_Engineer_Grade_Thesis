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
 -- $Id: key_update_fsm.v 10419 2017-01-17 20:41:21Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module key_update_fsm
#(
    parameter                                       NB_STATE        = 3     // [HINT] Must be 3. Added as parameter for routing state to stack.
)
(
    output  wire                                    o_trigger_key_sched_calc ,
    output  wire    [NB_STATE-1:0]                  o_state ,
    input   wire                                    i_update_key ,
    input   wire                                    i_valid ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;

    /* // BEGIN: Quick Instance.
    */ // END: Quick Instance.


    // LOCAL PARAMETERS.
    localparam      [NB_STATE-1:0]                  ST_INIT             = 0 ;
    localparam      [NB_STATE-1:0]                  ST_WAITING_TIMER    = 1 ;
    localparam      [NB_STATE-1:0]                  ST_GEN_PULSE        = 2 ;
    localparam      [NB_STATE-1:0]                  ST_INC_SEL          = 3 ;


    // INTERNAL SIGNALS.
    reg             [NB_STATE-1:0]                  state ;
    reg             [NB_STATE-1:0]                  state_next ;

    reg                                             fsmo_ ;

    wire                                            fsmi_timer_done ;

    reg             [NB_TIMER-1:0]                  timer ;




    // ALGORITHM BEGIN.


    // State update.
    always @( posedge i_clock )
    begin : l_state_update
        if ( i_reset )
            state
                <= ST_INIT ;
        else if ( i_valid )
            state
                <= state_next ;
    end // l_state_update


    // Next state and output calculation.
    always @( * )
    begin : l_next_state_and_o_calc

        state_next                     = ST_INIT ;
        fsmo_trigger_key_sched_calc    = 1'b0 ;

        case ( state )

            ST_WAIT_KEY_UPDATE :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop, i_h_ready, i_h_powers_ready} )
                    5'b1????   :   state_next  = ST_WAIT_KEY_SCHED_READY ;
                    default    :   state_next  = ST_WAIT_KEY_UPDATE ;
                endcase
                fsmo_trigger_key_sched_calc    = i_key_update ;
            end // l_st_init

            ST_WAIT_KEY_SCHED_READY :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop, i_h_ready, i_h_powers_ready} )
                    5'b1????   :   state_next  = ST_WAIT_KEY_SCHED_READY ;
                    5'b01???   :   state_next  = ST_WAIT_H_READY ;
                    default    :   state_next  = ST_WAIT_KEY_SCHED_READY ;
                endcase
                fsmo_trigger_key_sched_calc    = i_key_update ;
                
            end // l_st_init

            ST_WAIT_KEY_SCHED_READY :
            begin
                casez ( {i_key_update, i_key_sched_ready, i_sop, i_h_ready, i_h_powers_ready} )
                    5'b1????   :   state_next  = ST_WAIT_KEY_SCHED_READY ;
                    5'b0?1??   :   state_next  = ST_TRIGGER_H_POWER_CALC ;
                    default    :   state_next  = ST_WAIT_KEY_UPDATE ;
                endcase
                fsmo_trigger_key_sched_calc    = i_key_update ;
            end // l_st_init


        endcase
    end // l_next_state_and_o_calc


    // Effect selection register.
    always @( posedge i_clock )
    begin : l_sel_effect
        if ( i_reset || (i_valid && fsmo_reset_sel) )
            effect_sel
                <= {LOG2_N_STEPS{1'b0}} ;
        else if ( i_valid && fsmo_inc_sel )
            effect_sel
                <= effect_sel_next ;
    end // l_sel_effect
    assign  effect_sel_next
                = effect_sel + 1'b1 ;

    // Detect when all effects had been tryied.
    assign  fsmi_sel_done
                = ( effect_sel_next == LOG2_N_STEPS ) ;


    // Timer update.
    always @( posedge i_clock )
    begin : l_timer_update
        if ( i_reset || (i_valid && !fsmo_enable_timer) )
            timer
                <= {NB_TIMER{1'b0}} ;
        else if ( i_valid )
            timer
                <= timer + 1'b1 ;
    end // l_timer_update
    assign  limit_time_bus_extended
                = { {NB_TIMER{1'b0}}, i_limit_time_bus } ;
    assign  limit_selected
                = limit_time_bus_extended[ effect_sel*NB_TIMER +: NB_TIMER ]-1'b1 ;
    assign  fsmi_timer_done
                = ( timer == limit_selected ) ;



    // [HINT] Added for routing to stack.
    assign  o_state
                = state ;

    always @( * )
    begin : l_gen_enable_bus
        enable_bus_ext
            = {N_STEPS+1{1'b0}} ;
        enable_bus_ext[ effect_sel ]
            = fsmo_enable_timer ;
    end // l_gen_enable_bus
    assign  o_enable_bus
                = enable_bus_ext[ N_STEPS-1:0 ] ;

    always @( * )
    begin : l_gen_pulse_bus
        pulse_bus_ext
            = {N_STEPS+1{1'b0}} ;
        pulse_bus_ext[ effect_sel ]
            = fsmo_pulse ;
    end // l_gen_pulse_bus
    assign  o_load_bus
                = pulse_bus_ext[ N_STEPS-1:0 ] ;


endmodule // enable_load_sequencer_fsm

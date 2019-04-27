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
 -- $Id: pulse_sequencer_fsm.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module pulse_sequencer_fsm
#(
    parameter                                       NB_STATE        = 2 ,   // [HINT] Must be 2. Added as parameter for routing state to stack.
    parameter                                       N_STEPS         = 5 ,
    parameter                                       LOG2_N_STEPS    = 3 ,
    parameter                                       NB_TIMER        = 4
)
(
    output  wire    [N_STEPS-1:0]                   o_pulse_bus ,
    output  wire    [NB_STATE-1:0]                  o_state ,
    input   wire                                    i_trigger ,
    input   wire    [N_STEPS*NB_TIMER-1:0]          i_limit_time_bus ,
    input   wire                                    i_valid ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;

    /* // BEGIN: Quick Instance.
    pulse_sequencer_fsm
    #(
        .NB_STATE           ( 2 ),  // [HINT] Must be 2.
        .N_STEPS            ( 5 ),
        .LOG2_N_STEPS       ( 3 ),
        .NB_TIMER           ( 4 )
    )
    u_pulse_sequencer_fsm
    (
        .o_pulse_bus        (   ),
        .o_state            (   ),
        .i_trigger          (   ),
        .i_limit_time_bus   (   ),
        .i_valid            (   ),
        .i_reset            (   ),
        .i_clock            (   )
    ) ;
    */ // END: Quick Instance.


    // LOCAL PARAMETERS.
    localparam      [NB_STATE-1:0]                  ST_INIT             = 0 ;
    localparam      [NB_STATE-1:0]                  ST_WAITING_TIMER    = 1 ;
    localparam      [NB_STATE-1:0]                  ST_GEN_PULSE        = 2 ;
    localparam      [NB_STATE-1:0]                  ST_INC_SEL          = 3 ;


    // INTERNAL SIGNALS.
    reg             [NB_STATE-1:0]                  state ;
    reg             [NB_STATE-1:0]                  state_next ;

    reg                                             fsmo_reset_sel ;
    reg                                             fsmo_enable_timer ;
    reg                                             fsmo_inc_sel ;

    wire                                            fsmi_timer_done ;
    wire                                            fsmi_sel_done ;

    reg             [LOG2_N_STEPS-1:0]              effect_sel ;
    wire            [LOG2_N_STEPS-1:0]              effect_sel_next ;
    reg             [NB_TIMER-1:0]                  timer ;
    wire            [NB_TIMER-1:0]                  limit_selected ;

    wire            [(N_STEPS+1)*NB_TIMER-1:0]      limit_time_bus_extended ;
    reg             [(N_STEPS+1)-1:0]               enable_bus_ext ;
    reg             [(N_STEPS+1)-1:0]               pulse_bus_ext ;



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

        state_next          = ST_INIT ;
        fsmo_reset_sel      = 1'b1 ;
        fsmo_enable_timer   = 1'b0 ;
        fsmo_inc_sel        = 1'b0 ;

        case ( state )

            ST_INIT :
            begin : l_st_init
                casez ( {i_trigger, fsmi_sel_done} )
                    2'b1?   :   state_next  = ST_WAITING_TIMER ;
                    default :   state_next  = ST_INIT ;
                endcase
                fsmo_reset_sel      = 1'b1 ;
                fsmo_enable_timer   = 1'b0 ;
                fsmo_inc_sel        = 1'b0 ;
            end // l_st_init

            ST_WAITING_TIMER :
            begin : l_st_waiting_timer
                casez ( {i_trigger, fsmi_sel_done} )
                    2'b?1   :   state_next  = ST_INIT ;
                    default :   state_next  = ST_WAITING_TIMER ;
                endcase
                fsmo_reset_sel      = 1'b0 ;
                fsmo_enable_timer   = 1'b1 ;
                fsmo_inc_sel        = fsmi_timer_done ;
            end // l_st_waiting_timer

            default :
            begin : l_st_def
                casez ( {i_trigger, fsmi_timer_done, fsmi_sel_done} )
                    3'b1??  :   state_next  = ST_WAITING_TIMER ;
                    default :   state_next  = ST_INIT ;
                endcase
                fsmo_reset_sel      = 1'b1 ;
                fsmo_enable_timer   = 1'b0 ;
                fsmo_inc_sel        = 1'b0 ;
            end // l_st_def

        endcase
    end // l_next_state_and_o_calc


    // Effect selection register.
    always @( posedge i_clock )
    begin : l_sel_effect
        if ( i_reset || (i_valid && fsmo_reset_sel) )
            effect_sel
                <= {LOG2_N_STEPS{1'b0}} ;
        else if ( i_valid && fsmo_inc_sel && fsmi_timer_done )
            effect_sel
                <= effect_sel_next ;
    end // l_sel_effect
    assign  effect_sel_next
                = effect_sel + 1'b1 ;

    // Detect when all effects had been tryied.
    assign  fsmi_sel_done
                = ( effect_sel == N_STEPS-1 ) & fsmi_timer_done ;


    // Timer update.
    always @( posedge i_clock )
    begin : l_timer_update
        if ( i_reset || (i_valid && !fsmo_enable_timer) )
            timer
                <= {NB_TIMER{1'b0}} ;
        else if ( i_valid )
            timer
                <= ( fsmi_timer_done )? {NB_TIMER{1'b0}} : timer + 1'b1 ;
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
    assign  o_pulse_bus
                = enable_bus_ext[ N_STEPS-1:0 ] ;


endmodule // enable_load_sequencer_fsm

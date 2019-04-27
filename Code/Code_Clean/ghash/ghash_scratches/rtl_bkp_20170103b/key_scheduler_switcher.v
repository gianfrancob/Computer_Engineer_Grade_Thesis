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
 -- $Id: key_scheduler_switcher.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module key_scheduler_switcher
#(
    parameter                                                   NB_BYTE             = 8 ,
    parameter                                                   N_BYTES_STATE       = 16 ,
    parameter                                                   N_ROUNDS            = 14 ,
    parameter                                                   ROUND_FIRST_DELAY   = 1 ,
    parameter                                                   ROUND_MIDDLE_DELAY  = 2 ,
    parameter                                                   ROUND_LAST_DELAY    = 2 ,
    parameter                                                   NB_TIMER            = 2     // [HINT] Must be big enough to count up to ROUND_*_DELAY
)
(
    output  reg     [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    o_round_key_vector ,
    output  reg                                                 o_muxing_done ,
    output  reg                                                 o_loading_done ,
    input   wire    [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    i_round_key_vector ,
    input   wire                                                i_trigger_muxing ,
    input   wire                                                i_trigger_loading ,
    input   wire                                                i_valid ,
    input   wire                                                i_reset ,
    input   wire                                                i_clock
) ;

    /* // BEGIN: Quick instance.
    key_scheduler_switcher
    #(
        .NB_BYTE                (  ),
        .N_BYTES_STATE          (  ),
        .N_ROUNDS               (  ),
        .ROUND_FIRST_DELAY      (  ),
        .ROUND_MIDDLE_DELAY     (  ),
        .ROUND_LAST_DELAY       (  ),
        .NB_TIMER               (  )   // [HINT] Must be big enough to count up to ROUND_*_DELAY
    )
    u_key_scheduler_switcher
    (
        .o_round_key_vector     (  ),
        .o_muxing_done          (  ),
        .o_loading_done         (  ),
        .i_round_key_vector     (  ),
        .i_trigger_muxing       (  ),
        .i_trigger_loading      (  ),
        .i_valid                (  ),
        .i_reset                (  ),
        .i_clock                (  )
    ) ;
    // END: Quick instance. */


    // LOCAL PARAMETERS.
    localparam                                                  ROUND_FULL_DELAY    = ROUND_FIRST_DELAY + (N_ROUNDS-1)*ROUND_MIDDLE_DELAY + ROUND_LAST_DELAY + 1 ;

    // INTERNAL SIGNALS.
    wire                                                        trigger ;
    reg             [NB_TIMER-1:0]                              timer ;
    reg             [NB_TIMER-1:0]                              timer_limit ;
    wire                                                        timer_done ;
    reg             [N_ROUNDS+1-1:0]                            update_bus ;
    reg                                                         muxing_enable ;
    reg                                                         loading_enable ;
    reg             [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    reg_round_key_vector ;
    integer                                                     ia ;
    reg             [ROUND_FULL_DELAY-1:0]                      round_pipe_pointer ;
    wire            [N_ROUNDS+1-1:0]                            update_bus_w ;
    genvar                                                      ii ;


    // ALGORITHM BEGIN.

    assign  trigger
                = i_trigger_muxing | i_trigger_loading ;

    always @( posedge i_clock )
    begin
        if ( i_reset )
        round_pipe_pointer
        <= {ROUND_FULL_DELAY{1'b0}} ;
    else if ( i_valid )
        if ( trigger )
        round_pipe_pointer
            <= {trigger, {ROUND_FULL_DELAY-1{1'b0}} } ;
            else
        round_pipe_pointer
            <= {1'b0, round_pipe_pointer[ROUND_FULL_DELAY-1:1]} ;
    end

    generate
    for ( ii=0; ii<N_ROUNDS+1; ii=ii+1 )
    begin : genfor_bit_sel_reduction
        if ( ii==0 )
        begin : genif_ii_first
        assign  update_bus_w[ N_ROUNDS+1-1 - 0 ]
                = round_pipe_pointer[ ROUND_FULL_DELAY-1 - ROUND_FIRST_DELAY + 1 ] ;
        end // genif_ii0
        else if ( ii != N_ROUNDS+1-1 )
        begin : genif_ii_middle
        assign  update_bus_w[ N_ROUNDS+1-1 - ii ]
                = round_pipe_pointer[ ROUND_FULL_DELAY-1 - ii*ROUND_MIDDLE_DELAY - ROUND_FIRST_DELAY ] ;
        end // genif_ii_middle
        else
        begin : genif_ii_last
        assign  update_bus_w[ 0 ]
                = round_pipe_pointer[ 0 ] ;
        end // genif_ii_last
    end // genfor_bit_sel_Reduction
    endgenerate


    // First part of the bus is just the key.

    always @( posedge i_clock )
    begin
        if ( i_reset )
            update_bus
                <= {N_ROUNDS+1{1'b0}} ;
        else if ( i_valid )
        begin
            if ( trigger )
                update_bus
                    <= {1'b1, {N_ROUNDS+1-1{1'b0}}} ;
            else if ( timer_done )
                update_bus
                    <= {1'b0, update_bus[N_ROUNDS+1-1:1]} ;
        end
    end

    always @( posedge i_clock )
    begin
        if ( i_reset || (i_valid && (timer_done || trigger)) )
            timer
                <= {NB_TIMER{1'b0}} ;
        else if ( i_valid )
            timer
                <= timer + 1'b1 ; // [HINT] Mismatch intentional.
    end
    assign  timer_done
                = ( timer == (timer_limit-1'b1) ) ;

    always @( posedge i_clock )
    begin
        if ( i_reset || (i_valid && trigger) )
            timer_limit
                <= ROUND_FIRST_DELAY[NB_TIMER-1:0] ;
        else if ( i_valid || timer_done )
        begin
            if ( update_bus[1]==1'b0 )
                timer_limit
                    <= ROUND_MIDDLE_DELAY[NB_TIMER-1:0] ;
            else
                timer_limit
                    <= ROUND_LAST_DELAY[NB_TIMER-1:0] ;
        end
    end


    always @( posedge i_clock )
    begin
        if ( i_reset )
            muxing_enable
                <= 1'b0 ;
        else if ( i_valid )
        begin
            if ( i_trigger_muxing )
                muxing_enable
                    <= 1'b1 ;
            else if ( update_bus_w[0] )
                muxing_enable
                    <= 1'b0 ;
        end
    end

    always @( posedge i_clock )
    begin
        if ( i_reset )
           o_muxing_done
               <= 1'b0 ;
        else if ( i_valid )
            o_muxing_done
                <= muxing_enable & update_bus_w[0] ;
    end


    always @( posedge i_clock )
    begin
        if ( i_reset )
            loading_enable
                <= 1'b0 ;
        else if ( i_valid )
        begin
            if ( i_trigger_loading )
                loading_enable
                    <= 1'b1 ;
            else if ( update_bus_w[0] )
                loading_enable
                    <= 1'b0 ;
        end
    end

    always @( posedge i_clock )
    begin
        if ( i_reset )
           o_loading_done
               <= 1'b0 ;
        else if ( i_valid )
            o_loading_done
                <= loading_enable & update_bus_w[0] ;
    end

    // Load round key vector register.
    always @( posedge i_clock )
    begin
        if ( i_reset )
            reg_round_key_vector
                <= {(N_ROUNDS+1)*N_BYTES_STATE*NB_BYTE{1'b0}} ;
        else
            for ( ia=0; ia<(N_ROUNDS+1); ia=ia+1 )
                if ( i_valid && loading_enable && update_bus_w[N_ROUNDS+1-1-ia] )
                    reg_round_key_vector[ (ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]
                        <= i_round_key_vector[ (ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ] ;
    end


    // Mux output.
    always @( * )
    begin : l_out_muxes
        for ( ia=0; ia<(N_ROUNDS+1); ia=ia+1 )
            if ( (loading_enable || muxing_enable) && update_bus_w[N_ROUNDS+1-1-ia] )
                o_round_key_vector[ (ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]
                    = i_round_key_vector[ (ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ] ;
            else
                o_round_key_vector[ (ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]
                    = reg_round_key_vector[ (ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ] ;
    end // l_out_muxes



endmodule // key_scheduler

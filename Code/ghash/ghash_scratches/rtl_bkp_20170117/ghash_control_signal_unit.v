module ghash_control_signal_unit
#(
    // PARAMETERS
    parameter                                           NB_N_MESSAGES       = 10 ,
    parameter                                           LOG2_BLOCK_PROC_PAR = 2 ,
    parameter                                           HOLD_MSG_DELAY      = 4 ,
    parameter                                           HASH_DONE_DELAY     = 10
)
(
    // OUTPUTS
    output      reg                                     o_last_cycle ,
    output      wire                                    o_hold_msg ,
    output      wire                                    o_hash_done ,
    output      reg                                     o_skip_msg ,
    // INPUTS
    input       wire        [NB_N_MESSAGES-1:0]         i_msg_count ,
    input       wire                                    i_skip_bus ,
    input       wire                                    i_valid ,
    input       wire        [NB_N_MESSAGES-1:0]         i_rf_static_n_messages ,
    input       wire        [LOG2_BLOCK_PROC_PAR-1:0]   i_msg_bubbles ,
    input       wire                                    i_reset ,
    input       wire                                    i_clock
) ;

    // QUICK INSTANCE: BEGIN
    /*
    ghash_control_signal_unit
    #(
        // PARAMETERS
        .N_MESSEGES                     ( N_MESSEGES    ) ,
        .MSG_BUBBLES                    ( MSG_BUBBLES   ) ,
        .HOLD_MSG_DELAY                 ( DELAY4        ) ,
        .HASH_DONE_DELAY                ( DELAY10       )
    )
    u_ghash_control_signal_unit
    (
        // OUTPUTS
        .o_last_cycle                   (  ) ,
        .o_hold_msg                     (  ) ,
        .o_hash_done                    (  ) ,
        .o_skip_msg                     (  ) ,
        // INPUTS
        .i_msg_count                    (  ) ,
        .i_skip_bus                     (  ) ,
        .i_valid                        (  ) ,
        .i_reset                        (  ) ,
        .i_clock                        (  )
    ) ;
    */ // QUICK INSTANCE: END

    // INTERNAL SIGNALS
    localparam                                          BLOCK_PROC_PAR  = 4 ;

    integer                                             skip_bus_counter ;
    wire                                                last_cycle_shift_hold_msg ;
    wire                                                last_cycle_shift_hash_done ;
    // reg             [HOLD_MSG_DELAY-1:0]                last_cycle_shift_hold_msg ;
    // reg             [HASH_DONE_DELAY-1:0]               last_cycle_shift_hash_done ;

    // ALGORITHM BEGIN
    // always @( posedge i_clock ) begin
    //    if ( i_reset )
    //         o_last_cycle  = 1'b0;
    //    else
    //         o_last_cycle  = ( i_msg_bubbles == {LOG2_BLOCK_PROC_PAR{1'b0}} )                    ?
    //                         ( i_msg_count >= i_rf_static_n_messages - BLOCK_PROC_PAR - 1'b1 )   :   // FIXME: Usar aux para sumar.
    //                         ( i_rf_static_n_messages <= BLOCK_PROC_PAR )                        ?
    //                         1'b1                                                                :
    //                         ( i_msg_count >= i_rf_static_n_messages - i_msg_bubbles  - 1'b1 )   ;   // "-1" is because the delay caused by the registration. FIXME: aux sum
    // end

    // always @( * ) begin
    //      if ( i_skip_bus )
    //         skip_bus_counter    = skip_bus_counter + 1'b1 ;
    // end
    // assign o_skip_msg
    //             = ( i_skip_bus )? skip_bus_counter + 1'b1 : skip_bus_counter ;

    // always @( posedge i_clock ) begin
    //     if ( i_reset ) begin
    //         last_cycle_shift_hold_msg   <= { HOLD_MSG_DELAY{1'b0} };
    //         last_cycle_shift_hash_done  <= { HASH_DONE_DELAY{1'b0} };
    //     end else if ( i_valid ) begin
    //         last_cycle_shift_hold_msg   <= { last_cycle_shift_hold_msg[HOLD_MSG_DELAY-1:0], o_last_cycle};
    //         last_cycle_shift_hash_done  <= { last_cycle_shift_hash_done[HASH_DONE_DELAY-1:0], o_last_cycle};
    //     end
    // end
    // assign o_hold_msg       = o_last_cycle ^ last_cycle_shift_hold_msg[HOLD_MSG_DELAY-1];
    // assign o_hash_done      = last_cycle_shift_hash_done[HASH_DONE_DELAY-1];
    // always @( * ) begin
    //     o_last_cycle <= ( i_msg_bubbles == {LOG2_BLOCK_PROC_PAR{1'b0}} )            ?
    //                     ( i_msg_count >= i_rf_static_n_messages - BLOCK_PROC_PAR )  :   // FIXME: Usar aux para sumar.
    //                     ( i_rf_static_n_messages <= BLOCK_PROC_PAR )                ?
    //                     1'b1                                                        :
    //                     ( i_msg_count >= i_rf_static_n_messages - i_msg_bubbles )   ;
    // end
    // reg o_last_cycle2 ;
    always @( posedge i_clock ) begin
        if ( i_reset )
            o_last_cycle    <= ( i_rf_static_n_messages <= BLOCK_PROC_PAR ) ;
        else if ( i_valid )
            o_last_cycle    <= ( i_msg_count >= i_rf_static_n_messages - i_msg_bubbles - 1'b1 ) || ( i_rf_static_n_messages <= BLOCK_PROC_PAR );
    end

    always @( posedge i_clock ) begin
        if ( i_reset )
            o_skip_msg  = 1'b0 ;
        else if ( i_skip_bus & i_valid )
            o_skip_msg  = 1'b1 ;
    end

    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ) ,
        .DELAY                      ( HOLD_MSG_DELAY            )
    )
    u_common_fix_delay_line_w_valid__hold_msg
    (
        .o_data_out                 ( last_cycle_shift_hold_msg ) ,
        .i_data_in                  ( o_last_cycle              ) ,
        .i_valid                    ( i_valid                   ) ,
        .i_reset                    ( i_reset                   ) ,
        .clock                      ( i_clock                   )
    ) ;
    assign o_hold_msg   = o_last_cycle ^ last_cycle_shift_hold_msg ;

    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ) ,
        .DELAY                      ( HASH_DONE_DELAY           )
    )
    u_common_fix_delay_line_w_valid__hash_done
    (
        .o_data_out                 ( last_cycle_shift_hash_done) ,
        .i_data_in                  ( o_last_cycle              ) ,
        .i_valid                    ( i_valid                   ) ,
        .i_reset                    ( i_reset                   ) ,
        .clock                      ( i_clock                   )
    ) ;
    assign o_hash_done  = last_cycle_shift_hash_done ;

endmodule
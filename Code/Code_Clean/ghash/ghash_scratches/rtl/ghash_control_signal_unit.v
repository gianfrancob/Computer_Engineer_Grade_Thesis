module ghash_control_signal_unit
#(
    // PARAMETERS
    parameter                               N_MESSEGES      = 508,
    parameter                               MSG_BUBBLES     = 0,
    parameter                               HOLD_MSG_DELAY  = 4,
    parameter                               HASH_DONE_DELAY = 10 
)
(
    // OUTPUTS
    output      reg                         o_last_cycle,
    output      wire                        o_hold_msg,
    output      wire                        o_hash_done,
    output      wire                        o_skip_msg,
    // INPUTS
    input       wire        [9:0]           i_msg_count,               
    input       wire                        i_skip_bus,
    input       wire                        i_valid,
    input       wire                        i_reset,
    input       wire                        i_clock
);

    // QUICK INSTANCE: BEGIN
    /*
    ghash_control_signal_unit
    #(
        // PARAMETERS
        .N_MESSEGES                     ( N_MESSEGES    ),
        .MSG_BUBBLES                    ( MSG_BUBBLES   ),
        .HOLD_MSG_DELAY                 ( DELAY4        ),
        .HASH_DONE_DELAY                ( DELAY10       )
    )
    u_ghash_control_signal_unit
    (
        // OUTPUTS
        .o_last_cycle                   (  ),    
        .o_hold_msg                     (  ),
        .o_hash_done                    (  ),
        .o_skip_msg                     (  ),
        // INPUTS
        .i_msg_count                    (  ),
        .i_skip_bus                     (  ),
        .i_valid                        (  ),
        .i_reset                        (  ),
        .i_clock                        (  )
    );
    */ // QUICK INSTANCE: END

    // INTERNAL SIGNALS
    integer                                             skip_bus_counter;
    reg             [HOLD_MSG_DELAY-1:0]                last_cycle_shift_hold_msg;
    reg             [HASH_DONE_DELAY-1:0]               last_cycle_shift_hash_done;

    // ALGORITHM BEGIN
    always @( posedge i_clock ) begin
       if ( i_reset ) 
            o_last_cycle  = 1'b0;
       else 
            o_last_cycle  = ( MSG_BUBBLES == 0 )                            ?
                            ( i_msg_count >= N_MESSEGES - 4 - 1 )           :   
                            ( i_msg_count >= N_MESSEGES - MSG_BUBBLES - 1 ) ;   // "-1" is because the delay caused by the registration
    end

    always @( posedge i_clock ) begin
        if ( i_reset )
            skip_bus_counter    = 0;
        else if ( i_skip_bus )
            skip_bus_counter    = skip_bus_counter + 1'b1 ;
    end
    assign o_skip_msg
                = ( i_skip_bus )? skip_bus_counter + 1'b1 : skip_bus_counter ;

    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            last_cycle_shift_hold_msg   <= { HOLD_MSG_DELAY{1'b0} };
            last_cycle_shift_hash_done  <= { HASH_DONE_DELAY{1'b0} };    
        end else if ( i_valid ) begin
            last_cycle_shift_hold_msg   <= { last_cycle_shift_hold_msg[HOLD_MSG_DELAY-1:0], o_last_cycle};
            last_cycle_shift_hash_done  <= { last_cycle_shift_hash_done[HASH_DONE_DELAY-1:0], o_last_cycle};
        end
    end
    assign o_hold_msg       = (o_last_cycle ^ last_cycle_shift_hold_msg[HOLD_MSG_DELAY-1]) & !o_hash_done;
    assign o_hash_done      = last_cycle_shift_hash_done[HASH_DONE_DELAY-1];

endmodule
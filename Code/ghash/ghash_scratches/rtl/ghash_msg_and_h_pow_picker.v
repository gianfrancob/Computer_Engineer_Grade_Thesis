module ghash_msg_and_h_pow_picker
#(
    // PARAMETERS
    parameter                                               NB_BLOCK            = 128,
    parameter                                               N_BLOCKS            = 2,
    parameter                                               NB_DATA             = N_BLOCKS*NB_BLOCK,
    parameter                                               N_H_POW             = 8,
    parameter                                               LOG2_BLOCK_PROC_PAR = 2
)
(
    // OUTPUTS
    output          reg     [NB_BLOCK-1:0]                  o_m0,
    output          reg     [NB_BLOCK-1:0]                  o_m1,
    output          reg     [NB_DATA-1:0]                   o_h_pow,
    // INPUTS
    input           wire    [NB_DATA-1:0]                   i_data,
    input           wire    [N_H_POW*NB_BLOCK-1:0]          i_h_key_powers,
    input           wire    [NB_BLOCK-1:0]                  i_feedback,
    input           wire    [NB_BLOCK-1:0]                  i_mod_prod,
    input           wire    [1:0]                           i_stage,
    input           wire                                    i_hold_msg,
    input           wire                                    i_skip_msg,
    input           wire                                    i_last_cycle,
    input           wire                                    i_valid,
    input           wire    [LOG2_BLOCK_PROC_PAR-1:0]       i_msg_bubbles,
    input           wire                                    i_reset,
    input           wire                                    i_clock
);

    // QUICK INSTANCE: BEGIN
    /*
    ghash_msg_and_h_pow_picker
    #(
        // PARAMETERS
        .NB_BLOCK           ( NB_BLOCK      ),
        .N_BLOCKS           ( N_BLOCKS      ),
        .NB_DATA            ( NB_DATA       ),
        .N_H_POW            ( N_H_POW       ),
        .
    )
    u_ghash_msg_and_h_pow_picker
    (
        // OUTPUTS
        .o_m0               (  ),
        .o_m1               (  ),
        .o_h_pow            (  ),
        // INPUTS
        .i_data             (  ),
        .i_h_key_powers     (  ),
        .i_feedback         (  ),
        .i_mod_prod         (  ),
        .i_stage            (  ),
        .i_hold_msg         (  ),
        .i_skip_msg         (  ),
        .i_last_cycle       (  ),
        .i_valid            (  ),
        .i_msg_bubbles      (  ),
        .i_reset            (  ),
        .i_clock            (  )
    );
    */ // QUICK INSTANCE: END

    // INTERNAL SIGNALS
    reg             [NB_DATA-1:0]               message_buffer[3:0];

    // ALGORITHM MEGIN
    // Message Buffering for Last Cycle
    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            message_buffer[0]   <= { NB_DATA{1'b0} };
            message_buffer[1]   <= { NB_DATA{1'b0} };
            message_buffer[2]   <= { NB_DATA{1'b0} };
            message_buffer[3]   <= { NB_DATA{1'b0} };
        end else if ( i_valid && i_hold_msg ) begin
            message_buffer[0]   <= i_data;
            message_buffer[1]   <= message_buffer[0];
            message_buffer[2]   <= message_buffer[1];
            message_buffer[3]   <= message_buffer[2];
        end
    end
    // Output Calculation            
    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            o_m0            <= { NB_BLOCK{1'b0} };
            o_m1            <= { NB_BLOCK{1'b0} };                                                 
            o_h_pow         <= { NB_DATA{1'b0} };
        end 
        //  ==============  NORMAL OPERATION
        else if ( i_valid ) begin
            if ( !i_last_cycle ) begin                                    
                o_m0        <= i_data[0*NB_BLOCK+:NB_BLOCK];
                o_m1        <= i_data[1*NB_BLOCK+:NB_BLOCK];
                if ( i_stage == 2'd0 )                                  // first_mult 
                    o_h_pow <= i_h_key_powers[3*NB_DATA+:NB_DATA];
                else if ( i_stage == 2'd1 )                             // second_mult
                    o_h_pow <= i_h_key_powers[2*NB_DATA+:NB_DATA];
                else if ( i_stage == 2'd2 )                             // third_mult
                    o_h_pow <= i_h_key_powers[1*NB_DATA+:NB_DATA];
                else if ( i_stage == 2'd3 )                             // fourth_mult
                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                else                                                    // default
                    o_h_pow <= i_h_key_powers[3*NB_DATA+:NB_DATA];
            end
            //  ==============  LAST CYCLE OPERATION
            else begin
                case ( MSG_BUBBLES )
                    0 : begin                       
                        //  --------------  Last 4 messages, wating for skip_bus...
                        if ( i_hold_msg ) begin           
                            o_m0            <= { NB_BLOCK{1'b0} };
                            o_m1            <= { NB_BLOCK{1'b0} };                                                 
                            o_h_pow         <= { NB_DATA{1'b0} };
                        end else begin                      
                            //  --------------  After wating for skip_bus, if not occurs, then normal case0 operation
                            if ( !i_skip_msg ) begin
                                if ( i_stage == 2'd0 )
                                begin: case0_no_skip_msg_first_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK] ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK]; 
                                    o_h_pow <= i_h_key_powers[3*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd1 )
                                begin: case0_no_skip_msg_second_mult
                                    o_m0    <= message_buffer[2][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[2][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[2*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd2 )
                                begin: case0_no_skip_msg_third_mult
                                    o_m0    <= message_buffer[1][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[1][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[1*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd3 )
                                begin: case0_no_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[0][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[0][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else
                                begin: case0_no_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                            end 
                            //  --------------  After wating for skip_bus, if occurs, then...
                            else begin                  
                                if ( i_stage == 2'd0 )
                                begin: case0_skip_msg_first_mult 
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK] ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK]; 
                                    o_h_pow <= { i_h_key_powers[6*NB_BLOCK+:NB_BLOCK], i_h_key_powers[5*NB_BLOCK+:NB_BLOCK] };
                                end else if ( i_stage == 2'd1 ) 
                                begin: case0_skip_msg_second_mult
                                    o_m0    <= message_buffer[2][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[2][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= { i_h_key_powers[4*NB_BLOCK+:NB_BLOCK], i_h_key_powers[3*NB_BLOCK+:NB_BLOCK] };
                                end else if ( i_stage == 2'd2 ) 
                                begin: case0_skip_msg_third_mult
                                    o_m0    <= message_buffer[1][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[1][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= { i_h_key_powers[2*NB_BLOCK+:NB_BLOCK], i_h_key_powers[1*NB_BLOCK+:NB_BLOCK] };
                                end else if ( i_stage == 2'd3 )
                                begin: case0_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[0][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= {NB_BLOCK{1'b0}};      // <--- This is all 0s ( skiped )
                                    o_h_pow <= { i_h_key_powers[0*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else            
                                begin: case0_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} };    
                                end
                            end
                        end   
                    end
                    1 : begin                         
                        //  --------------  Last 4 messages, wating for skip_bus...
                        if ( i_hold_msg ) begin           
                            o_m0            <= { NB_BLOCK{1'b0} };
                            o_m1            <= { NB_BLOCK{1'b0} };                                                 
                            o_h_pow         <= { NB_DATA{1'b0} };
                        end else begin                      
                            //  --------------  After wating for skip_bus, if not occurs, then normal case1 operation
                            if ( !i_skip_msg ) begin
                                if ( i_stage == 2'd0 )
                                begin: case1_no_skip_msg_first_mult
                                    o_m0    <= { NB_BLOCK{1'b0} } ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd1 )
                                begin: case1_no_skip_msg_second_mult
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd2 )
                                begin: case1_no_skip_msg_third_mult
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd3 )
                                begin: case1_no_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else
                                begin: case1_no_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                             end 
                             //  --------------  After wating for skip_bus, if occurs, then...
                             else begin                  
                                if ( i_stage == 2'd0 )
                                begin: case1_skip_msg_first_mult
                                    o_m0    <= { NB_BLOCK{1'b0} } ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { i_h_key_powers[0*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else if ( i_stage == 2'd1 )
                                begin: case1_skip_msg_second_mult
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { NB_DATA{1'b0} };
                                end else if ( i_stage == 2'd2 )
                                begin: case1_skip_msg_third_mult
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { NB_DATA{1'b0} };
                                end else if ( i_stage == 2'd3 )
                                begin: case1_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= {NB_BLOCK{1'b0}};      // <--- This is all 0s ( skiped )
                                    o_h_pow <= { i_h_key_powers[0*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else
                                begin: case1_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                            end
                        end                 end                 2 : begin                 
                        //  --------------  Last 4 messages, wating for skip_bus...
                        if ( i_hold_msg ) begin           
                            o_m0            <= { NB_BLOCK{1'b0} };
                            o_m1            <= { NB_BLOCK{1'b0} };                                                 
                            o_h_pow         <= { NB_DATA{1'b0} };
                        end else begin                      
                            //  --------------  After wating for skip_bus, if not occurs, then normal case2 operation
                            if ( !i_skip_msg ) begin
                                if ( i_stage == 2'd0 )
                                begin: case2_no_skip_msg_first_mult
                                    o_m0    <= { NB_BLOCK{1'b0} } ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= i_h_key_powers[1*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd1 )
                                begin: case2_no_skip_msg_second_mult
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end else if ( i_stage == 2'd2 )
                                begin: case2_no_skip_msg_third_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[1*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd3 )
                                begin: case2_no_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[2][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[2][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else
                                begin: case2_no_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                             end 
                             //  --------------  After wating for skip_bus, if occurs, then...
                             else begin                  
                                if ( i_stage == 2'd0 )
                                begin: case2_skip_msg_first_mult
                                    o_m0    <= { NB_BLOCK{1'b0} } ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { i_h_key_powers[2*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else if ( i_stage == 2'd1 )
                                begin: case2_skip_msg_second_mult
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { NB_DATA{1'b0} };
                                end else if ( i_stage == 2'd2 )
                                begin: case2_skip_msg_third_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= { i_h_key_powers[2*NB_BLOCK+:NB_BLOCK], i_h_key_powers[1*NB_BLOCK+:NB_BLOCK] };
                                end else if ( i_stage == 2'd3 )
                                begin: case2_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[2][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= {NB_BLOCK{1'b0}};      // <--- This is all 0s ( skiped )
                                    o_h_pow <= { i_h_key_powers[0*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else
                                begin: case2_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                            end
                        end
                    end
                    3 : begin                        
                        //  --------------  Last 4 messages, wating for skip_bus...
                        if ( i_hold_msg ) begin           
                            o_m0            <= { NB_BLOCK{1'b0} };
                            o_m1            <= { NB_BLOCK{1'b0} };                                                 
                            o_h_pow         <= { NB_DATA{1'b0} };
                        end else begin
                            //  --------------  After wating for skip_bus, if not occurs, then normal case3 operation                      
                            if ( !i_skip_msg ) begin
                                if ( i_stage == 2'd0 )
                                begin: case3_no_skip_msg_first_mult
                                    o_m0    <= { NB_BLOCK{1'b0} } ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= i_h_key_powers[2*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd1 )
                                begin: case3_no_skip_msg_second_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[2*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd2 )
                                begin: case3_no_skip_msg_third_mult
                                    o_m0    <= message_buffer[2][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[2][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[1*NB_DATA+:NB_DATA];
                                end else if ( i_stage == 2'd3 )
                                begin: case3_no_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[1][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[1][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= i_h_key_powers[0*NB_DATA+:NB_DATA];
                                end else
                                begin: case3_no_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                             end 
                             //  --------------  After wating for skip_bus, if occurs, then...
                             else begin
                                if ( i_stage == 2'd0 )
                                begin: case3_skip_msg_first_mult
                                    o_m0    <= { NB_BLOCK{1'b0} } ^ i_feedback ^ i_mod_prod;
                                    o_m1    <= { NB_BLOCK{1'b0} };
                                    o_h_pow <= { i_h_key_powers[4*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else if ( i_stage == 2'd1 )
                                begin: case3_skip_msg_second_mult
                                    o_m0    <= message_buffer[3][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[3][1*NB_BLOCK+:NB_BLOCK];
                                    o_h_pow <= { i_h_key_powers[4*NB_BLOCK+:NB_BLOCK], i_h_key_powers[3*NB_BLOCK+:NB_BLOCK] };
                                end else if ( i_stage == 2'd2 )
                                begin: case3_skip_msg_third_mult
                                    o_m0    <= message_buffer[2][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= message_buffer[2][1*NB_BLOCK+:NB_BLOCK]; 
                                    o_h_pow <= { i_h_key_powers[2*NB_BLOCK+:NB_BLOCK], i_h_key_powers[1*NB_BLOCK+:NB_BLOCK] };
                                end else if ( i_stage == 2'd3 )
                                begin: case3_skip_msg_fourth_mult
                                    o_m0    <= message_buffer[1][0*NB_BLOCK+:NB_BLOCK];
                                    o_m1    <= {NB_BLOCK{1'b0}};      // <--- This is all 0s ( skiped )
                                    o_h_pow <= { i_h_key_powers[0*NB_BLOCK+:NB_BLOCK], {NB_BLOCK{1'b0}} };
                                end else
                                begin: case3_skip_msg_default
                                    o_m0    <= { NB_BLOCK{1'b0} };
                                    o_m1    <= { NB_BLOCK{1'b0} };                                            
                                    o_h_pow <= { NB_DATA{1'b0} }; 
                                end
                            end
                        end
                    end             
                    default : begin         
                        o_m0        <= { NB_BLOCK{1'b0} };
                        o_m1        <= { NB_BLOCK{1'b0} };                                            
                        o_h_pow     <= { NB_DATA{1'b0} };   
                    end
                endcase
            end
        end
    end

endmodule
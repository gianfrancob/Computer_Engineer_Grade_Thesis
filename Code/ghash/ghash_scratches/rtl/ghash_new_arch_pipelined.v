/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : ghash_new_arch_pipelined.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Nov 16, 2016
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: ghash_new_arch_pipelined.v 10343 2017-01-09 18:17:22Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the GHASH algorithm for GCM-AES.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/
module  ghash_new_arch_pipelined
#(
    //  PARAMETERS
    parameter                                           NB_BLOCK    = 128,                  // Plaintext length. Must be 128
    parameter                                           N_BLOCKS    = 2,                    // Level of paralelism. Must be 2
    parameter                                           NB_DATA     = N_BLOCKS*NB_BLOCK,    // Level of paralelism. Must be 256
    parameter                                           N_H_POW     = 8,                    // Max power of Hash Subkey "H". Must be 8
    parameter                                           N_MESSEGES  = 509                   // Max is 510, but it supports up to 2^10 - 1
)
(
    //  OUTPUTS
    output          wire    [NB_BLOCK-1:0]              o_data_y,                           // Hash
    output          wire                                o_ghash_done,                       // Hash done  
    //  INPUTS
    input           wire    [NB_DATA-1:0]               i_data_x,                           // Plaintext
    input           wire    [NB_BLOCK-1:0]              i_aad,                              // Aditional Authenticated Data
    input           wire    [N_H_POW*NB_BLOCK-1:0]      i_h_key_powers,                     // Powers of Hash Subkey "H" (from H¹ to H⁸)
    input           wire                                i_skip_bus,                         // Signal for skip 128 MSB of Plantext
    input           wire                                i_sop,                              // Start of Plaintext
    input           wire                                i_valid,                            // Valid input signal
    input           wire                                i_reset,                            // Reset signal
    input           wire                                i_clock                             // Clock signal
);

    // ~~~~~~~~~~~  QUICK INSTANCE: BEGIN  ~~~~~~~~~~~
    /*
    ghash_new_arch_pipelined
    #(
        //  PARAMETERS
        .NB_BLOCK           (  ),
        .N_BLOCKS           (  ),
        .NB_DATA            (  ),
        .N_H_POW            (  ),
        .N_MESSEGES         (  )
    )
    u_ghash_new_arch_pipelined
    (
        //  OUTPUTS
        .o_data_y           (  ),
        //  INPUTS
        .i_data_x           (  ),    
        .i_aad              (  ),
        .i_h_key_powers     (  ),        
        .i_skip_bus         (  ),    
        .i_sop              (  ),
        .i_valid            (  ),    
        .i_reset            (  ),    
        .i_clock            (  )
    );
    */ // QUICK INSTANCE: END

    // ~~~~~~~~~~~  LOCAL PARAMETERS  ~~~~~~~~~~~    
    localparam                                          MSG_BUBBLES = f_mod(N_MESSEGES);    // Number or messeges in last cycle
    localparam                                          DELAY1      = 1;
    localparam                                          DELAY4      = 4;
    localparam                                          DELAY10     = 11;

    // ~~~~~~~~~~~  INTERNAL SIGNALS  ~~~~~~~~~~~
    // MISC
    reg                     [9:0]                       count;                              // One extra bit for security
    reg                     [9:0]                       msg_count;                          // One extra bit for security
    reg                     [1:0]                       stage;
    reg                     [1:0]                       stage2;
    integer                                             sop_counter;
    wire                                                int_reset;
    wire                                                int_valid;
    wire                                                take_aad;

    // CONTROL UNIT
    // ---- Control Signals
    wire                                                last_cycle;
    wire                                                skip_msg;
    wire                                                hold_msg;
    wire                                                hash_done;
    // ---- Subproduct Buffering
    reg                     [NB_BLOCK-1:0]              feedback_mux_buff;
    reg                     [NB_BLOCK-1:0]              mod_prod_buff;

    // Stage 0
    wire                    [NB_BLOCK-1:0]              m0;
    wire                    [NB_BLOCK-1:0]              m1;
    wire                    [NB_DATA-1:0]               h_pow_mux;
    wire                    [NB_BLOCK-1:0]              feedback_mux;
    wire                    [NB_BLOCK-1:0]              aad_mux;

    // Pipeline Stage 1
    wire                    [NB_BLOCK-1:0]              stg1_h_pow_even;
    wire                    [NB_BLOCK-1:0]              stg1_h_pow_odd;
    wire                    [NB_BLOCK-1:0]              stg1_feedback_mux;
    wire                    [NB_BLOCK-1:0]              stg1_data_x_even;
    wire                    [NB_BLOCK-1:0]              stg1_data_x_odd;
    wire                                                stg1_stall;
    wire                    [N_BLOCKS-1:0]              stg1_skip_bus;

    // Stage 1
    wire                    [NB_BLOCK-1:0]              even_xor;
    wire                    [NB_DATA-1-1:0]             prod_even;
    wire                    [NB_DATA-1-1:0]             prod_odd;
    wire                                                stg1_stall_d;
    wire                    [N_BLOCKS-1:0]              stg1_skip_bus_d;
    reg                     [DELAY1-1:0]                stg1_stall_shift_reg;


    // Pipeline Stage 2
    wire                    [NB_DATA-1-1:0]             stg2_prod_even;
    wire                    [NB_DATA-1-1:0]             stg2_prod_odd;
    wire                                                stg2_stall;
    wire                    [N_BLOCKS-1:0]              stg2_skip_bus;

    // Stage 2
    reg                     [2*NB_BLOCK-1-1:0]          q[4:0];
    wire                    [NB_BLOCK-1-1:0]            overflow_prod;
    wire                    [NB_BLOCK-1:0]              reminder_prod;
    wire                    [NB_BLOCK-1:0]              mod_prod;

    // Pipeline Stage 3
    wire                    [NB_BLOCK-1:0]              stg3_mod_prod;
    wire                    [NB_BLOCK-1:0]              stg3_feedback;

    // Stage Feedback
    wire                    [NB_BLOCK-1:0]              x_in_feedback;
    wire                    [NB_BLOCK-1:0]              y_in_feedback;
    wire                    [NB_DATA-1-1:0]             prod_feedback;
    wire                    [NB_BLOCK-1-1:0]            overflow_feedback;
    wire                    [NB_BLOCK-1:0]              reminder_feedback;
    wire                    [NB_BLOCK-1:0]              mod_feedback;

    // ~~~~~~~~~~~  ALGORITHM BEGIN  ~~~~~~~~~~~
    // MISC
    always @( posedge i_clock ) begin
        if ( int_reset )
            count   <=  10'd0;
        else if ( int_valid )
            count   <=  count + 10'd1;
    end

    always @( posedge i_clock ) begin
        if ( int_reset )
            stage   <=  2'd0;
        else if ( int_valid ) begin
            stage   <=  (stage + 1'b1);
        end
    end

    // always @( posedge i_clock ) begin
    //     stage <= stage2;
    // end

    assign int_sop      =   ( i_sop & i_valid );
    
    assign int_reset    =   i_reset || int_sop;

    always @( posedge i_clock ) begin
        if ( i_reset || (count==N_MESSEGES) )
            sop_counter <=  0;
        else if ( int_sop )
            sop_counter <=  sop_counter+1;
    end

    always @( posedge i_clock ) begin
        if ( int_reset || (count==N_MESSEGES+9) )
            msg_count   <=  10'd0;
        else if ( i_valid && (sop_counter>0) )
            msg_count   <=  msg_count + 10'd1;
    end

    assign int_valid    =   ( msg_count<N_MESSEGES )        ?
                            ( i_valid && (sop_counter>0) )  :
                            ( ~hash_done )                  ;

    // assign take_aad     =    int_valid & i_sop;
    common_fix_delay_line_w_valid
    #(
        .NB_DATA                    ( 1                         ),
        .DELAY                      ( 1+1                       ) 
    )
    u_common_fix_delay_line_w_valid__c
    (
        .o_data_out                 ( take_aad                  ),
        .i_data_in                  ( int_sop                   ),
        .i_valid                    ( i_valid                   ),
        .i_reset                    ( i_reset                   ),
        .clock                      ( i_clock                   )
    ) ;

    assign o_ghash_done =   hash_done;

    // CONTROL UNIT
    // ---- Control Signal Asignation
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
        .o_last_cycle                   ( last_cycle    ),    
        .o_hold_msg                     ( hold_msg      ),
        .o_hash_done                    ( hash_done     ),
        .o_skip_msg                     ( skip_msg      ),
        // INPUTS
        .i_msg_count                    ( msg_count     ),
        .i_skip_bus                     ( i_skip_bus    ),
        .i_valid                        ( int_valid     ),
        .i_reset                        ( int_reset     ),
        .i_clock                        ( i_clock       )
    );

    // ---- Last couple of results buffering  ( needed for last cycle )
    always @( posedge i_clock ) begin
        if ( int_reset )
            feedback_mux_buff   <=  { NB_BLOCK{1'b0} };
        else if ( int_valid && hold_msg  && ( stage == 2'd1) )
            feedback_mux_buff   <=  feedback_mux;
    end

    always @( posedge i_clock ) begin
        if ( int_reset )
            mod_prod_buff   <=  { NB_BLOCK{1'b0} };
        else if ( int_valid && hold_msg && ( stage == 2'd3) )
            mod_prod_buff   <=  mod_prod;
    end
            
    // ---- Input Rewire
    // -------- Muxes for Accepting AAD and/or Feedback
    assign aad_mux          =   ( take_aad )        ?
                                i_aad               :
                                { NB_BLOCK{1'b0} }  ;

    assign feedback_mux     =   ( (msg_count)%4 == 2'd1 && !take_aad )  ?
                                mod_feedback                            :
                                aad_mux                                 ;
    // always @( /*posedge i_clock*/* ) begin
    //     if ( i_reset )
    //         feedback_mux    =  { NB_BLOCK{1'b0} };
    //     else if ( int_valid )
    //         feedback_mux    =   ( (msg_count)%4 == 2'd1 && !take_aad )  ?
    //                              mod_feedback                            :
    //                              aad_mux                                 ;
    // end
        
    // -------- Multipliers Inputs Decition            
    ghash_msg_and_h_pow_picker
    #(
        // PARAMETERS
        .NB_BLOCK           ( NB_BLOCK          ),
        .N_BLOCKS           ( N_BLOCKS          ),
        .NB_DATA            ( NB_DATA           ),
        .N_H_POW            ( N_H_POW           ),
        .MSG_BUBBLES        ( MSG_BUBBLES       )
    )
    u_ghash_msg_and_h_pow_picker
    (
        // OUTPUTS
        .o_m0               ( m0                ),
        .o_m1               ( m1                ),
        .o_h_pow            ( h_pow_mux         ),        
        // INPUTS
        .i_data             ( i_data_x          ),
        .i_h_key_powers     ( i_h_key_powers    ),
        .i_feedback         ( feedback_mux_buff ),
        .i_mod_prod         ( mod_prod_buff     ),
        .i_stage            ( stage             ),
        .i_hold_msg         ( hold_msg          ),
        .i_skip_msg         ( skip_msg          ),
        .i_last_cycle       ( last_cycle        ),
        .i_valid            ( int_valid         ),
        .i_reset            ( int_reset         ),
        .i_clock            ( i_clock           )
    );

    // ====     Pipeline Stages 1   ====
    ghash_stage1_pipe
    #(
        .NB_BLOCK       ( NB_BLOCK ),
        .N_BLOCKS       ( N_BLOCKS ),
        .NB_DATA        ( NB_DATA )
    )
    u_ghash_stage1_pipe
    (
        .o_h_pow_even   ( stg1_h_pow_even   ),
        .o_h_pow_odd    ( stg1_h_pow_odd    ),
        .o_feedback_mux ( stg1_feedback_mux ),
        .o_data_x_even  ( stg1_data_x_even  ),
        .o_data_x_odd   ( stg1_data_x_odd   ),
        .o_stall        ( stg1_stall        ),
        .i_feedback_mux ( feedback_mux      ),
        .i_data_x_even  ( m0                ),
        .i_data_x_odd   ( m1                ),
        .i_h_pow_pair   ( h_pow_mux         ),
        .i_stall        ( hold_msg          ),
        .i_valid        ( int_valid         ),
        .i_reset        ( int_reset         ),
        .i_clock        ( i_clock           )
    );

    //  ====    Stage 1             ====    Multiplication
    assign even_xor     =   ( last_cycle )                          ?           
                            stg1_data_x_even                        :
                            stg1_data_x_even ^ stg1_feedback_mux    ;

    // Even Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK         ),
        .CREATE_OUTPUT_REG   ( 0                )   
    )
    u_gf_2toN_koa_generated_even
    (
        .o_data_z            ( prod_even        ),
        .i_data_y            ( stg1_h_pow_even  ),
        .i_data_x            ( even_xor         ),
        .i_valid             ( int_valid        ),
        .i_reset             ( int_reset        ),
        .i_clock             ( i_clock          )   
    ) ;

    // Odd Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK         ),
        .CREATE_OUTPUT_REG   ( 0                )   
    )
    u_gf_2toN_koa_generated_odd
    (
        .o_data_z            ( prod_odd         ),
        .i_data_y            ( stg1_h_pow_odd   ),
        .i_data_x            ( stg1_data_x_odd  ),
        .i_valid             ( int_valid        ),
        .i_reset             ( int_reset        ),
        .i_clock             ( i_clock          )   
    ) ;

    // Stage 1 Delay aplied to wire.
    always @( posedge i_clock ) begin
        if ( int_reset )
            stg1_stall_shift_reg    <=  { DELAY1{1'b0} };
        else if ( int_valid )
            stg1_stall_shift_reg    <=  { stg1_stall_shift_reg[DELAY1-1:0], stg1_stall};
    end
    assign stg1_stall_d     =   stg1_stall_shift_reg[DELAY1-1];

    //  ====    Pipeline Stage 2    ====
    ghash_stage2_pipe
    #(
        .NB_BLOCK       ( NB_BLOCK          ),
        .N_BLOCKS       ( N_BLOCKS          ),
        .NB_DATA        ( NB_DATA           )
    )
    u_ghash_stage2_pipe
    (
        .o_prod_even    ( stg2_prod_even    ),
        .o_prod_odd     ( stg2_prod_odd     ),
        .o_stall        ( stg2_stall        ),
        .i_prod_even    ( prod_even         ),
        .i_prod_odd     ( prod_odd          ),
        .i_stall        ( stg1_stall_d      ),
        .i_valid        ( int_valid         ),
        .i_reset        ( int_reset         ),
        .i_clock        ( i_clock           )
    );

    //  ====    Stage 2             ====    Subproducts Accumulation & Modulo Operation
    //  Subproducts Accumulation
    reg stall2;
    always @( posedge i_clock )begin
        stall2 <= stg2_stall;
    end
    always @( * ) begin
        if ( int_reset ) 
            q[0]        =   { (2*NB_BLOCK-1){1'b0} };
        else begin
            if ( ~/*stg2_stall*/stall2 )
                q[0]    =   stg2_prod_even ^ stg2_prod_odd; 
            else
                q[0]    =   { (2*NB_BLOCK-1){1'b0} };
        end 
    end

    always @( posedge i_clock)
    begin: partial_results_registration
        if ( int_reset ) begin
            q[1]        <=  { (2*NB_BLOCK-1){1'b0} };
            q[2]        <=  { (2*NB_BLOCK-1){1'b0} };
            q[3]        <=  { (2*NB_BLOCK-1){1'b0} };
        end else begin
            if ( int_valid )  begin
                q[1]    <=  q[0];
                q[2]    <=  q[1];
                q[3]    <=  q[2];
            end else begin
                q[1]    <=  q[1];
                q[2]    <=  q[2];
                q[3]    <=  q[3];
            end 
        end
    end

    always @( * ) begin
        if ( int_reset )
            q[4]    =   { (2*NB_BLOCK-1){1'b0} };
        else 
            q[4]    =   q[0] ^ q[1] ^ q[2] ^ q[3];     // Acumulator
    end

    // Modulo Operation
    assign overflow_prod    =   q[4][NB_BLOCK-1-1:0];

    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_BLOCK-1    ),
        .NB_DATA            ( NB_BLOCK      )
      )
    u_gf_2to128_multiplier_booth1_subrem_prod
    (
        .o_sub_remainder    ( reminder_prod ),
        .i_data             ( overflow_prod )
     );

    assign mod_prod     =   q[4][2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_prod;

    //  ====    Pipeline Stage 3        ====    
    ghash_stage3_pipe
    #(
        .NB_BLOCK       ( NB_BLOCK          ),
        .N_BLOCKS       ( N_BLOCKS          ),
        .NB_DATA        ( NB_DATA           )
    )
    u_ghash_stage3_pipe
    (
        .o_mod_prod     ( stg3_mod_prod     ),
        .o_feedback     ( stg3_feedback     ),
        .i_mod_prod     ( mod_prod          ),
        .i_feedback     ( stg1_feedback_mux ),
        .i_valid        ( int_valid         ),
        .i_reset        ( int_reset         ),
        .i_clock        ( i_clock           ) 
    );

    //  ====    Stage Feedback          ====    //  Multiplication & Modulo Operation
    // Input rewire
    assign x_in_feedback    =   stg3_mod_prod;
    assign y_in_feedback    =   i_h_key_powers[7*NB_BLOCK+:NB_BLOCK];

    // Feedback Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK         ),
        .CREATE_OUTPUT_REG   ( 0                )   
    )
    u_gf_2toN_koa_generated_feedback
    (
        .o_data_z            ( prod_feedback    ),
        .i_data_y            ( x_in_feedback    ),
        .i_data_x            ( y_in_feedback    ),
        .i_valid             ( int_valid        ),
        .i_reset             ( int_reset        ),
        .i_clock             ( i_clock          )   
    );

    // Feedback Modulo Operation
    assign overflow_feedback    =   prod_feedback[NB_BLOCK-1-1:0] ;

    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_BLOCK-1        ),
        .NB_DATA            ( NB_BLOCK          )
      )
    u_gf_2to128_multiplier_booth1_subrem_feedback
    (
        .o_sub_remainder    ( reminder_feedback ),
        .i_data             ( overflow_feedback )
     ) ;

    assign mod_feedback     =   prod_feedback[2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_feedback ;

     // OUTPUT CALCULATION
    assign o_data_y     =   ( last_cycle  )             ?
                            mod_prod                    : // Xor not needed, mod_prod already includes previus product
                            mod_prod ^ stg3_feedback    ; // Xor between previous product and the one just calculated
    
    
    // SUPPORT FUNCTIONS

    // Calculates the module from the division between N_MESSEGES and 4 (i.e. N_MESSEGES % 4).
    function    automatic   [1:0]   f_mod;
        // Number which modulo needs to be calculated
        input   [1:0]   number;
        begin: function_mod_body
            f_mod   =   number%4;
        end // function_mod_body
    endfunction // f_mod
 
endmodule
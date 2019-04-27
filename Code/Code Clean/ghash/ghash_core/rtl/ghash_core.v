/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : ghash_core.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Nov 16, 2016
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: ghash_core.v 10704 2017-02-22 16:21:41Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the GHASH algorithm for GCM-AES.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/
module  ghash_core
#(
    //  PARAMETERS
    parameter                                                       NB_BLOCK                = 128               ,                 // Plaintext length. Must be 128
    parameter                                                       N_BLOCKS                = 2                 ,                   // Level of paralelism. Must be 2
    parameter                                                       NB_DATA                 = N_BLOCKS*NB_BLOCK ,   // Level of paralelism. Must be 256
    parameter                                                       N_H_POW                 = 8                 ,                   // Max power of Hash Subkey "H". Must be 8
    parameter                                                       NB_N_MESSAGES           = 10                ,   // Max is 510, but it supports up to 2^10 - 1
    parameter                                                       REG_OUTPUT              = 1                     // Must be 1 to close timing at gcm aes top level
)
(
    //  OUTPUTS
    output      reg     [ NB_BLOCK-1:0          ]                   o_data_y                ,   // Hash
    output      reg                                                 o_ghash_done            ,   // Hash done
    output      wire                                                o_err_sop_sync          ,   // Sop sync error
    //  INPUTS
    input       wire    [ NB_DATA-1:0           ]                   i_data_x                ,   // Plaintext
    // input       wire    [NB_DATA-1:0]                               i_aad                   ,   // Aditional Authenticated Data
    input       wire    [ N_H_POW*NB_BLOCK-1:0  ]                   i_h_key_powers          ,   // Powers of Hash Subkey "H" (from H¹ to H⁸)
    input       wire                                                i_skip_bus              ,   // Signal for skip 128 MSB of Plantext
    input       wire                                                i_sop                   ,   // Start of Plaintext
    input       wire                                                i_valid                 ,   // Valid input signal
    input       wire    [ NB_N_MESSAGES-1:0     ]                   i_rf_static_n_messages  ,   // Max is 510, but it supports up to 2^10 - 1
    input       wire    [ NB_N_MESSAGES-1:0     ]                   i_rf_static_n_aad       ,   // Aditional Anauthenticated Data Length
    input       wire                                                i_reset                 ,   // Reset signal
    input       wire                                                i_clock                     // Clock signal
);

// ~~~~~~~~~~~  QUICK INSTANCE: BEGIN  ~~~~~~~~~~~
/*
ghash_core
#(
    //  PARAMETERS
    .NB_BLOCK               (  ),
    .N_BLOCKS               (  ),
    .NB_DATA                (  ),
    .N_H_POW                (  ),
    .NB_N_MESSEGES          (  ),
    .REG_OUTPUT             (  )
)
u_ghash_core
(
    //  OUTPUTS
    .o_data_y               (  ),
    .o_ghash_done           (  ),
    .o_err_sop_sync         (  ),
    //  INPUTS
    .i_data_x               (  ),
    .i_aad                  (  ),
    .i_h_key_powers         (  ),
    .i_skip_bus             (  ),
    .i_sop                  (  ),
    .i_valid                (  ),
    .i_rf_static_n_messages (  ),
    .i_rf_static_n_aad      (  ),
    .i_reset                (  ),
    .i_clock                (  )
) ;
*/ // QUICK INSTANCE: END

// ~~~~~~~~~~~  LOCAL PARAMETERS  ~~~~~~~~~~~
localparam                                                          DELAY1                  = 1     ;
localparam                                                          DELAY4                  = 4     ;
localparam                                                          DELAY10                 = 11    ;
localparam                                                          BLOCK_PROC_PAR          = 4     ;   // Block Processing Parallelim.
localparam                                                          LOG2_BLOCK_PROC_PAR     = 2     ;
localparam          [ LOG2_BLOCK_PROC_PAR-1:0   ]                   ST_STAGE_0              = 2'd0  ;
localparam          [ LOG2_BLOCK_PROC_PAR-1:0   ]                   ST_STAGE_1              = 2'd1  ;
localparam          [ LOG2_BLOCK_PROC_PAR-1:0   ]                   ST_STAGE_2              = 2'd2  ;
localparam          [ LOG2_BLOCK_PROC_PAR-1:0   ]                   ST_STAGE_3              = 2'd3  ;
localparam                                                          LOG2_CYCLE_DELAY        = 4     ;
localparam          [ LOG2_CYCLE_DELAY-1:0      ]                   LAST_CYCLE_DELAY        = 9     ;

// ~~~~~~~~~~~  INTERNAL SIGNALS  ~~~~~~~~~~~
// MISC
wire        [ LOG2_BLOCK_PROC_PAR-1:0               ]               msg_bubbles             ;   // Number or messeges in last cycle
reg         [ NB_N_MESSAGES-1:0                     ]               count                   ;   // One extra bit for security
reg         [ NB_N_MESSAGES-1:0                     ]               msg_count               ;   // One extra bit for security
reg         [ LOG2_BLOCK_PROC_PAR-1:0               ]               stage                   ;
reg                                                                 sop_counter             ;
wire                                                                int_reset               ;
wire                                                                int_valid               ;
// wire                                                                take_aad                ;
wire        [ NB_N_MESSAGES+1-1:0                   ]               msg_count_limit         ;
wire        [ NB_DATA-1:0                           ]               data_in                 ;
wire        [ NB_N_MESSAGES+1-1:0                   ]               n_total_msgs            ;

// CONTROL UNIT
// ---- Control Signals
wire                                                                last_cycle              ;
wire                                                                skip_msg                ;
wire                                                                hold_msg                ;
wire                                                                hash_done               ;
// ---- Subproduct Buffering
reg         [ NB_BLOCK-1:0                          ]               feedback_mux_buff       ;
reg         [ NB_BLOCK-1:0                          ]               mod_prod_buff           ;

// Stage 0
wire        [ NB_BLOCK-1:0                          ]               m0                      ;
wire        [ NB_BLOCK-1:0                          ]               m1                      ;
wire        [ NB_DATA-1:0                           ]               h_pow_mux               ;
wire        [ NB_BLOCK-1:0                          ]               feedback_mux            ;
wire        [ NB_BLOCK-1:0                          ]               aad_mux                 ;

// Pipeline Stage 1
wire        [ NB_BLOCK-1:0                          ]               stg1_h_pow_even         ;
wire        [ NB_BLOCK-1:0                          ]               stg1_h_pow_odd          ;
wire        [ NB_BLOCK-1:0                          ]               stg1_feedback_mux       ;
wire        [ NB_BLOCK-1:0                          ]               stg1_data_x_even        ;
wire        [ NB_BLOCK-1:0                          ]               stg1_data_x_odd         ;
wire                                                                stg1_stall              ;

// Stage 1
wire        [ NB_BLOCK-1:0                          ]               even_xor                ;
wire        [ NB_DATA-1-1:0                         ]               prod_even               ;
wire        [ NB_DATA-1-1:0                         ]               prod_odd                ;
wire                                                                stg1_stall_d            ;
reg         [ DELAY1-1:0                            ]               stg1_stall_shift_reg    ;


// Pipeline Stage 2
wire        [ NB_DATA-1-1:0                         ]               stg2_prod_even          ;
wire        [ NB_DATA-1-1:0                         ]               stg2_prod_odd           ;
wire                                                                stg2_stall              ;

// Stage 2
reg         [ 2*NB_BLOCK-1-1:0                      ]               q[4:0]                  ;
wire        [ NB_BLOCK-1-1:0                        ]               overflow_prod           ;
wire        [ NB_BLOCK-1:0                          ]               reminder_prod           ;
wire        [ NB_BLOCK-1:0                          ]               mod_prod                ;

// Pipeline Stage 3
wire        [ NB_BLOCK-1:0                          ]               stg3_mod_prod           ;
wire        [ NB_BLOCK-1:0                          ]               stg3_feedback           ;

// Stage Feedback
wire        [ NB_BLOCK-1:0                          ]               x_in_feedback           ;
wire        [ NB_BLOCK-1:0                          ]               y_in_feedback           ;
wire        [ NB_DATA-1-1:0                         ]               prod_feedback           ;
wire        [ NB_BLOCK-1-1:0                        ]               overflow_feedback       ;
wire        [ NB_BLOCK-1:0                          ]               reminder_feedback       ;
wire        [ NB_BLOCK-1:0                          ]               mod_feedback            ;


// ~~~~~~~~~~~  ALGORITHM BEGIN  ~~~~~~~~~~~
// MISC
assign int_sop      = i_sop & i_valid   ;

assign int_reset    = i_reset | int_sop ;

assign n_total_msgs = i_rf_static_n_messages + i_rf_static_n_aad    ;
// assign  n_total_msgs    = i_rf_static_n_messages                ;

assign msg_bubbles  = n_total_msgs[LOG2_BLOCK_PROC_PAR-1:0] ;

always @( posedge i_clock ) begin
    if ( int_reset )    // cad_ence map_to_mux
        count   <= { NB_N_MESSAGES{1'b0} }  ;
    else if ( int_valid )
        count   <= count + 1'd1             ;  // [HINT] Mismatch and carry drop intentional.
end

always @( posedge i_clock ) begin
    if ( int_reset )    // cad_ence map_to_mux
        stage   <= { LOG2_BLOCK_PROC_PAR{1'b0} }    ;
    else if ( int_valid ) begin
        stage   <= (stage + 1'b1)                   ; // [HINT] Mismatch and carry drop intentional.
    end
end

always @( posedge i_clock ) begin
    if ( i_reset || o_ghash_done /*(count==n_total_msgs)*/ ) // cad_ence map_to_mux
        sop_counter <= 1'b0 ;
    else if ( int_sop )
        sop_counter <= 1'b1 ;
end

assign msg_count_limit = n_total_msgs+LAST_CYCLE_DELAY  ;

always @( posedge i_clock ) begin
    if ( int_reset || (count==msg_count_limit) )    // cad_ence map_to_mux
        msg_count   <=  { NB_N_MESSAGES{1'b0} }   ;
    else if ( i_valid && sop_counter )
        msg_count   <=  msg_count + 1'b1            ;
end

assign int_valid    =   ( msg_count<n_total_msgs )  ?   // cad_ence map_to_mux
                        (i_valid & sop_counter) : ~hash_done    ;

assign o_err_sop_sync   =   ( ~|n_total_msgs )  ?  // FIXME: Add output port. Add laathed vesion (better to add a counter (8bits?)). Add clear flag port.
                            sop_counter & i_sop : 1'b0  ;



// CONTROL UNIT
// ---- Control Signal Asignation
ghash_control_signal_unit
#(
    // PARAMETERS
    .NB_N_MESSAGES              ( NB_N_MESSAGES             ),
    .LOG2_BLOCK_PROC_PAR        ( LOG2_BLOCK_PROC_PAR       ),
    .HOLD_MSG_DELAY             ( DELAY4                    ),
    .HASH_DONE_DELAY            ( DELAY10                   )
)
u_ghash_control_signal_unit
(
    // OUTPUTS
    .o_last_cycle               ( last_cycle                ),
    .o_hold_msg                 ( hold_msg                  ),
    .o_hash_done                ( hash_done                 ),
    .o_skip_msg                 ( skip_msg                  ),
    // INPUTS
    .i_msg_count                ( msg_count                 ),
    .i_skip_bus                 ( i_skip_bus                ),
    .i_valid                    ( int_valid                 ),
    .i_rf_static_n_messages     ( n_total_msgs              ),
    .i_msg_bubbles              ( msg_bubbles               ),
    .i_reset                    ( int_reset                 ),
    .i_clock                    ( i_clock                   )
);
reg feedback_buff_done;
// ---- Last couple of results buffering  ( needed for last cycle )
always @( posedge i_clock ) begin
    if ( int_reset )    // cad_ence map_to_mux
    begin
        feedback_mux_buff   <=  { NB_BLOCK{1'b0} }  ;
        feedback_buff_done  <=  1'b0                ;
    end
    else if ( /*int_valid &&*/ hold_msg  && ( stage == ST_STAGE_1 ) && ~feedback_buff_done )
    begin
        feedback_mux_buff   <=  feedback_mux        ;
        feedback_buff_done  <=  1'b1                ;
    end
end

reg mod_prod_buff_done;
always @( posedge i_clock ) begin
    if ( int_reset )    // cad_ence map_to_mux
    begin
        mod_prod_buff       <=  { NB_BLOCK{1'b0} }  ;
        mod_prod_buff_done  <=  1'b0                ;
    end
    else if ( /*int_valid &&*/ hold_msg && ( stage == ST_STAGE_3 ) && ~mod_prod_buff_done )
    begin
        mod_prod_buff       <=  mod_prod            ;
        mod_prod_buff_done  <=  1'b1                ;
    end
end

// ---- Input Rewire
assign  feedback_mux    =   ( (msg_count)%BLOCK_PROC_PAR == 2'd1 )  ?   // cad_ence map_to_mux
                            mod_feedback : { NB_BLOCK{1'b0} }       ;

// -------- Multipliers Inputs Decition
ghash_msg_and_h_pow_picker
#(
    // PARAMETERS
    .NB_BLOCK               ( NB_BLOCK              ),
    .N_BLOCKS               ( N_BLOCKS              ),
    .NB_DATA                ( NB_DATA               ),
    .N_H_POW                ( N_H_POW               ),
    .LOG2_BLOCK_PROC_PAR    ( LOG2_BLOCK_PROC_PAR   )
)
u_ghash_msg_and_h_pow_picker
(
    // OUTPUTS
    .o_m0                   ( m0                    ),
    .o_m1                   ( m1                    ),
    .o_h_pow                ( h_pow_mux             ),
    // INPUTS
    .i_data                 ( i_data_x              ),
    .i_h_key_powers         ( i_h_key_powers        ),
    .i_feedback             ( feedback_mux_buff     ),
    .i_mod_prod             ( mod_prod_buff         ),
    .i_stage                ( stage                 ),
    .i_hold_msg             ( hold_msg              ),
    .i_skip_msg             ( skip_msg              ),
    .i_last_cycle           ( last_cycle            ),
    .i_valid                ( int_valid             ),
    .i_msg_bubbles          ( msg_bubbles           ),
    .i_reset                ( int_reset             ),
    .i_clock                ( i_clock               )
);

// ====     Pipeline Stages 1   ====
ghash_stage1_pipe
#(
    .NB_BLOCK       ( NB_BLOCK          ),
    .N_BLOCKS       ( N_BLOCKS          ),
    .NB_DATA        ( NB_DATA           )
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
assign even_xor     =   ( last_cycle )      ?   // cad_ence map_to_mux
                        stg1_data_x_even    : stg1_data_x_even ^ stg1_feedback_mux ;

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
);

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
);

// Stage 1 Delay aplied to wire.
always @( posedge i_clock ) begin
    if ( int_reset )    // cad_ence map_to_mux
        stg1_stall_shift_reg    <= { DELAY1{1'b0} }                                 ;
    else if ( int_valid )
        stg1_stall_shift_reg    <= { stg1_stall_shift_reg[DELAY1-1:0], stg1_stall } ;
end
assign  stg1_stall_d    = stg1_stall_shift_reg[DELAY1-1]    ;


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
reg stall2 ;

always @( posedge i_clock )begin
    stall2 <= stg2_stall ;
end

always @( * ) begin
    if ( int_reset )    // cad_ence map_to_mux
        q[0]        =   { (2*NB_BLOCK-1){1'b0} }        ;
    else
    begin
        if ( ~stall2 )  // cad_ence map_to_mux
            q[0]    =   stg2_prod_even ^ stg2_prod_odd  ;
        else
            q[0]    =   { (2*NB_BLOCK-1){1'b0} }        ;
    end
end

always @( posedge i_clock)
begin: partial_results_registration
    if ( int_reset )    // cad_ence map_to_mux
    begin
        q[1]        <= { (NB_DATA-1){1'b0} }    ;
        q[2]        <= { (NB_DATA-1){1'b0} }    ;
        q[3]        <= { (NB_DATA-1){1'b0} }    ;
    end else
    begin
        if ( int_valid )    // cad_ence map_to_mux
        begin
            q[1]    <= q[0]                     ;
            q[2]    <= q[1]                     ;
            q[3]    <= q[2]                     ;
        end else
        begin
            q[1]    <= q[1]                     ;
            q[2]    <= q[2]                     ;
            q[3]    <= q[3]                     ;
        end
    end
end

always @( * )
begin
    if ( int_reset )    // cad_ence map_to_mux
        q[4]    = { (NB_DATA-1){1'b0} }     ;
    else
        q[4]    = q[0] ^ q[1] ^ q[2] ^ q[3] ;   // Acumulator
end

// Modulo Operation
assign overflow_prod    = q[4][NB_BLOCK-1-1:0]  ;

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

assign mod_prod     = q[4][2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_prod   ;

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
assign x_in_feedback    = stg3_mod_prod                         ;
assign y_in_feedback    = i_h_key_powers[7*NB_BLOCK+:NB_BLOCK]  ;

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
assign overflow_feedback    = prod_feedback[NB_BLOCK-1-1:0] ;

gf_2to128_multiplier_booth1_subrem
#(
    .N_SUBPROD          ( NB_BLOCK-1        ),
    .NB_DATA            ( NB_BLOCK          )
)
u_gf_2to128_multiplier_booth1_subrem_feedback
(
    .o_sub_remainder    ( reminder_feedback ),
    .i_data             ( overflow_feedback )
);

assign mod_feedback = prod_feedback[2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_feedback  ;

 // OUTPUT CALCULATION
generate
    if( REG_OUTPUT == 1 )
    begin
        always @( posedge i_clock )
        begin
            if ( int_reset )
                o_data_y    <= { NB_BLOCK{1'b0} }       ;
            else if ( last_cycle)
                o_data_y    <= mod_prod                 ;   // Xor not needed, mod_prod already includes previus product
            else
                o_data_y    <= mod_prod ^ stg3_feedback ;   // Xor between previous product and the one just calculated
        end

        always @( posedge i_clock )
        begin
            if ( int_reset )
                o_ghash_done    <= 1'b0         ;
            else
                o_ghash_done    <= hash_done    ;
        end
    end
    else
    begin
        always @( * )
        begin
            if ( int_reset )
                o_data_y    = { NB_BLOCK{1'b0} }        ;
            else if ( last_cycle)
                o_data_y    = mod_prod                  ;   // Xor not needed, mod_prod already includes previus product
            else
                o_data_y    = mod_prod ^ stg3_feedback  ;   // Xor between previous product and the one just calculated
        end

        always @( * )
        begin
            if ( int_reset )
                o_ghash_done    = 1'b0      ;
            else
                o_ghash_done    = hash_done ;
        end
    end
endgenerate

endmodule
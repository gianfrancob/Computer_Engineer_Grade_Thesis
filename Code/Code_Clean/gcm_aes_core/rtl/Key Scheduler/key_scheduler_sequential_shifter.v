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
 -- $Id: key_scheduler_sequential_shifter.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module key_scheduler_sequential_shifter
#(
    parameter                                                           NB_BYTE             = 8     ,
    parameter                                                           N_BYTES_STATE       = 16    ,
    parameter                                                           N_BYTES_KEY         = 32    ,
    parameter                                                           N_ROUNDS            = 14
)
(
    output  reg     [ N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0    ]       o_round_key_vector  ,
    output  reg                                                         o_output_ready      ,
    input   wire    [ N_BYTES_KEY*NB_BYTE-1:0   ]                       i_key               ,
    input   wire                                                        i_trigger_schedule  ,
    input   wire                                                        i_valid             ,
    input   wire                                                        i_reset             ,
    input   wire                                                        i_clock
) ;

/* // BEGIN: Quick instance.
key_scheduler_sequential_shifter
#(
    .NB_BYTE                    ( NB_BYTE       ),
    .N_BYTES_STATE              ( N_BYTES       ),
    .N_BYTES_KEY                ( N_BYTES_KEY   ),
    .N_ROUNDS                   ( N_ROUNDS      )
)
u_key_scheduler_sequential_shifter
(
    .o_round_key_vector         (               ),
    .i_key                      (               ),
    .i_trigger_schedule         (               ),
    .i_valid                    ( i_valid       ),
    .i_reset                    ( i_reset       ),
    .i_clock                    ( i_clock       )
) ;
// END: Quick instance. */


// LOCAL PARAMETERS.
localparam                                                  N_BYTES_WORD        = 4                                     ;
localparam                                                  NB_WORD             = N_BYTES_WORD * NB_BYTE                ;
localparam                                                  NK                  = N_BYTES_KEY / N_BYTES_WORD            ;   // 8.
localparam                                                  N_STATE_WORDS       = N_BYTES_STATE / N_BYTES_WORD          ;   // 4.
localparam                                                  NB_KEY_VECTOR       = N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)    ;
localparam                                                  N_WORDS             = N_STATE_WORDS                         ;
localparam                                                  BAD_CONF            = ( NB_BYTE != 8 )                      ;
localparam                                                  NB_INDEX_BUS        = 4                                     ;   // Should be big enough to count up to N_ROUNDS.
localparam                                                  COMPLE_CASE_INDEX   = 4                                     ;
localparam                                                  NB_INDEX_WORD       = NB_INDEX_BUS + 3                      ;
localparam      [ NB_INDEX_BUS-1:0  ]                       START_INDEX_BUS     = 2                                     ;
localparam      [ NB_INDEX_BUS-1:0  ]                       FINAL_INDEX_BUS     = N_ROUNDS+1                            ;


// INTERNAL SIGNALS.
genvar                                                                          ii                      ;
reg             [ NB_WORD*N_STATE_WORDS*(N_ROUNDS+1)-1:0    ]                   key_word_bus            ;
reg             [ NB_WORD-1:0                               ]                   key_word_n_m_1          ;
reg             [ NB_WORD*N_WORDS-1:0                       ]                   key_word_n_m_nk_bus     ;
wire            [ NB_WORD*N_WORDS-1:0                       ]                   key_word_n_bus          ;
integer                                                                         ia                      ;
reg             [ NB_INDEX_BUS-1:0                          ]                   index_bus               ;
wire            [ NB_INDEX_WORD-1:0                         ]                   index_word              ;
wire                                                                            index_bus_at_limit      ;
reg                                                                             index_bus_at_limit_d    ;
reg                                                                             started                 ;

// ALGORITHM BEGIN.

always @( posedge i_clock )
begin
    if ( i_reset | o_output_ready )
        started = 1'b0  ;
    else if ( i_trigger_schedule && i_valid)
        started = 1'b1  ;
end


// Create a bus index to direct which part of the word-bus will be calculated.
always @( posedge i_clock )
begin : l_index_sequencer
    if ( i_reset || ( i_valid && i_trigger_schedule ) ) // cad_ence map_to_mux
        index_bus   <= START_INDEX_BUS  ;
    else if ( i_valid && started && !index_bus_at_limit )
        index_bus   <= index_bus + 1'b1 ;   // [HINT] Carry drop and size mismatch intentional.
end // l_index_sequencer
assign  index_bus_at_limit  = ( index_bus >= FINAL_INDEX_BUS )  ;
assign  index_word          = N_WORDS * index_bus               ; // [HINT] Mismatch and MSB drop intentional.

always @( posedge i_clock )
begin
    if ( i_reset )  // cad_ence map_to_mux
    begin
        index_bus_at_limit_d    <= 1'b0                                         ;
        o_output_ready          <= 1'b0                                         ;
    end
    else if ( i_valid /*&& started*/ )
    begin
        index_bus_at_limit_d    <= index_bus_at_limit                           ;
        o_output_ready          <= index_bus_at_limit & ~index_bus_at_limit_d   ;
    end
end


always @( posedge i_clock )
begin
    if ( i_reset || ( i_valid && i_trigger_schedule ) ) // cad_ence map_to_mux
        key_word_bus    <= { { NB_WORD*N_STATE_WORDS*(N_ROUNDS-1){1'b0} }, i_key }                                          ;
    else if ( i_valid && started && !index_bus_at_limit )
        key_word_bus    <= { key_word_bus[ NB_WORD*N_STATE_WORDS*(N_ROUNDS+1) - NB_WORD*N_WORDS - 1 : 0 ], key_word_n_bus } ;
end


// Select inputs for calculating the current key-words.
always @( * )
    key_word_n_m_1  = key_word_bus[ 0 +: NB_WORD ]  ;


// Select inputs for calculating the current key-words.
always @( * )
    key_word_n_m_nk_bus = key_word_bus[ NK*NB_WORD - 1 -: N_WORDS*NB_WORD ] ;


// Calculate words for the current section of the bus.
key_scheduler_sequential_nwords
#(
    .N_WORDS                ( N_WORDS               ),
    .NB_BYTE                ( NB_BYTE               ),
    .N_BYTES_STATE          ( N_BYTES_STATE         ),
    .N_BYTES_KEY            ( N_BYTES_KEY           ),
    .N_ROUNDS               ( N_ROUNDS              ),
    .N_BYTES_WORD           ( N_BYTES_WORD          ),
    .NB_WORD                ( NB_WORD               ),
    .NB_INDEX               ( NB_INDEX_WORD         ),
    .COMPLE_CASE_INDEX      ( COMPLE_CASE_INDEX     )
)
u_key_scheduler_sequential_nwords
(
    .o_key_word_n_bus       ( key_word_n_bus        ),
    .i_key_word_n_m_1       ( key_word_n_m_1        ),
    .i_key_word_n_m_nk_bus  ( key_word_n_m_nk_bus   ),
    .i_index                ( index_word            ),
    .i_valid                ( i_valid & started     ),
    .i_reset                ( i_reset               ),
    .i_clock                ( i_clock               )
) ;


// Rewire output.
always @( * )
begin : l_fliping_rewire
    for ( ia=0; ia<(N_ROUNDS+1); ia=ia+1 )
        o_round_key_vector[ ia*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]
            = key_word_bus[ (N_ROUNDS+1-1-ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]  ;
end // l_fliping_rewire


endmodule // key_scheduler

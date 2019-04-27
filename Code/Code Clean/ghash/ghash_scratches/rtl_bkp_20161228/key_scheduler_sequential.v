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
 -- $Id: key_scheduler_sequential.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module key_scheduler_sequential
#(
    parameter                                                   NB_BYTE             = 8 ,
    parameter                                                   N_BYTES_STATE       = 16 ,
    parameter                                                   N_BYTES_KEY         = 32 ,
    parameter                                                   N_ROUNDS            = 14
)
(
    output  reg     [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    o_round_key_vector ,
    input   wire    [N_BYTES_KEY*NB_BYTE-1:0]                   i_key ,
    input   wire                                                i_trigger_schedule ,
    input   wire                                                i_valid ,
    input   wire                                                i_reset ,
    input   wire                                                i_clock
) ;

    /* // BEGIN: Quick instance.
    key_scheduler_sequential
    #(
        .NB_BYTE                    ( NB_BYTE       ),
        .N_BYTES_STATE              ( N_BYTES       ),
        .N_BYTES_KEY                ( N_BYTES_KEY   ),
        .N_ROUNDS                   ( N_ROUNDS      )
    )
    u_key_scheduler_sequential
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
    localparam                                                  N_BYTES_WORD        = 4 ;
    localparam                                                  NB_WORD             = N_BYTES_WORD * NB_BYTE ;
    localparam                                                  NK                  = N_BYTES_KEY / N_BYTES_WORD ;      // 8.
    localparam                                                  N_STATE_WORDS       = N_BYTES_STATE / N_BYTES_WORD ;    // 4.
    localparam                                                  NB_KEY_VECTOR       = N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1) ;
    localparam                                                  N_WORDS             = N_STATE_WORDS ;
    localparam                                                  BAD_CONF            = ( NB_BYTE != 8 ) ;

    localparam                                                  NB_INDEX_BUS        = 4 ;   // Should be big enough to count up to N_ROUNDS.
    localparam                                                  COMPLE_CASE_INDEX   = 4 ;
    localparam                                                  NB_INDEX_WORD       = NB_INDEX_BUS + 3 ;
    localparam      [NB_INDEX_BUS-1:0]                          START_INDEX_BUS     = 2 ;


    // INTERNAL SIGNALS.
    genvar                                                      ii ;
    wire            [NB_WORD*N_STATE_WORDS*(N_ROUNDS+1)-1:0]    key_word_bus ;
    wire            [NB_WORD*NK-1:0]                            key_word_bus_a ;
    reg             [NB_WORD*(N_WORDS*(N_ROUNDS+1)-NK)-1:0]     key_word_bus_b ;
    reg             [NB_WORD-1:0]                               key_word_n_m_1 ;
    reg             [NB_WORD*N_WORDS-1:0]                       key_word_n_m_nk_bus ;
    wire            [NB_WORD*N_WORDS-1:0]                       key_word_n_bus ;
    integer                                                     ia ;
    reg             [NB_INDEX_BUS-1:0]                          index_bus ;
    wire            [NB_INDEX_WORD-1:0]                         index_word ;
    wire                                                        index_bus_at_limit ;
    reg                                                         vld_clk_div2 ;




    // ALGORITHM BEGIN.


    // First part of the bus is just the key.
    assign  key_word_bus_a
                = i_key ;


    // Create a clock divider to allow piped operation.
    always @( posedge i_clock )
    begin : l_clock_div
        if ( i_reset || ( i_valid && i_trigger_schedule ) )
            vld_clk_div2
                <= 1'b0 ;
        else if ( i_valid )
            vld_clk_div2
                <= ~vld_clk_div2 ;
    end // l_clock_div


    // Create a bus index to direct which part of the word-bus will be calculated.
    always @( posedge i_clock )
    begin : l_index_sequencer
        if ( i_reset || ( i_valid && i_trigger_schedule ) )
            index_bus
                <= START_INDEX_BUS ;
        else if ( i_valid && !index_bus_at_limit && vld_clk_div2 )
            index_bus
                <= index_bus + 1'b1 ;   // [HINT] Carry drop and size mismatch intentional.
    end // l_index_sequencer
    assign  index_bus_at_limit
                = ( index_bus >= N_ROUNDS ) ;
    assign  index_word
                = N_WORDS * index_bus ; // [HINT] Mismatch and MSB drop intentional.


    // Select inputs for calculating the current key-words.
    always @( posedge i_clock )
        if ( i_reset )
            key_word_n_m_1
                <= {NB_WORD{1'b0}} ;
        else if ( i_valid )
            key_word_n_m_1
                <= key_word_bus[ N_STATE_WORDS*(N_ROUNDS+1)*NB_WORD - index_bus*(N_WORDS*NB_WORD) +: NB_WORD ] ;


    // Select inputs for calculating the current key-words.
    always @( posedge i_clock )
        if ( i_reset )
            key_word_n_m_nk_bus
                <= {N_WORDS*NB_WORD{1'b0}} ;
        else if ( i_valid )
            key_word_n_m_nk_bus
                <= key_word_bus[ N_STATE_WORDS*(N_ROUNDS+1)*NB_WORD - index_bus*(N_WORDS*NB_WORD) + NK*NB_WORD - 1 -: N_WORDS*NB_WORD ] ;


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
        .i_valid                ( i_valid               ),
        .i_reset                ( i_reset               ),
        .i_clock                ( i_clock               )
    ) ;


    // Save the current words in a buffer.
    always @( posedge i_clock )
    begin : l_pipe_reg
        if ( i_reset )
            key_word_bus_b
                <= {NB_WORD*N_STATE_WORDS*(N_ROUNDS+1)-NK*NB_WORD{1'b0}} ;
        else if ( i_valid )
            key_word_bus_b[ N_STATE_WORDS*(N_ROUNDS+1)*NB_WORD - index_bus*(N_WORDS*NB_WORD) - 1 -: N_WORDS*NB_WORD ]
                <=  key_word_n_bus ;
    end // l_pipe_reg
    assign  key_word_bus
                = { key_word_bus_a, key_word_bus_b } ;


    // Rewire output.
    always @( * )
    begin : l_fliping_rewire
        for ( ia=0; ia<(N_ROUNDS+1); ia=ia+1 )
            o_round_key_vector[ (             ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]
                = key_word_bus[ (N_ROUNDS+1-1-ia)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ] ;
    end // l_fliping_rewire



endmodule // key_scheduler

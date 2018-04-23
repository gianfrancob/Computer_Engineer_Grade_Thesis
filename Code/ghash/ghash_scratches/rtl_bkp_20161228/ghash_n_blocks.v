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
 -- $Id: ghash_n_blocks.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the round ladder required by the AES
    cipher algorithm.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ghash_n_blocks
#(
    // PARAMETERS.
    parameter                                       NB_BLOCK        = 128 ,
    parameter                                       N_BLOCKS        = 2 ,
    parameter                                       LOG2_N_BLOCKS   = 1 ,
    parameter                                       NB_DATA         = (N_BLOCKS*NB_BLOCK)
)
(
    // OUTPUTS.
    output  wire    [NB_BLOCK-1:0]                  o_data_y ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]                   i_data_x_bus ,      // Plaintext words
    input   wire    [NB_BLOCK-1:0]                  i_data_x_initial ,
    input   wire    [NB_BLOCK-1:0]                  i_hash_subkey_h ,
    input   wire                                    i_sop ,             // Start of plaintext
    input   wire                                    i_valid ,
    input   wire    [N_BLOCKS-1:0]                  i_skip_bus ,        // Added to handle text wich are not multiple of 256 bits.
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;


    // QUICK INSTANCE: BEGIN.
    /* ghash_n_blocks
    #(
        .NB_BLOCK           (   ),
        .N_BLOCKS           (   ),
        .NB_DATA            (   )
    )
    u_ghash_n_blocks
    (
        .o_data_y           (   ),
        .i_data_x_bus       (   ),
        .i_data_x_initial   (   ),
        .i_hash_subkey_h    (   ),
        .i_sop              (   ),
        .i_valid            (   ),
        .i_skip_bus         (   ),
        .i_reset            (   ),
        .i_clock            (   )
    ) ; */ // QUICK INSTANCE: END.


    // LOCAL PARAMETERS.
    localparam                                      BAD_CONF    = ( NB_BLOCK!=128 ) ;

    // INTERNAL SIGNALS.
    genvar                                          ii ;
    integer                                         i ;
    reg             [NB_BLOCK-1:0]                  data_x_prev_final_d ;
    wire            [NB_BLOCK-1:0]                  data_x_array [ N_BLOCKS+1-1:0 ] ;
    reg             [LOG2_N_BLOCKS-1:0]             skip_bus_encoded ;


    // ALGORITHM BEGIN.

    // Counter block for first block.
    assign  data_x_array[ 0 ]
                = ( i_sop )? i_data_x_initial : data_x_prev_final_d ;


    generate
        for ( ii=0; ii<N_BLOCKS; ii=ii+1 )
        begin : genfor_ghash_base

            // Local signals.
            wire    [NB_BLOCK-1:0]                  ii_o_data_y ;
            wire    [NB_BLOCK-1:0]                  ii_i_data_x ;
            wire    [NB_BLOCK-1:0]                  ii_i_data_x_prev ;

            // Get an input block (and previous one).
            assign  ii_i_data_x
                        = i_data_x_bus[ ii*NB_BLOCK +: NB_BLOCK ] ;
            assign  ii_i_data_x_prev
                        = data_x_array[ ii ] ;

            // GHAS core operation (x-or with previous output and H product).
            ghash_core
            #(
                .NB_DATA        ( NB_BLOCK          )
            )
            u_ghash_core_ii
            (
                .o_data_y       ( ii_o_data_y       ),
                .i_data_x       ( ii_i_data_x       ),
                .i_data_x_prev  ( ii_i_data_x_prev  ),
                .i_h_key        ( i_hash_subkey_h   ),
                .i_valid        ( i_valid           ),
                .i_reset        ( i_reset           ),
                .i_clock        ( i_clock           )
            ) ;

            // Use current output as "previous output" for next stage..
            assign  data_x_array[ ii+1 ]
                        = ( i_skip_bus[ ii ] )? ii_i_data_x_prev : ii_o_data_y ;

        end // genfor_ghash_base
    endgenerate


    // Save last output block (to use in the first round).
    always @( posedge i_clock )
    begin : l_keep_last_outblock
        if ( i_reset )
            data_x_prev_final_d
                <= {NB_BLOCK{1'b0}} ;
        else if ( i_valid )
            data_x_prev_final_d
                <= data_x_array[ N_BLOCKS ] ;
    end // l_keep_last_outblock


    always @( * )
    begin : l_skip_encoder
        skip_bus_encoded
            = {LOG2_N_BLOCKS{1'b0}} ;
        for ( i=0; i<N_BLOCKS; i=i+1 )
            if ( i_skip_bus[ N_BLOCKS-1-i ] == 1'b1 )
                skip_bus_encoded
                    = i[ LOG2_N_BLOCKS-1:0 ] + 1'b1 ;
    end // l_skip_encoder


    // Output assignment.
    assign  o_data_y
             // = data_x_prev_final_d /*data_x_array[ N_BLOCKS - skip_bus_encoded ] */; // FIXME: Preguntar a Gian para que hizo este cambio.
                = data_x_array[ N_BLOCKS - skip_bus_encoded ] ;                         // FIXME: Cambio revertido (ver fixme previo).


endmodule // ghash_n_blocks

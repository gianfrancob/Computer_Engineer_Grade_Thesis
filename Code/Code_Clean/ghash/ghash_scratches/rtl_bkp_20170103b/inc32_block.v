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
 -- $Id: inc32_block.v 10397 2017-01-13 19:10:25Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {03} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module inc32_block
#(
    // PARAMETERS.
    parameter                                   NB_BLOCK    = 128 ,
    parameter                                   NB_MODE     = 2
)
(
    // OUTPUTS.
    output  reg     [NB_BLOCK-1:0]              o_block ,
    // INPUTS.
    input   wire    [NB_BLOCK-1:0]              i_block ,
    input   wire    [NB_MODE-1:0]               i_rf_static_mode
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_BLOCK!=128 ) ;
    localparam      [NB_MODE-1:0]               MODE_INC32  = 0 ;
    localparam      [NB_MODE-1:0]               MODE_INC64  = 1 ;
    localparam      [NB_MODE-1:0]               MODE_PRBS   = 2 ;   // FIXME: This mode must be implemented.
    localparam                                  NB_32       = 32 ;
    localparam                                  NB_64       = 64 ;


    // INTERNAL SIGNALS.
    wire            [NB_32-1:0]                 word32_tail ;
    wire            [NB_BLOCK-NB_32-1:0]        word32_head ;
    wire            [NB_64-1:0]                 word64_tail ;
    wire            [NB_BLOCK-NB_64-1:0]        word64_head ;


    // ALGORITHM BEGIN.

    assign  word32_tail
                = i_block[NB_32-1:0] + 1'b1 ;
    assign  word32_head
                = i_block[NB_BLOCK-1:NB_32] ;

    assign  word64_tail
                = i_block[NB_64-1:0] + 1'b1 ;
    assign  word64_head
                = i_block[NB_BLOCK-1:NB_64] ;


    always @( * )
    begin : l_out_mux
        if ( i_rf_static_mode==MODE_INC32 )
            o_block
                = { word32_head, word32_tail } ;
        else
            o_block
                = { word64_head, word64_tail } ;
    end // l_out_mux


endmodule // inc32_block

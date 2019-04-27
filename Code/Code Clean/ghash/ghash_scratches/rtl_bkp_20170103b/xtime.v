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
 -- $Id: xtime.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module xtime
#(
    // PARAMETERS.
    parameter                                   NB_BYTE     = 8
)
(
    // OUTPUTS.
    output  wire    [NB_BYTE - 1 : 0]           o_byte ,
    // INPUTS.
    input   wire    [NB_BYTE - 1 : 0]           i_byte
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_BYTE != 8 ) ;
    localparam      [NB_BYTE - 1 : 0]           M_X         = 8'h1b ;

    // INTERNAL SIGNALS.
    // None so far.


    // ALGORITHM BEGIN.

    assign  o_byte
                = ( i_byte[NB_BYTE-1]==1'b0 )? {i_byte[NB_BYTE-1-1:0],1'b0} : ({i_byte[NB_BYTE-1-1:0],1'b0} ^ M_X) ;

endmodule // xtime

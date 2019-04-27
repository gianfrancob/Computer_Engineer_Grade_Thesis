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
 -- $Id: time_03.v 8318 2016-09-19 18:18:34Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {03} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module time_03
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
                = ( ( i_byte[NB_BYTE-1]==1'b0 )? {i_byte[NB_BYTE-1-1:0],1'b0} : ({i_byte[NB_BYTE-1-1:0],1'b0} ^ M_X) ) ^ i_byte ;

endmodule // xtime

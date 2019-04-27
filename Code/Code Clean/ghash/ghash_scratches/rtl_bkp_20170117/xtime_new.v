/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : xtime_new.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: xtime_new.v 10419 2017-01-17 20:41:21Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {02} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module xtime_new
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

    // INTERNAL SIGNALS.
    // None so far.


    // ALGORITHM BEGIN.

    assign  o_byte[7]   =   i_byte[6] ;
    assign  o_byte[6]   =   i_byte[5] ;
    assign  o_byte[5]   =   i_byte[4] ;
    assign  o_byte[4]   =   i_byte[3] ^ i_byte[7] ;
    assign  o_byte[3]   =   i_byte[2] ^ i_byte[7] ;
    assign  o_byte[2]   =   i_byte[1] ;
    assign  o_byte[1]   =   i_byte[0] ^ i_byte[7] ;
    assign  o_byte[0]   =   i_byte[7] ;

endmodule   // xtime_new
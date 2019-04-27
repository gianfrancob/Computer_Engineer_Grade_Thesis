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
 -- $Id: j0_generator.v 8248 2016-09-14 14:37:55Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the product between an input Galois
    Finite {2^8} element and a fixed element {03} of the same field.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module j0_generator
#(
    // PARAMETERS.
    parameter                                   NB_BLOCK    = 128 ,
    parameter                                   NB_IV       = 96
)
(
    // OUTPUTS.
    output  wire    [NB_BLOCK-1:0]              o_j0 ,
    // INPUTS.
    input   wire    [NB_IV-1:0]                 i_iv
) ;


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_BLOCK!=128 || NB_IV!=96 ) ;


    // INTERNAL SIGNALS.
    // None so far.


    // ALGORITHM BEGIN.

    assign  o_j0
                = { i_iv, {NB_BLOCK-NB_IV-1{1'b0}}, 1'b1 } ;

endmodule // j0_generator

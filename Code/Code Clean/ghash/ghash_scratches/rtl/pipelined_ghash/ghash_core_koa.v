/*------------------------------------------------------------------------------
 -- Project     : CL40010
 -------------------------------------------------------------------------------
 -- File        : ghash_core_koa.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Sep 27, 2016
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: ghash_core_koa.v 8647 2016-09-30 18:51:25Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 xored with a previous value and a HASH subkey (H) with coefficients in 
 Galois-Field{2^128} and then calculates a modular reduction using the fixed 
 polynomial 1 + x + x² + x³ + x^128 ( in Hex 0xe1 concatenated with 120 "0" bits).
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ghash_core_koa
#(
    // PARAMETERS.
    parameter                                        NB_DATA = 128  // [HINT] Any value different to 128 is not valid
)
(
    // OUTPUTS.
    output  reg     [ NB_DATA-1 :  0 ]               o_data_y ,
    // INPUTS.  
    input   wire    [ NB_DATA-1 :  0 ]               i_data_x ,
    input   wire    [ NB_DATA-1 :  0 ]               i_data_x_prev ,
    input   wire    [ NB_DATA-1 :  0 ]               i_h_key ,
    input   wire                                     i_valid ,
    input   wire                                     i_reset ,
    input   wire                                     i_clock
) ;

    // QUICK INSTANCE: BEGIN
    /*ghash_core_koa
    #(
        // PARAMETERS.
        .NB_DATA(  )  // [HINT] Any value different to 128 is not valid
    )
    (
        // OUTPUTS.
        .o_data_y (  ) ,
        // INPUTS.  
        .i_data_x (  ) ,
        .i_data_x_prev (  ) ,
        .i_h_key (  ) ,
        .i_valid (  ) ,
        .i_reset (  ) ,
        .i_clock (  )
    ) ; */ // QUICK INSTANCE: END

    // LOCAL PARAMETERS.
    localparam                                        BAD_CONF = ( NB_DATA!=128 ) ;
    
    // INTERNAL SIGNALS.
    wire    [ 2*NB_DATA-1-1 :  0 ]                    prod ; 
    wire    [ NB_DATA-1     :  0 ]                    x_xor ;   
    wire    [ NB_DATA-1     :  0 ]                    reminder ;
    wire    [ NB_DATA-1     :  0 ]                    aux ;
    // ALGORITHM BEGIN.
    assign x_xor
        = i_data_x ^ i_data_x_prev ;

    // POLINOMIAL MULTIPLICATION over GF(2^128) 
    polinomial_mult_koa
    #(
      .NB_DATA( NB_DATA )
      )
    u_polinomial_mult_koa
    (
        // OUTPUTS.
        .o_data     ( prod      ),
        // INPUTS.
        .i_data_a   ( x_xor     ),
        .i_data_b   ( i_h_key   ) ,
        .i_clock    ( i_clock   )
     );

    // MODULE REDUCTION
    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_DATA-1 ),
        .NB_DATA            ( NB_DATA   )
      )
    u_gf_2to128_multiplier_booth1_subrem
    (
        .o_sub_remainder    ( reminder                  ),
        .i_data             ( prod[ NB_DATA-1-1  :  0 ] )
     ) ;

    // OUTPUT CALCULATION
    assign aux
        = prod[ 2*NB_DATA-1-1  :  NB_DATA-1 ] ;
    
     // PIPE BEFORE MODULE REDUCTION
    always @( posedge i_clock )
    begin: l_reg_out
     if ( i_reset ) begin
            o_data_y <= { NB_DATA{1'b0} } ;
        end
        else begin
            o_data_y <= aux ^ reminder ;
        end
    end // l_reg_out


endmodule // ghash_core_koa

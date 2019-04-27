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
 -- $Id: ghash_core_feedback_pipe.v 8468 2016-09-26 13:36:58Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
 the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ghash_core_feedback_pipe
#(
    // PARAMETERS.
    parameter                               NB_DATA     = 128
)
(
    // OUTPUTS.
    output  reg     [NB_DATA-1:0]           o_data_y ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]           i_data_x ,
    input   wire    [NB_DATA-1:0]           i_data_x_prev ,
    input   wire    [NB_DATA-1:0]           i_h_key ,
    input   wire                            i_valid ,
    input   wire                            i_reset ,
    input   wire                            i_clock
) ;


    // LOCAL PARAMETERS.
    localparam                              BAD_CONF    = ( NB_DATA != 128 ) ;

    // INTERNAL SIGNALS.
    wire [NB_DATA-1:0]                      x_xor ;
    wire [2*NB_DATA-2:0]                    prod;
    wire [NB_DATA-1:0]                      reminder;


   // ALGORITHM BEGIN.
   assign   x_xor
                = i_data_x ^ i_data_x_prev ;
/*
    gf_2to128_multiplier_reg
    #(
        .NB_DATA    ( NB_DATA   )
    )
    u_gf_2to128_multiplier_reg
    (
        .o_data_z   ( data_y    ),
        .i_data_x   ( x_xor     ),
        .i_data_y   ( i_h_key   )
    ) ;
*/
    polinomial_mult_koa
    #(
      .NB_DATA(NB_DATA)
      )
    (
    // OUTPUTS.
    .o_data( prod ),
    // INPUTS.
    .i_data_a( x_xor ),
    .i_data_b( i_h_key ) ,
    .i_clock( i_clock )
     );

    // MODULE REDUCTION
    gf_2to128_multiplier_booth1_subrem
    #(
          .N_SUBPROD          ( NB_DATA-1                       ),
          .NB_DATA            ( NB_DATA                         )
      )
    u_gf_2to128_multiplier_booth1_subrem
    (
         .o_sub_remainder    ( reminder                    ),
         .i_data             ( prod[ NB_DATA-1-1:0 ]       )
     ) ;

    wire [NB_DATA-1:0] aux;
    assign aux
    = prod[2*NB_DATA-2:NB_DATA-1];
    always @( * )
    begin
        o_data_y 
        = aux ^ reminder;
    end

endmodule // ghash_core_feedbakc_pipe
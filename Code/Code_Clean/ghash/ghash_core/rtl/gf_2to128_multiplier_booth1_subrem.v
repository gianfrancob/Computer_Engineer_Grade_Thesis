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
 -- $Id: gf_2to128_multiplier_booth1_subrem.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
 the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_booth1_subrem
#(
    // PARAMETERS.
    parameter                                       N_SUBPROD       = 1     ,
    parameter                                       NB_DATA         = 128
)
(
    // OUTPUTS.
    output reg      [ NB_DATA-1:0   ]               o_sub_remainder ,
    // INPUTS.
    input wire      [ N_SUBPROD-1:0 ]               i_data
);

// QUICK INSTANCE: BEGIN
/*
gf_2to128_multiplier_booth1_subrem
#(
    // PARAMETERS.
    .N_SUBPROD          (  ),
    .NB_DATA            (  )
)
  u_gf_2to128_multiplier_booth1_subrem
(
    // OUTPUTS.
    .o_sub_remainder    (  ),
    // INPUTS.
    .i_data             (  )
 ); */ // QUICK_INSTANCE: END

// LOCAL PARAMETERS.
localparam                                          BAD_CONF    = ( NB_DATA != 128 )    ;
localparam      [ NB_DATA-1:0   ]                   R_X         = { 8'he1, 120'd0 }     ;

// INTERNAL SIGNALS.
genvar                                              ii                                  ;
wire            [ NB_DATA-1:0   ]                   a_subprods[N_SUBPROD-1:0]           ;
wire            [ NB_DATA-1:0   ]                   o_sub_remainder_aux[N_SUBPROD-1:0]  ;
integer                                             i                                   ;


// ALGORITHM BEGIN.

// First partial product.
assign a_subprods[ N_SUBPROD-1-0 ]  = { NB_DATA{ i_data[ N_SUBPROD-1-0 ]} } & {R_X} ;

// High order partial product generation.
generate
    for ( ii=1; ii<N_SUBPROD; ii=ii+1 )
     begin : genfor_partial_products
        if(ii<N_SUBPROD-6)    // cad_ence map_to_mux
            assign  a_subprods[ N_SUBPROD-1-ii ]
                = { NB_DATA{ i_data[ N_SUBPROD-1-ii ] } } & { { ii{1'b0} }, R_X[ NB_DATA-1:ii ] }   ;
         else
         begin
            if( ii == N_SUBPROD-1 ) // cad_ence map_to_mux
                assign a_subprods[ N_SUBPROD-1-ii ]
                    =   { NB_DATA{ i_data[ N_SUBPROD-1-ii ] } } & { { ii{1'b0} }, R_X[ NB_DATA-1:ii ] }                                 ^
                        { NB_DATA{ i_data[ N_SUBPROD-1-ii ] } } & { { (ii-(N_SUBPROD-6)){1'b0} }, R_X[ NB_DATA-1:(ii-(N_SUBPROD-6)) ] } ^
                        { NB_DATA{ i_data[ N_SUBPROD-1-ii ] } } & {R_X}                                                                 ;
            else
                assign a_subprods[ N_SUBPROD-1-ii ]
                    =   { NB_DATA{ i_data[ N_SUBPROD-1-ii ] } } & { { ii{1'b0} }, R_X[ NB_DATA-1:ii ] }                                 ^
                        { NB_DATA{ i_data[ N_SUBPROD-1-ii ] } } & { { (ii-(N_SUBPROD-6)){1'b0} }, R_X[ NB_DATA-1:(ii-(N_SUBPROD-6)) ] } ;
             //end
         end
        end // genfor_partial_products
endgenerate

// Partial product summation.
always @( * )
begin : l_xor_tree
        o_sub_remainder     = { NB_DATA{1'b0} }                 ;
        for ( i=0; i<N_SUBPROD; i=i+1 )
            o_sub_remainder = o_sub_remainder ^ a_subprods[i]   ;
end // l_xor_tree


endmodule // gf_2to128_multiplier_booth1_subrem

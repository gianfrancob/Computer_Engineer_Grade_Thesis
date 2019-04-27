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
 -- $Id: multiplier.v 8441 2016-09-23 17:43:15Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
 the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module multiplier
    #(
      // PARAMETERS.
      parameter                                   NB_DATA       = 64 ,
      parameter                                   LOG2_NB_DATA  = 7
      )
    (
     // OUTPUTS.
     output wire [2*NB_DATA-2:0] o_data_z ,
     // INPUTS.
     input wire [NB_DATA-1:0] 	i_data_x ,
     input wire [NB_DATA-1:0] 	i_data_y ,
     input wire                 i_clock
     ) ;


    // LOCAL PARAMETERS.

    // INTERNAL SIGNALS.
    genvar                      ii ;
    wire [2*NB_DATA-2:0]        a_subprods [NB_DATA-1:0];
    wire [2*NB_DATA-2:0]        b_subprods [NB_DATA-1:0];
    integer                     i ;


    // ALGORITHM BEGIN.

    // First partial product.
    assign  a_subprods[ 0 ]
        = {(2*NB_DATA-1){i_data_x[ 0 ]}} & i_data_y ;
    assign  b_subprods[ 0 ]
        = a_subprods[ 0 ] ;


    // High order partial product generation.
    generate
        for ( ii=1; ii<(NB_DATA); ii=ii+1 )
            begin : genfor_partial_products

                assign  a_subprods[ ii ]
                            = {(2*NB_DATA-1){i_data_x[ ii ]}} & i_data_y ;

                assign  b_subprods[ ii ]
                            = { a_subprods[ ii ], {ii{1'b0}} } ;


            end // genfor_partial_products
    endgenerate

/*
    // Partial product summation.
    always @( * )
    begin : l_xor_tree
        o_data_z
            = {(2*NB_DATA-1){1'b0}} ;
        for ( i=0; i<(NB_DATA); i=i+1 )
            o_data_z
                = o_data_z ^ b_subprods[ i ] ;
    end // l_xor_tree
*/

    wire  [(2*NB_DATA-1)*NB_DATA-1:0]   tree_i_terms ;
    generate
       for ( ii=0; ii<NB_DATA; ii=ii+1 )
       begin : genfor_map_array_to_vector
           assign  tree_i_terms[ ii*(2*NB_DATA-1) +: (2*NB_DATA-1) ]
                       = b_subprods[ ii ] ;
       end // genfor_map_array_to_vector
    endgenerate
    common_generated_xor_tree
    #(
        .N_TERMS                ( NB_DATA           ),
        .NB_TERM                ( 2*NB_DATA-1       ),
        .NB_SUM                 ( 2*NB_DATA-1       ),
        .USE_SIGNED_ADDERS      ( 1                 ),
        .N_STAGES_BETWEEN_REGS  ( LOG2_NB_DATA/2    ),
        .USE_RESET_PIN          ( 1                 ),
        .RESET_VAL              ( 0                 )
    )
    u_common_generated_xor_tree
    (
        .o_sum                  ( o_data_z          ),
        .i_terms                ( tree_i_terms      ),
        .i_valid                ( 1'b1              ),
        .i_reset                ( 1'b0              ),
        .i_clock                ( i_clock           )
    ) ;



endmodule // multiplier


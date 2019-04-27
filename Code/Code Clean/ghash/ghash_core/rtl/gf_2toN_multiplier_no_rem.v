/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : subbytes_block.v
 -- Authors     : Ramiro R. Lopez and Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gf_2toN_multiplier_no_rem.v 10470 2017-01-25 18:33:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module gf_2toN_multiplier_no_rem
#(
    // PARAMETERS.
    parameter                                       NB_DATA             = 128   ,
    parameter                                       CREATE_OUTPUT_REG   = 0
)
(
    // OUTPUTS.
    output  reg     [ 2*NB_DATA-1-1:0   ]           o_data_z            ,
    // INPUTS.
    input   wire    [ NB_DATA-1:0       ]           i_data_x            ,
    input   wire    [ NB_DATA-1:0       ]           i_data_y            ,
    input   wire                                    i_valid             ,
    input   wire                                    i_reset             ,
    input   wire                                    i_clock
);


// LOCAL PARAMETERS.
// None so far.


// INTERNAL SIGNALS.
genvar                                      ii                          ;
integer                                     i                           ;
wire        [ NB_DATA-1:0   ]               a_subprods[NB_DATA-1:0]     ;
wire        [ 2*NB_DATA-1:0 ]               b_subprods[NB_DATA-1:0]     ;
reg         [ 2*NB_DATA-1:0 ]               raw_sum                     ;



// ALGORITHM BEGIN.

// First partial product.
assign a_subprods[0]    = { NB_DATA{i_data_x[ NB_DATA-1 ]} } & i_data_y ;
assign b_subprods[0]    = { a_subprods[ 0 ], {NB_DATA{1'b0}} }          ;


// High order partial product generation.
generate
    for ( ii=1; ii<NB_DATA; ii=ii+1 )
    begin : genfor_partial_products
        assign  a_subprods[ii]  = { NB_DATA{i_data_x[ NB_DATA-1-ii ]} } & i_data_y          ;

        assign  b_subprods[ii]  = { { ii{1'b0} }, a_subprods[ii], { NB_DATA-ii{1'b0} } }    ;
    end // genfor_partial_products
endgenerate


// Raw partial product sumation.
always @( * )
begin : l_xor_tree_raw
    raw_sum
        = {(2*NB_DATA){1'b0}} ;
    for ( i=0; i<NB_DATA; i=i+1 )
        raw_sum
            = raw_sum ^ b_subprods[ i ] ;
end // l_xor_tree_raw


// Final sumation.
generate
    if ( CREATE_OUTPUT_REG != 0 )   // cad_ence map_to_mux
    begin : genif_create_reg_out
        always @( posedge i_clock )
        begin : l_xor_tree
            if ( i_reset )  // cad_ence map_to_mux
                o_data_z    <= { (2*NB_DATA-1){1'b0} }  ;
            else if ( i_valid )
                o_data_z    <= raw_sum[2*NB_DATA-1:1]   ;
        end // l_xor_tree

    end // genif_create_reg_out
    else
    begin : genelse_create_reg_out

        always @( * )
        begin : l_xor_tree
            o_data_z    = raw_sum[2*NB_DATA-1:1]        ;
        end // l_xor_tree

    end // genelse_create_reg_out
endgenerate


endmodule // gf_2to128_multiplier_booth1

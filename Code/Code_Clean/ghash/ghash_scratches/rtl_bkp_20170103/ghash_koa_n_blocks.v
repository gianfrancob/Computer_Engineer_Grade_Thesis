/*------------------------------------------------------------------------------
 -- Project     : CL40010
 -------------------------------------------------------------------------------
 -- File        : ghash_koa_n_blocks.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Sep 27, 2016
 --
 -- Rev 0       : Initial release.
 --
 -- Rev 1       : RRL. Renamed from ghash_core_koa_pipe_parallel to
    ghash_koa_n_blocks. Also modified skip_bus operation to match
    ghash_n_blocks. Corrected some indentations.
 --
 --
 -- $Id: ghash_koa_n_blocks.v 10288 2017-01-05 13:48:15Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 xored with a previous value and a HASH subkey (H) with coefficients in 
 Galois-Field{2^128} and then calculates a modular reduction using the fixed 
 polynomial 1 + x + x² + x³ + x^128 ( in Hex 0xe1 concatenated with 120 "0" bits).
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ghash_koa_n_blocks
#(
    // PARAMETERS.
    parameter                                       NB_BLOCK   = 128               , // [HINT] Any value different to 128 is not valid
    parameter                                       N_BLOCKS   = 2                 ,
    parameter                                       NB_DATA    = N_BLOCKS*NB_BLOCK 
)
(
    // OUTPUTS.
    output  reg     [ NB_BLOCK-1 : 0 ]              o_data_y        ,
    // INPUTS.      
    input   wire    [ NB_DATA -1 : 0 ]              i_data_x        ,
    input   wire    [ NB_BLOCK-1 : 0 ]              i_data_x_prev   ,
    input   wire    [ NB_DATA-1 : 0 ]               i_h_key_powers  ,
    input   wire    [ N_BLOCKS-1 : 0 ]              i_skip_bus      ,
    input   wire                                    i_sop           ,
    input   wire                                    i_valid         ,
    input   wire                                    i_reset         ,
    input   wire                                    i_clock
) ;

    // QUICK INSTANCE: BEGIN
    /*ghash_koa_n_blocks
    #(
        // PARAMETERS.
        .NB_BLOCK   (  ) ,   // [HINT] Any value different to 128 is not valid 
        .N_BLOCKS   (  ) ,
        .NB_DATA    (  ) 
    )
    u_ghash_koa_n_blocks
    (
        // OUTPUTS.
        .o_data_y       (  ) ,
        // INPUTS.  
        .i_data_x       (  ) ,
        .i_data_x_prev  (  ) ,
        .i_h_key_powers (  ) ,
        .i_skip_bus     (  ) ,
        .i_feedback     (  ) ,
        .i_sop          (  ) ,
        .i_valid        (  ) ,
        .i_reset        (  ) ,
        .i_clock        (  )
    ) ; */ // QUICK INSTANCE: END

    // LOCAL PARAMETERS.
    localparam                                          BAD_CONF          = ( NB_BLOCK!=128 )   ;
    
    // INTERNAL SIGNALS.
    wire    [ NB_BLOCK-1      :  0 ]                    h_subkey                                ;
    wire    [ 2*NB_BLOCK-1-1  :  0 ]                    subprods          [ N_BLOCKS-1  :  0 ]  ;
    reg     [ 2*NB_BLOCK-1-1  :  0 ]                    prod              [ N_BLOCKS-1  :  0 ]  ;
    wire    [ NB_BLOCK-1      :  0 ]                    data_x_prev                             ;
    wire    [ NB_BLOCK-1      :  0 ]                    data_x_prev_final                       ;
    wire    [ NB_BLOCK-1      :  0 ]                    x_xor                                   ;
    wire    [ NB_BLOCK-1      :  0 ]                    reminder                                ;
    wire    [ NB_BLOCK-1      :  0 ]                    aux                                     ;
    integer                                             i                                       ;
    genvar                                              ii, ji                                  ;

    // ALGORITHM BEGIN.

    // POLINOMIAL MULTIPLICATION over GF(2^128)
    assign data_x_prev
        =   ( i_sop )                   ?
            i_data_x_prev               :
            data_x_prev_final           ;

    // 1st Multiplication
    assign x_xor
        = i_data_x[ 0+:NB_BLOCK ] ^ data_x_prev ;

    assign h_subkey
        =   ( i_skip_bus[N_BLOCKS-1] == 1'b0)                   ?
            i_h_key_powers[ NB_DATA-NB_BLOCK+:NB_BLOCK ]        :
            i_h_key_powers[ NB_DATA-(2*NB_BLOCK)+:NB_BLOCK  ]   ;

     polinomial_mult_koa
        #(
          .NB_DATA( NB_BLOCK )
          )
        u_polinomial_mult_koa_1st
        (
            // OUTPUTS.
            .o_data     ( subprods[0]                           ) ,
            // INPUTS.
            .i_data_a   ( x_xor                                 ) ,
            .i_data_b   ( h_subkey                              ) ,
            .i_clock    ( i_clock                               ) 
         );

    // Rest of Multiplications        
    generate
        for( ii=1; ii<N_BLOCKS; ii=ii+1 )
        begin: gen_for_subprods_calculation
            polinomial_mult_koa
            #(
              .NB_DATA      ( NB_BLOCK                              )
              )
            u_polinomial_mult_koa_ii
            (
                // OUTPUTS.
                .o_data     ( subprods[ii]                                          ) ,
                // INPUTS.
                .i_data_a   ( i_data_x[ NB_BLOCK*(ii)+:NB_BLOCK ]                   ) ,
                .i_data_b   ( i_h_key_powers[ NB_DATA-(NB_BLOCK*(ii+1))+:NB_BLOCK ] ) ,
                .i_clock    ( i_clock                                               )
             );
        end // gen_for_subprods_calculation       
    endgenerate
   
    // SUBPRODs XORs
    always @( * )
    begin
        prod[0] = subprods[0] & { (2*NB_BLOCK-1){~i_skip_bus[0]} } ;
        for ( i=1; i<N_BLOCKS; i=i+1 ) 
            prod[i] = prod[i-1] ^ ( subprods[i] & { (2*NB_BLOCK-1){~i_skip_bus[i]} } ) ; 
    end 

    // MODULE REDUCTION
    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_BLOCK-1 ),
        .NB_DATA            ( NB_BLOCK   )
      )
    u_gf_2to128_multiplier_booth1_subrem
    (
        .o_sub_remainder    ( reminder                              ) ,
        .i_data             ( prod[N_BLOCKS-1][ NB_BLOCK-1-1 : 0 ]  )
     ) ;

    // OUTPUT CALCULATION
    assign aux
        = prod[N_BLOCKS-1][ 2*NB_BLOCK-1-1  :  NB_BLOCK-1 ] ;


    // PIPE AFTER MODULE REDUCTION
    always @( posedge i_clock )
    begin: l_reg_out
     if ( i_reset ) begin
            o_data_y <= { NB_BLOCK{1'b0} } ;
        end
        else if ( i_valid )begin
            o_data_y <= aux ^ reminder ;
        end
    end // l_reg_out

    // FEEDBACK CALCULATION
    assign data_x_prev_final
        = o_data_y ;

endmodule // ghash_koa_n_blocks

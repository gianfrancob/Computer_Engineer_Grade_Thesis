/*------------------------------------------------------------------------------
 -- Project     : CL40010
 -------------------------------------------------------------------------------
 -- File        : ghash_core_koa_pipe_parallel.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Sep 27, 2016
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: ghash_core_koa_pipe_parallel.v 9290 2016-11-01 19:47:21Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
 xored with a previous value and a HASH subkey (H) with coefficients in 
 Galois-Field{2^128} and then calculates a modular reduction using the fixed 
 polynomial 1 + x + x² + x³ + x^128 ( in Hex 0xe1 concatenated with 120 "0" bits).
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module ghash_core_koa_pipe_parallel
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
    input   wire    [ NB_DATA-1  : 0 ]              i_h_key_powers  ,
    input   wire    [ N_BLOCKS-1 : 0 ]              i_skip_bus      ,
    input   wire                                    i_sop           ,
    input   wire                                    i_valid         ,
    input   wire    [ N_BLOCKS-1 : 0 ]              i_reset         ,
    input   wire                                    i_clock
) ;

    // QUICK INSTANCE: BEGIN
    /*ghash_core_koa_pipe_parallel
    #(
        // PARAMETERS.
        .NB_BLOCK   (  ) ,   // [HINT] Any value different to 128 is not valid 
        .N_BLOCKS   (  ) ,
        .NB_DATA    (  ) 
    )
    u_ghash_core_koa_pipe_parallel
    (
        // OUTPUTS.
        .o_data_y       (  ) ,
        // INPUTS.  
        .i_data_x       (  ) ,
        .i_data_x_prev  (  ) ,
        .i_h_key_powers (  ) ,
        .i_skip_bus     (  ) ,
        .i_sop          (  ) ,
        .i_valid        (  ) ,
        .i_reset        (  ) ,
        .i_clock        (  )
    ) ; */ // QUICK INSTANCE: END

    // LOCAL PARAMETERS.
    localparam                                      BAD_CONF          = ( NB_BLOCK!=128 )   ;
    
    // INTERNAL SIGNALS.
    wire    [ NB_BLOCK-1      :  0 ]                h_subkey                                ;
    wire    [ 2*NB_BLOCK-1-1  :  0 ]                subprods          [ N_BLOCKS-1  :  0 ]  ;
    reg     [ 2*NB_BLOCK-1-1  :  0 ]                prod              [ N_BLOCKS-1  :  0 ]  ;
    reg     [ NB_DATA-1       :  0 ]                i_data_x_reg                            ;
    reg     [ NB_BLOCK-1      :  0 ]                data_x_prev_reg                         ;
    wire    [ NB_BLOCK-1      :  0 ]                data_x_prev                             ;
    wire    [ NB_BLOCK-1      :  0 ]                data_x_prev_final                       ;
    wire    [ NB_BLOCK-1      :  0 ]                x_xor                                   ;   
    wire    [ NB_BLOCK-1      :  0 ]                reminder                                ;
    wire    [ NB_BLOCK-1      :  0 ]                mod                                     ;
    integer                                         i                                       ;
    genvar                                          ii, ji                                  ;

    // ALGORITHM BEGIN.

    // Polinomial Multiplication over GF(2^128).
    // always @( posedge i_clock ) begin
    //     if( i_reset )
    //         i_data_x_reg  <= { NB_DATA{1'b0} } ;
    //     else if ( i_valid )
    //         i_data_x_reg  <= i_data_x ;
    // end

    // always @( posedge i_clock ) begin
    //     if( i_reset )
    //         i_data_x_prev_reg  <= { NB_DATA{1'b0} } ;
    //     else if ( i_valid )
    //         i_data_x_prev_reg  <= i_data_x_prev ;
    // end

    assign data_x_prev
        =   ( i_sop )                   ?   
            i_data_x_prev               : 
            data_x_prev_final           ;
    // always @( posedge i_clock ) begin
    //     if( i_reset )
    //         data_x_prev_reg <= { NB_BLOCK{1'd0} } ;
    //     else if ( i_valid )
    //         data_x_prev_reg
    //             <=  ( i_sop )                   ?   
    //                 i_data_x_prev               : 
    //                 data_x_prev_final           ;
    // end

    // ---- 1st Multiplication
    assign x_xor
        = i_data_x[ 0+:NB_BLOCK ] ^ data_x_prev ;
    // assign x_xor
    //     = i_data_x_reg[ 0+:NB_BLOCK ] ^ data_x_prev_reg ;

    assign h_subkey
        =   ( i_skip_bus[N_BLOCKS-1] == 1'b0)                   ?
            i_h_key_powers[ NB_DATA-NB_BLOCK+:NB_BLOCK ]        :
            i_h_key_powers[ NB_DATA-(NB_BLOCK*2)+:NB_BLOCK ]    ;

    // polinomial_mult_koa_optimized_pipe
    // #(
    //   .NB_DATA  ( NB_BLOCK )
    //   )
    // u_polinomial_mult_koa_optimized_pipe
    // (
    //  // OUTPUTS.
    //  .o_data    ( subprods[0]                           ) ,
    //  // INPUTS.
    //  .i_data_a  ( x_xor                                 ) ,
    //  .i_data_b  ( h_subkey                              ) ,
    //  .i_clock   ( i_clock                               ) ,
    //  .i_reset   ( i_reset[0]                            ) ,
    //  .i_valid   ( i_valid                               ) 
    //  ); 

    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK     )   ,
        .CREATE_OUTPUT_REG   ( 0 )   
    )
    u_gf_2toN_koa_generated
    (
        .o_data_z            ( subprods[0]  )    ,
        .i_data_y            ( x_xor        )    ,
        .i_data_x            ( h_subkey     )    ,
        .i_valid             ( i_valid      )    ,
        .i_reset             ( i_reset[0]   )    ,
        .i_clock             ( i_clock      )   
    ) ;

    // ---- Rest of Multiplications        
    generate
        for( ii=1; ii<N_BLOCKS; ii=ii+1 )
        begin: gen_for_subprods_calculation

            // polinomial_mult_koa_optimized_pipe
            // #(
            //   .NB_DATA  ( NB_BLOCK )
            //   )
            // u_polinomial_mult_koa_optimized_pipe_ii
            // (
            //  // OUTPUTS.
            //  .o_data    ( subprods[ii]                                          ) ,
            //  // INPUTS.
            //  .i_data_a  ( i_data_x[ NB_BLOCK*(ii)+:NB_BLOCK ]                   ) ,
            //  .i_data_b  ( i_h_key_powers[ NB_DATA-(NB_BLOCK*(ii+1))+:NB_BLOCK ] ) ,
            //  .i_clock   ( i_clock                                               ) ,
            //  .i_reset   ( i_reset[ii]                                           ) ,
            //  .i_valid   ( i_valid                                               ) 
            //  );

             gf_2toN_koa_generated
            #(
                .NB_DATA             ( NB_BLOCK     )   ,
                .CREATE_OUTPUT_REG   ( 0 )   
            )
            u_gf_2toN_koa_generated_ii
            (
                .o_data_z            ( subprods[ii]                                          ) ,
                .i_data_y            ( i_data_x[ NB_BLOCK*(ii)+:NB_BLOCK ]               ) ,
                .i_data_x            ( i_h_key_powers[ NB_DATA-(NB_BLOCK*(ii+1))+:NB_BLOCK ] ) ,
                .i_valid             ( i_valid                                               ) ,
                .i_reset             ( i_reset[ii]                                           ) ,
                .i_clock             ( i_clock                                               ) 
            ) ;

        end // gen_for_subprods_calculation       
    endgenerate
   
    // Subproducst XOR.
    reg     [N_BLOCKS-1:0]  i_skip_bus_reg ;
    always @(posedge i_clock ) begin
        i_skip_bus_reg  <=  i_skip_bus;
    end
    always @( * )
    begin
        prod[0] <= subprods[0] & { (2*NB_BLOCK-1){~i_skip_bus_reg[0]} } ;
        for ( i=1; i<N_BLOCKS; i=i+1 ) 
            prod[i] <= prod[i-1] ^ ( subprods[i] & { (2*NB_BLOCK-1){~i_skip_bus_reg[i]} } ) ; 
    end 

    // Qs
    reg     [ NB_DATA-1-1    : 0 ]       q   [N_BLOCKS:0];
    always @( /*posedge i_clock*/* ) begin
        if ( i_reset ) begin
            q[0]    <= { NB_DATA-1{1'b0} } ;
        end else if ( i_valid ) begin
            q[0]    <= prod[N_BLOCKS-1];
        end
    end

    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            q[1]    <= { NB_DATA-1{1'b0} } ;
        end else if ( i_valid ) begin
            q[1]    <= q[0] ;
        end
    end


    always @( * ) begin
        q[2] = q[1] ^ q[0] ;
    end

    // Modular Reduction
    // gf_2to128_multiplier_booth1_subrem
    // #(
    //     .N_SUBPROD          ( NB_BLOCK-1 ),
    //     .NB_DATA            ( NB_BLOCK   )
    //   )
    // u_gf_2to128_multiplier_booth1_subrem
    // (
    //     .o_sub_remainder    ( reminder                              ) ,
    //     .i_data             ( prod[N_BLOCKS-1][ NB_BLOCK-1-1 : 0 ]  )
    //  ) ;

    wire    [NB_BLOCK-1-1:0]    overflow ;
    assign overflow
        = q[2][ NB_BLOCK-1-1 : 0 ] ;

    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_BLOCK-1    ),
        .NB_DATA            ( NB_BLOCK      )
      )
    u_gf_2to128_multiplier_booth1_subrem
    (
        .o_sub_remainder    ( reminder      ) ,
        .i_data             ( overflow      )
     ) ;

    // OUTPUT CALCULATION
    // assign mod
    //     = prod[N_BLOCKS-1][ 2*NB_BLOCK-1-1  :  NB_BLOCK-1 ] ^ reminder ;
    assign mod
        = q[2][ 2*NB_BLOCK-1-1  :  NB_BLOCK-1 ] ^ reminder ;
    
    // Pipe After Modular Reduction
    always @( posedge i_clock )
    begin: l_reg_out
     if ( i_reset || i_sop ) begin
            o_data_y <= { NB_BLOCK{1'b0} } ;
        end
        else if ( i_valid ) begin
            o_data_y <= mod ;
        end
    end // l_reg_out

    // FEEDBACK CALCULATION
    // assign data_x_prev_final
    //     = o_data_y/*mod*/ ;
    reg     [NB_BLOCK-1:0]  h_subkey_reg;
    always @(posedge i_clock )
        h_subkey_reg    <= h_subkey;
    gf_2to128_multiplier
    #(
        .NB_DATA    ( NB_BLOCK   )
    )
    u_gf_2to128_multiplier
    (
        .o_data_z   ( data_x_prev_final    ),
        .i_data_x   ( mod     ),
        .i_data_y   ( h_subkey_reg   )
    ) ;

endmodule // ghash_core_koa_pipe_parallel

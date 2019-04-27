module h_key_power_table
#(
    parameter       NB_BLOCK    = 128 ,
    parameter       N_BLOCKS    = 2 ,
    parameter       NB_DATA     = NB_BLOCK*N_BLOCKS
)
(
    // OUTPUTS.
    output  reg     [ NB_DATA-1 : 0 ]   o_h_key_powers  ,
    // INPUTS.
    input   wire    [ NB_BLOCK-1: 0 ]   i_h_key         ,
    input   wire                        i_clock     
) ;

    // QUICK INSTANCE: BEGIN
    /*h_key_power_table
    #(
        .NB_BLOCK       (  ) ,
        .N_BLOCKS       (  ) ,
        .NB_DATA        (  ) 
    )
    u_h_key_power_table
    (
        // OUTPUTS.
        .o_h_key_powers (  ) ,
        // INPUTS   
        .i_h_key        (  ) ,
        .i_clock        (  )
    ) ; */ // QUICK INSTANCE: END

    // LOCAL PARAMETERS.
    localparam                                          BAD_CONF          = ( NB_BLOCK!=128 )   ;
    
    // INTERNAL SIGNALS.
    wire    [ NB_BLOCK-1      :  0 ]                    t_table           [ N_BLOCKS-1  :  0 ]  ; 
    wire    [ 2*NB_BLOCK-1-1  :  0 ]                    t_table_aux       [ N_BLOCKS-1  :  1 ]  ;
    wire    [ NB_BLOCK-1      :  0 ]                    reminder          [ N_BLOCKS-1  :  1 ]  ;
    integer                                             i                                       ;
    genvar                                              ji                                      ;

    // ALGORITHM BEGIN.
    // "H" Powers Calculation
    assign t_table[ 0 ]
        = i_h_key;
    generate
        for( ji=1; ji<N_BLOCKS; ji=ji+1 )
            begin: gen_for_T_table_precomputation
               multiplier_without_pipe
                #(
                  // PARAMETERS.
                  .NB_DATA ( NB_BLOCK          )
                  )
                u_multiplier_without_pipe
                (
                 // OUTPUTS.
                 .o_data_z ( t_table_aux[ji]   ) ,
                 // INPUTS .
                 .i_data_x ( t_table[ji-1]     ) ,
                 .i_data_y ( i_h_key           ) 
                 ) ;
                /*
                polinomial_mult_koa
                #(
                  // PARAMETERS.
                  .NB_DATA  ( NB_BLOCK          )
                  )
                polinomial_mult_koa_t_table
                 (
                  // OUTPUTS.
                  .o_data   ( t_table_aux[ji]   ) ,
                  // INPUTS.
                  .i_data_a ( t_table[ji-1]     ) ,
                  .i_data_b ( i_h_key           ) ,
                  .i_clock  ( i_clock           )
                  ) ;
                */
                gf_2to128_multiplier_booth1_subrem
                    #(
                      .N_SUBPROD    ( NB_BLOCK-1    ) ,
                      .NB_DATA      ( NB_BLOCK      )
                      )
                u_gf_2to128_multiplier_booth1_subrem_t_table
                    (
                     .o_sub_remainder   ( reminder[ji]                          ) ,
                     .i_data            ( t_table_aux[ji][ NB_BLOCK-1-1 :  0 ]  )
                     ) ;
                
                assign t_table[ji]
                    = t_table_aux[ji][ 2*NB_BLOCK-1-1 : NB_BLOCK-1 ] ^ reminder[ji] ;

        end // block: gen_for_T_table2_precomputation
    endgenerate

    // OUTPUT CALCULATION.
    always @( * )
    begin
        for ( i=0; i<N_BLOCKS; i=i+1 )
            o_h_key_powers[ i*NB_BLOCK+:NB_BLOCK ]
                = t_table[i] ;
    end

endmodule // h_key_power_table
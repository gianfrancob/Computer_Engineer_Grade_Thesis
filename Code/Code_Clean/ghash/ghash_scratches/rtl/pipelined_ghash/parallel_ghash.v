module parallel_ghash
    #(
      parameter NB_PARALLELISM = 2,
      parameter NB_DATA = 128
      )
    (
     // OUTPUTS.
     output reg [NB_DATA-1:0]                o_data_mod,
     // INPUTS.
     input wire [NB_PARALLELISM*NB_DATA-1:0] i_data_x,
     input wire [NB_DATA-1:0]                i_data_x_prev,
     input wire [NB_DATA-1:0]                i_H
     );

    // LOCAL PARAMETERS.
    localparam R_X = { 8'he1, 120'd0 };
    

    // INTERNAL SIGNALS.
    wire [2*NB_DATA-2:0]                     data_out [NB_PARALLELISM-1:0];
    wire [NB_DATA-1:0]                       reminder;
    wire [2*NB_DATA-2:0]                     subprod [NB_PARALLELISM-1:0];
    wire [NB_DATA-1:0]                       x_xor;
    wire [NB_DATA-1:0]                       t_table [NB_PARALLELISM-1:0]; 
    wire [2*NB_DATA-2:0]                     t_table_aux [NB_PARALLELISM-1:1];
    wire [NB_DATA-1:0] 			                 reminder_aux [NB_PARALLELISM-1:1];
    genvar                                   ii, jj, ij, ji;

    assign x_xor
        = i_data_x[NB_PARALLELISM*NB_DATA-NB_DATA+:NB_DATA] ^ i_data_x_prev ;
    
    // ALGORITHM BEGIN.
    polinomial_mult_koa
        #(
          .NB_DATA(NB_DATA)
          )
    u_polinomial_mult_koa_1st_iter
        (
         // OUTPUTS.
         .o_data(data_out[ 0 ]),
         //               .o_data_mod,
         // INPUTS.
         .i_data_a(x_xor),
         .i_data_b(/*i_H*/t_table[NB_PARALLELISM-1])
         );
    
    generate
        for ( ii=1; ii<NB_PARALLELISM; ii=ii+1 )
            begin: gen_for_polinomial_mult_koa
                polinomial_mult_koa
                 #(
                   .NB_DATA(NB_DATA)
                   )
                u_polinomial_mult_koa_iter
                 (
                  // OUTPUTS.
                  .o_data(data_out[ ii ]),
                  //              .o_data_mod,
                  // INPUTS.
                  .i_data_a(i_data_x[ ((NB_PARALLELISM-1)*NB_DATA)-(NB_DATA*ii)+:NB_DATA ]),
                  .i_data_b(t_table[NB_PARALLELISM-1-ii])
                  );
            end // block: gen_for_polinomial_mult_koa
    endgenerate


    assign t_table[ 0 ]
        = i_H;
    generate
        for( ji=1; ji<NB_PARALLELISM; ji=ji+1 )
            begin: gen_for_T_table_precomputation
                multiplier
                #(
                  // PARAMETERS.
                  .NB_DATA(NB_DATA)
                  )
                u_multiplier
                 (
                  // OUTPUTS.
                  .o_data_z(t_table_aux[ji]) ,
                  // INPUTS.
                  .i_data_x(t_table[ji-1]) ,
                  .i_data_y(i_H)
                  ) ;
		
		gf_2to128_multiplier_booth1_subrem
		    #(
		      .N_SUBPROD( NB_DATA-1 ),
		      .NB_DATA( NB_DATA )
		      )
		u_reminder_cal
		    (
		     .o_sub_remainder    ( reminder_aux[ji] ),
		     .i_data             ( t_table_aux[ji][ NB_DATA-1-1:0 ] )
		     ) ;
		
		assign t_table[ji]
		    = t_table_aux[ji][2*NB_DATA-2:NB_DATA-1] ^ reminder_aux[ji];
            end // block: gen_for_T_table2_precomputation
    endgenerate
    
    assign subprod[ 0 ] 
        = data_out[ 0 ] ;
    generate
        for ( jj=1; jj<NB_PARALLELISM; jj=jj+1 )
            begin: gen_for
                assign subprod[ jj ] 
                    = subprod[ jj-1 ] ^ data_out[ jj ] ;
            end
    endgenerate
    
    gf_2to128_multiplier_booth1_subrem
        #(
          .N_SUBPROD( NB_DATA-1 ),
          .NB_DATA( NB_DATA )
          )
    u_gf_2to128_multiplier_booth1_subrem
        (
         .o_sub_remainder    ( reminder ),
         .i_data             ( subprod[ NB_PARALLELISM-1 ][ NB_DATA-1-1:0 ] )
         ) ;

    always @( * )
        begin
            o_data_mod <= subprod[ NB_PARALLELISM-1 ][ 2*NB_DATA-2:NB_DATA-1 ] ^ reminder;
        end
    
endmodule // parallel_ghash


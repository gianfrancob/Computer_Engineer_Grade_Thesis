module m0_table_generator
  #(
    parameter NB_DATA = 128,
    parameter NB_BYTE = 8
    )
   (
    // OUTPUTS.
    output wire [ NB_DATA*(NB_DATA+1)-1:0 ] o_value,
    // INPUTS.
    input wire [ NB_DATA-1:0 ]              i_H,
    input wire                              i_clock,
    input wire                              i_reset,
    input wire                              i_valid
    );

   // LOCAL PARAMETERS.
   localparam [NB_DATA-1:0]     R_X = { 8'he1, 120'd0 } ;

   // INTERNAL SIGNALS.
   genvar                                   ii, jj, kk;
   wire [ NB_DATA-1:0 ]                     subprod [ NB_DATA:0 ];

   // ALGORITHM BEGIN.
   assign subprod[ NB_DATA ]
       = i_H ;

   generate
      begin: subprod_init_stage1
         for ( ii=64; ii>0; ii=ii/2 )
           assign subprod[ ii ]
             = ( subprod[ 2*ii ][ 0 ] == 0 )                  ?
               { 1'b0, subprod[ 2*ii ][ NB_DATA-1:1 ] }       :
               { 1'b0, subprod[ 2*ii ][ NB_DATA-1:1 ] } ^ R_X ;
      end // block: subprod_init_stage1
   endgenerate

   generate
      begin: subprod_init_stage2
         for ( ii=2; ii<NB_DATA; ii=ii*2 )
           for ( jj=1; jj<ii; jj=jj+1 )
             assign subprod[ ii+jj ]
               = subprod[ ii ] ^ subprod[ jj ] ;
      end // block: subprod_init_stage2
   endgenerate

   assign subprod[ 0 ]
     = { NB_DATA{1'b0} } ;

   generate
      assign o_value[ 0+:NB_DATA ]
        = subprod[ 0 ] ;
      for ( kk=1; kk<NB_DATA+1; kk=kk+1 )
        begin: gen_for_output_calc
           assign o_value[ kk*NB_DATA+:NB_DATA ]
             = subprod[ kk ] ;
        end
   endgenerate

endmodule // m0_table_generator


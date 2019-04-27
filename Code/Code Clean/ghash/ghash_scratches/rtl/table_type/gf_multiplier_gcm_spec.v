module gf_multiplier_gcm_spec
  #(
    parameter NB_DATA = 128
    )
   (
    // OUTPUTS.
    output reg [NB_DATA-1:0] o_value ,
    // INPUTS.
    input wire [NB_DATA-1:0] i_data_x ,
    input wire [NB_DATA-1:0] i_data_x_prev,
    input wire [NB_DATA-1:0] i_H , // subkey "H"
    input wire               i_valid ,
    input wire               i_reset ,
    input wire               i_clock
    );

   // LOCAL PARAMETERS.
   //localparam [ NB_DATA-1:0 ] R_X = { 8'he1, 120'd0 } ;
   localparam NB_BYTE           = 8 ;
   
   // INTERNAL SIGNALS.
   wire [ NB_BYTE-1:0]              r_table_index [ (NB_DATA/NB_BYTE -1):1 ];
   wire [ NB_DATA-1:0]              r_table_aux [ (NB_DATA/NB_BYTE -1):1 ];
   wire [ 256*2*NB_BYTE-1:0 ]       r_table_value;
   wire [ NB_DATA-1:0 ]             m0_table_value_aux [ (NB_DATA/NB_BYTE - 1):0 ] ;
   wire [ NB_DATA-1:0 ]             m0_table_value_aux2 [ (NB_DATA/NB_BYTE - 1):0 ] ;
   wire [ NB_DATA*(NB_DATA+1)-1:0 ] m0_table_value;
   wire [ NB_DATA-1:0 ]             m0_value [ (NB_DATA/NB_BYTE - 1):0 ] ;
   wire [ NB_DATA-1:0 ]             z_subprods [ (NB_DATA/NB_BYTE)-1:0 ] ;
   wire [ NB_DATA-1:0 ]             z_subprods1 [ (NB_DATA/NB_BYTE)-1:1 ] ;
   wire [ NB_DATA-1:0 ]             z_subprods2 [ (NB_DATA/NB_BYTE)-1:1 ] ;
   wire [ NB_DATA-1:0 ]             x_xor ;
   wire [ NB_BYTE-1:0 ]             x_byte [ (NB_DATA/NB_BYTE - 1):0 ];
   genvar                           ii, jj ;   
   
   // ALGORITHM BEGIN.
   assign  x_xor
     = i_data_x ^ i_data_x_prev ;
   
   // MODULES INSTANCIATION
   // M0 table
   m0_table_generator
     #(
       .NB_DATA(NB_DATA),
       .NB_BYTE(NB_BYTE)
       )
   u_m0_table_generator
     (
      // OUTPUTS.
      .o_value(m0_table_value),
      // INPUTS.
      .i_H(i_H),
      .i_clock(i_clock),
      .i_reset(i_reset),
      .i_valid(i_valid)
      );

   // R table
   r_table_generator
     #(
       .NB_BYTE(NB_BYTE)
       )
   u_r_table_generator
     (
      // OUTPUTS.
      .o_value(r_table_value),
      // INPUTS.
      .i_clock(i_clock),
      .i_reset(i_reset),
      .i_valid(i_valid)
      );
   
   // Function "Change Endianness"
   function [ NB_BYTE-1:0 ] change_endianness;
      input [ NB_BYTE-1:0 ]         i_array;
      integer                       ji;
      begin
         for ( ji=NB_BYTE; ji>0; ji=ji-1 )
           change_endianness[ NB_BYTE-ji ] = i_array[ ji-1 ];
      end
   endfunction

   // GF(2^128) Multiplication
   assign  z_subprods[ NB_DATA/NB_BYTE -1 ]
     = {NB_DATA{1'b0}} ;
   assign  z_subprods_final 
     = {NB_DATA{1'b0}} ;

   generate
      for ( ii=(NB_DATA/NB_BYTE - 1); ii>0; ii=ii-1 )
        begin : genfor_partial_products // Starting from 15th byte up to nº 1 ( not nº 0 )
           // NB_BYTE Handling
           assign x_byte[ ii ]
             = x_xor[ NB_DATA-((ii+1)*NB_BYTE)+:NB_BYTE ] ;
          
           // M0 value calculation
           assign m0_table_value_aux[ ii ]
             = ( x_byte[ ii ][ 7 ] == 1 ) ? // If index > 128
               i_H                        : // M0[128] = "H"
               { NB_DATA{1'b0} }          ;
           assign m0_table_value_aux2[ ii ]
             = m0_table_value[ (NB_DATA*{ 1'b0, x_byte[ ii ][ 6:0 ] })+:NB_DATA ] ;
           assign m0_value[ ii ]
             = m0_table_value_aux[ ii ] ^ m0_table_value_aux2[ ii ] ;

           // Previous iteration XORed with M0 value (x_byte XOR H and R module)--> Z = Z ^ M0[byte(X,i)]
           assign  z_subprods1[ ii ]
             = z_subprods[ ii ] ^ m0_value[ ii ] ;
           
           // Rightmost byte is will be lost in the shifting procedure below, 
           // so it is saved to be aplied R module acordingly its bits (values 
           // precalculated in R table)
           assign r_table_index[ ii ]
             = change_endianness( z_subprods1[ ii ][ 0+:NB_BYTE ] ) ;
             //= change_endianness( x_xor[ 0+:NB_BYTE ] ) ;
           
           // Right shift procedure. ( 15th byte (rightmost) is lost, 0th byte is untouch )
           for ( jj=0; jj<15; jj=jj+1 )
             begin
                assign z_subprods2[ ii ][ (jj*NB_BYTE)+:NB_BYTE ]
                  = z_subprods1[ ii ][ ((jj+1)*NB_BYTE)+:NB_BYTE ] ;
             end
            assign z_subprods2[ ii ][ NB_DATA-NB_BYTE+:NB_BYTE ]
              = { (2*NB_BYTE){1'b0} }/*z_subprods1[ ii ][ NB_DATA-NB_BYTE+:NB_BYTE ]*/ ;
           
           // The 0th byte ( witch is h00 ) and the rest of Z is XORed with the 
           // value indexed from R table ( 2 bytes lenght ) and 112 "0s" append to its right.
           // The lenght is 2 bytes because R polynomial ( 8 bits long )
           // is shifted and XORed with itself up to 8 times
           assign r_table_aux[ ii ]
             = { {r_table_value[ ((2*NB_BYTE)*r_table_index[ ii ])+:(2*NB_BYTE) ]}, {(NB_DATA-(2*NB_BYTE)){1'b0}} } ;
           
           assign z_subprods[ ii-1 ]
             = z_subprods2[ ii ] ^ r_table_aux[ ii ] ; // Z = Z ^ R[A] // A = r_table_index
           
        end // genfor_partial_products
      // Again, byte handling, index calculation, etc.., but
      // with de 0th byte ( the leftmost byte ) only
      assign x_byte[ 0 ]
        = x_xor[ NB_DATA-NB_BYTE+:NB_BYTE ] ;
      assign m0_table_value_aux[ 0 ]
        = ( x_byte[ 0 ][ 7 ] == 1 ) ?
          i_H                       :
          { NB_DATA{1'b0} }         ;
      assign m0_table_value_aux2[ 0 ]
        = m0_table_value[ (NB_DATA*{ 1'b0, x_byte[ 0 ][ 6:0 ] })+:NB_DATA ] ;
      assign m0_value[ 0 ]
        = m0_table_value_aux[ 0 ] ^ m0_table_value_aux2[ 0 ] ;
      
   endgenerate

   // OUTPUT REG
   always @( posedge i_clock )
     begin : l_out_pipe
        if ( i_reset )
          o_value
            <= {NB_DATA{1'b0}} ;
        else /*if ( i_valid )*/
          o_value
            <=z_subprods[0] ^ m0_value[ 0 ] ; // Final Z value calculation--> Z = Z ^ M0[byte(X,0)]
     end // l_out_pipe
   
endmodule // gf_multiplier_gcm_spec

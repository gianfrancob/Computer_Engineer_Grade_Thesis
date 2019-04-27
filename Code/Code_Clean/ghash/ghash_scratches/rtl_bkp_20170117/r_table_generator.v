module r_table_generator
    #(
      parameter NB_BYTE = 8
      )
    (
     // OUTPUTS.
     output wire [ 256*2*NB_BYTE-1:0 ] o_value,
     // INPUTS.
     input wire 		       i_clock,
     input wire 		       i_valid,
     input wire 		       i_reset
     );

    // LOCAL PARAMETERS.
    localparam /*[ NB_BYTE+1:0 ]*/ NB_ROWS = 256;
    localparam [ 2*NB_BYTE-1:0 ] R_X ={ {8'he1}, {NB_BYTE{1'b0}} } ;
    
    // INTERNAL SIGNALS.
    genvar 			       ii, jj, kk, ll;
    wire [ 2*NB_BYTE-1:0 ] 	       r_table [ NB_ROWS-1:0 ] ;

    // ALGORITHM BEGIN.
    generate
	wire [ NB_BYTE-1:0 ] 	       combi_array [ NB_ROWS-1:0 ] ;   
	assign combi_array[ 0 ] = { NB_BYTE{1'b0} } ;
	for ( kk=0; kk<NB_ROWS-1; kk=kk+1)
            assign combi_array[ kk+1 ] = combi_array[ kk ] + 1'b1;

	wire [ 2*NB_BYTE-1:0 ] 	       mod [ NB_BYTE-1: 0];
	assign mod[ 0 ] = R_X;
	for ( jj=1; jj<NB_BYTE; jj=jj+1 )
            assign mod[ jj ] = mod[ jj-1 ] >> 1'b1;
	
	for ( ii=0; ii<NB_ROWS; ii=ii+1 )
            begin: gen_for
		assign r_table[ ii ]
		    = ( ( combi_array[ ii ][ 7 ] ) * (mod[ 7 ]) ) ^
		      ( ( combi_array[ ii ][ 6 ] ) * (mod[ 6 ]) ) ^
		      ( ( combi_array[ ii ][ 5 ] ) * (mod[ 5 ]) ) ^
		      ( ( combi_array[ ii ][ 4 ] ) * (mod[ 4 ]) ) ^
		      ( ( combi_array[ ii ][ 3 ] ) * (mod[ 3 ]) ) ^
		      ( ( combi_array[ ii ][ 2 ] ) * (mod[ 2 ]) ) ^
		      ( ( combi_array[ ii ][ 1 ] ) * (mod[ 1 ]) ) ^
		      ( ( combi_array[ ii ][ 0 ] ) * (mod[ 0 ]) ) ;
		
            end // block: gen_for
    endgenerate

    generate
	for ( ll=0; ll<NB_ROWS; ll=ll+1)
            begin: gen_for_output_calc
		assign o_value[ ll*(2*NB_BYTE)+:(2*NB_BYTE) ]
		    = r_table[ ll ] ;
            end
    endgenerate
    
    /*
     always @( posedge i_clock )
     begin
     if ( i_reset )
     o_value <= { (2*NB_BYTE){1'b0}} ;
     else if ( i_valid )
     o_value <= r_table[ i_index ] ;
     end        
     */       
endmodule // r_table_generator

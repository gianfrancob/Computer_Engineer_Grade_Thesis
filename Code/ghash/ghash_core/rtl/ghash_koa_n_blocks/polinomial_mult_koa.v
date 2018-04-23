module polinomial_mult_koa
    #(
      parameter NB_DATA = 128
      )
    (
     // OUTPUTS.
     output reg [2*NB_DATA-2:0] o_data,
  //   output reg [NB_DATA-1:0] 	o_data_mod,
     // INPUTS.
     input wire [NB_DATA-1:0] 	i_data_a,
     input wire [NB_DATA-1:0] 	i_data_b ,
     input wire 				i_clock
     );

    // LOCAL PARAMETERS.
    //localparam NB_WORD 	= 32;
    localparam [NB_DATA-1:0] R_X  = { 8'he1, 120'd0 };

    // Function "Change Endianness"
    function automatic [ NB_DATA-1:0 ] change_endianness;
	input [ NB_DATA-1:0 ] 	i_array;
	integer 		ji;
	begin
            for ( ji=NB_DATA; ji>0; ji=ji-1 )
		change_endianness[ NB_DATA-ji ] = i_array[ ji-1 ];
	end
    endfunction

    // INTERNAL SIGNALS.
    wire [NB_DATA-1:0]   data_a	      = change_endianness( i_data_a ) ;
    wire [NB_DATA-1:0] 	 data_b	      = change_endianness( i_data_b ) ;
    wire [NB_DATA/2-1:0] data_a_high  = data_a[NB_DATA-1:NB_DATA/2];
    wire [NB_DATA/2-1:0] data_a_low   = data_a[NB_DATA/2-1:0];
    wire [NB_DATA/2-1:0] data_b_high  = data_b[NB_DATA-1:NB_DATA/2];
    wire [NB_DATA/2-1:0] data_b_low   = data_b[NB_DATA/2-1:0];
    wire [NB_DATA-2:0] 	 dl;
    wire [NB_DATA-2:0] 	 dhl;
    wire [NB_DATA-2:0] 	 dhl_aux1;
    wire [NB_DATA-2:0] 	 dhl_aux2;
    wire [NB_DATA-2:0] 	 dh;
    wire [2*NB_DATA-2:0] d;
    wire [2*NB_DATA-2:0] subprod_a;
    genvar 		 ii;

    // ALGORITHM BEGIN.
    multiplier_without_pipe
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA/2)
	  )
    u_multiplier_without_pipe1
	(
	 // OUTPUTS.
	 .o_data_z(dl) ,
	 // INPUTS.
	 .i_data_x(data_a_low) ,
	 .i_data_y(data_b_low)
	 ) ;

    multiplier_without_pipe
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA/2)
	  )
    u_multiplier_without_pipe2
	(
	 // OUTPUTS.
	 .o_data_z(dh) ,
	 // INPUTS.
	 .i_data_x(data_a_high) ,
	 .i_data_y(data_b_high)
	 ) ;

    multiplier_without_pipe
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA/2)
	  )
    u_multiplier_without_pipe3
	(
	 // OUTPUTS.
	 .o_data_z(dhl_aux1) ,
	 // INPUTS.
	 .i_data_x(data_a_high) ,
	 .i_data_y(data_b_low)
	 ) ;

    multiplier_without_pipe
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA/2)
	  )
    u_multiplier_without_pipe4
	(
	 // OUTPUTS.
	 .o_data_z(dhl_aux2) ,
	 // INPUTS.
	 .i_data_x(data_b_high) ,
	 .i_data_y(data_a_low)
	 ) ;

    assign dhl
	= dhl_aux1 ^ dhl_aux2 ;
    assign d
	= { dh, {NB_DATA{1'b0}} } ^ { dhl, {(NB_DATA/2){1'b0}} } ^ {dl} ;

    generate
	for ( ii=0; ii<=2*NB_DATA-2; ii=ii+1 )
	    begin: for_gen_change_endianness
		assign subprod_a[ ii ]
		    = d[ 2*NB_DATA-2-ii] ;
	    end
    endgenerate


    always @( * )
	begin
	    o_data  = subprod_a;
	end

endmodule // polinomial_mult_koa



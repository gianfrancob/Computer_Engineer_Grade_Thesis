module polinomial_mult_koa_optimized_pipe
    #(
      parameter NB_DATA = 128
      )
    (
     // OUTPUTS.
     output reg [2*NB_DATA-2:0] o_data,
     // INPUTS.
     input wire [NB_DATA-1:0] 	i_data_a,
     input wire [NB_DATA-1:0] 	i_data_b,
     input wire 				i_clock,
     input wire 				i_reset,
     input wire 				i_valid
     );

	// QUICK INSTANCE: BEGIN
    /*
    polinomial_mult_koa_optimized_pipe
    #(
      .NB_DATA	(  )
      )
    u_polinomial_mult_koa_optimized_pipe
    (
     // OUTPUTS.
     .o_data    (  ) ,
     // INPUTS.
     .i_data_a  (  ) ,
     .i_data_b  (  ) ,
     .i_clock   (  ) ,
     .i_reset   (  ) ,
     .i_valid   (  ) 
     ); */ // QUICK INSTANCE: END

    // LOCAL PARAMETERS.
    
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
    wire    [ NB_DATA-1     : 0 ]   data_a	    ;
    wire    [ NB_DATA-1     : 0 ]   data_b	    ;
    wire    [ NB_DATA/2-1   : 0 ]   data_a_high ;
    wire    [ NB_DATA/2-1   : 0 ]   data_a_low  ;
    wire    [ NB_DATA/2-1   : 0 ]   data_b_high ;
    wire    [ NB_DATA/2-1   : 0 ]   data_b_low  ;
    wire    [ NB_DATA/2-1   : 0 ]   ahl         ;
    wire    [ NB_DATA/2-1   : 0 ]   bhl         ;
    wire    [ NB_DATA-2     : 0 ]   dl          ;
    wire    [ NB_DATA-2     : 0 ]   dhl         ;
    wire    [ NB_DATA-2     : 0 ]   dhl_aux     ;
    wire    [ NB_DATA-2     : 0 ]   dh          ;
    wire    [ 2*NB_DATA-2   : 0 ]   d           ;
    reg     [ 2*NB_DATA-2   : 0 ]   subprod_a   ;
    wire    [ NB_DATA-1     : 0 ]   reminder    ;

    reg     [ NB_DATA-2     : 0 ]   dl_reg      ;
    reg     [ NB_DATA-2     : 0 ]   dhl_reg     ;
    reg     [ NB_DATA-2     : 0 ]   dh_reg      ;

    integer                         i           ;
    genvar                          ii          ;
    
    // ALGORITHM BEGIN.
    // Input rewire.
    assign data_a       
        = change_endianness( i_data_a ) ;
    assign data_b       
        = change_endianness( i_data_b ) ;
    assign data_a_high
        = data_a[NB_DATA-1:NB_DATA/2]   ;
    assign data_a_low 
        = data_a[NB_DATA/2-1:0]         ;
    assign data_b_high
        = data_b[NB_DATA-1:NB_DATA/2]   ;
    assign data_b_low 
        = data_b[NB_DATA/2-1:0]         ;

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

    assign bhl
	= data_b_high ^ data_b_low ;
    
    assign ahl
	= data_a_high ^ data_a_low ;
    
    multiplier_without_pipe
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA/2)
	  )
    u_multiplier_without_pipe3
	(
	 // OUTPUTS.
	 .o_data_z(dhl_aux) ,
	 // INPUTS.
	 .i_data_x(ahl) ,
	 .i_data_y(bhl)
	 ) ;


    assign dhl
        =   dhl_aux ^ dh ^ dl ;
   
    // Pipe Stage
    // ---- Mult1, Mult2 and Mult3 output registration
    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            dl_reg          <= ( { NB_DATA-1{1'b0} } )  ; //Mult1 output
            dh_reg          <= ( { NB_DATA-1{1'b0} } )  ; //Mult2 output
            dhl_reg         <= ( { NB_DATA-1{1'b0} } )  ; //Mult3 output
        end else if ( i_valid ) begin
            dl_reg          <= ( dl  )  ;
            dh_reg          <= ( dh  )  ;
            dhl_reg         <= ( dhl )  ;
        end
    end // always @ ( posedge i_clock )


    // ---- D Calculation: Dh, Dhl and Dl Aligment
    assign d
        = { dh_reg, {NB_DATA{1'b0}} }                   ^ 
                    { dhl_reg,  {(NB_DATA/2){1'b0}} }   ^
                                {dl_reg}                ;

    // OUTPUT CALCULATION 
    // Change endianess again, to get output in correct form
    always @( * ) begin
        for ( i=0; i<=2*NB_DATA-2; i=i+1 )
        begin: for_gen_change_endianness
            subprod_a[ i ] = d[ 2*NB_DATA-2-i] ;
        end
    end

    always @( * ) begin
        if ( i_reset )
            o_data  <= { (2*NB_DATA-1){1'b0} } ;
        else
            o_data  <= subprod_a ;
    end

endmodule // polinomial_mult_koa_optimized_pipe

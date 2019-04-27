module tb_polinomial_mult_koa
    ();

    // PARAMETERS.
    localparam NB_DATA 	= 128;
    localparam EXP = NB_DATA*NB_DATA;
    
    // OUTPUTS.
    wire [2*NB_DATA-2:0] dut_o_data;
    wire [NB_DATA-1:0] 	 dut_o_data_mod;
    wire [NB_DATA-1:0] 	 dut_o_data_z;
    // INPUTS.
    reg [NB_DATA-1:0] 	 dut_i_data_a;
    reg [NB_DATA-1:0] 	 dut_i_data_b;

    // INTERNAL SIGNALS.
    reg 		 clock;
    wire 		 reset;
    integer 		 counter;
    wire [NB_DATA-1:0] 	 cont [EXP-1:0];
    

    initial
	begin
	    clock   <= 1'b0;
	    counter <= 0;
	end

    always #5 clock  = ~clock;

    always @( posedge clock )
	begin
	    counter <= counter + 1;
	end

    assign reset
	= ( counter == 2 );

    // Function "Change Endianness"
    function [ NB_DATA-1:0 ] change_endianness;
	input [ NB_DATA-1:0 ]         i_array;
	integer                       ji;
	begin
            for ( ji=NB_DATA; ji>0; ji=ji-1 )
		change_endianness[ NB_DATA-ji ] = i_array[ ji-1 ];
	end
    endfunction

    assign cont[ 0 ]
	= { NB_DATA{1'b0} };
    genvar ii;
    generate
	for ( ii=1; ii<EXP; ii=ii+1 )
	    begin: gen_for
		assign cont[ ii ]
		    = cont[ii-1] + 1'b1;
	    end
    endgenerate
    
    integer i, j;
    always @( posedge clock )
	begin
	    if ( reset )
		begin
		    dut_i_data_a <= ( { NB_DATA{1'b0} } );
	            dut_i_data_b <= ( { NB_DATA{1'b0} } ) ;
		    i 		 <= 0;
		    j 		 <= 0;
		end
	    else
		begin
		    if ( counter%20 == 0)
			begin
			    dut_i_data_a <= (/*{64'd1, 64'd0}*/ {$random,$random,$random,$random}/* change_endianness( cont[ i ] ) */);
			    i 		 <= i + 1 ;
			end
	            if ( counter%25 == 0)
			begin
			    dut_i_data_b <= ( /*128'hC0000000000000000000000000000000>>j */{$random,$random,$random,$random}/* change_endianness( cont[ j ] )*/ ) ;
			    j 		 <= j + 1;
			end
		end
	end // always @ ( posedge clock )

    polinomial_mult_koa
	#(
	  .NB_DATA(NB_DATA)
	  )
    u_polinomial_mult_koa
	(
	 // OUTPUTS.
	 .o_data(dut_o_data),
	 // INPUTS.
	 .i_data_a(dut_i_data_a),
	 .i_data_b(dut_i_data_b) ,
	 .i_clock(clock)
	 );

    gf_2to128_multiplier_reg
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA)
	  )
    u_gf_2to128_multiplier_reg
	(
	 // OUTPUTS.
	 .o_data_z(dut_o_data_z) ,
	 // INPUTS.
	 .i_data_x(dut_i_data_a) ,
	 .i_data_y(dut_i_data_b) ,
	 .i_valid(1'b1) ,
	 .i_reset(reset) ,
	 .i_clock(clock)
	 ) ;

    wire comp;
    wire [NB_DATA-1:0] comp2;
    wire [2*NB_DATA-2:0] prod;
    multiplier_without_pipe
	#(
	  // PARAMETERS.
	  .NB_DATA(NB_DATA)
	  )
    u_multiplier_without_pipe
	(
	 // OUTPUTS.
	 .o_data_z(prod) ,
	 // INPUTS.
	 .i_data_x(dut_i_data_a) ,
	 .i_data_y(dut_i_data_b)
	 ) ;
    assign comp3
	= ( prod == dut_o_data_z );
    
endmodule // tb_polinomial_mult_koa

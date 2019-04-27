module gf_2to4_multiplier
#(
	parameter							NB_DATA 	= 4	,	// [HINT] Works only if value is 4
	parameter							PIPELINED 	= 0		// Enable or Disable Pipe Stage
)
(
	// OUTPUTS.
	output 	wire	[ NB_DATA-1	: 0 ]	o_prod 			,
	// INPUTS.
	input 	wire	[ NB_DATA-1	: 0 ]	i_x				,
	input 	wire	[ NB_DATA-1	: 0 ]	i_y				,
	input	wire						i_clock
) ;
	
	// QUICK_INSTANCE: BEGIN
	/*
	gf_2to4_multiplier
	#(
		.NB_DATA			(  )	,	// [HINT] Works only if value is 4
		.PIPELINED			(  )		// Enable or Disable Pipe Stage
	)
	u_gf_2to4_multiplier
	(
		.o_prod				(  )	,
		.i_x				(  )	,
		.i_y				(  )	,
		.i_clock			(  )
	) ;
	*/ // QUICK_INSTANCE: END

	// INTERNAL SIGNALS.
	wire	[ NB_DATA/2-1 : 0 ]		y_h			;
	wire	[ NB_DATA/2-1 : 0 ]		y_l			;
	wire	[ NB_DATA/2-1 : 0 ]		x_h			;
	wire	[ NB_DATA/2-1 : 0 ]		x_l			;
	wire	[ NB_DATA/2-1 : 0 ]		prod_h		;
	wire	[ NB_DATA/2-1 : 0 ]		prod_hl		;
	wire	[ NB_DATA/2-1 : 0 ]		prod_l		;
	wire	[ NB_DATA/2-1 : 0 ]		prod_h_phi	;
	wire	[ NB_DATA/2-1 : 0 ]		xor_hl_l	;
	wire	[ NB_DATA/2-1 : 0 ]		xor_h_phi_l	;
	
	reg		[ NB_DATA/2-1 : 0 ]		y_h_reg		;
	reg		[ NB_DATA/2-1 : 0 ]		y_l_reg		;
	reg		[ NB_DATA/2-1 : 0 ]		x_h_reg		;
	reg		[ NB_DATA/2-1 : 0 ]		x_l_reg		;

	// ALGORITHM BEGIN,
	// Input Rewire.
	assign y_h
		= i_y[ NB_DATA-1 : NB_DATA/2 ] ;

	assign y_l
		= i_y[ NB_DATA/2-1 : 0 ] ;


	assign x_h
		= i_x[ NB_DATA-1 : NB_DATA/2 ] ;

	assign x_l
		= i_x[ NB_DATA/2-1 : 0 ] ;

	// Pipe Stage (Optional, only if parameter PIPELINED is 1 )
	generate
        if ( PIPELINED == 1'b1 )
        begin : genif_create_out_reg
            always @( posedge i_clock ) begin
				y_h_reg	<= y_h ; 
				y_l_reg	<= y_l ; 
				x_h_reg	<= x_h ; 
				x_l_reg	<= x_l ; 
			end
        end // genif_create_out_reg
        else
        begin : genelse_create_out_reg
            always @( * )
            begin : l_wireout
                y_h_reg	= y_h ; 
				y_l_reg	= y_l ; 
				x_h_reg	= x_h ; 
				x_l_reg	= x_l ; 
            end // l_wireout
        end // genelse_create_out_reg
    endgenerate

	// GF(2^2) Multipliers Instatiations.
	gf_2to2_multiplier
	#(
		.NB_DATA	( NB_DATA/2 )
	)
	u_gf_2to2_multiplier_h
	(
		.o_prod		( prod_h	)	,
		.i_x		( x_h_reg	)	,
		.i_y		( y_h_reg	)	
	) ;

	gf_2to2_multiplier
	#(
		.NB_DATA	( NB_DATA/2 )
	)
	u_gf_2to2_multiplier_hl
	(
		.o_prod		( prod_hl			)	,
		.i_x		( x_h_reg ^ x_l_reg	)	,
		.i_y		( y_h_reg ^ y_l_reg )	
	) ;

	gf_2to2_multiplier
	#(
		.NB_DATA	( NB_DATA/2 )
	)
	u_gf_2to2_multiplier_l
	(
		.o_prod		( prod_l	)	,
		.i_x		( x_l_reg	)	,
		.i_y		( y_l_reg	)	
	) ;

	// GF(2^2) Multiplier with Constant Phi Instantiation
	gf_2to2_multiplier_with_constant_phi
	#(
		.NB_DATA		( NB_DATA/2 	)
	)
	u_gf_2to2_multiplier_with_constant_phi
	(
		.o_x_times_phi	( prod_h_phi	)	,
		.i_x			( prod_h		)	
	) ;

	// Output Calculation
	assign xor_hl_l
		= prod_hl ^ prod_l ;

	assign xor_h_phi_l
		= prod_h_phi ^ prod_l ;

	assign o_prod
		= { xor_hl_l, xor_h_phi_l } ;

endmodule // gf_2to4_multiplier

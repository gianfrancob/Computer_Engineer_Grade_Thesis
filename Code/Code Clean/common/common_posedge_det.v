module common_posedge_det
(
	// OUTPUTS.
	output 	wire 								o_posedge	,
	output 	wire 								o_data_del	,
	// INPUTS.
	input 	wire 								i_data		,
	input 	wire 								i_valid		,
	input 	wire 								i_reset		,
	input 	wire 								i_clock
) ;

// =================================================================================================
// QUICK INSTANCE
// =================================================================================================
/*
common_posedge_det
u_common_posedge_det
.o_posedge	(  ) ,
.o_data_del	(  ) ,
.i_data		(  ) ,
.i_valid	(  ) ,
.i_reset	(  ) ,
.i_clock	(  )
*/
// END: Quick Instance.

// =================================================================================================
// INTERNAL SIGNALS.
// =================================================================================================
reg												aux_d ;

// =================================================================================================
// ALGORITHM BEGIN.
// =================================================================================================
always @( posedge i_clock )
begin
	if( i_reset )
		aux_d	<=	1'b0 ;
	else if( i_valid )
		aux_d	<=	i_data ;
end

assign 	o_posedge	=	i_data & ~aux_d ;

endmodule
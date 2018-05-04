module common_fix_delay_line_w_valid
#(
    parameter                                       NB_DATA     =   1   ,
    parameter                                       DELAY       =   1
)
(
    // OUTPUTS.
    output  wire    [ NB_DATA-1:0   ]               o_data_out  ,
    // INPUTS.
    input   wire    [ NB_DATA-1:0   ]               i_data_in   ,
    input   wire                                    i_valid     ,
    input   wire                                    i_reset     ,
    input   wire                                    clock
) ;

// =================================================================================================
// QUICK INSTANCE
// =================================================================================================
/*
common_fix_delay_line_w_valid
.NB_DATA    (  ) ,
.DELAY      (  ) ,
u_common_fix_delay_line_w_valid
.o_data_out (  ) ,
.i_data_in  (  ) ,
.i_valid    (  ) ,
.i_reset    (  ) ,
.clock      (  )
*/
// END: Quick Instance.

// =================================================================================================
// INTERNAL SIGNALS.
// =================================================================================================
reg     [ NB_DATA-1:0   ]                           shift_reg   [ DELAY-1:0 ]   ;
integer                                             i ;

// =================================================================================================
// ALGORITHM
// =================================================================================================
always@( posedge clock )
begin
    if( i_reset )
        shift_reg[0]    <=  { NB_DATA{1'b0} } ;
    else if( i_valid )
        shift_reg[0]    <=  i_data_in ;
end

always@( posedge clock )
begin
    if( i_valid )
        for( i=1; i<DELAY; i=i+1 )
            shift_reg[i]    <=  shift_reg[i-1] ;
end

assign  o_data_out  =   shift_reg[DELAY-1] ;

endmodule
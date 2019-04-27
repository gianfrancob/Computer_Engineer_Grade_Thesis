module t_r_table_generator
  ();

   // PARAMETERS.
   localparam NB_ROWS = 256;
   localparam NB_BYTE = 8;
   
   // OUTPUTS.
   wire [ NB_ROWS*2*NB_BYTE-1:0 ] dut_o_value;
   // INPUTS.
   reg                 clock;
   wire                reset;
   wire                valid;



    initial
     begin
        clock = 1'b0;
     end
   
   always #5 clock = ~clock;

   integer counter = 0;


   assign reset
     = ( counter == 2) ;

   assign valid
     = ( counter >= 2) ;

 
   r_table_generator
     #(
       .NB_BYTE(NB_BYTE)
       )
   u_r_table_generator
     (
      // OUTPUTS.
      .o_value(dut_o_value),
      // INPUTS.
      .i_clock(clock),
      .i_reset(reset),
      .i_valid(valid)
      );
   
endmodule // t_r_table_generator


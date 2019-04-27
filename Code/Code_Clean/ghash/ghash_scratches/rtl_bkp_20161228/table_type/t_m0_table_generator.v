module t_m0_table_generator
  ();

   // PARAMETERS.
   localparam NB_DATA = 128;
   localparam NB_BYTE = 8;
   
   // OUTPUTS.
   wire [ NB_DATA*(NB_DATA+1)-1:0 ] dut_o_value;
   // INPUTS.
   wire [ NB_DATA-1:0 ] dut_i_H;
   reg                  clock;
   wire                 reset;
   wire                 valid;



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

   assign dut_i_H
     = 128'hf0e0d0c0b0a090807060504030201000;
     //= 128'h66e94bd4ef8a2c3b884cfa59ca342b2e ;
 
   m0_table_generator
     #(
       .NB_DATA(NB_DATA)
      )
   u_m0_table_generator
     (
       // OUTPUTS.
      .o_value(dut_o_value),
      // INPUTS.
      .i_H(dut_i_H),     
      .i_clock(clock),
      .i_reset(reset),
      .i_valid(valid)
      );
   
endmodule // t_m0_table_generator

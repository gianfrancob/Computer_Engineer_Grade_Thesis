module t_gf_multiplier_gcm_spec
  ();

   // PARAMETERS.
   localparam NB_DATA = 128 ;

   // OUTPUTS.
   wire [NB_DATA-1:0] o_data ;
   // INPUTS.
   reg [NB_DATA-1:0]  i_data_x ;
   wire [NB_DATA-1:0] i_data_key ; // subkey "H"
   reg [NB_DATA-1:0]  i_data_x_prev;
   wire               i_valid ;
   wire               i_reset ;
   reg                i_clock ;
   wire [NB_DATA-1:0] expected_out ;
   wire [NB_DATA-1:0] data_length ;
   wire [NB_DATA-1:0] o_data2 ;
   wire [NB_DATA-1:0] o_data3 ;
   wire [NB_DATA-1:0] o_data4 ;
   initial
     begin
        i_clock <= 1'b0 ;
     end

   always #5 i_clock = ~i_clock ;

   integer count = 0 ;

   always @( posedge i_clock )
     begin
        count <= count + 1 ;
     end

   assign i_reset =
                   ( count == 2 ) ;

   assign i_valid =
                   ( count >= 2 ) ;

   integer i;
   always @( posedge i_clock )
     begin
        if ( i_reset )
          i_data_x <= { NB_DATA{1'b0} } ;
        else if ( i_valid )
          if ( count%3 == 0)
            for ( i=0; i<(NB_DATA/32); i=i+1 )
              i_data_x[ i*32+:32 ] <= $random;
        //128'h0388dace60b6a392f328c2b971b2fe78 ;
        //128'h00800000000000000000000000000000 ;
     end
   
   assign i_data_key =
                    // 128'hb83b533708bf535d0aa6e52980d53b78; // ghash subkey "H"
                    (1)? 128'h66e94bd4ef8a2c3b884cfa59ca342b2e : {120'd0, 8'h80};

   assign  data_length
               = {120'd0, 8'h80} ;

   assign  expected_out
               = 128'hf38cbb1ad69223dcc3457ae5b6b0f885 ;


   always @( posedge i_clock )
     begin
        if ( i_reset )
          i_data_x_prev <= 0;
        else if ( i_valid )
          i_data_x_prev <= o_data;
     end

   

  // assign i_data_x_prev = o_data;

   // MODULE INSTANTIATION.
   gf_multiplier_gcm_spec
     #(
       .NB_DATA(NB_DATA)
       )
   u_gf_mult_gcm_spec
   (
    // OUTPUTS.
    .o_value(o_data) ,
    // INPUTS.
    .i_data_x(i_data_x) ,
    .i_data_x_prev(128'd0),
    .i_H(i_data_key) , // subkey "H"
    .i_valid(i_valid) ,
    .i_reset(i_reset) ,
    .i_clock(i_clock)
    );
    gf_multiplier_gcm_spec
     #(
       .NB_DATA(NB_DATA)
       )
   u_gf_mult_gcm_spec2
   (
    // OUTPUTS.
    .o_value(o_data2) ,
    // INPUTS.
    .i_data_x(data_length) ,
    .i_data_x_prev(o_data),
    .i_H(i_data_key) , // subkey "H"
    .i_valid(i_valid) ,
    .i_reset(i_reset) ,
    .i_clock(i_clock)
    );
   
   ghash_core
     #(
       .NB_DATA(NB_DATA)
       )
   u_ghash_core
     (
      // OUTPUTS.
      .o_data_y(o_data3) ,
      // INPUTS.
      .i_data_x(i_data_x) ,
      .i_data_x_prev(/*i_data_x_prev*/128'd0),
      .i_h_key(i_data_key) , // subkey "H"
      .i_valid(i_valid) ,
      .i_reset(i_reset) ,
      .i_clock(i_clock)
      );

    ghash_core
     #(
       .NB_DATA(NB_DATA)
       )
   u_ghash_core_2
     (
      // OUTPUTS.
      .o_data_y(o_data4) ,
      // INPUTS.
      .i_data_x(data_length) ,
      .i_data_x_prev(o_data3),
      .i_h_key(i_data_key) , // subkey "H"
      .i_valid(i_valid) ,
      .i_reset(i_reset) ,
      .i_clock(i_clock)
      );


    assign  comp
                = /*expected_out*/o_data2 == o_data4 ;

endmodule // t_gf_multiplier_gcm_spec

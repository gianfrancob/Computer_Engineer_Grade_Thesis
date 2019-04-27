module tb_parallel_ghash
    ();

    // PARAMETERS.
    parameter NB_PARALLELISM = 1;
    parameter NB_DATA = 128;
    
    // OUTPUTS.
    wire [NB_DATA-1:0] 	dut_o_data_mod1;
    wire [NB_DATA-1:0] 	dut_o_data_mod2;
    wire [NB_DATA-1:0] 	dut_o_data_mod3;
    wire [NB_DATA-1:0] 	dut_o_data_mod4;
    wire [NB_DATA-1:0] 	dut_o_data_mod5;
    wire [NB_DATA-1:0] 	o_data1;
    wire [NB_DATA-1:0] 	o_data2;
    wire [NB_DATA-1:0] 	o_data3;
    wire [NB_DATA-1:0] 	o_data4;
    wire [NB_DATA-1:0] 	o_data5;
    // INPUTS.
    wire [NB_PARALLELISM*NB_DATA-1:0] dut_i_data_x;
    wire [NB_DATA-1:0] 		      dut_i_H;
    wire [NB_DATA-1:0] 		      data_length ;
    
    assign dut_i_H
	//= 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
	= 128'hb83b533708bf535d0aa6e52980d53b78;

    //assign dut_i_data_x     //AAD    ,     C
    //	= { /*128'd0, */128'h0388dace60b6a392f328c2b971b2fe78 } ;

    //assign  data_length
    //  = {120'd0, 8'h80} ;
    
    reg 			      i_clock ;
    wire 			      i_reset;
    wire 			      ghash_comp;
    wire 			      ghash_comp2;
    wire 			      ghash_comp3;
    wire 			      ghash_comp4;
    wire 			      ghash_comp5;
    wire 			      expect_comp_parallel_ghash;
    wire 			      expect_comp_ghash_core;
    wire [ NB_DATA-1:0 ] 	      expected_out;
    wire [ NB_DATA-1:0 ] 	      ciphertext [3:0];
    wire [ NB_DATA-1:0 ] 	      aad [1:0];
    
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

    assign ciphertext[ 0 ]
//	= 128'h42831ec2217774244b7221b784d0d49c;
	= 128'h8ce24998625615b603a033aca13fb894;
    assign ciphertext[ 1 ]
//	= 128'he3aa212f2c02a4e035c17e2329aca12e;
	= 128'hbe9112a5c3a211a8ba262a3cca7e2ca7;
    assign ciphertext[ 2 ]
//	= 128'h21d514b25466931c7d8f6a5aac84aa05;
	= 128'h01e4a9a4fba43c90ccdcb281d48c7c6f;
    assign ciphertext[ 3 ]
//	= 128'h1ba30b396a0aac973d58e091473f5985;
	= { 96'hd62875d2aca417034c34aee5, 32'd0 };
    assign aad[ 0 ]
	= 128'hfeedfacedeadbeeffeedfacedeadbeef;
    assign aad[ 1 ]
	= { 32'habaddad2, 96'd0 };
	//  assign dut_i_data_x
//	= ciphertext[ (count/10)%4 ];
    assign data_length
//	= { 116'd0, 12'h200 } ;
	= 128'h00000000000000a000000000000001e0;
    
    parallel_ghash
	#(
	  .NB_PARALLELISM(/*NB_PARALLELISM*/7),
	  .NB_DATA(NB_DATA)
	  )
    u_parallel_ghash1
	(
	 // OUTPUTS.
	 .o_data_mod(dut_o_data_mod1),
	 // INPUTS.
	 .i_data_x({ aad[0], aad[1], ciphertext[0], ciphertext[1], ciphertext[2], ciphertext[3], data_length } ),
	 .i_data_x_prev(128'd0),
	 .i_H(dut_i_H)
	 );

    ghash_core
	#(
	  .NB_DATA(NB_DATA)
	  )
    u_ghash_core
	(
	 // OUTPUTS.
	 .o_data_y(o_data1) ,
	 // INPUTS.
	 .i_data_x(/*dut_i_data_x*/ciphertext[0]) ,
	 .i_data_x_prev(/*i_data_x_prev*/128'd0),
	 .i_h_key(dut_i_H) , // subkey "H"
	 .i_valid(1'b1) ,
	 .i_reset(i_reset) ,
	 .i_clock(i_clock)
	 );
    
    parallel_ghash
	#(
	  .NB_PARALLELISM(NB_PARALLELISM),
	  .NB_DATA(NB_DATA)
	  )
    u_parallel_ghash2
	(
	 // OUTPUTS.
	 .o_data_mod(dut_o_data_mod2),
	 // INPUTS.
	 .i_data_x(/*data_lenght*/ciphertext[1]),
	 .i_data_x_prev(dut_o_data_mod1),
	 .i_H(dut_i_H)
	 );

    ghash_core
	#(
	  .NB_DATA(NB_DATA)
	  )
    u_ghash_core_2
	(
	 // OUTPUTS.
	 .o_data_y(o_data2) ,
	 // INPUTS.
	 .i_data_x(/*data_length*/ciphertext[1]) ,
	 .i_data_x_prev(o_data1),
	 .i_h_key(dut_i_H) , // subkey "H"
	 .i_valid(1'b1) ,
	 .i_reset(i_reset) ,
	 .i_clock(i_clock)
	 );

    parallel_ghash
	#(
	  .NB_PARALLELISM(NB_PARALLELISM),
	  .NB_DATA(NB_DATA)
	  )
    u_parallel_ghash3
	(
	 // OUTPUTS.
	 .o_data_mod(dut_o_data_mod3),
	 // INPUTS.
	 .i_data_x(ciphertext[2]),
	 .i_data_x_prev(dut_o_data_mod2),
	 .i_H(dut_i_H)
	 );

    ghash_core
	#(
	  .NB_DATA(NB_DATA)
	  )
    u_ghash_core_3
	(
	 // OUTPUTS.
	 .o_data_y(o_data3) ,
	 // INPUTS.
	 .i_data_x(ciphertext[2]) ,
	 .i_data_x_prev(o_data2),
	 .i_h_key(dut_i_H) , // subkey "H"
	 .i_valid(1'b1) ,
	 .i_reset(i_reset) ,
	 .i_clock(i_clock)
	 );
    
    parallel_ghash
	#(
	  .NB_PARALLELISM(NB_PARALLELISM),
	  .NB_DATA(NB_DATA)
	  )
    u_parallel_ghash4
	(
	 // OUTPUTS.
	 .o_data_mod(dut_o_data_mod4),
	 // INPUTS.
	 .i_data_x(ciphertext[3]),
	 .i_data_x_prev(dut_o_data_mod3),
	 .i_H(dut_i_H)
	 );

    ghash_core
	#(
	  .NB_DATA(NB_DATA)
	  )
    u_ghash_core_5
	(
	 // OUTPUTS.
	 .o_data_y(o_data5) ,
	 // INPUTS.
	 .i_data_x(data_length) ,
	 .i_data_x_prev(o_data4),
	 .i_h_key(dut_i_H) , // subkey "H"
	 .i_valid(1'b1) ,
	 .i_reset(i_reset) ,
	 .i_clock(i_clock)
	 );

     parallel_ghash
	#(
	  .NB_PARALLELISM(NB_PARALLELISM),
	  .NB_DATA(NB_DATA)
	  )
    u_parallel_ghash5
	(
	 // OUTPUTS.
	 .o_data_mod(dut_o_data_mod5),
	 // INPUTS.
	 .i_data_x(data_length),
	 .i_data_x_prev(dut_o_data_mod4),
	 .i_H(dut_i_H)
	 );

    ghash_core
	#(
	  .NB_DATA(NB_DATA)
	  )
    u_ghash_core_4
	(
	 // OUTPUTS.
	 .o_data_y(o_data4) ,
	 // INPUTS.
	 .i_data_x(ciphertext[3]) ,
	 .i_data_x_prev(o_data3),
	 .i_h_key(dut_i_H) , // subkey "H"
	 .i_valid(1'b1) ,
	 .i_reset(i_reset) ,
	 .i_clock(i_clock)
	 );
    
    assign expected_out
//	= 128'h7f1b32b81b820d02614f8895ac1d4eac ;
	= 128'h1c5afe9760d3932f3c9a878aac3dc3de;
    assign ghash_comp
	= dut_o_data_mod1 == o_data1 ;
    assign ghash_comp2
        = dut_o_data_mod2 == o_data2 ;
    assign ghash_comp3
	= dut_o_data_mod3 == o_data3 ;
    assign ghash_comp4
	= dut_o_data_mod4 == o_data4 ;
    assign ghash_comp5
        = dut_o_data_mod5 == o_data5 ;
    assign expect_comp_parallel_ghash
	= /*dut_o_data_mod5*/dut_o_data_mod1 == expected_out ;
    assign expect_comp_ghash_core
	= o_data5 == expected_out ;
    

endmodule // tb_parallel_ghash

module polinomial_mult_koa_optimized_pipe_recursive
#(
    parameter                               NB_DATA = 128   ,
    parameter                               N_LOG_2 = 7     
)
(
    // OUTPUTS.
    output  reg     [ 2*NB_DATA-1-1 :0 ]    o_data      ,
    // INPUTS.
    input   wire    [ NB_DATA-1     :0 ]    i_data_a    ,
    input   wire    [ NB_DATA-1     :0 ]    i_data_b    ,
    input   wire                            i_clock     ,
    input   wire                            i_reset     ,
    input   wire                            i_valid
 ) ;

    // QUICK INSTANCE: BEGIN
    /*
    polinomial_mult_koa_optimized_pipe_recursive
    #(
      .NB_DATA  (  )
      )
    u_polinomial_mult_koa_optimized_pipe_recursive
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
    input [ NB_DATA-1:0 ]   i_array;
    integer         ji;
    begin
        for ( ji=NB_DATA; ji>0; ji=ji-1 )
          change_endianness[ NB_DATA-ji ] = i_array[ ji-1 ];
    end
    endfunction

    // INTERNAL SIGNALS.
    wire    [ NB_DATA-1     : 0 ]   data_a      ;
    wire    [ NB_DATA-1     : 0 ]   data_b      ;
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
    wire    [ 2*NB_DATA-1-1 : 0 ]   d           ;
    reg     [ 2*NB_DATA-1-1 : 0 ]   subprod_a   ;

 /*  wire    [ 1             : 0 ]   dl_bin__h       [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dhl_aux_bin__h  [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dhl_bin__h      [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dh_bin__h       [ N_LOG_2-1 : 0 ]   ;
    wire    [ 2             : 0 ]   d_bin__h        [ N_LOG_2-1 : 0 ]   ;

    wire    [ 1             : 0 ]   dl_bin__hl      [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dhl_aux_bin__hl [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dhl_bin__hl     [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dh_bin__hl      [ N_LOG_2-1 : 0 ]   ;
    wire    [ 2             : 0 ]   d_bin__hl       [ N_LOG_2-1 : 0 ]   ;

    wire    [ 1             : 0 ]   dl_bin__l       [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dhl_aux_bin__l  [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dhl_bin__l      [ N_LOG_2-1 : 0 ]   ;
    wire    [ 1             : 0 ]   dh_bin__l       [ N_LOG_2-1 : 0 ]   ;
    wire    [ 2             : 0 ]   d_bin__l        [ N_LOG_2-1 : 0 ]   ;*/

    integer                         i           ;
    genvar                          ii, jj      ;
    
    // ALGORITHM BEGIN.

    // Input rewire.
    assign data_a       
        = change_endianness( i_data_a ) ;
    assign data_b       
        = change_endianness( i_data_b ) ;
    
    // --- A
    assign data_a_high
        = data_a[ NB_DATA-1     : NB_DATA/2 ] ;
    assign data_a_low
        = data_a[ NB_DATA/2-1   : 0 ] ;
    // --- B
    assign data_b_high
        = data_b[ NB_DATA-1     : NB_DATA/2 ] ;
    assign data_b_low
        = data_b[ NB_DATA/2-1   : 0 ] ;

   /* generate
        if( NB_DATA == 2 ) begin
            assign dh
                = data_a_high & data_b_high ;
            assign dl
                = data_a_low & data_b_low ;
            assign dhl_aux
                = ( data_a_high ^ data_a_low ) & (data_b_high ^ data_b_low ) ;
            assign dhl
                =  dh ^ dhl_aux ^ dl ;

            assign d
                = {dh, 2'd0} ^ {dhl, 1'b0} ^ {dl} ;

        end else begin
            polinomial_mult_koa_optimized_pipe_recursive
            #(
              .NB_DATA  ( NB_DATA/2 )
              )
            u_polinomial_mult_koa_optimized_pipe_recursive_high
            (
             // OUTPUTS.
             .o_data    ( dh ) ,
             // INPUTS.
             .i_data_a  ( data_a_high ) ,
             .i_data_b  ( data_b_high ) ,
             .i_clock   ( i_clock ) ,
             .i_reset   ( i_reset ) ,
             .i_valid   ( i_valid ) 
             ); 

            polinomial_mult_koa_optimized_pipe_recursive
            #(
              .NB_DATA  ( NB_DATA/2 )
              )
            u_polinomial_mult_koa_optimized_pipe_recursive_mid
            (
             // OUTPUTS.
             .o_data    ( dhl_aux ) ,
             // INPUTS.
             .i_data_a  ( data_a_high ^ data_a_low ) ,
             .i_data_b  ( data_b_high ^ data_b_low ) ,
             .i_clock   ( i_clock ) ,
             .i_reset   ( i_reset ) ,
             .i_valid   ( i_valid ) 
             ); 

            polinomial_mult_koa_optimized_pipe_recursive
            #(
              .NB_DATA  ( NB_DATA/2 )
              )
            u_polinomial_mult_koa_optimized_pipe_recursive_low
            (
             // OUTPUTS.
             .o_data    ( dl ) ,
             // INPUTS.
             .i_data_a  ( data_a_low ) ,
             .i_data_b  ( data_b_low ) ,
             .i_clock   ( i_clock ) ,
             .i_reset   ( i_reset ) ,
             .i_valid   ( i_valid ) 
             );

            assign dhl
                = dh ^ dhl_aux ^ dl ;

            assign d
                = { dh, {NB_DATA{1'b0}} }                   ^ 
                            { dhl,  {(NB_DATA/2){1'b0}} }   ^
                                    {dl}                    ;

        end
    endgenerate

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
*/

    generate
        for( ii=1; ii<N_LOG_2; ii=ii+1 )
        begin: genfor_depth
            for( jj=0; jj<3**(ii-1); jj=jj+1 )
            begin: genfor_width

                // HIGH
                // --- A
                wire [ (NB_DATA/(2**ii))-1   : 0 ] h_a_h ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] h_a_l ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] h_a_hl ;
                // --- B
                wire [ (NB_DATA/(2**ii))-1   : 0 ] h_b_h ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] h_b_l ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] h_b_hl ;

                // MID
                // --- A
                wire [ (NB_DATA/(2**ii))-1   : 0 ] m_a_h ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] m_a_l ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] m_a_hl ;               
                // --- B
                wire [ (NB_DATA/(2**ii))-1   : 0 ] m_b_h ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] m_b_l ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] m_b_hl ;


                // LOW
                // --- A
                wire [ (NB_DATA/(2**ii))-1   : 0 ] l_a_h ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] l_a_l ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] l_a_hl ;               
                // --- B
                wire [ (NB_DATA/(2**ii))-1   : 0 ] l_b_h ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] l_b_l ;
                wire [ (NB_DATA/(2**ii))-1   : 0 ] l_b_hl ;


                if( ii == 1 )
                begin: first_mult
                    // --- A
                    assign h_a_h
                        = data_a[ NB_DATA-1     : NB_DATA/2 ] ;
                    assign h_a_l
                        = data_a[ NB_DATA/2-1   : 0 ] ;
                    // --- B
                    assign h_b_h
                        = data_b[ NB_DATA-1     : NB_DATA/2 ] ;
                    assign h_b_l
                        = data_b[ NB_DATA/2-1   : 0 ] ;
                end else
                begin: rest_of_mults
                    // HIGH
                    // --- A
                    assign h_a_h
                        = genfor_depth[ii-1].genfor_width[jj].h_a_h[ (NB_DATA/(2**(ii-1)))-1       : (NB_DATA/(2**(ii-1)))/2    ] ;
                    // assign h_a_l
                    //     = genfor_depth[ii-1].genfor_width[jj].h_a_h[ ((NB_DATA/(2**(ii-1)))/2)-1   : 0                          ] ;
                    // --- B

                    // // MID
                    // // --- A
                    // assign m_a_h
                    //     = genfor_depth[ii-1].genfor_width[0].m_a_h[ (NB_DATA/2*(ii-1))-1     : (NB_DATA/2*(ii-1))/2 ] ;
                    // assign m_a_l
                    //     = genfor_depth[ii-1].genfor_width[0].m_a_l[ ((NB_DATA/2*(ii-1))/2)-1 : 0] ;
                    // // // --- B

                    // // // LOW
                    // // // --- A
                    // assign l_a_h
                    //     = genfor_depth[ii-1].genfor_width[0].l_a_h[ (NB_DATA/2*(ii-1))-1     : (NB_DATA/2*(ii-1))/2 ] ;
                    // assign l_a_l
                    //     = genfor_depth[ii-1].genfor_width[0].l_a_l[ ((NB_DATA/2*(ii-1))/2)-1 : 0] ;
                    // // // --- B
                end
                // HIGH
                // --- A
                assign h_a_hl
                    = h_a_h ^ h_a_l ;
                // --- B
                assign h_b_hl
                    = h_b_h ^ h_b_l ;
                
                // MID
                // --- A
                assign m_a_hl
                    = m_a_h ^ m_a_l ;
                // --- B
                assign m_b_hl
                    = m_b_h ^ m_b_l ;
                
                // LOW
                // --- A
                assign l_a_hl
                    = l_a_h ^ l_a_l ;
                // --- B
                assign h_b_hl
                    = l_b_h ^ l_b_l ;


            end   

        /*   if( ii == N_LOG_2-1 ) begin
                assign d_h
                    = a_h & b_h ;

                assign d_hl_aux
                    = a_hl & b_hl ;

                assign d_l
                    = a_l & b_l ;

                assign d_hl
                    = d_h ^ d_hl ^ d_l ;

                assign d
                    = { d_h, 2'd0 } ^ { d_hl, 1'b0 } ^ { d_l } ;
           end else begin
               
           end
*/

            // assign a_l
            //     = data_a[ NB_DATA-1      :(NB_DATA/(2**ii)) ] ;                        
        end
    endgenerate

endmodule // polinomial_mult_koa_optimized_pipe_recursive
 
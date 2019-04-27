/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : subbytes_block.v
 -- Author      : Ramiro R. Lopez and Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gf_2toN_koa_generated.v 10288 2017-01-05 13:48:15Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/


module gf_2toN_koa_generated
#(
    parameter                                       NB_DATA             = 128 ,
    parameter                                       CREATE_OUTPUT_REG   = 0
)
(
    output  wire    [2*NB_DATA-1-1:0]               o_data_z ,
    input   wire    [NB_DATA-1:0]                   i_data_y ,
    input   wire    [NB_DATA-1:0]                   i_data_x ,
    input   wire                                    i_valid ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;


    /* // BEGIN: Quick instance.
     gf_2toN_koa_generated
    #(
        .NB_DATA             (  )   ,
        .CREATE_OUTPUT_REG   (  )   
    )
    u_gf_2toN_koa_generated
    (
        .o_data_z            (  )   ,
        .i_data_y            (  )   ,
        .i_data_x            (  )   ,
        .i_valid             (  )   ,
        .i_reset             (  )   ,
        .i_clock             (  )                      
    ) ;
    // END: Quick instance. */


    // LOCAL PARAMETERS.
    //==============================================================================
    localparam                                      CONST_1             = 1 ;
    localparam                                      CONST_2             = 2 ;
    localparam                                      CONST_3             = 3 ;
    localparam                                      N_STAGES_SPLITTER   = /*(f_minlog2( NB_DATA ) - 1)*/ 4 ;
    localparam                                      NB_SPLITTER_BUS     = f_n_bits_prev( N_STAGES_SPLITTER ) ;
    localparam                                      NB_MERGER_BUS       = f_n_bits_prev_merger( N_STAGES_SPLITTER ) ;
    localparam                                      NB_MULTIPLIER       = f_nb_data_in( N_STAGES_SPLITTER ) ;
    localparam                                      N_MULTIPLIERS       = f_pow( CONST_3, N_STAGES_SPLITTER ) ;
    localparam                                      NB_PRE_PRODUCT_BUS  = f_pow( CONST_3, N_STAGES_SPLITTER )*(CONST_2*NB_MULTIPLIER-1) ;


    // INTERNAL SIGNALS.
    //==============================================================================
    wire            [NB_SPLITTER_BUS-1:0]           splitter_bus ;
    wire            [NB_PRE_PRODUCT_BUS-1:0]        pre_product_bus ;
    wire            [NB_MERGER_BUS-1:0]             merger_bus ;



    // ALGORITHM BEGIN.
    //==============================================================================

    assign  splitter_bus[ 0 +: CONST_2*NB_DATA ]
                = { i_data_y, i_data_x } ;


    // Generate Splitters.
    generate
        genvar  ii ;
        for ( ii=0; ii<N_STAGES_SPLITTER; ii=ii+1 )
        begin : genfor_splitter_lines

            wire    [ CONST_2*f_pow(CONST_3,ii+0)*f_nb_data_in(ii+0)-1 : 0 ]    ii_i_data_bus ;
            wire    [ CONST_2*f_pow(CONST_3,ii+1)*f_nb_data_in(ii+1)-1 : 0 ]    ii_o_data_bus ;

            assign  ii_i_data_bus
                        = splitter_bus[ f_n_bits_prev( ii )-1 -: CONST_2*f_pow(CONST_3,ii+0)*f_nb_data_in(ii+0) ] ;

            assign  splitter_bus[ f_n_bits_prev( ii ) +: CONST_2*f_pow(CONST_3,ii+1)*f_nb_data_in(ii+1) ]
                        = ii_o_data_bus ;

            gf_2toN_koa_splitter_line
            #(
                .N_INSTANCES        ( f_pow( CONST_3, ii )      ),
                .NB_DATA            ( f_nb_data_in( ii )        ),
                .CREATE_OUTPUT_REG  ( 0                         )
            )
            u_gf_2toN_koa_splitter_line
            (
                .o_data_bus         ( ii_o_data_bus             ),      // FIXME: This should replace the assign below.
                .i_data_bus         ( ii_i_data_bus             ),
                .i_valid            ( i_valid                   ),
                .i_clock            ( i_clock                   )
            ) ;
         // assign  ii_o_data_bus
         //             = u_gf_2toN_koa_splitter_line.o_data_bus ;  // FIXME: This should be connected to the module above.

        end // genfor_splitter_lines
    endgenerate


    // Generate multipliers.
    generate
        genvar  jj ;
        for ( jj=0; jj<N_MULTIPLIERS; jj=jj+1 )
        begin : genfor_multipliers

            wire    [ CONST_2*NB_MULTIPLIER-1-1 : 0 ]                           jj_o_data_z ;
            wire    [ NB_MULTIPLIER-1 : 0 ]                                     jj_i_data_y ;
            wire    [ NB_MULTIPLIER-1 : 0 ]                                     jj_i_data_x ;

            assign  jj_i_data_y
                        = splitter_bus[ NB_SPLITTER_BUS - 1 - CONST_2*NB_MULTIPLIER*jj - 0*NB_MULTIPLIER -: NB_MULTIPLIER ];
            assign  jj_i_data_x
                        = splitter_bus[ NB_SPLITTER_BUS - 1 - CONST_2*NB_MULTIPLIER*jj - 1*NB_MULTIPLIER -: NB_MULTIPLIER ];

            gf_2toN_multiplier_no_rem
            #(
                .NB_DATA            ( NB_MULTIPLIER             ),
                .CREATE_OUTPUT_REG  ( /*CREATE_OUTPUT_REG*/1        )
            )
            u_gf_2toN_multiplier_no_rem
            (
                .o_data_z           ( jj_o_data_z               ),
                .i_data_x           ( jj_i_data_y               ),
                .i_data_y           ( jj_i_data_x               ),
                .i_valid            ( i_valid                   ),
                .i_reset            ( i_reset                   ),
                .i_clock            ( i_clock                   )
            ) ;

            assign  pre_product_bus[ N_MULTIPLIERS*(CONST_2*NB_MULTIPLIER-1) - 1 - (CONST_2*NB_MULTIPLIER-1)*jj -: CONST_2*NB_MULTIPLIER-1 ]
                        = jj_o_data_z ;

        end // genfor_splitter_lines
    endgenerate


    assign  merger_bus[ NB_MERGER_BUS-1 -: NB_PRE_PRODUCT_BUS ]
                = pre_product_bus ;


    // Generate Mergers.
    generate
        genvar  hh;
        for ( hh=0; hh<N_STAGES_SPLITTER; hh=hh+1 )
        begin : genfor_merger_lines

            wire    [ f_pow(CONST_3,hh+1)*(CONST_1*f_nb_data_in_merger(hh)+0)-1 : 0 ]    hh_i_data_bus ;
            wire    [ f_pow(CONST_3,hh+0)*(CONST_2*f_nb_data_in_merger(hh)+1)-1 : 0 ]    hh_o_data_bus ;

            assign  hh_i_data_bus
                        = merger_bus[ f_n_bits_prev_merger( hh ) +: f_pow(CONST_3,hh+1)*(CONST_1*f_nb_data_in_merger(hh)+0) ] ;

            assign  merger_bus[ f_n_bits_prev_merger( hh )-1 -: f_pow(CONST_3,hh+0)*(CONST_2*f_nb_data_in_merger(hh)+1) ]
                        = hh_o_data_bus ;

            gf_2toN_koa_merger_line
            #(
                .N_INSTANCES        ( f_pow( CONST_3, hh )      ),
                .NB_DATA            ( f_nb_data_in_merger(hh)   ),
                .CREATE_OUTPUT_REG  ( 0                         )
            )
            u_gf_2toN_koa_merger_line
            (
                .o_data_bus         ( hh_o_data_bus             ),      // FIXME: This should replace the assign below.
                .i_data_bus         ( hh_i_data_bus             ),
                .i_valid            ( i_valid                   ),
                .i_clock            ( i_clock                   )
            ) ;
             // assign  hh_o_data_bus
             //         = u_gf_2toN_koa_merger_line.o_data_bus ;  // FIXME: This should be connected to the module above.

        end // genfor_merger_lines
    endgenerate


    assign  o_data_z
                = merger_bus[ 0 +: CONST_2*NB_DATA-1 ] ;

    // always @( posedge i_clock ) begin
    //     if ( i_reset ) 
    //         o_data_z    <=  { NB_DATA{1'b0} };
    //     else
    //         o_data_z    <= merger_bus[ 0 +: CONST_2*NB_DATA-1 ] ;
    // end

    // SUPPORT FUNCTIONS.
    //==============================================================================

    // Calculates the minimum integer power of 2 that is bigger than a given number.
    function automatic  integer         f_minlog2 ;
        // Number wich log2 needs to be calculated
        input   integer     number ;
        // Counter used to calculate power of 2.
        integer             log2count ;
        integer             aux_out ;
        begin : function_body
            aux_out
                = 1 ;
            for ( log2count = 0 ; (2**log2count) <= number ; log2count = log2count+1 )
                aux_out
                    = log2count + 1 ;
            f_minlog2
                = aux_out ;
        end // function_body
    endfunction // f_minlog2


    // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
    function automatic  integer         f_n_bits_prev ;
        // Number wich log2 needs to be calculated
        input   integer     fi_stage_number ;
        // Counter used to calculate power of 2.
        integer             aux_i ;
        integer             aux_n_bits_prev ;
        integer             aux_nb_data ;
        begin : function_body
            aux_nb_data
                = NB_DATA ;
            aux_n_bits_prev
                = CONST_2*NB_DATA ;
            for ( aux_i = 1 ; aux_i <= fi_stage_number ; aux_i = aux_i+1 )
            begin
                aux_nb_data
                    = aux_nb_data / CONST_2 ;
                aux_n_bits_prev
                    = aux_n_bits_prev + CONST_2*f_pow(CONST_3,aux_i)*aux_nb_data ;
            end
            f_n_bits_prev
                = aux_n_bits_prev ;
        end // function_body
    endfunction // f_minlog2


    // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
    function automatic  integer         f_n_bits_prev_merger ;
        // Number wich log2 needs to be calculated
        input   integer     fi_stage_number ;
        // Counter used to calculate power of 2.
        integer             aux_i ;
        integer             aux_n_bits_prev ;
        integer             aux_nb_data ;
        begin : function_body
            aux_nb_data
                = CONST_2*NB_DATA-1 ;
            aux_n_bits_prev
                = 1*aux_nb_data ;
            for ( aux_i = 1 ; aux_i <= fi_stage_number ; aux_i = aux_i+1 )
            begin
                aux_nb_data
                    = (aux_nb_data-1) / CONST_2 ;
                aux_n_bits_prev
                    = aux_n_bits_prev + f_pow(CONST_3,aux_i)*aux_nb_data ;
            end
            f_n_bits_prev_merger
                = aux_n_bits_prev ;
        end // function_body
    endfunction // f_minlog2


    // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
    function automatic  integer        f_pow ;
        // Number wich log2 needs to be calculated
        input   integer     fi_base ;
        input   integer     fi_exponent ;
        // Counter used to calculate power of 2.
        integer             aux_power ;
        integer             aux_pow_i ;
        begin : function_body
            aux_power
                = 1 ;
            for ( aux_pow_i = 1 ; aux_pow_i <= fi_exponent ; aux_pow_i = aux_pow_i+1 )
            begin
                aux_power
                    = aux_power * fi_base ;
            end
            f_pow
                = aux_power ;
        end // function_body
    endfunction // f_minlog2


    // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
    function automatic  integer         f_nb_data_in ;
        // Number wich log2 needs to be calculated
        input   integer     fi_stage_number ;
        // Counter used to calculate power of 2.
        integer             aux_nb ;
        integer             aux_nb_i ;
        begin : function_body
            aux_nb
                = NB_DATA ;
            for ( aux_nb_i = 1 ; aux_nb_i <= fi_stage_number ; aux_nb_i = aux_nb_i+1 )
            begin
                aux_nb
                    = aux_nb / CONST_2 ;
            end
            f_nb_data_in
                = aux_nb ;
        end // function_body
    endfunction // f_minlog2


    // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
    function automatic  integer         f_nb_data_in_merger ;
        // Number wich log2 needs to be calculated
        input   integer     fi_stage_number ;
        // Counter used to calculate power of 2.
        integer             aux_nb ;
        integer             aux_nb_i ;
        begin : function_body
            aux_nb
                = NB_DATA-1 ;
            for ( aux_nb_i = 1 ; aux_nb_i <= fi_stage_number ; aux_nb_i = aux_nb_i+1 )
            begin
                aux_nb
                    = (aux_nb-1) / CONST_2 ;
            end
            f_nb_data_in_merger
                = aux_nb ;
        end // function_body
    endfunction // f_minlog2



    // BORRAR: Quick test.
    // ==========================================================
    // reg                     t_clock = 1'b0 ;
    // wire    [NB_DATA*2-1-1:0] exp_o_data_z ;
    // always
    //     #( 50 )
    //         t_clock
    //             = ~t_clock ;
    // assign  i_data_y    = 128'hf38cbb1ad69223dcc3457ae5b6b0f885 ;
    // assign  i_data_x    = 128'h000cbb1ad692230003457ae5b6b0f000 ;
    // assign  i_valid     = 1'b1 ;
    // assign  i_clock     = t_clock ;
    // initial
    //     #100000 $stop() ;
    // gf_2toN_multiplier_no_rem
    // #(
    //     .NB_DATA            ( NB_DATA               ),
    //     .CREATE_OUTPUT_REG  ( CREATE_OUTPUT_REG     )
    // )
    // u_gf_2toN_multiplier_no_rem__borrar
    // (
    //     .o_data_z           ( exp_o_data_z          ),
    //     .i_data_x           ( i_data_y              ),
    //     .i_data_y           ( i_data_x              ),
    //     .i_valid            ( i_valid               ),
    //     .i_clock            ( i_clock               )
    // ) ;
    // wire comp;
    // assign comp = (exp_o_data_z == o_data_z );

endmodule // gf_2to128_multiplier_booth1

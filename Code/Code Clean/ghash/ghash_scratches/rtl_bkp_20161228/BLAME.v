  9015     rlopez /*------------------------------------------------------------------------------
  9015     rlopez  -- Project     : CL60010
  9015     rlopez  -------------------------------------------------------------------------------
  9015     rlopez  -- File        : subbytes_block.v
  9015     rlopez  -- Author      : Ramiro R. Lopez and Gianfranco Barbiani.
  9015     rlopez  -- Originator  : Clariphy Argentina S.A. 
  9015     rlopez  -- Date        : Apr 15, 2014
  9015     rlopez  --
  9015     rlopez  -- Rev 0       : Initial release.
  9015     rlopez  --
  9015     rlopez  --
  9015     rlopez  -- $Id: BLAME.v 10220 2016-12-28 19:02:56Z rlopez $
  9015     rlopez  -------------------------------------------------------------------------------
  9015     rlopez  -- Description : This module implements the modular product between an input
  9015     rlopez     four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
  9015     rlopez     the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
  9015     rlopez  -------------------------------------------------------------------------------
  9015     rlopez  -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
  9015     rlopez  ------------------------------------------------------------------------------*/
  9015     rlopez 
  9015     rlopez 
  9015     rlopez module gf_2toN_koa_generated
  9015     rlopez #(
  9133  gbarbiani     parameter                                       NB_DATA             = 128 ,
  9015     rlopez     parameter                                       CREATE_OUTPUT_REG   = 0
  9015     rlopez )
  9015     rlopez (
  9118  gbarbiani     output  wire    [2*NB_DATA-1-1:0]               o_data_z ,
  9015     rlopez     input   wire    [NB_DATA-1:0]                   i_data_y ,
  9015     rlopez     input   wire    [NB_DATA-1:0]                   i_data_x ,
  9015     rlopez     input   wire                                    i_valid ,
  9290  gbarbiani     input   wire                                    i_reset ,
  9015     rlopez     input   wire                                    i_clock
  9015     rlopez ) ;
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     /* // BEGIN: Quick instance.
  9157  gbarbiani      gf_2toN_koa_generated
  9157  gbarbiani     #(
  9157  gbarbiani         .NB_DATA             (  )   ,
  9157  gbarbiani         .CREATE_OUTPUT_REG   (  )   
  9157  gbarbiani     )
  9157  gbarbiani     u_gf_2toN_koa_generated
  9157  gbarbiani     (
  9157  gbarbiani         .o_data_z            (  )   ,
  9157  gbarbiani         .i_data_y            (  )   ,
  9157  gbarbiani         .i_data_x            (  )   ,
  9157  gbarbiani         .i_valid             (  )   ,
  9290  gbarbiani         .i_reset             (  )   ,
  9157  gbarbiani         .i_clock             (  )                      
  9157  gbarbiani     ) ;
  9015     rlopez     // END: Quick instance. */
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     // LOCAL PARAMETERS.
  9015     rlopez     //==============================================================================
  9118  gbarbiani     localparam                                      CONST_1             = 1 ;
  9015     rlopez     localparam                                      CONST_2             = 2 ;
  9015     rlopez     localparam                                      CONST_3             = 3 ;
  9290  gbarbiani     localparam                                      N_STAGES_SPLITTER   = f_minlog2( NB_DATA ) - 1 ;
  9053     rlopez     localparam                                      NB_SPLITTER_BUS     = f_n_bits_prev( N_STAGES_SPLITTER ) ;
  9118  gbarbiani     localparam                                      NB_MERGER_BUS       = f_n_bits_prev_merger( N_STAGES_SPLITTER ) ;
  9088     rlopez     localparam                                      NB_MULTIPLIER       = f_nb_data_in( N_STAGES_SPLITTER ) ;
  9088     rlopez     localparam                                      N_MULTIPLIERS       = f_pow( CONST_3, N_STAGES_SPLITTER ) ;
  9118  gbarbiani     localparam                                      NB_PRE_PRODUCT_BUS  = f_pow( CONST_3, N_STAGES_SPLITTER )*(CONST_2*NB_MULTIPLIER-1) ;
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     // INTERNAL SIGNALS.
  9015     rlopez     //==============================================================================
  9015     rlopez     wire            [NB_SPLITTER_BUS-1:0]           splitter_bus ;
  9088     rlopez     wire            [NB_PRE_PRODUCT_BUS-1:0]        pre_product_bus ;
  9118  gbarbiani     wire            [NB_MERGER_BUS-1:0]             merger_bus ;
  9015     rlopez 
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     // ALGORITHM BEGIN.
  9015     rlopez     //==============================================================================
  9015     rlopez 
  9015     rlopez     assign  splitter_bus[ 0 +: CONST_2*NB_DATA ]
  9015     rlopez                 = { i_data_y, i_data_x } ;
  9015     rlopez 
  9088     rlopez 
  9088     rlopez     // Generate Splitters.
  9015     rlopez     generate
  9157  gbarbiani         genvar  ii ;
  9015     rlopez         for ( ii=0; ii<N_STAGES_SPLITTER; ii=ii+1 )
  9015     rlopez         begin : genfor_splitter_lines
  9015     rlopez 
  9066     rlopez             wire    [ CONST_2*f_pow(CONST_3,ii+0)*f_nb_data_in(ii+0)-1 : 0 ]    ii_i_data_bus ;
  9066     rlopez             wire    [ CONST_2*f_pow(CONST_3,ii+1)*f_nb_data_in(ii+1)-1 : 0 ]    ii_o_data_bus ;
  9015     rlopez 
  9015     rlopez             assign  ii_i_data_bus
  9066     rlopez                         = splitter_bus[ f_n_bits_prev( ii )-1 -: CONST_2*f_pow(CONST_3,ii+0)*f_nb_data_in(ii+0) ] ;
  9015     rlopez 
  9066     rlopez             assign  splitter_bus[ f_n_bits_prev( ii ) +: CONST_2*f_pow(CONST_3,ii+1)*f_nb_data_in(ii+1) ]
  9066     rlopez                         = ii_o_data_bus ;
  9066     rlopez 
  9015     rlopez             gf_2toN_koa_splitter_line
  9015     rlopez             #(
  9118  gbarbiani                 .N_INSTANCES        ( f_pow( CONST_3, ii )      ),
  9118  gbarbiani                 .NB_DATA            ( f_nb_data_in( ii )        ),
  9118  gbarbiani                 .CREATE_OUTPUT_REG  ( 0                         )
  9015     rlopez             )
  9015     rlopez             u_gf_2toN_koa_splitter_line
  9015     rlopez             (
  9118  gbarbiani                 .o_data_bus         ( ii_o_data_bus             ),      // FIXME: This should replace the assign below.
  9118  gbarbiani                 .i_data_bus         ( ii_i_data_bus             ),
  9118  gbarbiani                 .i_valid            ( i_valid                   ),
  9118  gbarbiani                 .i_clock            ( i_clock                   )
  9015     rlopez             ) ;
  9090     rlopez          // assign  ii_o_data_bus
  9090     rlopez          //             = u_gf_2toN_koa_splitter_line.o_data_bus ;  // FIXME: This should be connected to the module above.
  9015     rlopez 
  9015     rlopez         end // genfor_splitter_lines
  9015     rlopez     endgenerate
  9015     rlopez 
  9015     rlopez 
  9088     rlopez     // Generate multipliers.
  9088     rlopez     generate
  9157  gbarbiani         genvar  jj ;
  9157  gbarbiani         for ( jj=0; jj<N_MULTIPLIERS; jj=jj+1 )
  9088     rlopez         begin : genfor_multipliers
  9015     rlopez 
  9157  gbarbiani             wire    [ CONST_2*NB_MULTIPLIER-1-1 : 0 ]                           jj_o_data_z ;
  9157  gbarbiani             wire    [ NB_MULTIPLIER-1 : 0 ]                                     jj_i_data_y ;
  9157  gbarbiani             wire    [ NB_MULTIPLIER-1 : 0 ]                                     jj_i_data_x ;
  9015     rlopez 
  9157  gbarbiani             assign  jj_i_data_y
  9157  gbarbiani                         = splitter_bus[ NB_SPLITTER_BUS - 1 - CONST_2*NB_MULTIPLIER*jj - 0*NB_MULTIPLIER -: NB_MULTIPLIER ];
  9157  gbarbiani             assign  jj_i_data_x
  9157  gbarbiani                         = splitter_bus[ NB_SPLITTER_BUS - 1 - CONST_2*NB_MULTIPLIER*jj - 1*NB_MULTIPLIER -: NB_MULTIPLIER ];
  9088     rlopez 
  9088     rlopez             gf_2toN_multiplier_no_rem
  9088     rlopez             #(
  9118  gbarbiani                 .NB_DATA            ( NB_MULTIPLIER             ),
  9290  gbarbiani                 .CREATE_OUTPUT_REG  ( /*CREATE_OUTPUT_REG*/1         )
  9088     rlopez             )
  9088     rlopez             u_gf_2toN_multiplier_no_rem
  9088     rlopez             (
  9157  gbarbiani                 .o_data_z           ( jj_o_data_z               ),
  9157  gbarbiani                 .i_data_x           ( jj_i_data_y               ),
  9157  gbarbiani                 .i_data_y           ( jj_i_data_x               ),
  9118  gbarbiani                 .i_valid            ( i_valid                   ),
  9290  gbarbiani                 .i_reset            ( i_reset                   ),
  9118  gbarbiani                 .i_clock            ( i_clock                   )
  9088     rlopez             ) ;
  9088     rlopez 
  9157  gbarbiani             assign  pre_product_bus[ N_MULTIPLIERS*(CONST_2*NB_MULTIPLIER-1) - 1 - (CONST_2*NB_MULTIPLIER-1)*jj -: CONST_2*NB_MULTIPLIER-1 ]
  9157  gbarbiani                         = jj_o_data_z ;
  9088     rlopez 
  9088     rlopez         end // genfor_splitter_lines
  9088     rlopez     endgenerate
  9088     rlopez 
  9088     rlopez 
  9118  gbarbiani     assign  merger_bus[ NB_MERGER_BUS-1 -: NB_PRE_PRODUCT_BUS ]
  9088     rlopez                 = pre_product_bus ;
  9088     rlopez 
  9088     rlopez 
  9088     rlopez     // Generate Mergers.
  9088     rlopez     generate
  9157  gbarbiani         genvar  hh;
  9157  gbarbiani         for ( hh=0; hh<N_STAGES_SPLITTER; hh=hh+1 )
  9088     rlopez         begin : genfor_merger_lines
  9088     rlopez 
  9157  gbarbiani             wire    [ f_pow(CONST_3,hh+1)*(CONST_1*f_nb_data_in_merger(hh)+0)-1 : 0 ]    hh_i_data_bus ;
  9157  gbarbiani             wire    [ f_pow(CONST_3,hh+0)*(CONST_2*f_nb_data_in_merger(hh)+1)-1 : 0 ]    hh_o_data_bus ;
  9088     rlopez 
  9157  gbarbiani             assign  hh_i_data_bus
  9157  gbarbiani                         = merger_bus[ f_n_bits_prev_merger( hh ) +: f_pow(CONST_3,hh+1)*(CONST_1*f_nb_data_in_merger(hh)+0) ] ;
  9088     rlopez 
  9157  gbarbiani             assign  merger_bus[ f_n_bits_prev_merger( hh )-1 -: f_pow(CONST_3,hh+0)*(CONST_2*f_nb_data_in_merger(hh)+1) ]
  9157  gbarbiani                         = hh_o_data_bus ;
  9088     rlopez 
  9088     rlopez             gf_2toN_koa_merger_line
  9088     rlopez             #(
  9157  gbarbiani                 .N_INSTANCES        ( f_pow( CONST_3, hh )      ),
  9157  gbarbiani                 .NB_DATA            ( f_nb_data_in_merger(hh)   ),
  9118  gbarbiani                 .CREATE_OUTPUT_REG  ( 0                         )
  9088     rlopez             )
  9088     rlopez             u_gf_2toN_koa_merger_line
  9088     rlopez             (
  9157  gbarbiani                 .o_data_bus         ( hh_o_data_bus             ),      // FIXME: This should replace the assign below.
  9157  gbarbiani                 .i_data_bus         ( hh_i_data_bus             ),
  9118  gbarbiani                 .i_valid            ( i_valid                   ),
  9118  gbarbiani                 .i_clock            ( i_clock                   )
  9088     rlopez             ) ;
  9157  gbarbiani              // assign  hh_o_data_bus
  9157  gbarbiani              //         = u_gf_2toN_koa_merger_line.o_data_bus ;  // FIXME: This should be connected to the module above.
  9088     rlopez 
  9088     rlopez         end // genfor_merger_lines
  9088     rlopez     endgenerate
  9088     rlopez 
  9088     rlopez 
  9088     rlopez     assign  o_data_z
  9157  gbarbiani                 = merger_bus[ 0 +: CONST_2*NB_DATA-1 ] ;
  9088     rlopez 
  9088     rlopez 
  9088     rlopez 
  9015     rlopez     // SUPPORT FUNCTIONS.
  9015     rlopez     //==============================================================================
  9015     rlopez 
  9015     rlopez     // Calculates the minimum integer power of 2 that is bigger than a given number.
  9015     rlopez     function automatic  integer         f_minlog2 ;
  9015     rlopez         // Number wich log2 needs to be calculated
  9015     rlopez         input   integer     number ;
  9015     rlopez         // Counter used to calculate power of 2.
  9015     rlopez         integer             log2count ;
  9015     rlopez         integer             aux_out ;
  9015     rlopez         begin : function_body
  9015     rlopez             aux_out
  9015     rlopez                 = 1 ;
  9015     rlopez             for ( log2count = 0 ; (2**log2count) <= number ; log2count = log2count+1 )
  9015     rlopez                 aux_out
  9015     rlopez                     = log2count + 1 ;
  9015     rlopez             f_minlog2
  9015     rlopez                 = aux_out ;
  9015     rlopez         end // function_body
  9015     rlopez     endfunction // f_minlog2
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
  9015     rlopez     function automatic  integer         f_n_bits_prev ;
  9015     rlopez         // Number wich log2 needs to be calculated
  9015     rlopez         input   integer     fi_stage_number ;
  9015     rlopez         // Counter used to calculate power of 2.
  9015     rlopez         integer             aux_i ;
  9015     rlopez         integer             aux_n_bits_prev ;
  9015     rlopez         integer             aux_nb_data ;
  9015     rlopez         begin : function_body
  9015     rlopez             aux_nb_data
  9015     rlopez                 = NB_DATA ;
  9015     rlopez             aux_n_bits_prev
  9015     rlopez                 = CONST_2*NB_DATA ;
  9015     rlopez             for ( aux_i = 1 ; aux_i <= fi_stage_number ; aux_i = aux_i+1 )
  9015     rlopez             begin
  9015     rlopez                 aux_nb_data
  9015     rlopez                     = aux_nb_data / CONST_2 ;
  9015     rlopez                 aux_n_bits_prev
  9053     rlopez                     = aux_n_bits_prev + CONST_2*f_pow(CONST_3,aux_i)*aux_nb_data ;
  9015     rlopez             end
  9015     rlopez             f_n_bits_prev
  9015     rlopez                 = aux_n_bits_prev ;
  9015     rlopez         end // function_body
  9015     rlopez     endfunction // f_minlog2
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
  9118  gbarbiani     function automatic  integer         f_n_bits_prev_merger ;
  9118  gbarbiani         // Number wich log2 needs to be calculated
  9118  gbarbiani         input   integer     fi_stage_number ;
  9118  gbarbiani         // Counter used to calculate power of 2.
  9118  gbarbiani         integer             aux_i ;
  9118  gbarbiani         integer             aux_n_bits_prev ;
  9118  gbarbiani         integer             aux_nb_data ;
  9118  gbarbiani         begin : function_body
  9118  gbarbiani             aux_nb_data
  9118  gbarbiani                 = CONST_2*NB_DATA-1 ;
  9118  gbarbiani             aux_n_bits_prev
  9118  gbarbiani                 = 1*aux_nb_data ;
  9118  gbarbiani             for ( aux_i = 1 ; aux_i <= fi_stage_number ; aux_i = aux_i+1 )
  9118  gbarbiani             begin
  9118  gbarbiani                 aux_nb_data
  9118  gbarbiani                     = (aux_nb_data-1) / CONST_2 ;
  9118  gbarbiani                 aux_n_bits_prev
  9118  gbarbiani                     = aux_n_bits_prev + f_pow(CONST_3,aux_i)*aux_nb_data ;
  9118  gbarbiani             end
  9118  gbarbiani             f_n_bits_prev_merger
  9118  gbarbiani                 = aux_n_bits_prev ;
  9118  gbarbiani         end // function_body
  9118  gbarbiani     endfunction // f_minlog2
  9118  gbarbiani 
  9118  gbarbiani 
  9118  gbarbiani     // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
  9066     rlopez     function automatic  integer        f_pow ;
  9015     rlopez         // Number wich log2 needs to be calculated
  9015     rlopez         input   integer     fi_base ;
  9015     rlopez         input   integer     fi_exponent ;
  9015     rlopez         // Counter used to calculate power of 2.
  9015     rlopez         integer             aux_power ;
  9015     rlopez         integer             aux_pow_i ;
  9015     rlopez         begin : function_body
  9015     rlopez             aux_power
  9015     rlopez                 = 1 ;
  9015     rlopez             for ( aux_pow_i = 1 ; aux_pow_i <= fi_exponent ; aux_pow_i = aux_pow_i+1 )
  9015     rlopez             begin
  9015     rlopez                 aux_power
  9015     rlopez                     = aux_power * fi_base ;
  9015     rlopez             end
  9015     rlopez             f_pow
  9015     rlopez                 = aux_power ;
  9015     rlopez         end // function_body
  9015     rlopez     endfunction // f_minlog2
  9015     rlopez 
  9015     rlopez 
  9015     rlopez     // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
  9015     rlopez     function automatic  integer         f_nb_data_in ;
  9015     rlopez         // Number wich log2 needs to be calculated
  9015     rlopez         input   integer     fi_stage_number ;
  9015     rlopez         // Counter used to calculate power of 2.
  9015     rlopez         integer             aux_nb ;
  9015     rlopez         integer             aux_nb_i ;
  9015     rlopez         begin : function_body
  9015     rlopez             aux_nb
  9015     rlopez                 = NB_DATA ;
  9015     rlopez             for ( aux_nb_i = 1 ; aux_nb_i <= fi_stage_number ; aux_nb_i = aux_nb_i+1 )
  9015     rlopez             begin
  9015     rlopez                 aux_nb
  9015     rlopez                     = aux_nb / CONST_2 ;
  9015     rlopez             end
  9015     rlopez             f_nb_data_in
  9015     rlopez                 = aux_nb ;
  9015     rlopez         end // function_body
  9015     rlopez     endfunction // f_minlog2
  9015     rlopez 
  9015     rlopez 
  9118  gbarbiani     // Calculates the number of bits of the collecting bus used as outputs by the previous stages.
  9118  gbarbiani     function automatic  integer         f_nb_data_in_merger ;
  9118  gbarbiani         // Number wich log2 needs to be calculated
  9118  gbarbiani         input   integer     fi_stage_number ;
  9118  gbarbiani         // Counter used to calculate power of 2.
  9118  gbarbiani         integer             aux_nb ;
  9118  gbarbiani         integer             aux_nb_i ;
  9118  gbarbiani         begin : function_body
  9118  gbarbiani             aux_nb
  9118  gbarbiani                 = NB_DATA-1 ;
  9118  gbarbiani             for ( aux_nb_i = 1 ; aux_nb_i <= fi_stage_number ; aux_nb_i = aux_nb_i+1 )
  9118  gbarbiani             begin
  9118  gbarbiani                 aux_nb
  9118  gbarbiani                     = (aux_nb-1) / CONST_2 ;
  9118  gbarbiani             end
  9118  gbarbiani             f_nb_data_in_merger
  9118  gbarbiani                 = aux_nb ;
  9118  gbarbiani         end // function_body
  9118  gbarbiani     endfunction // f_minlog2
  9053     rlopez 
  9053     rlopez 
  9118  gbarbiani 
  9053     rlopez     // BORRAR: Quick test.
  9053     rlopez     // ==========================================================
  9133  gbarbiani     // reg                     t_clock = 1'b0 ;
  9133  gbarbiani     // wire    [NB_DATA*2-1-1:0] exp_o_data_z ;
  9133  gbarbiani     // always
  9133  gbarbiani     //     #( 50 )
  9133  gbarbiani     //         t_clock
  9133  gbarbiani     //             = ~t_clock ;
  9157  gbarbiani     // assign  i_data_y    = 128'hf38cbb1ad69223dcc3457ae5b6b0f885 ;
  9157  gbarbiani     // assign  i_data_x    = 128'h000cbb1ad692230003457ae5b6b0f000 ;
  9133  gbarbiani     // assign  i_valid     = 1'b1 ;
  9133  gbarbiani     // assign  i_clock     = t_clock ;
  9133  gbarbiani     // initial
  9133  gbarbiani     //     #100000 $stop() ;
  9133  gbarbiani     // gf_2toN_multiplier_no_rem
  9133  gbarbiani     // #(
  9133  gbarbiani     //     .NB_DATA            ( NB_DATA               ),
  9133  gbarbiani     //     .CREATE_OUTPUT_REG  ( CREATE_OUTPUT_REG     )
  9133  gbarbiani     // )
  9133  gbarbiani     // u_gf_2toN_multiplier_no_rem__borrar
  9133  gbarbiani     // (
  9133  gbarbiani     //     .o_data_z           ( exp_o_data_z          ),
  9133  gbarbiani     //     .i_data_x           ( i_data_y              ),
  9133  gbarbiani     //     .i_data_y           ( i_data_x              ),
  9133  gbarbiani     //     .i_valid            ( i_valid               ),
  9133  gbarbiani     //     .i_clock            ( i_clock               )
  9133  gbarbiani     // ) ;
  9133  gbarbiani     // wire comp;
  9133  gbarbiani     // assign comp = (exp_o_data_z == o_data_z );
     -          -     assign  comp
     -          -                 = exp_o_data_z == o_data_z ;
  9053     rlopez 
  9015     rlopez endmodule // gf_2to128_multiplier_booth1

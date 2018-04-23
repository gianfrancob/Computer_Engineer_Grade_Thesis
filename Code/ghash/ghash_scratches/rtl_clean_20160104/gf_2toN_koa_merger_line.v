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
 -- $Id: gf_2toN_koa_merger_line.v 10314 2017-01-06 18:02:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/


module gf_2toN_koa_merger_line
#(
    parameter                                       N_INSTANCES         = 3 ,
    parameter                                       NB_DATA             = 128 , // [HINT] So far, it must be a power of 2.
    parameter                                       CREATE_OUTPUT_REG   = 0
)
(
    output  wire    [N_INSTANCES*(2*NB_DATA+1)-1:0] o_data_bus ,
    input   wire    [N_INSTANCES*(3*NB_DATA+0)-1:0] i_data_bus ,
    input   wire                                    i_valid ,
    input   wire                                    i_clock
) ;


    /* // BEGIN: Quick instance.
    gf_2toN_koa_merger_line
    #(
        .N_INSTANCES        (   ),
        .NB_DATA            (   ),
        .CREATE_OUTPUT_REG  (   )
    )
    u_gf_2toN_koa_merger_line
    (
        .o_data_bus         (   ),
        .i_data_bus         (   ),
        .i_valid            (   ),
        .i_clock            (   )
    ) ;
    // END: Quick instance. */


    // LOCAL PARAMETERS.
    // None so far.


    // INTERNAL SIGNALS.
    genvar                                          ii ;



    // ALGORITHM BEGIN.

    generate

        for ( ii=0; ii<N_INSTANCES; ii=ii+1 )
        begin : genfor_mergers

            wire    [2*NB_DATA+1-1:0]               ii_o_data_bus ;
            wire    [3*NB_DATA-0-1:0]               ii_i_data_bus ;

            assign  ii_i_data_bus
                        = i_data_bus[ ii*3*NB_DATA +: 3*NB_DATA ] ;

            gf_2toN_koa_merger
            #(
                .NB_DATA            ( NB_DATA               ),
                .CREATE_OUTPUT_REG  ( CREATE_OUTPUT_REG     )
            )
            u_gf_2toN_koa_merger
            (
                .o_data_bus         ( ii_o_data_bus         ),
                .i_data_bus         ( ii_i_data_bus         ),
                .i_valid            ( i_valid               ),
                .i_clock            ( i_clock               )
            ) ;

            assign  o_data_bus[ ii*(2*NB_DATA+1) +: 2*NB_DATA+1 ]
                        = ii_o_data_bus ;

        end // genfor_mergers

    endgenerate


endmodule // gf_2to128_multiplier_booth1

/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : gf_2toN_koa_splitter.v
 -- Author      : Ramiro R. Lopez and Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: gf_2toN_koa_splitter.v 10288 2017-01-05 13:48:15Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/


module gf_2toN_koa_splitter
#(
    parameter                                       NB_DATA             = 128 ,
    parameter                                       CREATE_OUTPUT_REG   = 0
)
(
    output  reg     [NB_DATA+NB_DATA+NB_DATA-1:0]   o_data_bus ,
    input   wire    [NB_DATA+NB_DATA-1:0]           i_data_bus ,
    input   wire                                    i_valid ,
    input   wire                                    i_clock
) ;


    /* // BEGIN: Quick instance.
    gf_2toN_koa_splitter
    #(
        .NB_DATA            (   ),
        .CREATE_OUTPUT_REG  (   )
    )
    u_gf_2toN_koa_splitter
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
    wire            [NB_DATA-1:0]                   data_i_x ;
    wire            [NB_DATA-1:0]                   data_i_y ;
    wire            [NB_DATA-1:0]                   data_hh ;
    wire            [NB_DATA-1:0]                   data_hl ;
    wire            [NB_DATA-1:0]                   data_ll ;
    wire            [NB_DATA+NB_DATA+NB_DATA-1:0]   data_o_bus ;



    // ALGORITHM BEGIN.


    assign  data_i_x
                = i_data_bus[ 0*NB_DATA +: NB_DATA ] ;
    assign  data_i_y
                = i_data_bus[ 1*NB_DATA +: NB_DATA ] ;


    assign  data_hh
                = { data_i_y[ 0*NB_DATA/2 +: NB_DATA/2 ],
                    data_i_x[ 0*NB_DATA/2 +: NB_DATA/2 ] } ;
    assign  data_hl
                = { data_i_y[ 0*NB_DATA/2 +: NB_DATA/2 ] ^ data_i_y[ 1*NB_DATA/2 +: NB_DATA/2 ],
                    data_i_x[ 0*NB_DATA/2 +: NB_DATA/2 ] ^ data_i_x[ 1*NB_DATA/2 +: NB_DATA/2 ] } ;
    assign  data_ll
                = { data_i_y[ 1*NB_DATA/2 +: NB_DATA/2 ],
                    data_i_x[ 1*NB_DATA/2 +: NB_DATA/2 ] } ;


    assign  data_o_bus
                = { data_ll, data_hl, data_hh } ;


    generate
        if ( CREATE_OUTPUT_REG != 0 )
        begin : genif_create_reg_out

            always @( posedge i_clock )
            begin : l_rout
                if ( i_valid )
                    o_data_bus
                        <= data_o_bus ;
            end // l_rout

        end // genif_create_reg_out
        else
        begin : genelse_create_reg_out

            always @( * )
            begin : l_wout
                o_data_bus
                    = data_o_bus ;
            end // l_wout

        end // genelse_create_reg_out
    endgenerate


endmodule // gf_2toN_koa_splitter

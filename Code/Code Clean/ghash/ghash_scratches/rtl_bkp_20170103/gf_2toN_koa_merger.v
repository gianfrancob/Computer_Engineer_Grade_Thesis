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
 -- $Id: gf_2toN_koa_merger.v 10288 2017-01-05 13:48:15Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/


module gf_2toN_koa_merger
#(
    parameter                                       NB_DATA             = 127 , // [HINT] Must be and odd number.
    parameter                                       CREATE_OUTPUT_REG   = 0
)
(
    output  reg     [2*NB_DATA+1-1:0]               o_data_bus ,
    input   wire    [3*NB_DATA+0-1:0]               i_data_bus ,
    input   wire                                    i_valid ,
    input   wire                                    i_clock
) ;


    /* // BEGIN: Quick instance.
    gf_2toN_koa_merger
    #(
        .NB_DATA            (   ),
        .CREATE_OUTPUT_REG  (   )
    )
    u_gf_2toN_koa_merger
    (
        .o_data_bus         (   ),
        .i_data_bus         (   ),
        .i_valid            (   ),
        .i_clock            (   )
    ) ;
    // END: Quick instance. */


    // LOCAL PARAMETERS.
    localparam                                      BAD_CONF    = ( NB_DATA % 2 ) == 0 ;


    // INTERNAL SIGNALS.
    wire            [NB_DATA-1:0]                   data_hh ;
    wire            [NB_DATA-1:0]                   data_hl ;
    wire            [NB_DATA-1:0]                   data_ll ;
    wire            [2*NB_DATA+1-1:0]               data_hh_ext ;
    wire            [2*NB_DATA+1-1:0]               data_hl_ext ;
    wire            [2*NB_DATA+1-1:0]               data_ll_ext ;
    wire            [2*NB_DATA+1-1:0]               data_sum ;



    // ALGORITHM BEGIN.


    assign  data_hh
                = i_data_bus[ 0*NB_DATA +: NB_DATA ] ;
    assign  data_hl
                = i_data_bus[ 1*NB_DATA +: NB_DATA ] ;
    assign  data_ll
                = i_data_bus[ 2*NB_DATA +: NB_DATA ] ;


    assign  data_hh_ext
                = { {NB_DATA+1{1'b0}}, data_hh } ;
    assign  data_hl_ext
                = { {NB_DATA/2+1{1'b0}}, data_hh^data_hl^data_ll, {NB_DATA/2+1{1'b0}} } ;
    assign  data_ll_ext
                = { data_ll, {NB_DATA+1{1'b0}} } ;


    assign  data_sum
                = data_ll_ext ^ data_hl_ext ^ data_hh_ext ;


    generate
        if ( CREATE_OUTPUT_REG != 0 )
        begin : genif_create_reg_out

            always @( posedge i_clock )
            begin : l_rout
                if ( i_valid )
                    o_data_bus
                        <= data_sum ;
            end // l_rout

        end // genif_create_reg_out
        else
        begin : genelse_create_reg_out

            always @( * )
            begin : l_wout
                o_data_bus
                    = data_sum ;
            end // l_wout

        end // genelse_create_reg_out
    endgenerate


endmodule // gf_2to128_multiplier_booth1

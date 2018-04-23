/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : subbytes_block.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: subkey_h_powers_generator.v 10314 2017-01-06 18:02:37Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module subkey_h_powers_generator
#(
    // PARAMETERS.
    parameter                                       NB_DATA         = 128 ,
    parameter                                       LOG2_NB_DATA    = 8 ,
    parameter                                       MAX_POWER       = 2
)
(
    // OUTPUTS.
    output  reg     [(MAX_POWER)*NB_DATA-1:0]       o_h_power_bus ,
    output  reg                                     o_powers_ready ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]                   i_subkey_h ,
    input   wire                                    i_valid ,
    input   wire                                    i_trigger ,
    input   wire                                    i_reset ,
    input   wire                                    i_clock
) ;


    /* // BEIGN: Quick instance.
    subkey_h_powers_generator
    #(
        .NB_DATA        (   ),
        .LOG2_NB_DATA   (   ),
        .MAX_POWER      (   )
    )
    u_subkey_h_powers_generator
    (
        .o_h_power_bus  (   ),
        .powers_ready_x (   ),
        .i_subkey_h     (   ),
        .i_valid        (   ),
        .i_trigger      (   ),
        .i_reset        (   ),
        .i_clock        (   )
    ) ;
    // END: Quick instance.*/


    // LOCAL PARAMETERS.
    localparam                                      BAD_CONF        = ( NB_DATA != 128 ) ;
    localparam                                      NB_COUNT        = LOG2_NB_DATA ;
    localparam      [NB_COUNT-1:0]                  MAX_POWER_M1    = MAX_POWER - 1 ;



    // ALGORITHM BEGIN.

    generate

        if ( MAX_POWER <= 1 )
        begin : genif_null_power

            reg                                             trigger_d ;

            always @( posedge i_clock )
                if ( i_valid )
                    o_h_power_bus
                        <= i_subkey_h ;

            always @( posedge i_clock )
                if ( i_reset )
                    trigger_d
                        <= 1'b0 ;
                else if ( i_valid && i_trigger )
                    trigger_d
                        <= 1'b1 ;

            always @( * )
                o_powers_ready
                    = trigger_d ;

        end // genif_null_power

        else
        begin : genelse_null_power

            // INTERNAL SIGNALS.
            reg                                             triggered ;
            reg             [NB_COUNT-1:0]                  count ;
            wire            [NB_DATA-1:0]                   h_power ;
            wire            [NB_DATA-1:0]                   h_power_prev ;
            wire                                            prod_ready ;
            reg                                             prod_ready_d ;
            reg                                             trigger_d ;
            wire                                            trigger_prod ;
            wire                                            powers_ready_x ;

            gf_2to128_multiplier_sequential
            #(
                .NB_DATA        ( NB_DATA       ),
                .LOG2_NB_DATA   ( LOG2_NB_DATA  )
            )
            u_gf_2to128_multiplier_sequential
            (
                .o_data_z       ( h_power       ),
                .o_prod_done    ( prod_ready    ),
                .i_data_x       ( i_subkey_h    ),
                .i_data_y       ( h_power_prev  ),
                .i_valid        ( i_valid       ),
                .i_trigger      ( trigger_prod  ),
                .i_reset        ( i_reset       ),
                .i_clock        ( i_clock       )
            ) ;

            always @( posedge i_clock )
            begin
                if ( i_reset || (i_valid && i_trigger) )
                    o_h_power_bus
                        <= { i_subkey_h, {(MAX_POWER-1)*NB_DATA{1'b0}} } ;
                else if ( i_valid && prod_ready && !powers_ready_x )
                    o_h_power_bus
                        <= { h_power, o_h_power_bus[ (MAX_POWER)*NB_DATA-1 : NB_DATA ] } ;
            end
            assign  h_power_prev
                        = o_h_power_bus[ (MAX_POWER)*NB_DATA-1 -: NB_DATA ] ;

            always @( posedge i_clock )
            begin
                if ( i_reset || ( i_valid && powers_ready_x && !i_trigger ) )
                    triggered
                        <= 1'b0 ;
                else if ( i_valid && i_trigger )
                    triggered
                        <= 1'b1 ;
            end
            always @( posedge i_clock )
            begin
                if ( i_reset )
                    count
                        <= {NB_COUNT{1'b1}} ;
                else if ( i_trigger && i_valid )
                    count
                        <= MAX_POWER_M1 ;
                else if ( i_valid && !powers_ready_x && prod_ready && triggered )
                    count
                        <= count - 1'b1 ;   // [HINT] Mismatch and carry drop intentional.
            end
            assign  powers_ready_x
                        = ( count == {NB_COUNT{1'b0}} ) ;

            always @( posedge i_clock )
                if ( i_reset || (i_valid && i_trigger) )
                    o_powers_ready
                        <= 1'b0 ;
                else if ( i_valid )
                    o_powers_ready
                        <= triggered & powers_ready_x ;

            always @( posedge i_clock )
                if ( i_reset )
                    trigger_d
                        <= 1'b0 ;
                else if ( i_valid )
                    trigger_d
                        <= i_trigger ;

            always @( posedge i_clock )
                if ( i_reset )
                    prod_ready_d
                        <= 1'b0 ;
                else if ( i_valid )
                    prod_ready_d
                        <= prod_ready ;

            assign  trigger_prod
                        = trigger_d | ( prod_ready_d & ~powers_ready_x ) ;

        end // genelse_null_power

    endgenerate



endmodule // ax_modular_multiplier

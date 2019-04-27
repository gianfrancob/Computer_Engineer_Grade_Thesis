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
 -- $Id: gf_2to128_multiplier_sequential.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : This module implements the modular product between an input
    four term polynomial with coefficients in Galois-Field{2^8} <i_column> and
    the AES cipher fixed polynomial {03}x^3+{01}x^2+{01}x^1+{02}x^0.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module gf_2to128_multiplier_sequential
#(
    // PARAMETERS.
    parameter                                   NB_DATA         = 128 ,
    parameter                                   LOG2_NB_DATA    = 8
)
(
    // OUTPUTS.
    output  wire    [NB_DATA-1:0]               o_data_z ,
    output  wire                                o_prod_done ,
    // INPUTS.
    input   wire    [NB_DATA-1:0]               i_data_x ,
    input   wire    [NB_DATA-1:0]               i_data_y ,
    input   wire                                i_valid ,
    input   wire                                i_trigger ,
    input   wire                                i_reset ,
    input   wire                                i_clock
) ;


    /* // BEIGN: Quick instance.
    gf_2to128_multiplier_sequential
    #(
        .NB_DATA        (   ),
        .LOG2_NB_DATA   (   )
    )
    u_gf_2to128_multiplier_sequential
    (
        .o_data_z       (   ),
        .o_prod_done    (   ),
        .i_data_x       (   ),
        .i_data_y       (   ),
        .i_valid        (   ),
        .i_trigger      (   ),
        .i_reset        (   ),
        .i_clock        (   )
    ) ;
    // END: Quick instance.*/


    // LOCAL PARAMETERS.
    localparam                                  BAD_CONF    = ( NB_DATA != 128 ) ;
    localparam      [NB_DATA-1:0]               R_X         = { 8'he1, 120'd0 } ;

    // INTERNAL SIGNALS.
    genvar                                      ii ;
    reg             [NB_DATA-1:0]               z_subprods ;
    reg             [NB_DATA-1:0]               v_subprods ;
    reg             [NB_DATA-1:0]               data_x ;
    reg                                         triggered ;
    reg             [LOG2_NB_DATA-1:0]          count ;
    wire                                        prod_done ;
    reg                                         prod_done_d ;


    // ALGORITHM BEGIN.


    // -----------------------------------------------------
    always @( posedge i_clock )
    begin : l_shifters
        if ( i_reset || (i_valid && i_trigger ) )
        begin
            z_subprods
                <= {NB_DATA{1'b0}} ;
            v_subprods
                <= i_data_y ;
            data_x
                <= i_data_x ;
        end
        else if ( i_valid && !prod_done )
        begin
            z_subprods
                <= z_subprods ^ ( {NB_DATA{data_x[ NB_DATA-1 ]}} & v_subprods ) ;
            v_subprods
                <= { 1'b0, v_subprods[ NB_DATA-1:1 ] } ^ ( {NB_DATA{v_subprods[ 0 ]}} & R_X ) ;
            data_x
                <= { data_x[NB_DATA-1-1:0], 1'b0 } ;
        end
    end // l_shifters


    // -----------------------------------------------------
    always @( posedge i_clock )
    begin
        if ( i_reset || ( i_valid && prod_done && !i_trigger ) )
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
                <= {LOG2_NB_DATA{1'b1}} ;
        else if ( i_valid && i_trigger )
            count
                <= {LOG2_NB_DATA{1'b0}} ;
        else if ( i_valid && !prod_done && triggered )
            count
                <= count + 1'b1 ;   // [HINT] Mismatch and carry drop intentional.
    end
    assign  prod_done
                = ( count == NB_DATA ) ;


    assign  o_data_z
                = z_subprods ;


    always @( posedge i_clock )
        if ( i_reset )
            prod_done_d
                <= 1'b0 ;
        else if ( i_valid )
            prod_done_d
                <= prod_done ;
    assign  o_prod_done
                = prod_done & ~prod_done_d ;



endmodule // ax_modular_multiplier

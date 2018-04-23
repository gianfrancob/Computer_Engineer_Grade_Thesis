/*------------------------------------------------------------------------------
 -- Project     : CL40GC
 -------------------------------------------------------------------------------
 -- File        : common_fix_delay_line.v
 -- Author      : Ramiro R. Lopez
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : 2010-Mar-27
 --
 -- Rev 0       : Initial release. RRL.
 -- Rev 1       : 20121107. Changed port declaration style.
 --
 -- $Id: common_fix_delay_line_w_valid.v 10419 2017-01-17 20:41:21Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : .
 -------------------------------------------------------------------------------
 -- Copyright (C) 2009 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

//`timescale  1ns/1ps

module common_fix_delay_line_w_valid
#(
    // PARAMETERS.
    parameter                               NB_DATA     = 8,
    parameter                               DELAY       = 10
)
(
    // OUTPUTS.
    output  wire    [NB_DATA-1:0]           o_data_out,

    // INPUTS.
    input   wire    [NB_DATA-1:0]           i_data_in,
    input   wire                            i_valid,
    input   wire                            i_reset,
    input   wire                            clock
);


    /*// BEGIN: Quick instance
    common_fix_delay_line_w_valid
    #(
        .NB_DATA        (  ),
        .DELAY          (  )
    )
    u_common_fix_delay_line_w_valid
    (
        .o_data_out     (  ),
        .i_data_in      (  ),
        .i_valid        (  ),
        .i_reset        (  ),
        .clock          (  )
    ) ;
    // END: Quick instance.*/



    // ALGORITHM BEGIN.


    generate
    //begin : gen_delay // Removed begin/end for synopsys...

        if ( DELAY <= 0 )
        begin : genif_0_delay

            assign  o_data_out  = i_data_in;

        end // genif_0_delay

        else if ( DELAY == 1 )
        begin : genif_1_delay

            reg             [NB_DATA-1:0]           delay_l;

            always @( posedge clock )
                if ( i_reset )
                    delay_l <= { NB_DATA {1'b0} };
                else if ( i_valid )
                    delay_l <= i_data_in;

            assign  o_data_out  = delay_l;

        end // genif_1_delay

        else if ( DELAY > 1 )
        begin : genif_no_01_delay

            reg             [DELAY*NB_DATA-1:0]     delay_l;

            always @( posedge clock )
                if ( i_reset )
                    delay_l <= { DELAY*NB_DATA {1'b0} };
                else if ( i_valid )
                    delay_l <= { delay_l[ DELAY*NB_DATA-1-NB_DATA : 0 ], i_data_in };

            assign  o_data_out  = delay_l[ DELAY*NB_DATA-1 -: NB_DATA ];

        end // genif_no_01_delay

    //end // gen_delay
    endgenerate


endmodule // common_fix_delay_line_w_valid

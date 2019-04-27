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
 -- $Id: subbytes_block.v 10705 2017-02-22 16:36:01Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved
 ------------------------------------------------------------------------------*/

module subbytes_block
#(
    // PARAMETERS.
    parameter                                           NB_BYTE             = 8 ,
    parameter                                           N_BYTES             = 16 ,
    parameter                                           CREATE_OUTPUT_REG   = 0 ,
    parameter                                           USE_LUT             = 1
)
(
    // OUTPUTS.
    output  wire    [N_BYTES * NB_BYTE - 1 : 0]         o_state ,
    output  wire                                        o_valid ,
    // INPUTS.
    input   wire    [N_BYTES * NB_BYTE - 1 : 0]         i_state ,
    input   wire                                        i_valid ,
    input   wire                                        i_reset ,
    input   wire                                        i_clock
) ;


    // LOCAL PARAMETERS.
    localparam                                          BAD_CONF            = ( NB_BYTE != 8 ) ;

    // INTERNAL SIGNALS.
    genvar                                              ii ;
    wire            [N_BYTES-1:0]                       valid_bus ;   // [NOTE] Only bit 0 is actually used.


    // ALGORITHM BEGIN.

    // Creating N_BYTES instances of S-Box block.
    generate
        for ( ii=0; ii<N_BYTES; ii=ii+1 )
        begin : genfor_sboxes

            // Local signals.
            wire    [NB_BYTE-1:0]                       ii_o_byte ;
            wire    [NB_BYTE-1:0]                       ii_i_byte ;

            // Global inputs to local input.
            assign  ii_i_byte
                        = i_state[ ii*NB_BYTE +: NB_BYTE ] ;

            if ( USE_LUT==1 )
            begin : genif_use_lut

            // S-Box instance.
            byte_substitution_box
            #(
                .NB_BYTE            ( NB_BYTE           ),
                .CREATE_OUTPUT_REG  ( CREATE_OUTPUT_REG )
            )
            u_byte_substitution_box__ii
            (
                .o_byte             ( ii_o_byte         ),
                .i_byte             ( ii_i_byte         ),
                .i_valid            ( i_valid           ),
                .i_clock            ( i_clock           )
            ) ;

            assign  valid_bus[  ii ]
                        = i_valid ;  // NOTE: Using unpiped valid.

            end // genif_use_lut

            else
            begin : genelse_use_lut

            // S-Box instance.
            byte_substitution_algorithm
            #(
                .NB_BYTE            ( NB_BYTE           ),
                .CREATE_OUTPUT_REG  ( 0                 )
            )
            u_byte_substitution_algorithm__ii
            (
                .o_byte             ( ii_o_byte         ),
                .o_valid            ( valid_bus[ ii ]   ),
                .i_byte             ( ii_i_byte         ),
                .i_valid            ( i_valid           ),
                .i_reset            ( i_reset           ),  // FIXME: Analizar fanout de reset.
                .i_clock            ( i_clock           )
            ) ;


            end // genelse_use_lut

            // Local output to global outputs.
            assign  o_state[ ii*NB_BYTE +: NB_BYTE ]    = ii_o_byte ;

        end // genfor_sboxes
    endgenerate

    assign  o_valid
                = valid_bus[ 0 ] ; // NOTE: Only bit 0 is used.

endmodule // subbytes_block

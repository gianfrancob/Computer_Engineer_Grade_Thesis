/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : byte_substitution_box.v
 -- Author      : Ramiro R. Lopez.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Apr 15, 2014
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: byte_substitution_box.v 10419 2017-01-17 20:41:21Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 1 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module byte_substitution_box
#(
    // PARAMETERS.
    parameter                                           NB_BYTE             = 8 ,   // HINT: Works only for 8.
    parameter                                           CREATE_OUTPUT_REG   = 0 ,
    parameter                                           USE_LUT             = 1
)
(
    // OUTPUTS.
    output  reg     [NB_BYTE-1:0]                       o_byte ,
    // INPUTS.
    input   wire    [NB_BYTE-1:0]                       i_byte ,
    input   wire                                        i_valid ,
    input   wire                                        i_clock
);

    // LOCAL PARAMETERS.
    localparam                                          BAD_CONF            = ( NB_BYTE != 8 ) ;

    // INTERNAL SIGNALS.
    wire            [NB_BYTE-1:0]                       sub_bytes_lut_array [((2**NB_BYTE)-1):0];

    // ALGORITHM BEGIN.
/*
    generate
        if ( USE_LUT != 0 )
        begin : genif_use_lut
*/
            assign  sub_bytes_lut_array[8'h00]  = 8'h63 ;
            assign  sub_bytes_lut_array[8'h01]  = 8'h7c ;
            assign  sub_bytes_lut_array[8'h02]  = 8'h77 ;
            assign  sub_bytes_lut_array[8'h03]  = 8'h7b ;
            assign  sub_bytes_lut_array[8'h04]  = 8'hf2 ;
            assign  sub_bytes_lut_array[8'h05]  = 8'h6b ;
            assign  sub_bytes_lut_array[8'h06]  = 8'h6f ;
            assign  sub_bytes_lut_array[8'h07]  = 8'hc5 ;
            assign  sub_bytes_lut_array[8'h08]  = 8'h30 ;
            assign  sub_bytes_lut_array[8'h09]  = 8'h01 ;
            assign  sub_bytes_lut_array[8'h0a]  = 8'h67 ;
            assign  sub_bytes_lut_array[8'h0b]  = 8'h2b ;
            assign  sub_bytes_lut_array[8'h0c]  = 8'hfe ;
            assign  sub_bytes_lut_array[8'h0d]  = 8'hd7 ;
            assign  sub_bytes_lut_array[8'h0e]  = 8'hab ;
            assign  sub_bytes_lut_array[8'h0f]  = 8'h76 ;

            assign  sub_bytes_lut_array[8'h10]  = 8'hca ;
            assign  sub_bytes_lut_array[8'h11]  = 8'h82 ;
            assign  sub_bytes_lut_array[8'h12]  = 8'hc9 ;
            assign  sub_bytes_lut_array[8'h13]  = 8'h7d ;
            assign  sub_bytes_lut_array[8'h14]  = 8'hfa ;
            assign  sub_bytes_lut_array[8'h15]  = 8'h59 ;
            assign  sub_bytes_lut_array[8'h16]  = 8'h47 ;
            assign  sub_bytes_lut_array[8'h17]  = 8'hf0 ;
            assign  sub_bytes_lut_array[8'h18]  = 8'had ;
            assign  sub_bytes_lut_array[8'h19]  = 8'hd4 ;
            assign  sub_bytes_lut_array[8'h1a]  = 8'ha2 ;
            assign  sub_bytes_lut_array[8'h1b]  = 8'haf ;
            assign  sub_bytes_lut_array[8'h1c]  = 8'h9c ;
            assign  sub_bytes_lut_array[8'h1d]  = 8'ha4 ;
            assign  sub_bytes_lut_array[8'h1e]  = 8'h72 ;
            assign  sub_bytes_lut_array[8'h1f]  = 8'hc0 ;

            assign  sub_bytes_lut_array[8'h20]  = 8'hb7 ;
            assign  sub_bytes_lut_array[8'h21]  = 8'hfd ;
            assign  sub_bytes_lut_array[8'h22]  = 8'h93 ;
            assign  sub_bytes_lut_array[8'h23]  = 8'h26 ;
            assign  sub_bytes_lut_array[8'h24]  = 8'h36 ;
            assign  sub_bytes_lut_array[8'h25]  = 8'h3f ;
            assign  sub_bytes_lut_array[8'h26]  = 8'hf7 ;
            assign  sub_bytes_lut_array[8'h27]  = 8'hcc ;
            assign  sub_bytes_lut_array[8'h28]  = 8'h34 ;
            assign  sub_bytes_lut_array[8'h29]  = 8'ha5 ;
            assign  sub_bytes_lut_array[8'h2a]  = 8'he5 ;
            assign  sub_bytes_lut_array[8'h2b]  = 8'hf1 ;
            assign  sub_bytes_lut_array[8'h2c]  = 8'h71 ;
            assign  sub_bytes_lut_array[8'h2d]  = 8'hd8 ;
            assign  sub_bytes_lut_array[8'h2e]  = 8'h31 ;
            assign  sub_bytes_lut_array[8'h2f]  = 8'h15 ;

            assign  sub_bytes_lut_array[8'h30]  = 8'h04 ;
            assign  sub_bytes_lut_array[8'h31]  = 8'hc7 ;
            assign  sub_bytes_lut_array[8'h32]  = 8'h23 ;
            assign  sub_bytes_lut_array[8'h33]  = 8'hc3 ;
            assign  sub_bytes_lut_array[8'h34]  = 8'h18 ;
            assign  sub_bytes_lut_array[8'h35]  = 8'h96 ;
            assign  sub_bytes_lut_array[8'h36]  = 8'h05 ;
            assign  sub_bytes_lut_array[8'h37]  = 8'h9a ;
            assign  sub_bytes_lut_array[8'h38]  = 8'h07 ;
            assign  sub_bytes_lut_array[8'h39]  = 8'h12 ;
            assign  sub_bytes_lut_array[8'h3a]  = 8'h80 ;
            assign  sub_bytes_lut_array[8'h3b]  = 8'he2 ;
            assign  sub_bytes_lut_array[8'h3c]  = 8'heb ;
            assign  sub_bytes_lut_array[8'h3d]  = 8'h27 ;
            assign  sub_bytes_lut_array[8'h3e]  = 8'hb2 ;
            assign  sub_bytes_lut_array[8'h3f]  = 8'h75 ;

            assign  sub_bytes_lut_array[8'h40]  = 8'h09 ;
            assign  sub_bytes_lut_array[8'h41]  = 8'h83 ;
            assign  sub_bytes_lut_array[8'h42]  = 8'h2c ;
            assign  sub_bytes_lut_array[8'h43]  = 8'h1a ;
            assign  sub_bytes_lut_array[8'h44]  = 8'h1b ;
            assign  sub_bytes_lut_array[8'h45]  = 8'h6e ;
            assign  sub_bytes_lut_array[8'h46]  = 8'h5a ;
            assign  sub_bytes_lut_array[8'h47]  = 8'ha0 ;
            assign  sub_bytes_lut_array[8'h48]  = 8'h52 ;
            assign  sub_bytes_lut_array[8'h49]  = 8'h3b ;
            assign  sub_bytes_lut_array[8'h4a]  = 8'hd6 ;
            assign  sub_bytes_lut_array[8'h4b]  = 8'hb3 ;
            assign  sub_bytes_lut_array[8'h4c]  = 8'h29 ;
            assign  sub_bytes_lut_array[8'h4d]  = 8'he3 ;
            assign  sub_bytes_lut_array[8'h4e]  = 8'h2f ;
            assign  sub_bytes_lut_array[8'h4f]  = 8'h84 ;

            assign  sub_bytes_lut_array[8'h50]  = 8'h53 ;
            assign  sub_bytes_lut_array[8'h51]  = 8'hd1 ;
            assign  sub_bytes_lut_array[8'h52]  = 8'h00 ;
            assign  sub_bytes_lut_array[8'h53]  = 8'hed ;
            assign  sub_bytes_lut_array[8'h54]  = 8'h20 ;
            assign  sub_bytes_lut_array[8'h55]  = 8'hfc ;
            assign  sub_bytes_lut_array[8'h56]  = 8'hb1 ;
            assign  sub_bytes_lut_array[8'h57]  = 8'h5b ;
            assign  sub_bytes_lut_array[8'h58]  = 8'h6a ;
            assign  sub_bytes_lut_array[8'h59]  = 8'hcb ;
            assign  sub_bytes_lut_array[8'h5a]  = 8'hbe ;
            assign  sub_bytes_lut_array[8'h5b]  = 8'h39 ;
            assign  sub_bytes_lut_array[8'h5c]  = 8'h4a ;
            assign  sub_bytes_lut_array[8'h5d]  = 8'h4c ;
            assign  sub_bytes_lut_array[8'h5e]  = 8'h58 ;
            assign  sub_bytes_lut_array[8'h5f]  = 8'hcf ;

            assign  sub_bytes_lut_array[8'h60]  = 8'hd0 ;
            assign  sub_bytes_lut_array[8'h61]  = 8'hef ;
            assign  sub_bytes_lut_array[8'h62]  = 8'haa ;
            assign  sub_bytes_lut_array[8'h63]  = 8'hfb ;
            assign  sub_bytes_lut_array[8'h64]  = 8'h43 ;
            assign  sub_bytes_lut_array[8'h65]  = 8'h4d ;
            assign  sub_bytes_lut_array[8'h66]  = 8'h33 ;
            assign  sub_bytes_lut_array[8'h67]  = 8'h85 ;
            assign  sub_bytes_lut_array[8'h68]  = 8'h45 ;
            assign  sub_bytes_lut_array[8'h69]  = 8'hf9 ;
            assign  sub_bytes_lut_array[8'h6a]  = 8'h02 ;
            assign  sub_bytes_lut_array[8'h6b]  = 8'h7f ;
            assign  sub_bytes_lut_array[8'h6c]  = 8'h50 ;
            assign  sub_bytes_lut_array[8'h6d]  = 8'h3c ;
            assign  sub_bytes_lut_array[8'h6e]  = 8'h9f ;
            assign  sub_bytes_lut_array[8'h6f]  = 8'ha8 ;

            assign  sub_bytes_lut_array[8'h70]  = 8'h51 ;
            assign  sub_bytes_lut_array[8'h71]  = 8'ha3 ;
            assign  sub_bytes_lut_array[8'h72]  = 8'h40 ;
            assign  sub_bytes_lut_array[8'h73]  = 8'h8f ;
            assign  sub_bytes_lut_array[8'h74]  = 8'h92 ;
            assign  sub_bytes_lut_array[8'h75]  = 8'h9d ;
            assign  sub_bytes_lut_array[8'h76]  = 8'h38 ;
            assign  sub_bytes_lut_array[8'h77]  = 8'hf5 ;
            assign  sub_bytes_lut_array[8'h78]  = 8'hbc ;
            assign  sub_bytes_lut_array[8'h79]  = 8'hb6 ;
            assign  sub_bytes_lut_array[8'h7a]  = 8'hda ;
            assign  sub_bytes_lut_array[8'h7b]  = 8'h21 ;
            assign  sub_bytes_lut_array[8'h7c]  = 8'h10 ;
            assign  sub_bytes_lut_array[8'h7d]  = 8'hff ;
            assign  sub_bytes_lut_array[8'h7e]  = 8'hf3 ;
            assign  sub_bytes_lut_array[8'h7f]  = 8'hd2 ;

            assign  sub_bytes_lut_array[8'h80]  = 8'hcd ;
            assign  sub_bytes_lut_array[8'h81]  = 8'h0c ;
            assign  sub_bytes_lut_array[8'h82]  = 8'h13 ;
            assign  sub_bytes_lut_array[8'h83]  = 8'hec ;
            assign  sub_bytes_lut_array[8'h84]  = 8'h5f ;
            assign  sub_bytes_lut_array[8'h85]  = 8'h97 ;
            assign  sub_bytes_lut_array[8'h86]  = 8'h44 ;
            assign  sub_bytes_lut_array[8'h87]  = 8'h17 ;
            assign  sub_bytes_lut_array[8'h88]  = 8'hc4 ;
            assign  sub_bytes_lut_array[8'h89]  = 8'ha7 ;
            assign  sub_bytes_lut_array[8'h8a]  = 8'h7e ;
            assign  sub_bytes_lut_array[8'h8b]  = 8'h3d ;
            assign  sub_bytes_lut_array[8'h8c]  = 8'h64 ;
            assign  sub_bytes_lut_array[8'h8d]  = 8'h5d ;
            assign  sub_bytes_lut_array[8'h8e]  = 8'h19 ;
            assign  sub_bytes_lut_array[8'h8f]  = 8'h73 ;

            assign  sub_bytes_lut_array[8'h90]  = 8'h60 ;
            assign  sub_bytes_lut_array[8'h91]  = 8'h81 ;
            assign  sub_bytes_lut_array[8'h92]  = 8'h4f ;
            assign  sub_bytes_lut_array[8'h93]  = 8'hdc ;
            assign  sub_bytes_lut_array[8'h94]  = 8'h22 ;
            assign  sub_bytes_lut_array[8'h95]  = 8'h2a ;
            assign  sub_bytes_lut_array[8'h96]  = 8'h90 ;
            assign  sub_bytes_lut_array[8'h97]  = 8'h88 ;
            assign  sub_bytes_lut_array[8'h98]  = 8'h46 ;
            assign  sub_bytes_lut_array[8'h99]  = 8'hee ;
            assign  sub_bytes_lut_array[8'h9a]  = 8'hb8 ;
            assign  sub_bytes_lut_array[8'h9b]  = 8'h14 ;
            assign  sub_bytes_lut_array[8'h9c]  = 8'hde ;
            assign  sub_bytes_lut_array[8'h9d]  = 8'h5e ;
            assign  sub_bytes_lut_array[8'h9e]  = 8'h0b ;
            assign  sub_bytes_lut_array[8'h9f]  = 8'hdb ;

            assign  sub_bytes_lut_array[8'ha0]  = 8'he0 ;
            assign  sub_bytes_lut_array[8'ha1]  = 8'h32 ;
            assign  sub_bytes_lut_array[8'ha2]  = 8'h3a ;
            assign  sub_bytes_lut_array[8'ha3]  = 8'h0a ;
            assign  sub_bytes_lut_array[8'ha4]  = 8'h49 ;
            assign  sub_bytes_lut_array[8'ha5]  = 8'h06 ;
            assign  sub_bytes_lut_array[8'ha6]  = 8'h24 ;
            assign  sub_bytes_lut_array[8'ha7]  = 8'h5c ;
            assign  sub_bytes_lut_array[8'ha8]  = 8'hc2 ;
            assign  sub_bytes_lut_array[8'ha9]  = 8'hd3 ;
            assign  sub_bytes_lut_array[8'haa]  = 8'hac ;
            assign  sub_bytes_lut_array[8'hab]  = 8'h62 ;
            assign  sub_bytes_lut_array[8'hac]  = 8'h91 ;
            assign  sub_bytes_lut_array[8'had]  = 8'h95 ;
            assign  sub_bytes_lut_array[8'hae]  = 8'he4 ;
            assign  sub_bytes_lut_array[8'haf]  = 8'h79 ;

            assign  sub_bytes_lut_array[8'hb0]  = 8'he7 ;
            assign  sub_bytes_lut_array[8'hb1]  = 8'hc8 ;
            assign  sub_bytes_lut_array[8'hb2]  = 8'h37 ;
            assign  sub_bytes_lut_array[8'hb3]  = 8'h6d ;
            assign  sub_bytes_lut_array[8'hb4]  = 8'h8d ;
            assign  sub_bytes_lut_array[8'hb5]  = 8'hd5 ;
            assign  sub_bytes_lut_array[8'hb6]  = 8'h4e ;
            assign  sub_bytes_lut_array[8'hb7]  = 8'ha9 ;
            assign  sub_bytes_lut_array[8'hb8]  = 8'h6c ;
            assign  sub_bytes_lut_array[8'hb9]  = 8'h56 ;
            assign  sub_bytes_lut_array[8'hba]  = 8'hf4 ;
            assign  sub_bytes_lut_array[8'hbb]  = 8'hea ;
            assign  sub_bytes_lut_array[8'hbc]  = 8'h65 ;
            assign  sub_bytes_lut_array[8'hbd]  = 8'h7a ;
            assign  sub_bytes_lut_array[8'hbe]  = 8'hae ;
            assign  sub_bytes_lut_array[8'hbf]  = 8'h08 ;

            assign  sub_bytes_lut_array[8'hc0]  = 8'hba ;
            assign  sub_bytes_lut_array[8'hc1]  = 8'h78 ;
            assign  sub_bytes_lut_array[8'hc2]  = 8'h25 ;
            assign  sub_bytes_lut_array[8'hc3]  = 8'h2e ;
            assign  sub_bytes_lut_array[8'hc4]  = 8'h1c ;
            assign  sub_bytes_lut_array[8'hc5]  = 8'ha6 ;
            assign  sub_bytes_lut_array[8'hc6]  = 8'hb4 ;
            assign  sub_bytes_lut_array[8'hc7]  = 8'hc6 ;
            assign  sub_bytes_lut_array[8'hc8]  = 8'he8 ;
            assign  sub_bytes_lut_array[8'hc9]  = 8'hdd ;
            assign  sub_bytes_lut_array[8'hca]  = 8'h74 ;
            assign  sub_bytes_lut_array[8'hcb]  = 8'h1f ;
            assign  sub_bytes_lut_array[8'hcc]  = 8'h4b ;
            assign  sub_bytes_lut_array[8'hcd]  = 8'hbd ;
            assign  sub_bytes_lut_array[8'hce]  = 8'h8b ;
            assign  sub_bytes_lut_array[8'hcf]  = 8'h8a ;

            assign  sub_bytes_lut_array[8'hd0]  = 8'h70 ;
            assign  sub_bytes_lut_array[8'hd1]  = 8'h3e ;
            assign  sub_bytes_lut_array[8'hd2]  = 8'hb5 ;
            assign  sub_bytes_lut_array[8'hd3]  = 8'h66 ;
            assign  sub_bytes_lut_array[8'hd4]  = 8'h48 ;
            assign  sub_bytes_lut_array[8'hd5]  = 8'h03 ;
            assign  sub_bytes_lut_array[8'hd6]  = 8'hf6 ;
            assign  sub_bytes_lut_array[8'hd7]  = 8'h0e ;
            assign  sub_bytes_lut_array[8'hd8]  = 8'h61 ;
            assign  sub_bytes_lut_array[8'hd9]  = 8'h35 ;
            assign  sub_bytes_lut_array[8'hda]  = 8'h57 ;
            assign  sub_bytes_lut_array[8'hdb]  = 8'hb9 ;
            assign  sub_bytes_lut_array[8'hdc]  = 8'h86 ;
            assign  sub_bytes_lut_array[8'hdd]  = 8'hc1 ;
            assign  sub_bytes_lut_array[8'hde]  = 8'h1d ;
            assign  sub_bytes_lut_array[8'hdf]  = 8'h9e ;

            assign  sub_bytes_lut_array[8'he0]  = 8'he1 ;
            assign  sub_bytes_lut_array[8'he1]  = 8'hf8 ;
            assign  sub_bytes_lut_array[8'he2]  = 8'h98 ;
            assign  sub_bytes_lut_array[8'he3]  = 8'h11 ;
            assign  sub_bytes_lut_array[8'he4]  = 8'h69 ;
            assign  sub_bytes_lut_array[8'he5]  = 8'hd9 ;
            assign  sub_bytes_lut_array[8'he6]  = 8'h8e ;
            assign  sub_bytes_lut_array[8'he7]  = 8'h94 ;
            assign  sub_bytes_lut_array[8'he8]  = 8'h9b ;
            assign  sub_bytes_lut_array[8'he9]  = 8'h1e ;
            assign  sub_bytes_lut_array[8'hea]  = 8'h87 ;
            assign  sub_bytes_lut_array[8'heb]  = 8'he9 ;
            assign  sub_bytes_lut_array[8'hec]  = 8'hce ;
            assign  sub_bytes_lut_array[8'hed]  = 8'h55 ;
            assign  sub_bytes_lut_array[8'hee]  = 8'h28 ;
            assign  sub_bytes_lut_array[8'hef]  = 8'hdf ;

            assign  sub_bytes_lut_array[8'hf0]  = 8'h8c ;
            assign  sub_bytes_lut_array[8'hf1]  = 8'ha1 ;
            assign  sub_bytes_lut_array[8'hf2]  = 8'h89 ;
            assign  sub_bytes_lut_array[8'hf3]  = 8'h0d ;
            assign  sub_bytes_lut_array[8'hf4]  = 8'hbf ;
            assign  sub_bytes_lut_array[8'hf5]  = 8'he6 ;
            assign  sub_bytes_lut_array[8'hf6]  = 8'h42 ;
            assign  sub_bytes_lut_array[8'hf7]  = 8'h68 ;
            assign  sub_bytes_lut_array[8'hf8]  = 8'h41 ;
            assign  sub_bytes_lut_array[8'hf9]  = 8'h99 ;
            assign  sub_bytes_lut_array[8'hfa]  = 8'h2d ;
            assign  sub_bytes_lut_array[8'hfb]  = 8'h0f ;
            assign  sub_bytes_lut_array[8'hfc]  = 8'hb0 ;
            assign  sub_bytes_lut_array[8'hfd]  = 8'h54 ;
            assign  sub_bytes_lut_array[8'hfe]  = 8'hbb ;
            assign  sub_bytes_lut_array[8'hff]  = 8'h16 ;

    generate
            if ( CREATE_OUTPUT_REG == 1 )
            begin : genif_create_out_reg
                always @( posedge i_clock )
                begin : l_regout
                    if ( i_valid )
                        o_byte
                            <= sub_bytes_lut_array[ i_byte ] ;
                end // l_regout
            end // genif_create_out_reg
            else
            begin : genelse_create_out_reg
                always @( * )
                begin : l_wireout
                    o_byte
                        = sub_bytes_lut_array[ i_byte ] ;
                end // l_wireout
            end // genelse_create_out_reg
    endgenerate
/*
        end // genif_use_lut

        else
        begin : genelse_use_lut

           wire            [NB_BYTE-1:0]                       byte_o ;

           byte_substitution_algorithm
            #(
                .NB_BYTE            ( NB_BYTE               ),
                .CREATE_OUTPUT_REG  ( CREATE_OUTPUT_REG     )
            )
            u_byte_substitution_algorithm
            (
                .o_byte             ( byte_o                ) ,
                .i_byte             ( i_byte                ) ,
                .i_valid            ( i_valid               ) ,
                .i_clock            ( i_clock               ) ,
                .i_reset            ( i_reset               )
            ) ;

            always @( * )
                o_byte
                    = byte_o ;

        end // genelse_use_lut

    endgenerate
*/

endmodule // byte_substitution_box

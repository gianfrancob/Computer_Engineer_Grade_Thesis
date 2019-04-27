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
 -- $Id: key_scheduler.v 10220 2016-12-28 19:02:56Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box LUT for 16 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/

module key_scheduler
#(
    // PARAMETERS.
    parameter                                                   NB_BYTE         = 8 ,
    parameter                                                   N_BYTES_STATE   = 16 ,
    parameter                                                   N_BYTES_KEY     = 32 ,
    parameter                                                   N_ROUNDS        = 14
)
(
    // OUTPUTS.
    output  wire    [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    o_round_key_vector ,
    // INPUTS.
    input   wire    [N_BYTES_KEY*NB_BYTE-1:0]                   i_key ,
    input   wire                                                i_valid ,
    input   wire                                                i_reset ,
    input   wire                                                i_clock
) ;

    // LOCAL PARAMETERS.
    localparam                                                  N_BYTES_WORD    = 4 ;
    localparam                                                  NB_WORD         = N_BYTES_WORD * NB_BYTE ;
    localparam                                                  NK              = N_BYTES_KEY / N_BYTES_WORD ; // 8.
    localparam                                                  N_STATE_WORDS   = N_BYTES_STATE / N_BYTES_WORD ;
    localparam                                                  NB_KEY_VECTOR   = N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1) ;
    localparam                                                  BAD_CONF        = ( NB_BYTE != 8 ) ;

    // INTERNAL SIGNALS.
    genvar                                                      ii ;
    genvar                                                      jj ;
    integer                                                     i ;
    integer                                                     ib ;
    wire            [NB_WORD-1:0]                               key_words [ N_STATE_WORDS * (N_ROUNDS+1)-1:0] ;
    wire            [NB_WORD-1:0]                               rcon [ NK-1:0] ;
    reg             [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    round_key_vector ;
    reg             [N_BYTES_STATE*NB_BYTE*(N_ROUNDS+1)-1:0]    round_key_vector_rwr ;


    // ALGORITHM BEGIN.

    // Rcon constant words.
    assign  rcon[ 0 ]   = 32'h01_00_00_00 ;
    assign  rcon[ 1 ]   = 32'h02_00_00_00 ;
    assign  rcon[ 2 ]   = 32'h04_00_00_00 ;
    assign  rcon[ 3 ]   = 32'h08_00_00_00 ;
    assign  rcon[ 4 ]   = 32'h10_00_00_00 ;
    assign  rcon[ 5 ]   = 32'h20_00_00_00 ;
    assign  rcon[ 6 ]   = 32'h40_00_00_00 ;
    assign  rcon[ 7 ]   = 32'h80_00_00_00 ;


    // Creating N_BYTES instances of S-Box block.
    generate
        for ( ii=0; ii<NK; ii=ii+1 )
        begin : genfor_first_key_sched
            assign  key_words[ N_STATE_WORDS*(N_ROUNDS+1)-1-ii ]
                        = i_key[ (NK-1-ii)*NB_WORD +: NB_WORD ] ;
        end // genfor_first_key_sched
    endgenerate


    generate
        for ( ii=NK; ii<N_STATE_WORDS*(N_ROUNDS+1); ii=ii+1 )
        begin : genfor_second_key_sched

            wire    [NB_WORD-1:0]                               temp_word_1 ;
            wire    [NB_WORD-1:0]                               temp_word_2 ;

            assign  temp_word_1
                        = key_words[ N_STATE_WORDS*(N_ROUNDS+1)-1-(ii-1) ] ;

            if ( ii%NK == 0 )
            begin : genif_mix_1
                wire    [NB_WORD-1:0]                           rot_word ;
                wire    [NB_WORD-1:0]                           sub_word ;

                assign  rot_word
                            = { temp_word_1[ NB_WORD-NB_BYTE-1 : 0 ], temp_word_1[ NB_WORD-1 -: NB_BYTE ] } ;

                subbytes_block
                #(
                    .NB_BYTE            ( NB_BYTE               ),
                    .N_BYTES            ( N_BYTES_WORD          ),
                    .CREATE_OUTPUT_REG  ( 0                     )
                )
                u_subbytes_block
                (
                    .o_state            ( sub_word              ),
                    .i_state            ( rot_word              ),
                    .i_valid            ( i_valid               ),
                    .i_reset            ( i_reset               ),
                    .i_clock            ( i_clock               )
                ) ;

                assign  temp_word_2
                            = sub_word ^ rcon[ (ii/NK)-1 ] ;
            end // genif_mix_1
            else if ( NK > 6 && ii%NK==4 )
            begin : genif_mix_2
                subbytes_block
                #(
                    .NB_BYTE            ( NB_BYTE               ),
                    .N_BYTES            ( N_BYTES_WORD          ),
                    .CREATE_OUTPUT_REG  ( 0                     )
                )
                u_subbytes_block
                (
                    .o_state            ( temp_word_2           ),
                    .i_state            ( temp_word_1           ),
                    .i_valid            ( i_valid               ),
                    .i_reset            ( i_reset               ),
                    .i_clock            ( i_clock               )
                ) ;
            end // genif_mix_2
            else
            begin : genelse_special_mix
                assign  temp_word_2
                            = temp_word_1 ;
            end // genelse_special_mix

            assign  key_words[ N_STATE_WORDS*(N_ROUNDS+1)-1-(ii) ]
                        = key_words[ N_STATE_WORDS*(N_ROUNDS+1)-1-(ii-NK) ] ^ temp_word_2 ;

        end // genfor_second_key_sched
    endgenerate


    // Cast array to output wire.
    always @( * )
    begin : l_array_cast
        for ( i=0; i<N_STATE_WORDS*(N_ROUNDS+1); i=i+1 )
            round_key_vector[ i*NB_WORD +: NB_WORD ]
                = key_words[ i ] ;
        for ( ib=0; ib<(N_ROUNDS+1); ib=ib+1 )
            round_key_vector_rwr  [ (             ib)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ]
                = round_key_vector[ (N_ROUNDS+1-1-ib)*N_BYTES_STATE*NB_BYTE +: N_BYTES_STATE*NB_BYTE ] ;
    end // l_array_cast


    // Conditional output register.
    common_fix_delay_line_w_valid
    #(
        .NB_DATA            ( NB_KEY_VECTOR         ),
        .DELAY              ( 1                     )
    )
    u_common_fix_delay_line_w_valid
    (
        .o_data_out         ( o_round_key_vector    ),
        .i_data_in          ( round_key_vector_rwr  ),
        .i_valid            ( i_valid               ),
        .i_reset            ( i_reset               ),
        .clock              ( i_clock               )
    ) ;


 // function automatic  [N_BYTES_KEY*NB_BYTE-1:0]   f_fliplr_bits ;
 //     input   [N_BYTES_KEY*NB_BYTE-1:0]       fi_data ;
 //     input   [N_BYTES_KEY*NB_BYTE-1:0]       fr_flipped_data ;
 //     integer                                 fr_i ;
 //     begin
 //         for ( fr_i=0; fr_i<N_BYTES_KEY*NB_BYTE; fr_i=fr_i+1 )
 //             fr_flipped_data[ fr_i ]
 //                 = fi_data[ N_BYTES_KEY*NB_BYTE - 1 - fr_i ] ;
 //         f_fliplr_bits
 //             = fi_data ;
 //     end
 // endfunction


endmodule // key_scheduler

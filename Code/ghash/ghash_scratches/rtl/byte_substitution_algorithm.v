/*------------------------------------------------------------------------------
 -- Project     : CL60010
 -------------------------------------------------------------------------------
 -- File        : byte_substitution_algorithm.v
 -- Author      : Gianfranco Barbiani.
 -- Originator  : Clariphy Argentina S.A. 
 -- Date        : Oct 4, 2016
 --
 -- Rev 0       : Initial release.
 --
 --
 -- $Id: byte_substitution_algorithm.v 10178 2016-12-22 20:26:34Z gbarbiani $
 -------------------------------------------------------------------------------
 -- Description : Implements S-Box for 1 byte. Can create an output
    register depending on a parameter.
 -------------------------------------------------------------------------------
 -- Copyright (C) 2016 ClariPhy Argentina S.A.  All rights reserved 
 ------------------------------------------------------------------------------*/
module byte_substitution_algorithm
#( // PARAMETERS.
    parameter                                           NB_BYTE             = 8 ,   // HINT: Works only for 8.
    parameter                                           CREATE_OUTPUT_REG   = 0     // Enable or Disable Output Registration
)
(
    // OUTPUTS.
    output      reg         [NB_BYTE-1:0]               o_byte,
    // INPUTS.
    input       wire        [NB_BYTE-1:0]               i_byte,
    input       wire                                    i_valid,
    input       wire                                    i_reset,
    input       wire                                    i_clock
) ;

    /* // QUICK_INSTANCE: BEGIN
    byte_substitution_algorithm
    #(
        .NB_BYTE            (  ),   // HINT: Works only for 8.
        .CREATE_OUTPUT_REG  (  )    // Enable or Disable Output Registration
    )
    u_byte_substitution_algorithm
    (
        .o_byte             (  ),
        .i_byte             (  ),
        .i_valid            (  ),
        .i_reset            (  ),
        .i_clock            (  )
    );
    // QUICK_INSTANCE: END */ 

    // LOCAL PARAMETERS.
    localparam                                          BAD_CONF    = ( NB_BYTE != 8 );
    localparam          [NB_BYTE-1:0]                   R_X         = 8'h63;
    localparam          [NB_BYTE-1:0]                   AFFINE_X    = 8'h1f;

    // INTERNAL SIGNALS.
    wire                [NB_BYTE-1:0]                   mult_inv;
    wire                [NB_BYTE-1:0]                   subprod[NB_BYTE-1:0];
    wire                [NB_BYTE-1:0]                   result;
    genvar                                              ii;

    // ALGORITHM BEGIN
    // Multiplicative Inverse Calculation
    multiplicative_inversion
    #(
        .NB_BYTE            ( NB_BYTE           ),  // [HINT] Works only if value is 8
        .CREATE_OUTPUT_REG  ( 1'b0              )
    )
    u_multiplicative_inversion
    (       
        .o_mult_inverse     ( mult_inv          ),   
        .i_data             ( i_byte            ),
        .i_clock            ( i_clock           ),
        .i_reset            ( i_reset           )
    );

    // Affine Transformation
    // generate
    //     assign subprod[0]   = { NB_BYTE{mult_inv[0]} } & AFFINE_X;
    //     for ( ii=1; ii<NB_BYTE; ii=ii+1 )
    //     begin : genfor_partial_products
    //         assign  subprod[ii] = subprod[ii-1] ^ ( { NB_BYTE{mult_inv[ii]} } & { AFFINE_X[NB_BYTE-1-ii:0], AFFINE_X[NB_BYTE-ii+:ii] } );
    //     end // genfor_partial_products
    // endgenerate

    // assign result   = subprod[NB_BYTE-1] ^ R_X;
    assign result
        = mult_inv ^ R_X;

    // Output Calculation
    generate
        if ( CREATE_OUTPUT_REG == 1 )
        begin: genif_create_out_reg
            always @( posedge i_clock )
            begin: l_regout
                if ( i_valid )
                    o_byte  <= result ;
            end // l_regout
        end // genif_create_out_reg
        else
        begin: genelse_create_out_reg
            always @( * )
            begin: l_wireout
                o_byte      = result ;
            end // l_wireout
        end // genelse_create_out_reg
    endgenerate

endmodule // byte_substitution_algorithm
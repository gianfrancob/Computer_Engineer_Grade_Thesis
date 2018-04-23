module multiplicative_inversion
#(
    // PARAMETERS
    parameter                                           NB_BYTE             = 8,    // [HINT] Works only if value is 8
    parameter                                           CREATE_OUTPUT_REG   = 0     // Enable or Disable Output Registration
)
(
    // OUTPUTS.
    output          reg         [NB_BYTE-1:0]           o_mult_inverse,
    // INPUTS.
    input           wire        [NB_BYTE-1:0]           i_data,
    input           wire                                i_clock,
    input           wire                                i_reset
) ;

    // QUICK_INSTANCE: BEGIN
    /*
    multiplicative_inversion
    #(
        .NB_BYTE            (  ),   // [HINT] Works only if value is 8
        .CREATE_OUTPUT_REG  (  )    // Enable or Disable Output Registration
    )
    u_multiplicative_inversion
    (
        .o_mult_inverse     (  ),
        .i_data             (  ),
        .i_clock            (  ),
        .i_reset            (  ) 
    ) ;
    */ // QUICK_INSTANCE: END

    // LOCAL PARAMETERS.
    localparam                                          NB_HALF_BYTE = NB_BYTE/2 ;

    // INTERNAL SIGNALS.
    wire            [NB_BYTE-1:0]                       delta;
    wire            [NB_BYTE-1:0]                       inv_delta;
    wire            [NB_BYTE-1:0]                       byte_concat;
    wire            [NB_HALF_BYTE-1:0]                  delta_h;
    wire            [NB_HALF_BYTE-1:0]                  delta_l;
    wire            [NB_HALF_BYTE-1:0]                  delta_hl;
    wire            [NB_HALF_BYTE-1:0]                  xto2;
    wire            [NB_HALF_BYTE-1:0]                  x_times_lambda;
    wire            [NB_HALF_BYTE-1:0]                  prod;
    wire            [NB_HALF_BYTE-1:0]                  inv_q;
    wire            [NB_HALF_BYTE-1:0]                  prod2_1;
    wire            [NB_HALF_BYTE-1:0]                  prod2_2;
    wire            [NB_HALF_BYTE-1:0]                  aux_xor;

    reg             [NB_HALF_BYTE-1:0]                  delta_h_reg;
    reg             [NB_HALF_BYTE-1:0]                  x_times_lambda_reg;
    reg             [NB_HALF_BYTE-1:0]                  prod_reg;
    reg             [NB_HALF_BYTE-1:0]                  delta_hl_reg;

    // ALGORITHM BEGIN
    byte_isomorphic_mapping
    #(
        .NB_DATA            ( NB_BYTE   )
    )
    u_byte_isomorphic_mapping
    (
        .o_delta            ( delta     ),
        .i_q                ( i_data    )
    ) ;


    assign delta_h  = delta[NB_BYTE-1:NB_HALF_BYTE];
    assign delta_l  = delta[NB_HALF_BYTE-1:0];
    assign delta_hl = delta_h ^ delta_l ;

    gf_2to4_squarer
    #(
        .NB_DATA            ( NB_HALF_BYTE  )
    )
    u_gf_2to4_squarer
    (
        .o_xto2             ( xto2          ),
        .i_x                ( delta_h       )
    ) ;

    gf_2to4_multiplier_with_constant_lambda
    #(
        .NB_DATA            ( NB_HALF_BYTE      )
    )
    u_gf_2to4_multiplier_with_constant_lambda
    (
        .o_x_times_lambda   ( x_times_lambda    ),
        .i_x                ( xto2              )
    ) ;

    gf_2to4_multiplier
    #(
        .NB_DATA            ( NB_HALF_BYTE  ),
        .CREATE_OUTPUT_REG  ( 1'b0          )
    )
    u_gf_2to4_multiplier1
    (
        .o_prod             ( prod          ),
        .i_x                ( delta_hl      ),
        .i_y                ( delta_l       ),
        .i_clock            ( i_clock       )
    ) ;
 
    //======================    PIPE: BEGIN     =============================
    always @( posedge i_clock ) begin
        if( i_reset ) begin
            delta_h_reg         <= { NB_HALF_BYTE{1'b0} };
            x_times_lambda_reg  <= { NB_HALF_BYTE{1'b0} };
            prod_reg            <= { NB_HALF_BYTE{1'b0} };
            delta_hl_reg        <= { NB_HALF_BYTE{1'b0} };
        end else begin
            delta_h_reg         <= delta_h;
            x_times_lambda_reg  <= x_times_lambda;
            prod_reg            <= prod;
            delta_hl_reg        <= delta_hl;
        end
    end
    //======================    PIPE: END       =============================
    
    assign aux_xor  = x_times_lambda_reg ^ prod_reg ;

    gf_2to4_multiplicative_inversion
    #(
        .NB_DATA            ( NB_HALF_BYTE  )
    )
    u_gf_2to4_multiplicative_inversion
    (
        .o_inv_q            ( inv_q         ),
        .i_q                ( aux_xor       )
    );
    
    gf_2to4_multiplier
    #(
        .NB_DATA            ( NB_HALF_BYTE      ),
        .CREATE_OUTPUT_REG  ( 1'b1 )                // 2nd Stage of PIPES

    )
    u_gf_2to4_multiplier2_1
    (
        .o_prod             ( prod2_1           ),
        .i_x                ( inv_q             ),
        .i_y                ( delta_h_reg       ),
        .i_clock            ( i_clock           )
    );

    gf_2to4_multiplier
    #(
        .NB_DATA            ( NB_HALF_BYTE      ),
        .CREATE_OUTPUT_REG  ( 1'b1 )                // 2nd Stage of PIPES
    )
    u_gf_2to4_multiplier2_2
    (
        .o_prod             ( prod2_2           ),
        .i_x                ( inv_q             ),
        .i_y                ( delta_hl_reg      ),
        .i_clock            ( i_clock           )
    );

    assign byte_concat  = { prod2_1, prod2_2 };

    byte_inverse_isomorphic_mapping
    #(
        .NB_DATA            ( NB_BYTE           )
    )
    u_byte_inverse_isomorphic_mapping
    (
        .o_inv_delta        ( inv_delta         ),
        .i_q                ( byte_concat       )
    ) ;

    generate
        if ( CREATE_OUTPUT_REG == 1'b1 )
        begin : genif_create_out_reg
            always @( posedge i_clock ) begin
                o_mult_inverse  <= inv_delta;
            end
        end // genif_create_out_reg
        else
        begin : genelse_create_out_reg
            always @( * )
            begin : l_wireout
                o_mult_inverse  = inv_delta;
            end // l_wireout
        end // genelse_create_out_reg
    endgenerate

endmodule // multiplicative_inversion
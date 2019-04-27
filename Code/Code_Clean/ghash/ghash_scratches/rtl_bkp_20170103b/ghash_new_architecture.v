module ghash_new_architecture
#(
    // PARAMETERS
    parameter                                   NB_BLOCK    = 128,
    parameter                                   N_BLOCKS    = 2,
    parameter                                   NB_DATA     = N_BLOCKS*NB_BLOCK,
    parameter                                   N_H_POW     = 4
)
(
    // OUTPUTS
    output  wire    [NB_BLOCK-1:0]              o_data_y,
    // INPUTS
    input   wire    [NB_DATA-1:0]               i_data_x,
    input   wire    [N_H_POW*NB_BLOCK-1:0]      i_h_key_powers,
    input   wire    [N_BLOCKS-1:0]              i_skip_bus,
    input   wire                                i_sop,
    input   wire                                i_valid,
    input   wire                                i_reset,
    input   wire                                i_clock
);

    // QUICK INSTANCE: BEGIN
    /*
    ghash_new_architecture
    #(
        // PARAMETERS
        .NB_BLOCK       (  ),
        .N_BLOCKS       (  ),
        .NB_DATA        (  ),
        .N_H_POW        (  )
    )
    u_ghash_new_architecture
    (
        // OUTPUTS
        .o_data_y       (  ),
        // INPUTS
        .i_data_x       (  ),
        .i_h_key_powers (  ),
        .i_skip_bus     (  ),
        .i_sop          (  ),
        .i_valid        (  ),
        .i_reset        (  ),
        .i_clock        (  )
    );
    */
    // QUICK INSTANCE: END

    // INTERNAL SIGNALS
    wire            [NB_DATA-1:0]               h_key;
    wire            [NB_BLOCK-1:0]              mux_feedback;
    wire            [NB_BLOCK-1:0]              data_x_even;
    wire            [NB_BLOCK-1:0]              data_x_odd;
    wire            [NB_BLOCK-1:0]              data_x_feedback;
    wire            [NB_BLOCK-1:0]              data_y_even;
    wire            [NB_BLOCK-1:0]              data_y_odd;
    wire            [NB_BLOCK-1:0]              data_y_feedback;
    wire            [2*NB_BLOCK-1-1:0]          data_z_even;
    wire            [2*NB_BLOCK-1-1:0]          data_z_odd;
    wire            [2*NB_BLOCK-1-1:0]          data_z_feedback;
    wire            [NB_BLOCK-1-1:0]            overflow_prod;
    wire            [NB_BLOCK-1-1:0]            overflow_feedback;
    wire            [NB_BLOCK-1:0]              reminder_prod;
    wire            [NB_BLOCK-1:0]              reminder_feedback;
    wire            [NB_BLOCK-1:0]              mod_prod;
    wire            [NB_BLOCK-1:0]              mod_feedback;
    wire            [2*NB_BLOCK-1-1:0]          q_aux;
    reg             [2*NB_BLOCK-1-1:0]          q[2:0];
    reg                                         even;

    // ALGORITHM BEGIN
    always @( posedge i_clock ) begin
        if ( i_reset )
            even    <=  1'b1;       // Reset in previous clock to sop
        else
            even    <= ~even;
    end

    assign h_key
        = ( even ) ?    i_h_key_powers[NB_DATA+:NB_DATA]   :
                        i_h_key_powers[0+:NB_DATA]         ;

    assign mux_feedback
        = ( even ) ?    { NB_BLOCK{1'b0} }  :
                        mod_feedback        ;

    // MULTIPLICATIONS
    // Even Multiplier INPUTS
    assign data_x_even
        =  i_data_x[0+:NB_BLOCK] ^ mux_feedback;
    assign data_y_even
        =  h_key[NB_BLOCK+:NB_BLOCK];

    // Even Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK     ),
        .CREATE_OUTPUT_REG   ( 0            )
    )
    u_gf_2toN_koa_generated_even
    (
        .o_data_z            ( data_z_even  ),
        .i_data_y            ( data_y_even  ),
        .i_data_x            ( data_x_even  ),
        .i_valid             ( i_valid      ),
        .i_reset             ( i_reset      ),
        .i_clock             ( i_clock      )
    ) ;

    // Odd Multiplier INPUTS
    assign data_x_odd
        =  i_data_x[NB_BLOCK+:NB_BLOCK]  ;
    assign data_y_odd
        =  h_key[0+:NB_BLOCK]  ;

    // Odd Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK     ),
        .CREATE_OUTPUT_REG   ( 0            )
    )
    u_gf_2toN_koa_generated_odd
    (
        .o_data_z            ( data_z_odd   ),
        .i_data_y            ( data_y_odd   ),
        .i_data_x            ( data_x_odd   ),
        .i_valid             ( i_valid      ),
        .i_reset             ( i_reset      ),
        .i_clock             ( i_clock      )
    ) ;

    // SUBPRODUCTS REGISTRATION
    always @( * ) begin
        if ( i_reset )
            q[0]   = { (2*NB_BLOCK-1){1'b0} };
        else
            q[0]   = data_z_even ^ data_z_odd;
    end

    assign q_aux = q[0];

    always @( posedge i_clock) begin
        if ( i_reset )
            q[1]   <= { (2*NB_BLOCK-1){1'b0} };
        else
            q[1]   <= q_aux;
    end

    always @( * ) begin
        if ( i_reset )
            q[2]   = { (2*NB_BLOCK-1){1'b0} };
        else
            q[2]   = q[0] ^ q[1];
    end

    // MODULE CALCULATION
    assign overflow_prod
        = q[2][NB_BLOCK-1-1:0];

    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_BLOCK-1    ),
        .NB_DATA            ( NB_BLOCK      )
      )
    u_gf_2to128_multiplier_booth1_subrem_prod
    (
        .o_sub_remainder    ( reminder_prod ),
        .i_data             ( overflow_prod )
     );

    assign mod_prod
        = q[2][2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_prod;

    // FEEDBACK
    // Feddback Multiplier INPUTS
    assign data_x_feedback
        =  mod_prod;
    assign data_y_feedback
        =  i_h_key_powers[1*NB_BLOCK+:NB_BLOCK]  ;

    // Feedback Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK         ),
        .CREATE_OUTPUT_REG   ( 0                )
    )
    u_gf_2toN_koa_generated_feedback
    (
        .o_data_z            ( data_z_feedback  ),
        .i_data_y            ( data_y_feedback  ),
        .i_data_x            ( data_x_feedback  ),
        .i_valid             ( 1'b1             ),
        .i_reset             ( i_reset          ),
        .i_clock             ( i_clock          )
    ) ;

    // Feedback Module Calculation
    assign overflow_feedback
        = data_z_feedback[NB_BLOCK-1-1:0] ;

    gf_2to128_multiplier_booth1_subrem
    #(
        .N_SUBPROD          ( NB_BLOCK-1            ),
        .NB_DATA            ( NB_BLOCK              )
      )
    u_gf_2to128_multiplier_booth1_subrem_feedback
    (
        .o_sub_remainder    ( reminder_feedback     ),
        .i_data             ( overflow_feedback     )
     ) ;

    assign mod_feedback
        = data_z_feedback[2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_feedback ;

    // OUTPUT CALCULATION
    assign o_data_y
        = ( even )  ?  mod_prod : o_data_y ;

endmodule   // ghash_new_architecture
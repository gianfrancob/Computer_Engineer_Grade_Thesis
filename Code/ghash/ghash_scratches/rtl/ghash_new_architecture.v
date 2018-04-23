module ghash_new_architecture
#(
    // PARAMETERS
    parameter                                   NB_BLOCK    = 128,
    parameter                                   N_BLOCKS    = 2,
    parameter                                   NB_DATA     = N_BLOCKS*NB_BLOCK,
    parameter                                   N_H_POW     = 8
)
(
    // OUTPUTS
    output  wire    [NB_BLOCK-1:0]              o_data_y,
    // INPUTS
    input   wire    [NB_DATA-1:0]               i_data_x,
    input   wire    [NB_BLOCK-1:0]              i_aad,
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
        .i_aad          (  ),
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
    reg             [NB_DATA-1:0]               h_key;
    reg             [NB_BLOCK-1:0]              mux_feedback;
    wire            [NB_BLOCK-1:0]              data_x_even;
    wire            [NB_BLOCK-1:0]              data_x_odd;
    wire            [NB_BLOCK-1:0]              data_x_feedback;
    wire            [NB_BLOCK-1:0]              data_y_even;
    wire            [NB_BLOCK-1:0]              data_y_odd;
    wire            [NB_BLOCK-1:0]              data_y_feedback;
    wire            [2*NB_BLOCK-1-1:0]          data_z_even;
    wire            [2*NB_BLOCK-1-1:0]          data_z_odd;
    wire            [2*NB_BLOCK-1-1:0]          data_z_feedback;
    reg             [2*NB_BLOCK-1-1:0]          data_z_even_reg;    
    reg             [2*NB_BLOCK-1-1:0]          data_z_odd_reg;
    reg             [2*NB_BLOCK-1-1:0]          data_z_feedback_reg;
    wire            [NB_BLOCK-1-1:0]            overflow_prod;
    wire            [NB_BLOCK-1-1:0]            overflow_feedback;
    wire            [NB_BLOCK-1:0]              reminder_prod;
    wire            [NB_BLOCK-1:0]              reminder_feedback;
    wire            [NB_BLOCK-1:0]              mod_prod;
    wire            [NB_BLOCK-1:0]              mod_feedback;
    reg             [NB_BLOCK-1:0]              mod_feedback_reg;
    wire            [2*NB_BLOCK-1-1:0]          q_aux;
    reg             [2*NB_BLOCK-1-1:0]          q[4:0];
    integer                                     count;
    reg             [1:0]                       count2;
    reg                                         start_of_count;
    reg                                         accept_aad;
    wire            [NB_BLOCK-1:0]              aad_mux;

    // ALGORITHM BEGIN

    always @( posedge i_clock ) begin
        if ( i_reset ) begin
            count   <=  0;
        end else if ( i_valid ) begin
            if ( start_of_count )
                count   <= count+1;
            else
                count   <= count;
        end
    end


    always @( posedge i_clock ) begin
        if ( i_reset )
            count2  <=  2'd0;
        else if ( i_valid ) begin
            if ( start_of_count )
                count2  <= count2 + 1'b1;
            else
                count2  <= count2;
        end
    end

    always @( posedge i_clock ) begin
        if ( i_reset )
            h_key   =  i_h_key_powers[3*NB_DATA+:NB_DATA];
        else if ( i_valid ) begin
            if ( count2 == 2'd3 )
                h_key   =  i_h_key_powers[3*NB_DATA+:NB_DATA];
            else if ( count2 == 2'd0 )
                h_key   =  i_h_key_powers[2*NB_DATA+:NB_DATA];
            else if ( count2 == 2'd1 )
                h_key   =  i_h_key_powers[1*NB_DATA+:NB_DATA];
            else if ( count2 == 2'd2 )
                h_key   =  i_h_key_powers[0*NB_DATA+:NB_DATA];
            else
                h_key   = i_h_key_powers[3*NB_DATA+:NB_DATA];
        end
    end
      always @( * ) begin
        if (i_reset ) begin
            start_of_count  = 1'b0;
            accept_aad  = 1'b0;
        end else begin
            start_of_count = ( i_sop || start_of_count );
            accept_aad     = ( i_sop || accept_aad && (count<1) );
        end
    end
    assign aad_mux
        =   ( accept_aad && i_valid )         ?
            i_aad               :
            { NB_BLOCK{1'b0} }  ;
     always @( posedge i_clock ) begin
        if ( i_reset )
            mux_feedback    =  { NB_BLOCK{1'b0} };
        else if ( i_valid ) begin 
            if ( ( (count+1)%4 == 0) && ( (count+1)>7 ) && !(accept_aad && i_valid)  )
                mux_feedback    =   mod_feedback;
            else
                mux_feedback    =   aad_mux;
        end
    end


    // MULTIPLICATIONS
    // Even Multiplier INPUTS
    assign data_x_even
        =  (i_data_x[0+:NB_BLOCK] ^ mux_feedback);
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
    

    always @( posedge i_clock )
    begin: delayed_multipliers_outputs
        if ( i_reset ) begin
            data_z_even_reg     <= { (2*NB_BLOCK-1){1'b0} };
            data_z_odd_reg      <= { (2*NB_BLOCK-1){1'b0} };
        end else if ( i_valid ) begin
            data_z_even_reg     <= data_z_even;
            data_z_odd_reg      <= data_z_odd;
        end
    end

    // SUBPRODUCTS REGISTRATION    
    always @( * ) begin
        if ( i_reset )
            q[0]   = { (2*NB_BLOCK-1){1'b0} };
        else 
            q[0]   = data_z_even_reg ^ data_z_odd_reg;
    end

    always @( posedge i_clock)
    begin: partial_results_registration
        if ( i_reset ) begin
            q[1]   <= { (2*NB_BLOCK-1){1'b0} };
            q[2]   <= { (2*NB_BLOCK-1){1'b0} };
            q[3]   <= { (2*NB_BLOCK-1){1'b0} };
        end else if ( i_valid ) begin
            q[1]   <= q[0];
            q[2]   <= q[1];
            q[3]   <= q[2];
        end
    end

    always @( * ) begin
        if ( i_reset )
            q[4]   = { (2*NB_BLOCK-1){1'b0} };
        else 
            q[4]   = q[0] ^ q[1] ^ q[2] ^ q[3];     // Acumulator
    end

    // MODULE CALCULATION
    assign overflow_prod
        = q[4][NB_BLOCK-1-1:0];

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
        = q[4][2*NB_BLOCK-1-1:NB_BLOCK-1] ^ reminder_prod;

    reg     [NB_BLOCK-1:0]  mod_prod_reg;
    always @( posedge i_clock ) begin
        if ( i_reset )
            mod_prod_reg    <= { NB_BLOCK{1'b0} };
        else if ( i_valid )
            mod_prod_reg    <= mod_prod;
    end

    // FEEDBACK
    // Feddback Multiplier INPUTS
    assign data_x_feedback
        =  mod_prod_reg;
    assign data_y_feedback
        =  i_h_key_powers[7*NB_BLOCK+:NB_BLOCK]  ;

    // Feedback Multiplication
    gf_2toN_koa_generated
    #(
        .NB_DATA             ( NB_BLOCK     )   ,
        .CREATE_OUTPUT_REG   ( 0 )   
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

    always @( posedge i_clock ) begin
        if ( i_reset )
            data_z_feedback_reg     <= { (2*NB_BLOCK-1){1'b0} };
        else if ( i_valid )
            data_z_feedback_reg     <= data_z_feedback;
    end

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
    always @( posedge i_clock ) begin
        if ( i_reset )
            mod_feedback_reg    <= { NB_BLOCK{1'b0} };
        else if ( i_valid )
            mod_feedback_reg    <= mux_feedback;
    end

    assign o_data_y
        = mod_prod ^ mod_feedback_reg ;

endmodule   // ghash_new_architecture
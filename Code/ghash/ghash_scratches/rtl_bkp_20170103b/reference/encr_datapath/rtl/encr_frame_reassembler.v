//% ----------------------------------------------------------------------------
//% Project     : M200
//% ----------------------------------------------------------------------------
//% \encr_frame_reassembler
//% \ingroup TBD
//% \author Omar Tarif
//% \date Jun 28, 2016
//% Originator  : Clariphy Argentina S.A.
//%
//% Rev 0       : Initial release.
//%
//% $Id: encr_frame_reassembler.v 10644 2017-02-15 17:06:41Z gbarbiani $
//% ----------------------------------------------------------------------------
//% Description : encr_frame_reassembler
//%
//% \image html encr_frame_reassembler.png
//% ----------------------------------------------------------------------------
//% \copyright Copyright (C) 2015 ClariPhy Argentina S.A.  All rights reserved
//% ----------------------------------------------------------------------------

module encr_frame_reassembler

#(
    //PARAMETERS
    parameter                                           NB_DATA                         =  256  ,
    parameter                                           NB_FRAME_OH                     =  16*8 ,
    parameter                                           NB_ENCRIPTION_OH                =  4*64 ,
    parameter                                           NB_COUNTER                      =  16   ,
    parameter                                           NB_ADDRESS                      =  4    //3     
)
(

    output wire     [NB_DATA            -1 : 0]         o_data,    
    output wire                                         o_valid,
    output wire                                         o_sof,
    
    output wire                                         o_encr_oh_req,

    input wire      [NB_DATA            -1 : 0]         i_payload_data,
    input wire                                          i_payload_data_valid,
    input wire      [NB_ENCRIPTION_OH   -1 : 0]         i_encription_oh,
    input wire      [NB_FRAME_OH        -1 : 0]         i_frame_oh,    
    input wire                                          i_sof,
    input wire                                          i_valid,
    input wire                                          i_resync,
    input wire                                          i_qlast,
    input wire      [NB_ADDRESS         -1 : 0]         i_rf_static_start_address,
    input wire                                          i_rf_static_enable, 
    output wire     [NB_COUNTER         -1 : 0]         o_rf_static_overflow_counter,
    output wire     [NB_COUNTER         -1 : 0]         o_rf_static_underflow_counter,

    input wire                                          i_clock,
    input wire                                          i_reset
);

    // LOCAL PARAMETERS.
    localparam                                          NB_AUX_BUFFER              = 192 ;
    localparam                                          NB_BLOCK                   = 64  ;
    localparam                                          NB_COL_COUNTER             = 14  ;
    localparam                                          NB_ROW_COUNTER             = 2   ;
    localparam                                          ROW_COUNTER_LIMIT          = 3   ;
    localparam                                          COL_COUNTER_LIMIT          = 126 ;
    localparam                                          COL_COUNTER_LIMIT_PLUS_ONE = 127 ;
    localparam                                          DELAY_INT_SOF              = 10  ;
    localparam                                          NB_ROW_ENCR_OH             = 64  ;
    localparam                                          N_ADDRESS                  = 16  ;
    localparam                                          FIRST_ROW                  = 0   ;
    localparam                                          SECOND_ROW                 = 1   ;
    localparam                                          THIRD_ROW                  = 2   ;
    localparam                                          FOURTH_ROW                 = 3   ;
    localparam                                          FIRST_COL                  = 0   ;
    localparam                                          ENC_OH_COL                 = 119 ;
    localparam                                          ENC_OH_REQ_COL             = 100 ;
    localparam                                          FEC_COL                    = 120 ;


    // INTERNAL SIGNALS.

    reg         [NB_AUX_BUFFER -1  :0]                  aux_buffer;              
    reg         [NB_COL_COUNTER-1  :0]                  col_counter;              
    reg         [NB_ROW_COUNTER-1  :0]                  row_counter;   
    wire                                                row_counter_limit;           
    wire                                                col_counter_limit; 
    wire        [NB_COL_COUNTER-1  :0]                  col_counter_limit_sel; 
    reg                                                 plus_one; 
    reg                                                 first_sof; 
    reg         [DELAY_INT_SOF -1:0]                    sof_sr; 
    wire                                                insert_fec;
    wire                                                stop_read;
    wire                                                internal_sof;
    wire                                                auxiliar;
    wire                                                enable_buffer;


    /***********************************************************************************/
    /*                               SYNC LOGIC                                        */
    /***********************************************************************************/    
    reg                             first_qlast;

    always @(posedge i_clock) 
    begin
        if(i_reset || i_resync || !i_rf_static_enable )
            first_qlast <= 1'b1;
        else if (i_valid && i_qlast )
            first_qlast <= 1'b0;
    end

    always @(posedge i_clock) 
    begin
        if(i_reset || i_resync || first_qlast)
            first_sof <= 1'b1;
        else if (i_valid && i_sof && i_rf_static_enable)
            first_sof <= 1'b0;
    end
    
    always @(posedge i_clock) 
    begin
        if(i_reset)
            sof_sr <= 0;
        else if (i_valid && i_rf_static_enable)
        begin
            sof_sr <= {sof_sr[DELAY_INT_SOF -2 : 0], auxiliar} ;            
        end
    end

    assign auxiliar = i_sof & first_sof;
    assign internal_sof = sof_sr[9] & i_valid; // 0

    reg sof_d;

    always @ (posedge i_clock)
    begin
        if(i_reset)
            sof_d <= 1'b0;
        else if(i_valid && i_rf_static_enable ) begin
            sof_d <= i_sof;
        end
    end
    /***********************************************************************************/
    /*                           PAYLOAD DATA FIFO                                     */
    /***********************************************************************************/
    wire        [NB_DATA            -1 : 0]         payload_data;

    encr_payload_fifo
    #(
        .NB_DATA                           (NB_DATA                        ),
        .N_ADRESS                          (N_ADDRESS                      ),
        .NB_ADRESS                         (NB_ADDRESS                     ),
        .NB_COUNTER                        (NB_COUNTER                     )
    
    )
    u_payload_fifo
    (
        .o_data                            ( payload_data                  ),
        .i_stop_read                       ( stop_read                     ),
        .o_fifo_level                      (                               ),
        .i_data                            ( i_payload_data                ),
        .i_valid                           ( i_payload_data_valid          ),
        .i_restart_wr_ptr                  ( first_sof                     ),
        .i_rf_static_start_address         ( i_rf_static_start_address     ),
        .i_rf_static_enable                ( i_rf_static_enable            ),
        .o_rf_static_overflow_counter      ( o_rf_static_overflow_counter  ),
        .o_rf_static_underflow_counter     ( o_rf_static_underflow_counter ),
        .i_clock                           ( i_clock                       ),
        .i_reset                           ( i_reset | first_sof           )
    );

    /***********************************************************************************/
    /*                           ROW COLS COUNTERS                                     */
    /***********************************************************************************/

    assign col_counter_limit_sel = ( plus_one ) ? COL_COUNTER_LIMIT_PLUS_ONE[NB_COL_COUNTER-1 :0] : COL_COUNTER_LIMIT[NB_COL_COUNTER-1 :0];
    assign row_counter_limit     = ( (row_counter == ROW_COUNTER_LIMIT[NB_ROW_COUNTER -1:0]) && col_counter_limit );
    assign col_counter_limit     = ( col_counter == col_counter_limit_sel );

    always @(posedge i_clock) begin
        if( i_reset || internal_sof ) 
        begin
            col_counter <= {NB_COL_COUNTER{1'b0}};
            plus_one    <= 1'b0;
        end
        else if ( i_valid && i_rf_static_enable ) 
        begin
            if( col_counter_limit )
            begin
                col_counter <= {NB_COL_COUNTER{1'b0}};
                plus_one    <= ~plus_one;
            end
            else 
            begin
                col_counter <= col_counter + 1'b1;
            end
        end
    end

    always @(posedge i_clock) begin
        if( i_reset || internal_sof )
            row_counter <= {NB_ROW_COUNTER{1'b0}};
        else if ( i_valid && i_rf_static_enable ) 
        begin
            if( row_counter_limit )
                row_counter <= {NB_ROW_COUNTER{1'b0}};
            else if ( col_counter_limit )
                row_counter <= row_counter + 1'b1;
        end
    end

    /***********************************************************************************/
    /*                              OH MUX AND REQUEST LOGIC                           */
    /***********************************************************************************/
    wire                                oh_request;
    reg                                 oh_request_d;
    reg     [NB_ENCRIPTION_OH -1 :0]    encr_oh;
    wire    [NB_ROW_ENCR_OH   -1 :0]    row_oh;

    assign oh_request = ( (col_counter == ENC_OH_REQ_COL[NB_COL_COUNTER-1:0]) && (row_counter == FIRST_ROW [NB_ROW_COUNTER-1:0]) && i_valid );


    always @(posedge i_clock) 
    begin
        if( i_reset )
            oh_request_d <= 1'b0;
        else if( i_valid && i_rf_static_enable)
            oh_request_d <= oh_request;
    end

    always @(posedge i_clock) 
    begin
        if( oh_request_d && i_rf_static_enable)
            encr_oh <= i_encription_oh;        
    end

    assign row_oh = encr_oh[NB_ENCRIPTION_OH - row_counter*NB_ROW_ENCR_OH -1 -: NB_ROW_ENCR_OH]; 
    /***********************************************************************************/
    /*                                 AUX PAYLOAD BUFFER                              */
    /***********************************************************************************/
    wire        first_row;
    wire        second_row;
    wire        third_row;
    wire        fourth_row;
    wire        first_row_stop_read;

    
    assign first_row           = ( ( col_counter == ENC_OH_COL[NB_COL_COUNTER-1:0] ) && (row_counter == FIRST_ROW [NB_ROW_COUNTER-1:0] ) );
    assign second_row          = ( ( col_counter == ENC_OH_COL[NB_COL_COUNTER-1:0] ) && (row_counter == SECOND_ROW[NB_ROW_COUNTER-1:0] ) );
    assign third_row           = ( ( col_counter == FIRST_COL[NB_COL_COUNTER-1:0]  ) && (row_counter == FOURTH_ROW[NB_ROW_COUNTER-1:0] ) );
    assign fourth_row          = ( ( col_counter == ENC_OH_COL[NB_COL_COUNTER-1:0] ) && (row_counter == FOURTH_ROW[NB_ROW_COUNTER-1:0] ) );
    assign first_row_stop_read = ( ( col_counter == FIRST_COL[NB_COL_COUNTER-1:0]  ) && (row_counter == SECOND_ROW[NB_ROW_COUNTER-1:0] ) );

    assign enable_buffer = stop_read;
    assign stop_read = (insert_fec | first_row_stop_read | first_row | second_row | third_row | fourth_row) | !i_valid;


    always @(posedge i_clock) begin
        if( i_reset )
            aux_buffer <= {NB_AUX_BUFFER{1'b0}};
        else if ( i_valid && !enable_buffer )
            aux_buffer <= payload_data[0 +: 3*NB_BLOCK];
    end

    /***********************************************************************************/
    /*                                 OH SEL MUX                                      */
    /***********************************************************************************/

    wire        [NB_DATA -1       :0]                   oh_to_insert;
    wire        [2*NB_BLOCK -1    :0]                   data_with_oh;    

    assign oh_to_insert = ( row_counter[0] ) ? {{NB_BLOCK{1'b0}}, {NB_BLOCK{1'b0}}, i_frame_oh} : {i_frame_oh, data_with_oh};  
    //assign data_with_oh = ( row_counter[1] ) ?  aux_buffer[NB_BLOCK +: 2*NB_BLOCK] : payload_data[NB_DATA -1 -: 2*NB_BLOCK];  
    assign data_with_oh = ( row_counter[1] ) ?  payload_data[0 +: 2*NB_BLOCK] : payload_data[NB_DATA -1 -: 2*NB_BLOCK];  

    /***********************************************************************************/
    /*                            ENCRIPTION OH SEL MUX                                */
    /***********************************************************************************/
    reg         [NB_DATA -1       :0]                   encr_oh_to_insert;

    always @(*)
    begin: encr_oh_sel_logic
        case(row_counter)
            FIRST_ROW [NB_ROW_COUNTER-1:0]: encr_oh_to_insert = {aux_buffer[NB_BLOCK +: NB_BLOCK], row_oh, {NB_BLOCK{1'b0}}, {NB_BLOCK{1'b0}} };
            SECOND_ROW[NB_ROW_COUNTER-1:0]: encr_oh_to_insert = {aux_buffer[0 +: NB_BLOCK], payload_data[NB_DATA -1 -: 2*NB_BLOCK], row_oh };
            THIRD_ROW [NB_ROW_COUNTER-1:0]: encr_oh_to_insert = {payload_data[NB_DATA -1 -: NB_BLOCK], row_oh, {NB_BLOCK{1'b0}}, {NB_BLOCK{1'b0}} };
            FOURTH_ROW[NB_ROW_COUNTER-1:0]: encr_oh_to_insert = {aux_buffer, row_oh };
          default: encr_oh_to_insert = {aux_buffer, row_oh };
        endcase
    end //encr_oh_sel_logic

    /***********************************************************************************/
    /*                               PAYLOAD SELECTION                                 */
    /***********************************************************************************/
    reg         [NB_DATA -1       :0]                   payload_to_insert;

    always @(*)
    begin: payload_sel_logic
        case(row_counter)
            FIRST_ROW [NB_ROW_COUNTER-1:0]: payload_to_insert = {aux_buffer[0 +: 2*NB_BLOCK], payload_data[2*NB_BLOCK +: 2*NB_BLOCK]}; 
            SECOND_ROW[NB_ROW_COUNTER-1:0]: payload_to_insert = {aux_buffer[0 +: NB_BLOCK], payload_data[NB_BLOCK   +: 3*NB_BLOCK]}; 
            THIRD_ROW [NB_ROW_COUNTER-1:0]: payload_to_insert = payload_data; 
            FOURTH_ROW[NB_ROW_COUNTER-1:0]: payload_to_insert = {aux_buffer, payload_data[3*NB_BLOCK +: NB_BLOCK]}; 
          default: payload_to_insert = payload_data; 
        endcase
    end //encr_oh_sel_logic

    /***********************************************************************************/
    /*                               FRAME ASSEMBLY                                    */
    /***********************************************************************************/
    wire        [NB_DATA -1       :0]                   all_fec; 
    wire                                                insert_oh;    
    wire                                                insert_encr_oh;
    reg         [NB_DATA -1       :0]                   output_data; 
    reg                                                 output_sof; 
    wire                                                to_output_sof; 

    assign all_fec = {NB_DATA{1'b0}};

    assign insert_oh      = ( col_counter == FIRST_COL[NB_COL_COUNTER-1:0] );    
    assign insert_encr_oh = ( col_counter == ENC_OH_COL[NB_COL_COUNTER-1:0]);
    assign insert_fec     = ( col_counter >= FEC_COL[NB_COL_COUNTER-1:0]   );

    always @(posedge i_clock) begin
        if( i_reset )
            output_data <= {NB_DATA{1'b0}};
        else if ( i_valid && i_rf_static_enable )
        begin
            if( insert_oh )
                output_data <= oh_to_insert;
            else if( insert_encr_oh )
                output_data <= encr_oh_to_insert;
            else if ( insert_fec )
                output_data <= all_fec;
            else 
                output_data <= payload_to_insert;
        end
    end

    assign to_output_sof = ( insert_oh && (row_counter == 0 ) );  

    always @(posedge i_clock)
    begin
        if( i_reset )
            output_sof <= 1'b0;
        else if(i_valid && i_rf_static_enable)     
            output_sof <= to_output_sof;
    end


assign o_data        = output_data;
assign o_sof         = output_sof;
assign o_valid       = i_valid;
assign o_encr_oh_req = oh_request;

endmodule //encr_frame_reassembler

//% ----------------------------------------------------------------------------
//% Project     : M200
//% ----------------------------------------------------------------------------
//% \encr_payload_fifo
//% \ingroup TBD
//% \author Omar Tarif
//% \date Jun 28, 2016
//% Originator  : Clariphy Argentina S.A.
//%
//% Rev 0       : Initial release.
//%
//% $Id: encr_payload_fifo.v 10644 2017-02-15 17:06:41Z gbarbiani $
//% ----------------------------------------------------------------------------
//% Description : encr_payload_fifo
//%
//% \image html encr_payload_fifo.png
//% ----------------------------------------------------------------------------
//% \copyright Copyright (C) 2015 ClariPhy Argentina S.A.  All rights reserved
//% ----------------------------------------------------------------------------

module encr_payload_fifo

#(
    //PARAMETERS
    parameter                                           NB_DATA                         =  256  ,
    parameter                                           N_ADRESS                        =  8    ,
    parameter                                           NB_ADRESS                       =  3    ,   
    parameter                                           NB_COUNTER                      =  16
    
)
(

    output wire     [NB_DATA            -1 : 0]         o_data,    
    output wire     [NB_ADRESS          -1 : 0]         o_fifo_level,

    input wire                                          i_stop_read,
    input wire      [NB_DATA            -1 : 0]         i_data,
    input wire                                          i_valid,
    input wire                                          i_restart_wr_ptr,
    input wire      [NB_ADRESS          -1 : 0]         i_rf_static_start_address,
    input wire                                          i_rf_static_enable, 
    output wire     [NB_COUNTER         -1 : 0]         o_rf_static_overflow_counter,
    output wire     [NB_COUNTER         -1 : 0]         o_rf_static_underflow_counter,

    input wire                                          i_clock,
    input wire                                          i_reset
);

    localparam                                          LAST_ADDRESS  = N_ADRESS -1;

    wire            [NB_DATA            -1 : 0]         fifo_data;
    wire            [NB_DATA            -1 : 0]         to_output_data;
    reg             [NB_DATA            -1 : 0]         fifo_mem  [N_ADRESS -1 : 0];
    reg             [NB_ADRESS          -1 : 0]         wr_ptr;
    wire            [NB_ADRESS          -1 : 0]         wr_ptr_inc;
    reg             [NB_ADRESS          -1 : 0]         rd_ptr;
    wire            [NB_ADRESS          -1 : 0]         fill_level;
    reg             [NB_ADRESS          -1 : 0]         start_counter;
    reg                                                 start_flag;
    wire                                                fifo_empty;
    wire                                                fifo_rd;
    wire                                                fifo_full;    


    assign to_output_data  = ( i_rf_static_enable ) ? fifo_data  : i_data  ;

    //Write ptr logic
    always @( posedge i_clock ) 
    begin
        if ( i_reset || ~i_rf_static_enable || i_restart_wr_ptr)
            wr_ptr <= {NB_ADRESS{1'b0}};
        else if ( i_valid )
        begin
            if ( ( wr_ptr == LAST_ADDRESS[NB_ADRESS -1:0] ) )
                wr_ptr <= {NB_ADRESS{1'b0}};
            else
                wr_ptr <= wr_ptr_inc;
        end            
    end

    assign wr_ptr_inc = wr_ptr + 1;
    
    //Write data into fifo_mem
    always @( posedge i_clock ) 
    begin
    if( i_valid && i_rf_static_enable )
        fifo_mem[ wr_ptr ] <= i_data;
    end

    //Read ptr logic
    always @( posedge i_clock ) 
    begin
        if ( i_reset || ~i_rf_static_enable )
            rd_ptr <= {NB_ADRESS{1'b0}};

        else if ( fifo_rd )
        begin
            if ( rd_ptr == LAST_ADDRESS[NB_ADRESS -1:0] )
                rd_ptr <= {NB_ADRESS{1'b0}};
            else
                rd_ptr <= rd_ptr +1 ;
        end                    
    end

    //Start counter - Fill half of the FIFO before read data.
    always @(posedge i_clock)
        if ( i_reset || ~i_rf_static_enable  )
        begin
            start_counter <= {NB_ADRESS{1'b0}};
            start_flag    <= 1'b0; 
        end
        else if( i_valid )
        begin
            if ( start_counter < i_rf_static_start_address )
            begin
                start_counter <= start_counter +1;
                start_flag <= 1'b0;
            end
            else 
            begin
                start_flag <= 1'b1;
            end
        end

    assign fifo_empty = ( wr_ptr == rd_ptr ) ;
    assign fifo_full  = ( ( wr_ptr_inc == rd_ptr ) || ( (wr_ptr_inc == N_ADRESS[NB_ADRESS -1:0]) && (rd_ptr == {NB_ADRESS{1'b0}} ) ) );
    
    assign fifo_rd    = !i_stop_read & start_flag;
    
    assign fill_level = (wr_ptr >= rd_ptr) ? wr_ptr - rd_ptr : ( N_ADRESS[NB_ADRESS -1:0] -rd_ptr + wr_ptr ) ;        
                  
    assign fifo_data  = fifo_mem[ rd_ptr ];

    /*********************************************************************************************************/
    /*                                                COUNTERS                                               */
    /*********************************************************************************************************/
    reg     [NB_COUNTER-1 :0]   overflows_count ;
    reg     [NB_COUNTER-1 :0]   underflows_count;

    always @(posedge i_clock ) begin
        if (i_reset || ~i_rf_static_enable) begin
            overflows_count <= {NB_COUNTER{1'b0}};
        end
        else if ( fifo_full ) begin
            overflows_count <= overflows_count + 1'b1;
        end
    end

    always @(posedge i_clock ) begin
        if (i_reset || ~i_rf_static_enable ) begin
            underflows_count <= {NB_COUNTER{1'b0}};
        end
        else if ( fifo_empty ) begin
            underflows_count <= underflows_count + 1'b1;
        end
    end
    
//    //outputs regs
//    always @( posedge i_clock )
//    begin
//        output_data  <= to_output_data;
//    end

    assign o_data                         = to_output_data;
    assign o_fifo_level                   = fill_level;
    assign o_rf_static_underflow_counter  = underflows_count;
    assign o_rf_static_overflow_counter   = overflows_count;




endmodule //encr_payload_fifo
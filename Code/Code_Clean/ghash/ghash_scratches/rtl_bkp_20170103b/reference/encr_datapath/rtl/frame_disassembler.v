//% ----------------------------------------------------------------------------
//% Project     : M200
//% ----------------------------------------------------------------------------
//% \class frame_disassembler
//% \ingroup TBD
//% \author Fernando Romero
//% \date Sep 7, 2016
//% Originator  : Clariphy Argentina S.A.
//%
//% Rev 0       : Initial release.
//%
//% $Id: frame_disassembler.v 10644 2017-02-15 17:06:41Z gbarbiani $
//% ----------------------------------------------------------------------------
//% Description :
//% Splits data contained in frame. Frame OH goes to reassembler.
//% encryption overhead goes to control block.
//% and payload goes to AES core
//%
//% \image html frame_disassembler.png
//% ----------------------------------------------------------------------------
//% \copyright Copyright (C) 2015 ClariPhy Argentina S.A.  All rights reserved
//% ----------------------------------------------------------------------------
module frame_disassembler
#(
    // PARAMETERS.
    parameter                                           NB_DATA                  =  256        ,
    parameter                                           NB_INIT_VECTOR           =  96         ,
    parameter                                           NB_ENCR_OVERHEAD         =  64         ,
    parameter                                           NB_FRAME_OVERHEAD        =  128        , //sent by row
    parameter                                           NB_ROW                   =  2          ,
    parameter                                           NB_AAD                   =  512         
)
(
    // OUTPUTS:
    // Data to AES 
    output wire    [NB_DATA                - 1 : 0 ]    o_payload_data                         ,
    output wire                                         o_start                                ,
    output wire                                         o_last                                 ,
    output wire                                         o_cen                                  ,
    output wire    [NB_DATA                - 1 : 0 ]    o_key                                  ,
    output wire    [NB_INIT_VECTOR         - 1 : 0 ]    o_init_vector                          ,
    output wire                                         o_insert_add                           ,

    // Data to frame reassembler
    output wire    [NB_FRAME_OVERHEAD      - 1 : 0 ]    o_frame_oh                             ,
    output wire                                         o_resync                               ,
    // Data to control 
    output wire    [NB_ENCR_OVERHEAD       - 1 : 0 ]    o_encr_oh                              ,
    output wire                                         o_encr_oh_rdy                          ,
    output wire    [NB_ROW                 - 1 : 0 ]    o_encr_oh_row                          ,
    output wire                                         o_core_idle                            ,
    
    // INPUTS:
    // Data interface
    input wire     [NB_DATA                - 1 : 0 ]    i_data                                 ,
    input wire                                          i_valid                                ,
    input wire                                          i_sof                                  ,

    // Configurations for AES
    input wire     [NB_DATA                - 1 : 0 ]    i_key                                  ,
    input wire     [NB_INIT_VECTOR         - 1 : 0 ]    i_init_vector                          ,
    input wire     [NB_AAD                 - 1 : 0 ]    i_aad                                  ,

    // RF's 

    // CLOCKS & RESETS.
    input wire                                          i_clock                                ,
    input wire                                          i_reset                                
);
    // LOCAL PARAMETERS.
    localparam                                          NB_COUNTER              =   9          ;
    localparam                                          NB_COL_COUNTER          =   8          ;
    localparam                                          NB_ROW_COUNTER          =   2          ;
    localparam                                          NB_BUFFER               =   192        ; // 3/4 of a word 
    localparam                                          NB_POINTER              =   2          ;
    localparam                                          QUARTER                 =   NB_DATA / 4;
    localparam                                          FRAME_COLUMNS           =   4080       ;
    localparam                                          COL_COUNTER_LIMIT       =   126        ;
    localparam                                          COL_COUNTER_LIMIT_PLUS_ONE = 127       ;
    localparam                                          ROW_COUNTER_LIMIT       =   3          ;
    localparam                                          SOF_COUNTER_LIMIT       =   510        ;
    localparam                                          NB_SOF_RESYNC           =   3          ;
    localparam                                          CONST_1                 =   1          ;
    localparam                                          START_CNT_VAL           =   18         ;
    localparam                                          LAST_CNT_VAL            =   11         ;
    localparam                                          HALF_NB_AAD             =   256        ;
    // INTERNAL SIGNALS    
    // Frame Col Counter
    reg            [NB_COL_COUNTER        - 1 : 0 ]     col_counter                            ; //otarif
    //reg            [NB_COUNTER        - 1 : 0 ]         col_counter                            ;
    reg            [NB_ROW_COUNTER        - 1 : 0 ]     row_counter                            ;

    //Frame Dissasembler
    wire                                                freeze_buffer                          ;
    reg            [NB_BUFFER             - 1 : 0 ]     aux_data_buffer                        ;
    reg            [NB_DATA               - 1 : 0 ]     output_data                            ;
    

    //**************************************************
    // Sof Predictor
    //**************************************************
    reg            [NB_COUNTER            - 1 : 0 ]     sof_counter                            ;
    wire           [NB_COUNTER            - 1 : 0 ]     sof_counter_next                       ;
    wire                                                generated_sof                          ;
    reg                                                 first_sof                              ;
    wire                                                resync                                 ;  
    reg                                                 resync_d                               ; 
    reg            [NB_SOF_RESYNC         - 1 : 0 ]     sof_resync_d                           ; 
    reg                                                 sof_resync                             ; 

    always @(posedge i_clock)
    begin
        if(i_reset || resync_d)
            first_sof <= 1'b 1;
        else if (i_sof && i_valid)
            first_sof <= 1'b 0;
    end

    always @(posedge i_clock)
    begin
        if(i_reset || first_sof && i_sof)
            sof_counter <=  {{(NB_COUNTER-1){1'b 0}}, 1'b1 };//1'b 1 otarif
        else if(i_valid)
        begin
            if(generated_sof)
                sof_counter <= 1;
            else
                sof_counter <= sof_counter_next;
        end
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            resync_d <= 1'b 0;
        else if(i_valid)
            resync_d <= resync;
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            sof_resync <= 1'b 0;
        else if(resync_d)
            sof_resync <= 1'b 1;
        else if(i_sof)
            sof_resync <= 1'b 0;
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            sof_resync_d <=  {NB_SOF_RESYNC{1'b 0}};
        else if(i_sof)
        begin
            sof_resync_d <= {sof_resync_d[NB_SOF_RESYNC -2 : 0], sof_resync};
        end
    end


    assign sof_counter_next = sof_counter + { {NB_COUNTER-1{1'b 0}}, {1'b 1}};
    assign generated_sof = (sof_counter == SOF_COUNTER_LIMIT ) ? 1'b 1 : 1'b 0;
    assign resync = (i_sof ^ generated_sof) && ~first_sof;
    assign o_resync = sof_resync_d[NB_SOF_RESYNC-1];
    
    
    //**************************************************
    // Start Pulse Generation
    //**************************************************
    reg            [NB_COUNTER            - 1 : 0 ]     start_counter                          ;
    wire           [NB_COUNTER            - 1 : 0 ]     start_counter_next                     ;  
    reg                                                 start                                  ;  

    always @(posedge i_clock)
    begin
        if(i_reset | i_sof)
            start_counter <= START_CNT_VAL[NB_COUNTER-1:0];//{ {NB_COUNTER-5{1'b 0}}, {5'b 10010}}; // Restarts in TBD otarif
        else
            if(i_valid)
                start_counter <= start_counter_next;
    end

    always @(posedge i_clock)
    begin
        if(i_reset)
            start <= 1'b 0;
        else
            if(i_valid)
                start <= (start_counter == {NB_COUNTER{1'b 0}} ) ? 1'b 1 : 1'b 0;
    end

    assign start_counter_next = start_counter + { {NB_COUNTER-1{1'b 0}}, {1'b 1}};
    //assign o_start = (start_counter == {NB_COUNTER{1'b 0}} ) ? 1'b 1 : 1'b 0;
    assign o_start = start;
    assign o_key = i_key;
    assign o_init_vector = i_init_vector; //borism was o_init_vector = o_init_vector
    
    //**************************************************
    // Last Pulse Generation
    //**************************************************
    reg            [NB_COUNTER            - 1 : 0 ]     last_counter                           ;
    wire           [NB_COUNTER            - 1 : 0 ]     last_counter_next                      ;

    always @(posedge i_clock)
    begin
        if(i_reset | o_start)
            last_counter <= LAST_CNT_VAL[NB_COUNTER-1:0];//{ {NB_COUNTER-4{1'b 0}}, {4'b 1011}}; // Restarts in 8 or 9 ????  :( otarif
        else
            if(i_valid)
                last_counter <= last_counter_next;
    end

    assign last_counter_next = last_counter + { {NB_COUNTER-1{1'b 0}}, {1'b 1}};
    assign o_last = (last_counter == {NB_COUNTER{1'b 0}} ) ? 1'b 1 : 1'b 0;

    //**************************************************
    // Idle Signal Generation
    //**************************************************
    reg                                                 core_idle                              ;
    
    always @(posedge i_clock)
    begin
        if(i_reset)
            core_idle <= 1'b 0;
        else if(i_valid)
        begin
            if(o_last)
                core_idle <= 1'b 1;
            else if (o_start)
                core_idle <= 1'b 0;
        end
    end

    assign o_core_idle = core_idle ^ o_start;
    //**************************************************
    // Frame Row Col Counter
    //**************************************************
    reg                                                 plus_one                               ;
    wire            [NB_COL_COUNTER       - 1 : 0 ]     col_counter_limit_sel                  ;
    wire                                                row_counter_limit                      ;
    wire                                                col_counter_limit                      ;

    assign col_counter_limit_sel = ( plus_one ) ? COL_COUNTER_LIMIT_PLUS_ONE[NB_COL_COUNTER-1 :0] : COL_COUNTER_LIMIT[NB_COL_COUNTER-1 :0];
    assign row_counter_limit = ( row_counter == ROW_COUNTER_LIMIT[NB_ROW_COUNTER -1:0] );
    assign col_counter_limit = ( col_counter == col_counter_limit_sel );

    always @(posedge i_clock) begin
        if( i_reset || i_sof ) 
        begin
            col_counter <= {NB_COL_COUNTER{1'b0}};
            plus_one    <= 1'b0;
        end
        else if ( i_valid ) 
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
        if( i_reset || i_sof )
            row_counter <= {NB_ROW_COUNTER{1'b0}};
        else if ( i_valid )
            if( row_counter_limit & col_counter_limit)
                row_counter <= {NB_ROW_COUNTER{1'b0}};
            else if ( col_counter_limit )
                row_counter <= row_counter + 1'b1;
    end
    
    //**************************************************
    // Auxiliary save buffer logic
    //**************************************************
    always @(posedge i_clock)
    begin
        if(i_reset)
            aux_data_buffer <= {NB_BUFFER{1'b 0}};
        else
            if(i_valid )
            begin
                if(!freeze_buffer | i_sof)
                    aux_data_buffer <= i_data[NB_DATA - QUARTER -1 -: NB_BUFFER]; /// Save 3/4 of the input data
                else if(col_counter == 118)
                begin
                    //aux_data_buffer <= aux_data_buffer << QUARTER;
                    //aux_data_buffer[QUARTER-1 -: QUARTER] <= i_data[NB_DATA-1 -: QUARTER];
                    aux_data_buffer <= {aux_data_buffer[NB_BUFFER- QUARTER -1 : 0], i_data[NB_DATA-1 -: QUARTER]};
                end
            end
    end

    assign freeze_buffer = ~((plus_one) ? (col_counter < 119) : (col_counter < 118));
    //assign o_cen = freeze_buffer ^ (col_counter == 127 & row_counter == 1); // Special case finishing 1st row going for 2nd

    //**************************************************
    // Aad Register
    //**************************************************
    reg            [NB_AAD        - 1 : 0 ]              aad_d                     ; 

    always @(posedge i_clock)
    begin
        if(i_reset)
            aad_d <= { NB_AAD {1'b 0} };
        else if (o_start)
            aad_d <= i_aad;
    end

    //**************************************************
    // Output Data Logic
    //**************************************************
    reg            [NB_DATA                - 1 : 0 ]     data                      ;
    reg                                                  cen                       ;
    reg                                                  insert_aad                ;
    reg                                                  insert_aad_d              ;
    
    always @(*)
    begin
    //if (start_counter == 14 | start_counter == 15) //For AAD
    //begin
    //    output_data = {NB_DATA{1'b 0}};
    //    insert_aad = 1'b 1;        
    //end
    if (start_counter == 14 /*| start_counter == 15*/) //For AAD
    begin
        output_data = aad_d[NB_AAD - 1 -: HALF_NB_AAD];
        insert_aad = 1'b 1;        
    end
    else if( start_counter == 15 ) //For AAD
    begin
        output_data = aad_d[HALF_NB_AAD - 1 -: HALF_NB_AAD];
        insert_aad = 1'b 1;        
    end
    else
        begin
            insert_aad = 1'b 0;
            case(row_counter)
                2'b 00 : output_data = {aux_data_buffer[NB_BUFFER- QUARTER -1  -: QUARTER * 2], i_data[NB_DATA-1 -: QUARTER * 2] };
                2'b 01 : 
                begin
                    if(col_counter == 127)
                        output_data = {aux_data_buffer[NB_BUFFER - 1 -: QUARTER * 2], i_data[NB_DATA- QUARTER * 2 - 1 -: QUARTER * 2] };
                    else
                        output_data = {aux_data_buffer[NB_BUFFER-1 -: QUARTER * 3], i_data[NB_DATA-1 -: QUARTER * 1] };
                end
                2'b 10 : output_data = i_data;
                2'b 11 : output_data = {aux_data_buffer[QUARTER-1 -: QUARTER], i_data[NB_DATA-1 -: QUARTER * 3] };
                default: output_data = i_data; 
            endcase
        end
    end
    
    //Output Register
    always @(posedge i_clock)
    begin
        if(i_valid)
        begin
            data <= output_data;
            cen <= (freeze_buffer ^ (col_counter == 127 & row_counter == 1)) ;
            insert_aad_d <= insert_aad;
        end
        else
        begin
            cen <= 1'b 1 ;
            insert_aad_d <= 1'b 0;
        end
            
    end
    
    assign o_payload_data = data;
    assign o_cen = ~cen | insert_aad_d;
    assign o_insert_add = insert_aad_d;

    //**************************************************
    // Encryption Overhead Extraction
    //**************************************************
    reg                                                encr_oh_rdy                      ;
    reg            [NB_ENCR_OVERHEAD      - 1 : 0 ]    encr_oh                          ;
    always @(*)
    begin
        if(!row_counter[0] & col_counter == 118) // even positions
        begin
           encr_oh_rdy = 1'b 1;
           encr_oh = i_data[3*QUARTER-1 -: QUARTER];
        end
        else if(row_counter[0] & col_counter == 118) /// mmmmmm dijo la muda
        begin
            encr_oh_rdy = 1'b 1;
            encr_oh = i_data[QUARTER -1 -: QUARTER];  // Less significant quarter
        end
        else
        begin 
            encr_oh_rdy = 1'b 0;
            encr_oh = {NB_ENCR_OVERHEAD{1'b 0}};
        end 
    end

    assign o_encr_oh_rdy = encr_oh_rdy & i_valid;
    assign o_encr_oh = encr_oh;
    assign o_encr_oh_row = row_counter;

    //**************************************************
    // Frame Overhead
    //**************************************************
    reg            [NB_FRAME_OVERHEAD    - 1 : 0 ]    frame_oh                          ;

    always @(posedge i_clock)
    begin
        if(col_counter_limit & i_valid)
        begin
            if(row_counter[0]) 
                frame_oh <= i_data[NB_DATA-1 -: 2*QUARTER];
            else 
                frame_oh <= i_data[2*QUARTER -1 -: 2*QUARTER];  
        end
    end

    assign  o_frame_oh = frame_oh;

endmodule

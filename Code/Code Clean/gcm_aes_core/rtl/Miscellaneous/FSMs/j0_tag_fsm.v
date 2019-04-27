module j0_tag_fsm
#(
    parameter                                           NB_STATE            = 3                 ,     // Must be 3
    parameter                                           NB_BLOCK            = 128

)
(
    // OUTPUTS.
    output  wire    [ NB_BLOCK-1:0  ]                   o_j0_tag_locked                         ,
    // INPUTS.
    input   wire    [ NB_BLOCK-1:0  ]                   i_j0_tag                                ,
    input   wire                                        i_update_key                            ,
    input   wire                                        i_ctrl_o_trigger_h_power_vector_calc    ,
    input   wire                                        i_ctrl_o_gctr_o_sop_pre                 ,
    input   wire                                        i_ctrl_o_gctr_triggered_o_sop_pre       ,
    input   wire                                        i_key_switch_load_done                  ,
    input   wire                                        i_ctrl_o_trigger_j0_tag_new_locking     ,
    input   wire                                        i_reset                                 ,
    input   wire                                        i_valid                                 ,
    input   wire                                        i_clock
);

// QUICK INSTANCE: BEGIN
/*
j0_tag_fsm
#(
    .NB_STATE                               (  ),   // Must be 3
    .NB_BLOCK                               (  )
)
u_j0_tag_fsm
(
    .o_j0_tag_locked                        (  ),
    .i_j0_tag                               (  ),
    .i_update_key                           (  ),
    .i_ctrl_o_trigger_h_power_vector_calc   (  ),
    .i_ctrl_o_gctr_o_sop_pre                (  ),
    .i_ctrl_o_gctr_triggered_o_sop_pre      (  ),
    .i_key_switch_load_done                 (  ),
    .i_ctrl_o_trigger_j0_tag_new_locking    (  ),
    .i_reset                                (  ),
    .i_valid                                (  ),
    .i_clock                                (  )
);
*/
// QUICK INSTANCE: END

// LOCAL PARAMETERS.
localparam  [ NB_STATE-1:0  ]           ST_0_WAIT_KEY_UPDATE                = 0 ;
localparam  [ NB_STATE-1:0  ]           ST_1_WAIT_GCTR_O_SOP_PRE            = 1 ;
localparam  [ NB_STATE-1:0  ]           ST_2_WAIT_GCTR_O_SOP_PRE            = 2 ;
localparam  [ NB_STATE-1:0  ]           ST_3_WAIT_KEY_SWITCH_DONE           = 3 ;
localparam  [ NB_STATE-1:0  ]           ST_4_WAIT_J0_NEW_LOCKING_TRIGGER    = 4 ;

// INTERNAL SIGNALS
reg         [ NB_STATE-1:0  ]           state                                   ;
reg         [ NB_STATE-1:0  ]           state_next                              ;

reg         [ NB_BLOCK-1:0  ]           j0_tag_old_reg                          ;
wire        [ NB_BLOCK-1:0  ]           j0_tag_old                              ;
reg         [ NB_BLOCK-1:0  ]           j0_tag_new_reg                          ;
wire        [ NB_BLOCK-1:0  ]           j0_tag_new                              ;
reg         [ NB_BLOCK-1:0  ]           j0_tag_normal_reg                       ;
wire        [ NB_BLOCK-1:0  ]           j0_tag_normal                           ;
reg         [ NB_BLOCK-1:0  ]           j0_tag_locked_reg                       ;
wire        [ NB_BLOCK-1:0  ]           j0_tag_locked                           ;


// J0 Tag New Locking
always @( posedge i_clock )
begin: j0_tag_new_locking
    if ( i_reset )
    begin
        j0_tag_old_reg      <= { NB_BLOCK{1'b0} }   ;
        j0_tag_new_reg      <= { NB_BLOCK{1'b0} }   ;
        j0_tag_normal_reg   <= { NB_BLOCK{1'b0} }   ;
    end
    else if ( i_valid && i_ctrl_o_trigger_h_power_vector_calc )
    begin
        j0_tag_old_reg      <= j0_tag_new_reg       ;
        j0_tag_new_reg      <= i_j0_tag             ;
    end
    if( i_valid && i_ctrl_o_gctr_o_sop_pre )
        j0_tag_normal_reg   <= i_j0_tag             ;
end // j0_tag_new_locking
assign j0_tag_new       =   ( i_valid && i_ctrl_o_trigger_h_power_vector_calc )   ?   // cad_ence map_to_mux
                            i_j0_tag : j0_tag_new_reg                                                       ;

assign j0_tag_old       =   ( i_valid && i_ctrl_o_trigger_h_power_vector_calc )   ?   // cad_ence map_to_mux
                            j0_tag_new_reg : j0_tag_old_reg                                                 ;

assign j0_tag_normal   =    ( i_valid && i_ctrl_o_gctr_o_sop_pre )   ?   // cad_ence map_to_mux
                            i_j0_tag : j0_tag_normal_reg                                                    ;


// State update.
always @( posedge i_clock )
begin : l_state_update
    if ( i_reset )  // cad_ence map_to_mux
        state   <= ST_0_WAIT_KEY_UPDATE ;
    else if ( i_valid )
        state   <= state_next           ;
end // l_state_update

always @( * )
begin: j0_tag_locking

    state_next              = ST_0_WAIT_KEY_UPDATE  ;
    j0_tag_locked_reg       = j0_tag_normal              ;

    case( state )
    ST_0_WAIT_KEY_UPDATE            :
    begin
        casez( {i_update_key, i_ctrl_o_gctr_triggered_o_sop_pre, i_key_switch_load_done, i_ctrl_o_trigger_j0_tag_new_locking} )
        4'b1??? :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        default :   state_next      = ST_0_WAIT_KEY_UPDATE      ;
        endcase
        j0_tag_locked_reg           = j0_tag_normal  ;
    end

    ST_1_WAIT_GCTR_O_SOP_PRE        :
    begin
        casez( {i_update_key, i_ctrl_o_gctr_triggered_o_sop_pre, i_key_switch_load_done, i_ctrl_o_trigger_j0_tag_new_locking} )
        4'b1??? :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        4'b?1?? :   state_next      = ST_2_WAIT_GCTR_O_SOP_PRE  ;
        default :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        endcase
        j0_tag_locked_reg           =   ( ~i_ctrl_o_gctr_triggered_o_sop_pre )    ?
                                        j0_tag_normal : j0_tag_old           ;
    end

    ST_2_WAIT_GCTR_O_SOP_PRE        :
    begin
        casez( {i_update_key, i_ctrl_o_gctr_triggered_o_sop_pre, i_key_switch_load_done, i_ctrl_o_trigger_j0_tag_new_locking} )
        4'b1??? :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        4'b?1?? :   state_next      = ST_3_WAIT_KEY_SWITCH_DONE     ;
        default :   state_next      = ST_2_WAIT_GCTR_O_SOP_PRE      ;
        endcase
        j0_tag_locked_reg           = j0_tag_normal ;
    end

    ST_3_WAIT_KEY_SWITCH_DONE       :
    begin
        casez( {i_update_key, i_ctrl_o_gctr_triggered_o_sop_pre, i_key_switch_load_done, i_ctrl_o_trigger_j0_tag_new_locking} )
        4'b1??? :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        4'b??1? :   state_next      = ST_4_WAIT_J0_NEW_LOCKING_TRIGGER  ;
        default :   state_next      = ST_3_WAIT_KEY_SWITCH_DONE         ;
        endcase
        j0_tag_locked_reg           =   ( i_key_switch_load_done )  ?
                                        j0_tag_new : j0_tag_old     ;
    end

    ST_4_WAIT_J0_NEW_LOCKING_TRIGGER:
    begin
        casez( {i_update_key, i_ctrl_o_gctr_triggered_o_sop_pre, i_key_switch_load_done, i_ctrl_o_trigger_j0_tag_new_locking} )
        4'b1??? :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        4'b???1 :   state_next      = ST_0_WAIT_KEY_UPDATE              ;
        default :   state_next      = ST_4_WAIT_J0_NEW_LOCKING_TRIGGER  ;
        endcase
        j0_tag_locked_reg           = j0_tag_new    ;
    end


    default                         :
    begin
        casez( {i_update_key, i_ctrl_o_gctr_triggered_o_sop_pre, i_key_switch_load_done, i_ctrl_o_trigger_j0_tag_new_locking} )
        4'b1??? :   state_next      = ST_1_WAIT_GCTR_O_SOP_PRE  ;
        default :   state_next      = ST_0_WAIT_KEY_UPDATE      ;
        endcase
        j0_tag_locked_reg           = j0_tag_normal  ;
    end
    endcase
end

assign o_j0_tag_locked    = j0_tag_locked_reg   ;

endmodule   // j0_tag_fsm
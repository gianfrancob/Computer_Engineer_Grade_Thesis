/**
* \class encr_datapath.h
* \ingroup
* \date 25/11/16
* \author otarif
*
* \brief encr_datapath SC shell
*
* \copyright Copyright (C), ClariPhy Argentina. All rights reserved.
*
*/

#include "systemc.h"
#include PARAMETERS_FILE
#ifndef encr_datapath_H
#define encr_datapath_H

class encr_datapath : public ncsc_foreign_module {
public:
	sc_out < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > o_data;
	sc_out < sc_logic > o_valid;
	sc_out < sc_logic > o_sof;
	sc_out < sc_logic > o_core_idle;
	sc_out < sc_lv < ((0>=(NB_TAG - 1))?(0 - (NB_TAG - 1) + 1):((NB_TAG - 1) - 0 + 1)) > > o_tag;
	sc_out < sc_logic > o_tstrobe;
	sc_out < sc_lv < ((0>=(NB_ENCR_OVERHEAD - 1))?(0 - (NB_ENCR_OVERHEAD - 1) + 1):((NB_ENCR_OVERHEAD - 1) - 0 + 1)) > > o_encr_oh;
	sc_out < sc_logic > o_encr_oh_rdy;
	sc_out < sc_lv < ((0>=(NB_ROW - 1))?(0 - (NB_ROW - 1) + 1):((NB_ROW - 1) - 0 + 1)) > > o_encr_oh_index;
	sc_out < sc_logic > o_qlast;
	sc_out < sc_logic > o_qstart;
	sc_out < sc_logic > o_start_single_cycle;
	sc_out < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > o_single_cycle_data;
	sc_out < sc_logic > o_encr_oh_req;
	sc_out < sc_lv < ((0>=(NB_COUNTER - 1))?(0 - (NB_COUNTER - 1) + 1):((NB_COUNTER - 1) - 0 + 1)) > > o_rf_static_overflow_counter;
	sc_out < sc_lv < ((0>=(NB_COUNTER - 1))?(0 - (NB_COUNTER - 1) + 1):((NB_COUNTER - 1) - 0 + 1)) > > o_rf_static_underflow_counter;
	sc_in < sc_lv < ((0>=((4 * NB_ENCR_OVERHEAD) - 1))?(0 - ((4 * NB_ENCR_OVERHEAD) - 1) + 1):(((4 * NB_ENCR_OVERHEAD) - 1) - 0 + 1)) > > i_encr_oh;
	sc_in < sc_logic > i_single_cycle_start;
	sc_in < sc_logic > i_single_cycle_last;
	sc_in < sc_logic > i_single_cycle_data_valid;
	sc_in < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > i_single_cycle_data;
	sc_in < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > i_data;
	sc_in < sc_logic > i_valid;
	sc_in < sc_logic > i_sof;
	sc_in < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > i_key;
	sc_in < sc_lv < ((0>=(NB_INIT_VECTOR - 1))?(0 - (NB_INIT_VECTOR - 1) + 1):((NB_INIT_VECTOR - 1) - 0 + 1)) > > i_init_vector;
	sc_in < sc_lv < ((0>=(NB_AAD - 1))?(0 - (NB_AAD - 1) + 1):((NB_AAD - 1) - 0 + 1)) > > i_aad;
	sc_in < sc_logic > i_rf_static_enable;
	sc_in < sc_lv < ((0>=(NB_ENCR_MODE_WIDTH - 1))?(0 - (NB_ENCR_MODE_WIDTH - 1) + 1):((NB_ENCR_MODE_WIDTH - 1) - 0 + 1)) > > i_rf_static_mode;
	sc_in < sc_logic > i_rf_static_in_boot_up;
	sc_in < sc_logic > i_clock;
	sc_in < sc_logic > i_reset;
	sc_in < sc_logic > i_async_reset;

	encr_datapath(
		sc_module_name nm
	) : ncsc_foreign_module(nm)
		, o_data("o_data")
		, o_valid("o_valid")
		, o_sof("o_sof")
		, o_core_idle("o_core_idle")
		, o_tag("o_tag")
		, o_tstrobe("o_tstrobe")
		, o_encr_oh("o_encr_oh")
		, o_encr_oh_rdy("o_encr_oh_rdy")
	
		, o_encr_oh_index("o_encr_oh_index")
		, o_qlast("o_qlast")
		, o_qstart("o_qstart")
		, o_start_single_cycle("o_start_single_cycle")
		, o_single_cycle_data("o_single_cycle_data")
		, o_encr_oh_req("o_encr_oh_req")
	
		, o_rf_static_overflow_counter("o_rf_static_overflow_counter")
		, o_rf_static_underflow_counter("o_rf_static_underflow_counter")
		, i_encr_oh("i_encr_oh")
		, i_single_cycle_start("i_single_cycle_start")
	
		, i_single_cycle_last("i_single_cycle_last")
		, i_single_cycle_data_valid("i_single_cycle_data_valid")
		, i_single_cycle_data("i_single_cycle_data")
		, i_data("i_data")
		, i_valid("i_valid")
	
		, i_sof("i_sof")
		, i_key("i_key")
		, i_init_vector("i_init_vector")
		, i_aad("i_aad")
		, i_rf_static_enable("i_rf_static_enable")
		, i_rf_static_mode("i_rf_static_mode")
		, i_rf_static_in_boot_up("i_rf_static_in_boot_up")
	
		, i_clock("i_clock")
		, i_reset("i_reset")
		, i_async_reset("i_async_reset")

	{
	    ncsc_set_hdl_param("NB_AAD", NB_AAD );
	    ncsc_set_hdl_param("NB_COUNTER", NB_COUNTER );
	    ncsc_set_hdl_param("NB_ENCR_MODE_WIDTH", NB_ENCR_MODE_WIDTH );
	    ncsc_set_hdl_param("NB_ADDRESS", NB_ADDRESS );
	    ncsc_set_hdl_param("NB_ROW", NB_ROW );
	    ncsc_set_hdl_param("NB_TAG", NB_TAG );
	    ncsc_set_hdl_param("NB_ENCR_OVERHEAD", NB_ENCR_OVERHEAD );
	    ncsc_set_hdl_param("NB_INIT_VECTOR", NB_INIT_VECTOR );
	    ncsc_set_hdl_param("NB_DATA", NB_DATA );
	}

	const char* hdl_name() const { return "encr_datapath"; }
};
#endif /* encr_datapath_H */

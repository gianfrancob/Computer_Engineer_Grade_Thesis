/**
* \class CVL_test
* \ingroup
* \date 02/07/2014
* \author Roman Arenas
*
* \brief Test case class
*
* \copyright Copyright (C), ClariPhy Argentina. All rights reserved.
*
*/

#ifndef __TESTCASE_H
#define __TESTCASE_H

#include <string>
#include <iostream>
#include <sys/stat.h>
#include <fstream>
#include <iostream>
#include "cvl_test.h"
#include "cvl_test_factory.h"
#include "cvl_testcase.h"
#include PARAMETERS_FILE
#include "basic_env.h"
#include "encr_datapath.h"
#include "valid_agent.h"
#include "otu_agent.h"
#include "cvl_frame_scoreboard.h"

#define TESTCASE_NAME "encr_datapath.default_tb"

namespace cpi { class Cpi_Encr_Datapath_cvl; }

using namespace std;
using namespace cvl;
using namespace cpi;
using namespace otu_cvc;
using namespace valid_cvc;

class Testcase: public CVL_testcase, public Basic_env
{        
    public:
        CVL_TEST_DEFS();
        
        Testcase(sc_module_name name): CVL_testcase(name), uut("UUT"),
        //<SIGNAL_CONSTRUCTORS> Do not remove this comment
        o_data("o_data"),
        o_valid("o_valid"),
        o_sof("o_sof"),
        o_core_idle("o_core_idle"),
        o_tag("o_tag"),
        o_tstrobe("o_tstrobe"),
        o_encr_oh("o_encr_oh"),
        o_encr_oh_rdy("o_encr_oh_rdy"),
        o_encr_oh_index("o_encr_oh_index"),
        o_qlast("o_qlast"),
        o_qstart("o_qstart"),
        o_start_single_cycle("o_start_single_cycle"),
        o_single_cycle_data("o_single_cycle_data"),
        o_encr_oh_req("o_encr_oh_req"),
        o_rf_static_overflow_counter("o_rf_static_overflow_counter"),
        o_rf_static_underflow_counter("o_rf_static_underflow_counter"),
        i_encr_oh("i_encr_oh"),
        i_single_cycle_start("i_single_cycle_start"),
        i_single_cycle_last("i_single_cycle_last"),
        i_single_cycle_data_valid("i_single_cycle_data_valid"),
        i_single_cycle_data("i_single_cycle_data"),
        i_data("i_data"),
        i_valid("i_valid"),
        i_sof("i_sof"),
        i_key("i_key"),
        i_init_vector("i_init_vector"),
        i_aad("i_aad"),
        i_rf_static_enable("i_rf_static_enable"),
        i_rf_static_mode("i_rf_static_mode"),
        i_rf_static_in_boot_up("i_rf_static_in_boot_up"),
        i_async_reset("i_async_reset")
        //</SIGNAL_CONSTRUCTORS>
        {
            //<UUT_CONNECTIONS>, Do not insert code here or remove this comment            
            uut.o_data  (o_data);
            uut.o_valid  (o_valid);
            uut.o_sof  (o_sof);
            uut.o_core_idle  (o_core_idle);
            uut.o_tag  (o_tag);
            uut.o_tstrobe  (o_tstrobe);
            uut.o_encr_oh  (o_encr_oh);
            uut.o_encr_oh_rdy  (o_encr_oh_rdy);
            uut.o_encr_oh_index  (o_encr_oh_index);
            uut.o_qlast  (o_qlast);
            uut.o_qstart  (o_qstart);
            uut.o_start_single_cycle  (o_start_single_cycle);
            uut.o_single_cycle_data  (o_single_cycle_data);
            uut.o_encr_oh_req  (o_encr_oh_req);
            uut.o_rf_static_overflow_counter  (o_rf_static_overflow_counter);
            uut.o_rf_static_underflow_counter  (o_rf_static_underflow_counter);
            uut.i_encr_oh  (i_encr_oh);
            uut.i_single_cycle_start  (i_single_cycle_start);
            uut.i_single_cycle_last  (i_single_cycle_last);
            uut.i_single_cycle_data_valid  (i_single_cycle_data_valid);
            uut.i_single_cycle_data  (i_single_cycle_data);
            uut.i_data  (i_data);
            uut.i_valid  (i_valid);
            uut.i_sof  (i_sof);
            uut.i_key  (i_key);
            uut.i_init_vector  (i_init_vector);
            uut.i_aad  (i_aad);
            uut.i_rf_static_enable  (i_rf_static_enable);
            uut.i_rf_static_mode  (i_rf_static_mode);
            uut.i_rf_static_in_boot_up  (i_rf_static_in_boot_up);
            uut.i_clock  (i_clock);
            uut.i_reset  (i_reset);
            uut.i_async_reset  (i_reset);
            //</UUT_CONNECTIONS>
                
            //Add resource db sets here
            
            //Build basic environmet
            Basic_env::build();
            SC_HAS_PROCESS(Testcase);
            SC_THREAD(log_signals);
            SC_THREAD(create_files);
            
            //Add CVCs instances here
            otu_agent_input = new OTU_agent<OTU_interface<256> > ("OTU_AGENT_INPUT", true);
            otu_agent_input->vif.i_clock       ( i_clock                       );
            otu_agent_input->vif.i_reset       ( i_reset                       );
            otu_agent_input->vif.i_enable      ( valid                         );
            otu_agent_input->vif.o_data        ( i_data                        );
            otu_agent_input->vif.o_valid       ( i_valid                       );
            otu_agent_input->vif.o_sof         ( i_sof                         );
            otu_agent_input->vif.i_data        ( i_data                        );
            otu_agent_input->vif.i_valid       ( i_valid                       );
            otu_agent_input->vif.i_sof         ( i_sof                         );

            otu_agent_output = new OTU_agent<OTU_interface<256> > ("OTU_AGENT_OUTPUT", false);
            otu_agent_output->vif.i_clock       ( i_clock                      );
            otu_agent_output->vif.i_reset       ( i_reset                      );
            otu_agent_output->vif.i_data        ( o_data                       );
            otu_agent_output->vif.i_valid       ( o_valid                      );
            otu_agent_output->vif.i_sof         ( o_sof                        );

            valid_agent = new Valid_agent("VALID_AGENT"                        );
            valid_agent->i_clock               ( i_clock                       );
            valid_agent->i_reset               ( i_reset                       );
            valid_agent->o_valid               ( valid                         );

            otu_scoreboard = new CVL_frame_scoreboard("SCOREBOARD_INGRESS");
            otu_agent_input->monitor->analysis_port.bind(*otu_scoreboard->ref_port);
            otu_agent_output->monitor->analysis_port.bind(*otu_scoreboard->comp_port);

        };
        
        //UUT instance
        encr_datapath uut;

        Cpi_Encr_Datapath_cvl *cpi;

        OTU_agent<OTU_interface<256> >*       otu_agent_input   ;
        OTU_agent<OTU_interface<256> >*       otu_agent_output  ;
        Valid_agent*                          valid_agent       ;
        CVL_frame_scoreboard*                 otu_scoreboard    ;
        sc_signal < sc_logic > valid                            ;
        
        //Methods
        void log_signals(); 
        void create_files();
            
        //<UUT_SIGNALS> Do not remove this comment        
        sc_signal < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > o_data;
        sc_signal < sc_logic > o_valid;
        sc_signal < sc_logic > o_sof;
        sc_signal < sc_logic > o_core_idle;
        sc_signal < sc_lv < ((0>=(NB_TAG - 1))?(0 - (NB_TAG - 1) + 1):((NB_TAG - 1) - 0 + 1)) > > o_tag;
        sc_signal < sc_logic > o_tstrobe;
        sc_signal < sc_lv < ((0>=(NB_ENCR_OVERHEAD - 1))?(0 - (NB_ENCR_OVERHEAD - 1) + 1):((NB_ENCR_OVERHEAD - 1) - 0 + 1)) > > o_encr_oh;
        sc_signal < sc_logic > o_encr_oh_rdy;
        sc_signal < sc_lv < ((0>=(NB_ROW - 1))?(0 - (NB_ROW - 1) + 1):((NB_ROW - 1) - 0 + 1)) > > o_encr_oh_index;
        sc_signal < sc_logic > o_qlast;
        sc_signal < sc_logic > o_qstart;
        sc_signal < sc_logic > o_start_single_cycle;
        sc_signal < sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > o_single_cycle_data;
        sc_signal < sc_logic > o_encr_oh_req;
        sc_signal < sc_lv < ((0>=(NB_COUNTER - 1))?(0 - (NB_COUNTER - 1) + 1):((NB_COUNTER - 1) - 0 + 1)) > > o_rf_static_overflow_counter;
        sc_signal < sc_lv < ((0>=(NB_COUNTER - 1))?(0 - (NB_COUNTER - 1) + 1):((NB_COUNTER - 1) - 0 + 1)) > > o_rf_static_underflow_counter;
        sc_signal< sc_lv < ((0>=((4 * NB_ENCR_OVERHEAD) - 1))?(0 - ((4 * NB_ENCR_OVERHEAD) - 1) + 1):(((4 * NB_ENCR_OVERHEAD) - 1) - 0 + 1)) > > i_encr_oh;
        sc_signal< sc_logic > i_single_cycle_start;
        sc_signal< sc_logic > i_single_cycle_last;
        sc_signal< sc_logic > i_single_cycle_data_valid;
        sc_signal< sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > i_single_cycle_data;
        sc_signal< sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > i_data;
        sc_signal< sc_logic > i_valid;
        sc_signal< sc_logic > i_sof;
        sc_signal< sc_lv < ((0>=(NB_DATA - 1))?(0 - (NB_DATA - 1) + 1):((NB_DATA - 1) - 0 + 1)) > > i_key;
        sc_signal< sc_lv < ((0>=(NB_INIT_VECTOR - 1))?(0 - (NB_INIT_VECTOR - 1) + 1):((NB_INIT_VECTOR - 1) - 0 + 1)) > > i_init_vector;
        sc_signal< sc_lv < ((0>=(NB_AAD - 1))?(0 - (NB_AAD - 1) + 1):((NB_AAD - 1) - 0 + 1)) > > i_aad;
        sc_signal< sc_logic > i_rf_static_enable;
        sc_signal< sc_lv < ((0>=(NB_ENCR_MODE_WIDTH - 1))?(0 - (NB_ENCR_MODE_WIDTH - 1) + 1):((NB_ENCR_MODE_WIDTH - 1) - 0 + 1)) > > i_rf_static_mode;
        sc_signal< sc_logic > i_rf_static_in_boot_up;
        //	sc_signal< sc_logic > i_clock; This signal was already declared in the enviroment
        //	sc_signal< sc_logic > i_reset; This signal was already declared in the enviroment
        sc_signal< sc_logic > i_async_reset;
        //</UUT_SIGNALS>
        //<SIGNALS_FILES>
        ofstream f_o_data;
        ofstream f_o_valid;
        ofstream f_o_sof;
        ofstream f_o_core_idle;
        ofstream f_o_tag;
        ofstream f_o_tstrobe;
        ofstream f_o_encr_oh;
        ofstream f_o_encr_oh_rdy;
        ofstream f_o_encr_oh_index;
        ofstream f_o_qlast;
        ofstream f_o_qstart;
        ofstream f_o_start_single_cycle;
        ofstream f_o_single_cycle_data;
        ofstream f_o_encr_oh_req;
        ofstream f_o_rf_static_overflow_counter;
        ofstream f_o_rf_static_underflow_counter;
        ofstream f_i_encr_oh;
        ofstream f_i_single_cycle_start;
        ofstream f_i_single_cycle_last;
        ofstream f_i_single_cycle_data_valid;
        ofstream f_i_single_cycle_data;
        ofstream f_i_data;
        ofstream f_i_valid;
        ofstream f_i_sof;
        ofstream f_i_key;
        ofstream f_i_init_vector;
        ofstream f_i_aad;
        ofstream f_i_rf_static_enable;
        ofstream f_i_rf_static_mode;
        ofstream f_i_rf_static_in_boot_up;
        ofstream f_i_reset;
        ofstream f_i_async_reset;
        //</SIGNALS_FILES>

};

#endif

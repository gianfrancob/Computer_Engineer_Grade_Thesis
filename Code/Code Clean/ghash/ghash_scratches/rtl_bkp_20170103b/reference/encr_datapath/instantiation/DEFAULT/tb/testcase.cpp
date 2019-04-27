/**
* \class CVL_test
* \ingroup
* \date 02/07/2014
* \author Roman Arenas
*
* \brief Class test case
*
* \copyright Copyright (C), ClariPhy Argentina. All rights reserved.
*
*/
#include "testcase.h"
#include "cpi_encr_datapath_cvl.h"

using namespace cvl;
using namespace cpi;

CVL_TEST_RESET( Testcase )
{
    //cpi class initialization (only first time)
    if (cpi==NULL)
        cpi = new Cpi_Encr_Datapath_cvl();

    vector <char>    encrypt_key;
    vector <char>    encrypt_key2;
    vector <char>    encrypt_iv;
    encrypt_key.clear();
    encrypt_key2.clear();
    encrypt_iv.clear();

    for (int i = 0; i < 32; i++){
        encrypt_key.push_back(0x1);
        encrypt_key2.push_back(0x1);
    }

    for (int i = 0; i < 12; i++)
        encrypt_iv.push_back(0x0);
    
    sc_lv <32*8> enc_oh;
    sc_lv <32*8> key;
    std::vector < char > fix_stuff;

    i_rf_static_mode.write(1);
    
    for(unsigned i = 0 ; i < 4 ; i++){
        for(unsigned j = 0 ; j < 8 ; j++){
        //enc_oh.range( i*64 + (j+1)*8 -1, i*64 + j*8 ) = i+1;
        enc_oh.range( i*64 + (j+1)*8 -1, i*64 + j*8 ) = 0;
        fix_stuff.push_back(i+1);
        }
    }
    i_encr_oh.write(enc_oh);
    i_aad.write(0);
    
    i_rf_static_enable.write(SC_LOGIC_1);
    i_rf_static_in_boot_up.write(SC_LOGIC_0);
    i_single_cycle_data_valid.write(SC_LOGIC_0);

    //Single cycle inputs to zero!
    i_single_cycle_start.write(SC_LOGIC_0);    
    i_single_cycle_last.write(SC_LOGIC_0);    
    //i_single_cycle_cen.write(SC_LOGIC_0);    

    //i_spi.write(0);
    
    for (int i = 0; i < 32; i++){
        //encrypt_key.push_back(rand()%255);
        //key.range((i+1)*8 -1, i*8) = encrypt_key[i];
        key.range((i+1)*8 -1, i*8) = 0x01;
    }
    i_key.write(key);
    i_init_vector.write(0);

    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*"   , "enable_decrypt" ,  true                            );
    //CVL_resource_db< vector<char> >::set( "*.OTU_AGENT_OUTPUT.*"   , "encrypt_key"      , encrypt_key          );
    //CVL_resource_db< vector<char> >::set( "*.*"   , "encrypt_key"      , encrypt_key          );
    CVL_resource_db< vector<char> >::set( "*.*"   , "encrypt_iv"      , encrypt_iv          );
    CVL_resource_db< vector< char >  >::set( "*.OTU_AGENT_OUTPUT.*"      , "encrypt_key"      , encrypt_key );
    //CVL_resource_db< std::vector < char > >::set( "*.OTU_AGENT_INPUT.Monitor*", "fix_stuff"        , fix_stuff   );
    //CVL_resource_db< bool                 >::set( "*.OTU_AGENT_INPUT.Monitor*", "replace_fix_stuff", true        );
    read_db();
}

// Test using valid always high
CVL_TEST( Testcase, Case_000  )
{
    unsigned scb_resync , new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;    

    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                            );
    env->read_db();
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

// Test using valid half 
CVL_TEST( Testcase, Case_001  )
{
    unsigned scb_resync, new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;

    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                            );
    env->read_db();

    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_half"));   
    env->valid_agent->driver->reset();
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

// Test using valid sd of 5 / 8 
CVL_TEST( Testcase, Case_002  )
{
    unsigned scb_resync, new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;

    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_sd"));
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                            );
    CVL_resource_db<int>::set( "*.*", "val_num", 5 );
    CVL_resource_db<int>::set( "*.*", "val_den", 8 );
    env->read_db();    
    env->valid_agent->driver->reset();
    
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

// Test using resync
CVL_TEST( Testcase, Case_003  )
{
    unsigned scb_resync, new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;

    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    //CVL_resource_db<bool>::set      ("*.OTU_AGENT_INPUT;*"   , "demap_prbs_to_x_colum" ,  true                            );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                            );
    CVL_resource_db<int>::set( "*.*", "val_num", 5 );
    CVL_resource_db<int>::set( "*.*", "val_den", 8 );
    env->read_db();


    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_sd"));
    env->valid_agent->driver->reset();
    
    for(int i = 0; i < 10; i++)
    {
        // Stabilization time for traffic - more than enough
        wait(20,SC_US);
        prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
        scb_resync  = env->otu_scoreboard->get_resync_count();
        EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
        EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
        
        // Persistency check 
        new_scb_resync  = env->otu_scoreboard->get_resync_count();
        new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
        EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
        EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
        EXPECT_EQ  ( scb_resync, new_scb_resync                             );
        EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );

        // Resync generation
        wait(rand()%998,SC_NS);
        env->otu_agent_input->driver->generate_sof_slip();        
    }

}

// Test using valid always high
CVL_TEST( Testcase, Case_004  )
{
    unsigned scb_resync , new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;    

    env->i_rf_static_mode.write(2);
    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                    );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "enable_decrypt"        ,  false                   );
    env->read_db();    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

// Test using valid half 
CVL_TEST( Testcase, Case_005  )
{
    unsigned scb_resync, new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;

    env->i_rf_static_mode.write(2);
    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                    );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "enable_decrypt"        ,  false                   );
    env->read_db();

    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_half"));   
    env->valid_agent->driver->reset();
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

// Test using valid sd of 5 / 8 
CVL_TEST( Testcase, Case_006  )
{
    unsigned scb_resync, new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;

    env->i_rf_static_mode.write(2);
    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                    );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "enable_decrypt"        ,  false                   );
    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_sd"));
    CVL_resource_db<int>::set( "*.*", "val_num", 5 );
    CVL_resource_db<int>::set( "*.*", "val_den", 8 );
    env->read_db();    
    env->valid_agent->driver->reset();
    
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

// Test using resync
CVL_TEST( Testcase, Case_007  )
{
    unsigned scb_resync, new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;
    
    env->i_rf_static_mode.write(2);
    // CVL configurations
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "enable_decrypt"        ,  false                   );
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    //CVL_resource_db<bool>::set      ("*.OTU_AGENT_INPUT;*"   , "demap_prbs_to_x_colum" ,  true                            );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                            );
    CVL_resource_db<int>::set( "*.*", "val_num", 5 );
    CVL_resource_db<int>::set( "*.*", "val_den", 8 );
    env->read_db();


    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_sd"));
    env->valid_agent->driver->reset();
    
    for(int i = 0; i < 10; i++)
    {
        // Stabilization time for traffic - more than enough
        wait(20,SC_US);
        prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
        scb_resync  = env->otu_scoreboard->get_resync_count();
        EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
        EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
        
        // Persistency check 
        new_scb_resync  = env->otu_scoreboard->get_resync_count();
        new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
        EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
        EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
        EXPECT_EQ  ( scb_resync, new_scb_resync                             );
        EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );

        // Resync generation
        wait(rand()%998,SC_NS);
        env->otu_agent_input->driver->generate_sof_slip();        
    }
}
// Test using valid always high
CVL_TEST( Testcase, Case_008  )
{
    unsigned scb_resync , new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;    

    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                            );
    env->read_db();

    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_random"));
    env->valid_agent->driver->reset();
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

CVL_TEST( Testcase, Case_009  )
{
    unsigned scb_resync , new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;    

    env->i_rf_static_mode.write(2);
    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                    );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "enable_decrypt"        ,  false                   );
    env->read_db();    

    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_random"));
    env->valid_agent->driver->reset();
    
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
}

CVL_TEST( Testcase, Case_010  )
{
    unsigned scb_resync , new_scb_resync;
    unsigned prbs_resync, new_prbs_resync;
    sc_lv<96> iv;
    sc_lv<256> key;

    for(unsigned i = 0 ; i < 12 ; i++)
        iv.range((i+1)*8 -1, i*8) = 0xFF;

    for (int i = 0; i < 32; i++){
        //encrypt_key.push_back(rand()%255);
        //key.range((i+1)*8 -1, i*8) = encrypt_key[i];
        key.range((i+1)*8 -1, i*8) = 0xFE;
    }
    env->i_key.write(key);
    env->i_init_vector.write(iv);    

    env->i_rf_static_mode.write(2);
    // CVL configurations
    env->otu_agent_input->sequencer->set_sequence(otu_cvc::OTU_sequence::create("OTU_prbs_in_payload_to_encrypt")); 
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "demap_prbs_to_x_colum" ,  true                    );
    CVL_resource_db<bool>::set      ("*.OTU_AGENT_OUTPUT.*" , "enable_decrypt"        ,  false                   );
    env->read_db();    

    env->valid_agent->sequencer->set_sequence(valid_cvc::Valid_sequence::create("Valid_random"));
    env->valid_agent->driver->reset();
    
    env->i_rf_static_enable.write(SC_LOGIC_0);
    wait(20,SC_US);
    env->i_rf_static_enable.write(SC_LOGIC_1);
    // Stabilization time for traffic - more than enough
    wait(20,SC_US);
    
    prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    scb_resync  = env->otu_scoreboard->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    
    wait(50,SC_US);

    // Persistency check 
    new_scb_resync  = env->otu_scoreboard->get_resync_count();
    new_prbs_resync = env->otu_agent_output->prbs_agent->monitor->get_resync_count();
    EXPECT_TRUE( env->otu_scoreboard->get_lock()                        );
    EXPECT_TRUE( env->otu_agent_output->prbs_agent->monitor->get_lock() );
    EXPECT_EQ  ( scb_resync, new_scb_resync                             );
    EXPECT_EQ  ( prbs_resync, new_prbs_resync                           );
    env->i_rf_static_enable.write(SC_LOGIC_0);

    for(unsigned i = 0 ; i < 12 ; i++)
        iv.range((i+1)*8 -1, i*8) = 0x00;

    for (int i = 0; i < 32; i++){
        //encrypt_key.push_back(rand()%255);
        //key.range((i+1)*8 -1, i*8) = encrypt_key[i];
        key.range((i+1)*8 -1, i*8) = 0x01;
    }
    env->i_key.write(key);
    env->i_init_vector.write(iv);
    wait(1,SC_US);
}


void Testcase::log_signals(){
    
    while(true){
        if(!enable_logging) break;
        wait(i_clock.posedge_event());
        //<SIGNALS_WRITE>
        f_o_data << o_data.read() << endl;
        f_o_valid << o_valid.read() << endl;
        f_o_sof << o_sof.read() << endl;
        f_o_core_idle << o_core_idle.read() << endl;
        f_o_tag << o_tag.read() << endl;
        f_o_tstrobe << o_tstrobe.read() << endl;
        f_o_encr_oh << o_encr_oh.read() << endl;
        f_o_encr_oh_rdy << o_encr_oh_rdy.read() << endl;
        f_o_encr_oh_index << o_encr_oh_index.read() << endl;
        f_o_qlast << o_qlast.read() << endl;
        f_o_qstart << o_qstart.read() << endl;
        f_o_start_single_cycle << o_start_single_cycle.read() << endl;
        f_o_single_cycle_data << o_single_cycle_data.read() << endl;
        f_o_encr_oh_req << o_encr_oh_req.read() << endl;
        f_o_rf_static_overflow_counter << o_rf_static_overflow_counter.read() << endl;
        f_o_rf_static_underflow_counter << o_rf_static_underflow_counter.read() << endl;
        f_i_encr_oh << i_encr_oh.read() << endl;
        f_i_single_cycle_start << i_single_cycle_start.read() << endl;
        f_i_single_cycle_last << i_single_cycle_last.read() << endl;
        f_i_single_cycle_data_valid << i_single_cycle_data_valid.read() << endl;
        f_i_single_cycle_data << i_single_cycle_data.read() << endl;
        f_i_data << i_data.read() << endl;
        f_i_valid << i_valid.read() << endl;
        f_i_sof << i_sof.read() << endl;
        f_i_key << i_key.read() << endl;
        f_i_init_vector << i_init_vector.read() << endl;
        f_i_aad << i_aad.read() << endl;
        f_i_rf_static_enable << i_rf_static_enable.read() << endl;
        f_i_rf_static_mode << i_rf_static_mode.read() << endl;
        f_i_rf_static_in_boot_up << i_rf_static_in_boot_up.read() << endl;
        f_i_reset << i_reset.read() << endl;
        f_i_async_reset << i_async_reset.read() << endl;
        //</SIGNALS_WRITE>
                
    }

}


void Testcase::create_files(){    
    while(true){
        if(!enable_logging) break;        
        //Create new folder
        string crnt_folder = "./";
        crnt_folder.append(current_test->name);               
        mkdir(crnt_folder.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);        
        //Create new log file for each signal                             
        string crnt_file;
        //Do not remove the lines below
        //<SIGNALS_FILES>
        crnt_file = crnt_folder; crnt_file.append("/o_data");
        f_o_data.close();f_o_data.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_valid");
        f_o_valid.close();f_o_valid.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_sof");
        f_o_sof.close();f_o_sof.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_core_idle");
        f_o_core_idle.close();f_o_core_idle.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_tag");
        f_o_tag.close();f_o_tag.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_tstrobe");
        f_o_tstrobe.close();f_o_tstrobe.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_encr_oh");
        f_o_encr_oh.close();f_o_encr_oh.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_encr_oh_rdy");
        f_o_encr_oh_rdy.close();f_o_encr_oh_rdy.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_encr_oh_index");
        f_o_encr_oh_index.close();f_o_encr_oh_index.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_qlast");
        f_o_qlast.close();f_o_qlast.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_qstart");
        f_o_qstart.close();f_o_qstart.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_start_single_cycle");
        f_o_start_single_cycle.close();f_o_start_single_cycle.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_single_cycle_data");
        f_o_single_cycle_data.close();f_o_single_cycle_data.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_encr_oh_req");
        f_o_encr_oh_req.close();f_o_encr_oh_req.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_rf_static_overflow_counter");
        f_o_rf_static_overflow_counter.close();f_o_rf_static_overflow_counter.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/o_rf_static_underflow_counter");
        f_o_rf_static_underflow_counter.close();f_o_rf_static_underflow_counter.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_encr_oh");
        f_i_encr_oh.close();f_i_encr_oh.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_single_cycle_start");
        f_i_single_cycle_start.close();f_i_single_cycle_start.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_single_cycle_last");
        f_i_single_cycle_last.close();f_i_single_cycle_last.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_single_cycle_data_valid");
        f_i_single_cycle_data_valid.close();f_i_single_cycle_data_valid.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_single_cycle_data");
        f_i_single_cycle_data.close();f_i_single_cycle_data.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_data");
        f_i_data.close();f_i_data.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_valid");
        f_i_valid.close();f_i_valid.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_sof");
        f_i_sof.close();f_i_sof.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_key");
        f_i_key.close();f_i_key.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_init_vector");
        f_i_init_vector.close();f_i_init_vector.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_aad");
        f_i_aad.close();f_i_aad.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_rf_static_enable");
        f_i_rf_static_enable.close();f_i_rf_static_enable.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_rf_static_mode");
        f_i_rf_static_mode.close();f_i_rf_static_mode.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_rf_static_in_boot_up");
        f_i_rf_static_in_boot_up.close();f_i_rf_static_in_boot_up.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_reset");
        f_i_reset.close();f_i_reset.open( crnt_file.c_str() );
        crnt_file = crnt_folder; crnt_file.append("/i_async_reset");
        f_i_async_reset.close();f_i_async_reset.open( crnt_file.c_str() );
        //</SIGNALS_FILES>
        
        wait(test_changed);                                                     //event declared in cvl_testcase
    }

}

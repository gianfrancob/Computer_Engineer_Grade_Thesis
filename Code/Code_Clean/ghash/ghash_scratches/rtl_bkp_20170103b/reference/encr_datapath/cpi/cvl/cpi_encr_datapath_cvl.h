/**
* \class Cpi_Encr_Datapath_cvl
* \ingroup      
* \date </DATE>
* \author Script
* 
* \brief Derived class used for port connection only in CVL environment
*
* \copyright Copyright (C), ClariPhy Argentina. All rights reserved.
* 
*/     

#ifndef __cpi_encr_datapath_cvl_h
#define __cpi_encr_datapath_cvl_h

#include "cpi_encr_datapath.h"

namespace cpi
{
    
    class Cpi_Encr_Datapath_cvl: public Cpi_Encr_Datapath 
    {
        public:
            Cpi_Encr_Datapath_cvl( unsigned int base_address = 0x0 ): 
            Cpi_Encr_Datapath( base_address )
            {
                //<CPI_PORT_TABLES> Do not remove this comment
                this->rfport_table.push_back( (sc_object*)&((Testcase*)CVL_testcase::cvl_testcase_unique_instance)->i_rf_static_mode);
                //</CPI_PORT_TABLES>
            };
    };
}  
     
#endif

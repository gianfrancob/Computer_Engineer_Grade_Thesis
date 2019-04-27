/**
* \class Cpi_Encr_Datapath_cvl
* \ingroup      
* \date </DATE>
* \author Script
* 
* \brief Derived class used for port connection only in Modulisst environment
*
* \copyright Copyright (C), ClariPhy Argentina. All rights reserved.
* 
*/     

#ifndef __cpi_encr_datapath_mdl_h
#define __cpi_encr_datapath_mdl_h

#include "cpi_encr_datapath.h"

namespace cpi
{
    
    class Cpi_Encr_Datapath_mdl: public Cpi_Encr_Datapath 
    {
        public:
            Cpi_Encr_Datapath_mdl( unsigned int base_address = 0x0 ): 
            Cpi_Encr_Datapath( base_address )
            {
                //<CPI_PORT_TABLES> Do not remove this comment
                this->rfport_table.push_back( "u_encr_datapath i_rf_static_mode");
                //</CPI_PORT_TABLES>
            };
    };
}  
     
#endif

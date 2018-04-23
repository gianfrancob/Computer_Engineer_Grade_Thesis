/**
* \class Cpi_Encr_Datapath
* \ingroup      
* \date </DATE>
* \author Script
* 
* \brief encr_datapath configuration methods
*
* \copyright Copyright (C), ClariPhy Argentina. All rights reserved.
* 
*/     

#ifndef __cpi_encr_datapath_h
#define __cpi_encr_datapath_h

#include <cpi_base.h>
#include <cpi_base_rf_access.h>
#include "cpi_encr_datapath_defs.h"

//<SUB_CPI_FILES> Do not remove this comment
//</SUB_CPI_FILES>


namespace cpi
{
    
    class Cpi_Encr_Datapath: public Cpi_Base 
    {
        public:
            //<SUB_CPI_INSTANCES> Do not remove this comment
            //</SUB_CPI_INSTANCES>
            
            Cpi_Encr_Datapath( unsigned int base_address ): 
            //<SUB_CPI_CONTRUSCTORS> Do not remove this comment
            Cpi_Base ( base_address )
            //</SUB_CPI_CONTRUSCTORS>
            {
            };

            /**
            * @name configure
            * @brief Enable/disable block
            * @param enable Set true to enable block
            */                
            void configure( UINT8 enable );   
            
            #ifdef COMPILE_CPI_SIM_METHODS
            //Add methods used only in simulations here
            #endif

    };
}  
     
#endif

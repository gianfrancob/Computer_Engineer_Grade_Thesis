#####################################################################
#
# RTL Compiler setup file
# Created by Encounter(R) RTL Compiler RC14.28 - v14.20-s067_1
#   on 07/03/2017 15:03:57
#
#
#####################################################################


# This script is intended for use with RTL Compiler version RC14.28 - v14.20-s067_1


# Remove Existing Design
###########################################################
if {[find -design /designs/gcm_aes_core] ne ""} {
  puts "** A design with the same name is already loaded. It will be removed. **"
  rm /designs/gcm_aes_core
}


# Libraries
###########################################################
set_attribute library {/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdssgnp0p63v0c_ccs.lib /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdmbssgnp0p63v0c_ccs.lib /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusllbwp7d5t16p96cpdlvtssgnp0p63v0c_ccs.lib /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusllbwp7d5t16p96cpdulvtssgnp0p63v0c_ccs.lib /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdmbulvtssgnp0p63v0c_ccs.lib /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdmblvtssgnp0p63v0c_ccs.lib} /

set_attribute lef_library {/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/clariphy_VHV.tcl /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/tcbn16ffplusglbwp7d5t16p96cpd.lef /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/tcbn16ffplusglbwp7d5t16p96cpdmb.lef /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/tcbn16ffplusllbwp7d5t16p96cpdlvt.lef /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/tcbn16ffplusllbwp7d5t16p96cpdulvt.lef /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/tcbn16ffplusglbwp7d5t16p96cpdmblvt.lef /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef/tcbn16ffplusglbwp7d5t16p96cpdmbulvt.lef} /
set_attribute qrc_tech_file /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/qrctech/cworst_CCworst_T/qrcTechFile /


# Design
###########################################################
read_netlist -top gcm_aes_core /scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/output/final/gcm_aes_core.v.gz

source /scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/output/final/gcm_aes_core.g.gz
puts "\n** Restoration Completed **\n"


# Data Integrity Check
###########################################################
# program version
if {"[string_representation [get_attribute program_version /]]" != "{RC14.28 - v14.20-s067_1}"} {
   mesg_send [find -message /messages/PHYS/PHYS-91] "golden program_version: {RC14.28 - v14.20-s067_1}  current program_version: [string_representation [get_attribute program_version /]]"
}
# license
if {"[string_representation [get_attribute startup_license /]]" != "Genus_Synthesis"} {
   mesg_send [find -message /messages/PHYS/PHYS-91] "golden license: Genus_Synthesis  current license: [string_representation [get_attribute startup_license /]]"
}
# slack
set _slk_ [get_attribute slack /designs/gcm_aes_core]
if {[regexp {^-?[0-9.]+$} $_slk_]} {
  set _slk_ [format %.1f $_slk_]
}
if {$_slk_ != "0.0"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden slack: 0.0,  current slack: $_slk_"
}
unset _slk_
# multi-mode slack
# tns
set _tns_ [get_attribute tns /designs/gcm_aes_core]
if {[regexp {^-?[0-9.]+$} $_tns_]} {
  set _tns_ [format %.0f $_tns_]
}
if {$_tns_ != "0"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden tns: 0,  current tns: $_tns_"
}
unset _tns_
# cell area
set _cell_area_ [get_attribute cell_area /designs/gcm_aes_core]
if {[regexp {^-?[0-9.]+$} $_cell_area_]} {
  set _cell_area_ [format %.0f $_cell_area_]
}
if {$_cell_area_ != "104206"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden cell area: 104206,  current cell area: $_cell_area_"
}
unset _cell_area_
# net area
set _net_area_ [get_attribute net_area /designs/gcm_aes_core]
if {[regexp {^-?[0-9.]+$} $_net_area_]} {
  set _net_area_ [format %.0f $_net_area_]
}
if {$_net_area_ != "39348"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden net area: 39348,  current net area: $_net_area_"
}
unset _net_area_

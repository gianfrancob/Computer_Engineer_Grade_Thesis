#############################################################################
## Synthesis Script for block level synthesis
##
## Author:  Alejandro Aguirre
## Company: Clariphy Argentina S.A.
## Version: 1.0
## Date:    Jun 5, 2014
#############################################################################

# environment variales
set PROJDIR               /projects/CL40010/RevA0/RELEASE/APR/projdir
#borism $env(PROJDIR)


set SCRIPTDIR             /projects/PROJ_COMMON/ASIC_PD/pd_release/PD.6.0/
#borism $env(SCRIPTDIR)
set DISTRIBUTED           0 
#borism $env(DISTRIBUTED)

#set USER $env(USER)   ; # in case you wnat to point to your release area
set USER RTL_RELEASE   ; # standard repository, must be used

# opt effort (high effort may affect LEC)
set to_gen_eff            "high"                 ; # options low | medium | high
set to_map_eff            "high"                 ; # options low | medium | high
set to_place_eff          "medium"               ; # options low | medium | high
set check_fanout          "false"                ; # this option is for debuging purposes only, "true" to generate fanout report, very expensive in runtime

# more opt
set cost_groups           "false"                ; # when set to false default cost gorups are used
set dp_area               "false"                ; # bad QoR for designs like FFE
set first_incremental     "true"                 ; # enable the first incremental
set scnd_incremental      "true"                 ; # enable a second pass of incremental synthesis
set incremental_opt_en    "true"                 ; # enabel a few attribs for incremental synthesis only
set preserve_top          "true" 

set design                "GCM3LP_256"
set OUTDATA               ../outData
# Path to the folder that contains the verilog_list.lst
set FILELISTDIR           "/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/filelist"
set v_files               ""
set sv_files 			  " /design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/utils/rtl/synchronizer.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/AES256_256KEpl14.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/GCM3LP-256.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/K2gmp16x16.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/K3gmp32x32.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/K4gmp64x64.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/K5gmp128x128.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/KeyExpander256K_128EPE.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/Kgmp16x128.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/Kgmp4x32.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/Kgmp8x64.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/Kgmp8x8.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/MixCol.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/Sbox.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/Sbox2R.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/encoder128PL2S.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/gmp2x16.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/gmp4x4.v
/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/rtl/GCM3LP_256.v"

# functional and mbist sdc
set func.sdc              "/design/M200/RevA0/Work/bmaliatski/DIGITAL/trunk/externals/asic_rtl/library/GCM3LP_256/instantiation/DEFAULT/constraints/constraints.sdc.tcl"   ; # Use default or custom constraint, script will look at default or override dir for this file name
set mbist.sdc             ""                      ; # if rtl has mbist set to ${design}.mbist.sdc
set generate_ple          0                       ; # Set to 1 and copy the def file into your override for generate custom PLE model


# drv options this will be driven by user
set max_transition        0.20                    ; #  0.3 is set in AP
set max_capacitance       0.39                    ; # 
set max_fanout            200                     ; #

# low power options
set OPT_LEAKAGE           "false"                 ; # Do not enable this without setting properly the corner
set OPT_DYNAMIC           "false"                 ; # Depends on the activity file, or maximum toogle if no activity file defined (unit is in mW)


##############################################################################
## Preset mail address & start time
##############################################################################
# E-mails must be setup before run synthesis, complete both fields, both variables could be the same

set mail_to "bmaliatski@clariphy.com"
set mail_cc "bmaliatski@clariphy.com"


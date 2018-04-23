#################################################################################
## GHASH CORE [TOP MODULE]
#################################################################################
$PROJ_RTL_MODULES/ghash_core/rtl/ghash_core.v

#################################################################################
## GHASH CORE SUBLOCKS
#################################################################################
$PROJ_RTL_MODULES/ghash_core/rtl/ghash_control_signal_unit.v                    ## TOP

$PROJ_RTL_MODULES/ghash_core/rtl/ghash_msg_and_h_pow_picker.v                   ## TOP

$PROJ_RTL_MODULES/ghash_core/rtl/ghash_stage1_pipe.v                            ## TOP

$PROJ_RTL_MODULES/ghash_core/rtl/gf_2toN_koa_generated.v                        ## TOP
$PROJ_RTL_MODULES/ghash_core/rtl/gf_2toN_koa_splitter_line.v                    ## Sublock
$PROJ_RTL_MODULES/ghash_core/rtl/gf_2toN_koa_splitter.v                         ##-- Sublock
$PROJ_RTL_MODULES/ghash_core/rtl/gf_2toN_multiplier_no_rem.v                    ## Sublock
$PROJ_RTL_MODULES/ghash_core/rtl/gf_2toN_koa_merger_line.v                      ## Sublock
$PROJ_RTL_MODULES/ghash_core/rtl/gf_2toN_koa_merger.v                           ##-- Sublock

$PROJ_RTL_MODULES/ghash_core/rtl/ghash_stage2_pipe.v                            ## TOP

$PROJ_RTL_MODULES/ghash_core/rtl/gf_2to128_multiplier_booth1_subrem.v           ## TOP

$PROJ_RTL_MODULES/ghash_core/rtl/ghash_stage3_pipe.v                            ## TOP

#################################################################################
# UTILS
#################################################################################
$PROJ_COMMON_RTL_UTILS/common_fix_delay_line_w_valid.v
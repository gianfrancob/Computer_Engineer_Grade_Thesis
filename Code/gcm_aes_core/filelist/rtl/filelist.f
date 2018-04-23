#################################################################################
## GCM AES CORE [TOP MODULE]
#################################################################################
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gcm_aes_core.v

#################################################################################
## GCM AES CORE SUBLOCKS
#################################################################################
$PROJ_RTL_MODULES/gcm_aes_core/rtl/j0_generator.v                               ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/inc32_block.v                                ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/key_update_fsm.v                             ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/pulse_sequencer_fsm.v                        ## TOP (Not used)

$PROJ_RTL_MODULES/gcm_aes_core/rtl/gcm_aes_fsm.v                                ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/key_scheduler_sequential_shifter.v           ## TOP
$PROJ_RTL_MODULES/gcm_aes_core/rtl/key_scheduler_sequential_nwords.v            ## Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/key_scheduler_sequential_1word.v             ##-- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/subbytes_block.v                             ##---- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/byte_substitution_box.v                      ##------ Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/byte_substitution_algorithm.v                ##------ Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/multiplicative_inversion.v                   ##-------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/byte_isomorphic_mapping.v                    ##---------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to4_squarer.v                            ##---------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to4_multiplier_with_constant_lambda.v    ##---------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to4_multiplier.v                         ##---------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to2_multiplier.v                         ##------------ Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to2_multiplier_with_constant_phi.v       ##------------ Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to4_multiplicative_inversion.v           ##---------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/byte_inverse_isomorphic_mapping.v            ##---------- Sublock

$PROJ_RTL_MODULES/gcm_aes_core/rtl/key_scheduler_switcher.v                     ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/subkey_h_powers_generator.v                  ## TOP
$PROJ_RTL_MODULES/gcm_aes_core/rtl/gf_2to128_multiplier_sequential.v            ## Sublock

$PROJ_RTL_MODULES/gcm_aes_core/rtl/gctr_function.v                              ## TOP
$PROJ_RTL_MODULES/gcm_aes_core/rtl/aes_round_ladder_xor_data.v                  ## Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/round_block_and_pipe.v                       ##-- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/shiftrows_block.v                            ##---- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/mixcolumns_block.v                           ##---- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/ax_modular_multiplier.v                      ##------ Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/time_03.v                                    ##-------- Sublock
$PROJ_RTL_MODULES/gcm_aes_core/rtl/xtime.v                                      ##-------- Sublock

$PROJ_RTL_MODULES/gcm_aes_core/rtl/gcm_aes_cipher_tag_fsm.v                     ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/ghash_wrapper.v                              ## TOP
$PROJ_RTL_MODULES/ghash_core/rtl/ghash_core.v                                   ##-- Sublock
                                                                                ##---- Include sublocks
#include $PROJ_RTL_MODULES/ghash_core/filelist/rtl/filelist.f
$PROJ_RTL_MODULES/ghash_core/rtl/ghash_koa_n_blocks/ghash_koa_n_blocks.v        ##-- Sublock
$PROJ_RTL_MODULES/ghash_core/rtl/ghash_koa_n_blocks/polinomial_mult_koa.v       ##---- Sublock
$PROJ_RTL_MODULES/ghash_core/rtl/ghash_koa_n_blocks/multiplier_without_pipe.v   ##------ Sublock
##$PROJ_RTL_MODULES/ghash_core/rtl/ghash_koa_n_blocks/ghash_koa_n_blocks2.v     ##-- Sublock

$PROJ_RTL_MODULES/gcm_aes_core/rtl/j0_tag_fsm.v                                 ## TOP

$PROJ_RTL_MODULES/gcm_aes_core/rtl/common_fix_delay_line_w_del_valid.v          ## TOP

#################################################################################
## UTILS
#################################################################################
$PROJ_COMMON_RTL_UTILS/common_fix_delay_line_w_valid.v

$PROJ_COMMON_RTL_UTILS/common_flag_check.v

$PROJ_COMMON_RTL_UTILS/common_posedge_det.v


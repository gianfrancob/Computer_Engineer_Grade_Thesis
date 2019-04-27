// Generated by Cadence Encounter(R) RTL Compiler RC14.28 - v14.20-s067_1
tclmode
set env(RC_VERSION) "RC14.28 - v14.20-s067_1"
vpxmode
set dofile abort exit
usage -auto -elapse
set log file /scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/lec/rtl2intermediate.lec.log -replace
tclmode
set ver [lindex [split [lindex [get_version_info] 0] "-"] 0]
vpxmode
tclmode
set env(CDN_SYNTH_ROOT) /tools/cad/cadence/RC/14.28.000/Linux/tools
set CDN_SYNTH_ROOT /tools/cad/cadence/RC/14.28.000/Linux/tools
vpxmode
tclmode
if {$ver >= 08.10} {
  vpx set naming style rc
}
vpxmode
set naming rule "" -parameter
set naming rule "%s[%d]" -instance_array
set naming rule "%s_reg" -register -golden
set naming rule "%L_%s" "%L_%d__%s" "%s" -instance
set naming rule "%L_%s" "%L_%d__%s" "%s" -variable
set undefined cell black_box -noascend -both
set hdl options -VERILOG_INCLUDE_DIR "sep:src:cwd"
set undriven signal 0 -golden
echo "The undriven setting must be 'Z' to be consistent with"
echo "the silicon behavior when the design is made into silicon."

add search path -library ./override /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib /projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lef
read library -statetable -liberty -both  \
	/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdssgnp0p63v0c_ccs.lib \
	/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdmbssgnp0p63v0c_ccs.lib \
	/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusllbwp7d5t16p96cpdlvtssgnp0p63v0c_ccs.lib \
	/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusllbwp7d5t16p96cpdulvtssgnp0p63v0c_ccs.lib \
	/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdmbulvtssgnp0p63v0c_ccs.lib \
	/projects/M200/RevA0/RELEASE/APR/projdir7.5T/libraries/lib/tcbn16ffplusglbwp7d5t16p96cpdmblvtssgnp0p63v0c_ccs.lib

delete search path -all
add search path -design .
tclmode
if {$ver < 13.10} {
vpx read design   -define SYNTHESIS  -golden -lastmod -noelab -verilog2k \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gcm_aes_core.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/j0_generator.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/inc32_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_update_fsm.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gcm_aes_ghash_fsm.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_sequential_shifter.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_sequential_nwords.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_sequential_1word.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/subbytes_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_substitution_box.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_substitution_algorithm.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/multiplicative_inversion.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_isomorphic_mapping.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_squarer.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_multiplier_with_constant_lambda.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_multiplier.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to2_multiplier.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to2_multiplier_with_constant_phi.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_multiplicative_inversion.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_inverse_isomorphic_mapping.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_switcher.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/subkey_h_powers_generator.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to128_multiplier_sequential.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gctr_function.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/aes_round_ladder_xor_data.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/round_block_and_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/shiftrows_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/mixcolumns_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/ax_modular_multiplier.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/time_03.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/xtime.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/ghash_wrapper.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_core.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_control_signal_unit.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_msg_and_h_pow_picker.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_stage1_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_generated.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_splitter_line.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_splitter.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_multiplier_no_rem.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_merger_line.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_merger.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_stage2_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2to128_multiplier_booth1_subrem.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_stage3_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/utils/rtl/common_fix_delay_line_w_valid.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/common_fix_delay_line_w_del_valid.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/utils/rtl/common_posedge_det.v
} else {
vpx read design   -define SYNTHESIS  -merge bbox -golden -lastmod -noelab -verilog2k \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gcm_aes_core.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/j0_generator.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/inc32_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_update_fsm.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gcm_aes_ghash_fsm.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_sequential_shifter.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_sequential_nwords.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_sequential_1word.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/subbytes_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_substitution_box.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_substitution_algorithm.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/multiplicative_inversion.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_isomorphic_mapping.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_squarer.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_multiplier_with_constant_lambda.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_multiplier.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to2_multiplier.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to2_multiplier_with_constant_phi.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to4_multiplicative_inversion.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/byte_inverse_isomorphic_mapping.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/key_scheduler_switcher.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/subkey_h_powers_generator.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gf_2to128_multiplier_sequential.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/gctr_function.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/aes_round_ladder_xor_data.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/round_block_and_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/shiftrows_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/mixcolumns_block.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/ax_modular_multiplier.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/time_03.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/xtime.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/ghash_wrapper.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_core.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_control_signal_unit.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_msg_and_h_pow_picker.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_stage1_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_generated.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_splitter_line.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_splitter.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_multiplier_no_rem.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_merger_line.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2toN_koa_merger.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_stage2_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/gf_2to128_multiplier_booth1_subrem.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/ghash_core/rtl/ghash_stage3_pipe.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/utils/rtl/common_fix_delay_line_w_valid.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/modules/gcm_aes_core/rtl/common_fix_delay_line_w_del_valid.v \
	/projects/CL120020/RevA0/Work/gbarbiani/DIGITAL/trunk/rtl/utils/rtl/common_posedge_det.v
}
vpxmode

elaborate design -golden -root gcm_aes_core -rootonly \

tclmode
if {$ver < 13.10} {
vpx read design -verilog -revised -lastmod -noelab \
	/scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/lec/gcm_aes_core_intermediate.v
} else {
vpx read design -verilog95 -revised -lastmod -noelab \
	/scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/lec/gcm_aes_core_intermediate.v
}
vpxmode

elaborate design -revised -root gcm_aes_core

tclmode
set ver [lindex [split [lindex [get_version_info] 0] "-"] 0]
if {$ver < 13.10} {
vpx substitute blackbox model -golden
}
vpxmode
report design data
report black box

uniquify -all -nolib
set flatten model -seq_constant -seq_constant_x_to 0
set flatten model -nodff_to_dlat_zero -nodff_to_dlat_feedback
set parallel option -threads 4 -license xl -norelease_license
set flatten model -gated_clock
set analyze option -auto

write hier_compare dofile /scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/lec/hier_rtl2intermediate.lec.do \
	-noexact_pin_match -constraint -usage -replace -balanced_extraction -input_output_pin_equivalence \
	-prepend_string "analyze datapath -module -verbose; usage; analyze datapath -share -verbose"
run hier_compare /scratch/CL120020/RevA0/gbarbiani/gcm_aes_core/synthesis/rc/results_Jul03-13:56:48/lec/hier_rtl2intermediate.lec.do -dynamic_hierarchy
// report hier_compare result -dynamicflattened
set system mode lec
tclmode
puts "No of diff points    = [get_compare_points -NONequivalent -count]"
if {[get_compare_points -NONequivalent -count] > 0} {
    puts "------------------------------------"
    puts "ERROR: Different Key Points detected"
    puts "------------------------------------"
#     foreach i [get_compare_points -NONequivalent] {
#         vpx report test vector [get_keypoint $i]
#         puts "     ----------------------------"
#     }
}
vpxmode
exit -force
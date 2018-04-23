# ------------------------------------
# Template to set input/output delays.
# ------------------------------------
#
# set_input_delay  -add_delay <value> -clock [get_clocks vir_<CLOCK_NAME>] <PORT>
# set_output_delay -add_delay <value> -clock [get_clocks vir_<CLOCK_NAME>] <PORT>
#
# Add input/output delays here:

###############################################################################################
#                                 Input delay                                                 #
###############################################################################################
set_input_delay  -add_delay 0.1 -clock [get_clocks vir_CORE_CLOCK] i_*


###############################################################################################
#                                 Output delay                                                #
###############################################################################################
set_output_delay -add_delay 0.1 -clock [get_clocks vir_CORE_CLOCK] o_*


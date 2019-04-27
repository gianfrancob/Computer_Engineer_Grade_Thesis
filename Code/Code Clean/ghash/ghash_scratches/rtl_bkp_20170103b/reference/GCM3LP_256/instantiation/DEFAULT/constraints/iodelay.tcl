###
set IN_DELAY   0.1
set OUT_DELAY  0.1



# Set the commands as following:

# set_input_delay -add_delay <DELAY> -clock [get_clocks <VIRTUAL_CLOCK>] <INPUT>
# set_output_delay -add_delay <DELAY> -clock [get_clocks <VIRTUAL_CLOCK>] <OUTPUT>

# EXAMPLE:

# set_output_delay -add_delay 0.5 -clock [get_clocks vir_${CLOCK_NAME}] o_real_output

##############################################################################
##           Input delay
##############################################################################
puts "**********************************"
puts "User_Info: Setting input delay ..."
puts "**********************************"
set_input_delay -add_delay IN_DELAY -clock [get_clocks vir_${CLK_NAME}] [all_inputs]

##############################################################################
##           Output delay
##############################################################################
puts "***********************************"
puts "User_Info: Setting output delay ..."
puts "***********************************"
set_output_delay -add_delay OUT_DELAY -clock [get_clocks vir_${CLK_NAME}] [all_output]


#####################################
### interface
#####################################
#set_input_delay [expr $IN_DELAY * $CLK_PERIOD] -max -clock CLK [get_ports {i_data_bus i_valid i_static_align_status}] -add

#set_output_delay [expr $OUT_DELAY *  $CLK_PERIOD] -max -clock JTCK_SRC [get_ports {jtdo}] -add

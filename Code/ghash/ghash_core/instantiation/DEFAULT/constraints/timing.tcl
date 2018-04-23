if {![info exists subblocks]} {
  set subinstance ""
}

# -----------------------------------
# Template to set timing constraints.
# -----------------------------------
#
# set_false_path <-through|-to> ${subinstance}<PORT> <-through|-to> ${subinstance}<PORT>
# set_false_path <-from|-through|-to> ${subinstance}<PIN|CELL> <-from|-through|-to> ${subinstance}<PIN|CELL>
# set_disable_timing [get_cells ${subinstance}<CELL>] -from <PIN_1> -to <PIN_2>
# set_case_analysis <1|0> ${subinstance}<PIN|PORT>
# set_multicycle_path <value> <-setup|-hold> -through ${subinstance}<PORT> -to ${subinstance}<PORT|PIN|CELL>
# set_multicycle_path <value> <-setup|-hold> -from ${subinstance}<PORT|PIN|CELL> -to ${subinstance}<PORT|PIN|CELL>
# 
# (Don't forget to add the variable ${subinstance} in each constraint)
#
# Add constraints here:

set_false_path -through ${subinstance}i_rf_static*



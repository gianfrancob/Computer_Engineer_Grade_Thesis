#####################################
### slow io
#####################################
set_false_path -from [get_ports {i_rf_static_*}]
set_false_path -from [get_ports {encrypt}]
set_false_path -to   [get_ports {o_rf_static_*}]


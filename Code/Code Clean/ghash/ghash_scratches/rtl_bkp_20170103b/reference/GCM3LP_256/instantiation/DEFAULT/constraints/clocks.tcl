
set CLK_PERIOD   1.35
set CLK_NAME     CLK


create_clock -name ${CLK_NAME} -period $CLK_PERIOD [get_ports {clk}]
set_false_path -from [get_ports {reset}]

create_clock -name vir_${CLK_NAME} -period $CLK_PERIOD

# ---------------------------
# Template to set the clocks.
# ---------------------------
#
# set clk_names   [list  <CLOCK_1>  <CLOCK_2> ]
# set clk_ports   [list  <clock_1>  <clock_2> ]
# set clk_periods [list   <prd_1>    <prd_2>  ]
#
# Add clocks here:
set clk_names   [list  CORE_CLOCK           ]
set clk_ports   [list  i_clock              ]
set clk_periods [list  1.300                ]


foreach clk_name $clk_names clk_port $clk_ports clk_period $clk_periods {
  create_clock [get_ports $clk_port] -name $clk_name -period $clk_period -waveform "0 [expr 0.5 * $clk_period]"
  set_clock_transition 0.1 [get_clocks $clk_name]
  create_clock -name vir_${clk_name} -period $clk_period
}


# ----------------------------------
# Template to set clock constraints.
# ----------------------------------
#
# set_false_path -from [get_clocks <CLOCK_1>] -to [get_clocks <CLOCK_2>]
#
# set_clock_groups <-logically_exclusive|-physical_exclusive|-asynchronous> \
#   -group {<CLOCK_1> <CLOCK_2>} \
#   -group {<CLOCK_3> <CLOCK_4>} 
#
# * -physical_exclusive : Physically-exclusive clocks cannot coexist in the design physically. An example of this is multiple clocks that are defined on the same source pin.
# * -logically_exclusive : An example of logically-exclusive clocks is multiple clocks that are selected by a multiplexer but might have coupling with each other in the design.
# * -asynchronous : Two clocks are asynchronous with respect to each other if they have no phase relationship at all.
#
# 
# Add constraints here:





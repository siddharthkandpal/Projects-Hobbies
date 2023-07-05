set_units -time ns

#------------------------- Creating clock Input -------------------------------
create_clock -name clk -period 1.0 -waveform { 0 0.5 } [get_ports clk]

# ------------------------- Input constraints ----------------------------------
set_input_delay 0.0150 -rise -clock clk [all_inputs]

# ------------------------- Output constraints ---------------------------------

set_output_delay 0.015 -rise -clock clk [all_outputs]

set_max_delay 1 -from [all_inputs] -to [all_outputs]

# Assume 50fF load capacitances everywhere:
set_load 0.050 [all_outputs]
# Set 10fF maximum capacitance on all inputs
set_max_capacitance 0.010 [all_inputs]

# set clock uncertainty of the system clock (skew and jitter)
set_clock_uncertainty -setup 0.005 [get_clocks clk]
set_clock_uncertainty -hold 0.005 [get_clocks clk]


# set maximum transition at output ports
set_max_transition 10 [current_design]

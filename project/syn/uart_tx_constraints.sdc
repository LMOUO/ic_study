create_clock -name sys_clk -period 20.000 [get_ports sys_clk]

set_clock_uncertainty -setup 0.300 [get_clocks sys_clk]
set_clock_uncertainty -hold  0.100 [get_clocks sys_clk]

# sys_rst_n 是异步复位，建议先作为 false path
set_false_path -from [get_ports sys_rst_n]

set_input_delay -max 2.000 -clock [get_clocks sys_clk] [get_ports uart_en]
set_input_delay -min 0.000 -clock [get_clocks sys_clk] [get_ports uart_en]

set_input_delay -max 2.000 -clock [get_clocks sys_clk] [get_ports uart_din[*]]
set_input_delay -min 0.000 -clock [get_clocks sys_clk] [get_ports uart_din[*]]

set_output_delay -max 3.000 -clock [get_clocks sys_clk] [get_ports uart_txd]
set_output_delay -min 0.000 -clock [get_clocks sys_clk] [get_ports uart_txd]

set_output_delay -max 3.000 -clock [get_clocks sys_clk] [get_ports uart_tx_busy]
set_output_delay -min 0.000 -clock [get_clocks sys_clk] [get_ports uart_tx_busy]

set_load 0.050 [get_ports uart_txd]
set_load 0.050 [get_ports uart_tx_busy]

set_max_transition 0.5 [current_design]
set_max_capacitance 1.0 [current_design]
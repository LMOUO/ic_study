#约束系统时钟
create_clock -name sys_clk -period 20.000 [get_ports sys_clk]
#设置时钟不确定性 建立时间和保持时间
set_clock_uncertainty -setup 0.300 [get_clocks sys_clk]
set_clock_uncertainty -hold  0.100 [get_clocks sys_clk]

#设置异步复位的约束
set_false_path -from [get_ports sys_rst_n]

#串口的rx同样也是异步输入
# uart_rxd comes from an external asynchronous serial line.
# It is synchronized inside RTL by uart_rxd_d0 / uart_rxd_d1.
# Do not analyze uart_rxd as a normal synchronous input.
set_false_path -from [get_ports uart_rxd]

#输出延时约束
set_output_delay -max 3.000 -clock [get_clocks sys_clk] [all_outputs]
set_output_delay -min 1.000 -clock [get_clocks sys_clk] [all_outputs]

#设置负载电容 单位pF
set_load 0.050 [all_outputs]

#设置最大转换时间 即0到1的变化速度
set_max_transition  0.5 [current_design]
#设置最大输出电容
set_max_capacitance 1.0 [current_design]




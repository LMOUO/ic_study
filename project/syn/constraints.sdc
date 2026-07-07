# 同步复位，不需要特殊约束，但要设输入延迟
# 输入延迟：外部逻辑在时钟沿前 2ns 将 sys_rst_n 稳定
set_input_delay -clock sys_clk 2.0 [get_ports sys_rst_n]
# 同样 sys_clk 本身如果是从外部来，也需要设置（此处它已作为时钟，除外）

# 输出延迟：外部电路要求在时钟沿后 3ns 内得到 o_led
set_output_delay -clock sys_clk 3.0 [get_ports o_led]


# 时钟定义 
create_clock -name sys_clk -period 20.000 [get_ports sys_clk]

# 时钟不确定性（抖动 + 偏斜） 给 sys_clk 增加 0.300 ns 的不确定性 set - 0.3 hold + 0.1
set_clock_uncertainty -setup 0.300 [get_clocks sys_clk]
set_clock_uncertainty -hold  0.100 [get_clocks sys_clk]

#输入最大延迟，外部输入 sys_rst_n 最晚在时钟边沿后 2.000 ns 到达本芯片。
#可以理解为：外部电路已经消耗了 2 ns 时间，所以芯片内部留给 setup 的时间减少了。
set_input_delay  -max 2.000 -clock [get_clocks sys_clk] [get_ports sys_rst_n]

#输入最大延迟，外部输入 sys_rst_n 最晚在时钟边沿后 2.000 ns 到达本芯片。
#外部信号可能非常早到达，所以要检查输入到寄存器路径是否会造成 hold 违例
set_input_delay  -min 0.000 -clock [get_clocks sys_clk] [get_ports sys_rst_n]

#外部接收电路要求 o_led 在时钟边沿后的一定时间内稳定 ? 用于 setup 分析
#外部设备在一个时钟周期中，需要预留 3 ns 做它自己的 setup 要求或板级延迟
set_output_delay -max 3.000 -clock [get_clocks sys_clk] [get_ports o_led]

#外部接收电路对 o_led 的最小延迟要求是 0.000 ns。 用于 hold 分析
#它表示输出信号不能太早破坏外部设备的 hold 要求
set_output_delay -min 0.000 -clock [get_clocks sys_clk] [get_ports o_led]

#给输出端口 o_led 设置 0.050 pF 的负载电容
set_load 0.050 [get_ports o_led]






# 设计规则约束
set_max_transition 0.5 [current_design]
set_max_capacitance 1.0 [current_design]





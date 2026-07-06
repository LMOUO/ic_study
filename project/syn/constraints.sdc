# 时钟定义
create_clock -name sys_clk -period 20 [get_ports sys_clk]

# 时钟不确定性（抖动 + 偏斜）
set_clock_uncertainty 0.3 [get_clocks sys_clk]

# 同步复位，不需要特殊约束，但要设输入延迟
# 输入延迟：外部逻辑在时钟沿前 2ns 将 sys_rst_n 稳定
set_input_delay -clock sys_clk 2.0 [get_ports sys_rst_n]
# 同样 sys_clk 本身如果是从外部来，也需要设置（此处它已作为时钟，除外）

# 输出延迟：外部电路要求在时钟沿后 3ns 内得到 o_led
set_output_delay -clock sys_clk 3.0 [get_ports o_led]

# 设计规则约束
set_max_transition 0.5 [current_design]
set_max_capacitance 1.0 [current_design]

# 如果复位是异步的，需设 false path；但你是同步复位，不需额外处理


set_drive 4 [get_ports dac_data*]   ;# 设置输出驱动电阻，数值参考 IO 库
set_load 5.0 [get_ports dac_data*]  ;# 设置外部负载电容，单位 pF


#######################
#######################
#######################
###纯组合逻辑 用虚拟时钟（推荐）
# 定义一个不绑定任何端口的虚拟时钟，作为时序参考
create_clock -name vclk -period 10

# 指定所有输入/输出相对于这个虚拟时钟的延迟
set_input_delay -clock vclk 3 [all_inputs]
set_output_delay -clock vclk 2 [all_outputs]
###纯组合逻辑 用虚拟时钟（推荐）
#直接约束路径最大延迟（更直观）
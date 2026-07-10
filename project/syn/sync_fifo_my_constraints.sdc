# ============================================================
# sync_fifo_my timing constraints
# Clock: 50 MHz
# Period: 20 ns
# ============================================================


# ------------------------------------------------------------
# 1. 主时钟
# ------------------------------------------------------------

create_clock -name sys_clk -period 20.000 [get_ports sys_clk]


# ------------------------------------------------------------
# 2. 时钟不确定度
# ------------------------------------------------------------

set_clock_uncertainty -setup 0.300 [get_clocks sys_clk]

set_clock_uncertainty -hold 0.100 [get_clocks sys_clk]


# ------------------------------------------------------------
# 3. 异步复位
# ------------------------------------------------------------

set_false_path -from [get_ports sys_rst_n]


# ------------------------------------------------------------
# 4. 同步输入约束
#
# 假设 i_wr_data、i_wr_en、i_rd_en 来自同一个 sys_clk 时钟域。
# max 表示外部逻辑最多占用 3 ns。
# min 表示最早可以在时钟沿后立即到达。
# ------------------------------------------------------------

set_input_delay -clock [get_clocks sys_clk] -max 3.000 [get_ports i_wr_data*]

set_input_delay -clock [get_clocks sys_clk] -min 0.000 [get_ports i_wr_data*]


set_input_delay -clock [get_clocks sys_clk] -max 3.000 [get_ports {i_wr_en i_rd_en}]

set_input_delay -clock [get_clocks sys_clk] -min 0.000 [get_ports {i_wr_en i_rd_en}]


# ------------------------------------------------------------
# 5. 同步输出约束
#
# 假设这些输出由同一个 sys_clk 时钟域的下一级逻辑采样。
# 给外部逻辑预留 3 ns。
# ------------------------------------------------------------

set_output_delay -clock [get_clocks sys_clk] -max 3.000 [get_ports o_rd_data*]

set_output_delay -clock [get_clocks sys_clk] -min 0.000 [get_ports o_rd_data*]


set_output_delay -clock [get_clocks sys_clk] -max 3.000 [get_ports {o_rd_valid o_fifo_full o_fifo_empty}]

set_output_delay -clock [get_clocks sys_clk] -min 0.000 [get_ports {o_rd_valid o_fifo_full o_fifo_empty}]


set_output_delay -clock [get_clocks sys_clk] -max 3.000 [get_ports o_data_count*]

set_output_delay -clock [get_clocks sys_clk] -min 0.000 [get_ports o_data_count*]


# ------------------------------------------------------------
# 6. 输出负载
#
# 单位通常由 Liberty 库决定，Nangate45 中一般按 pF 理解。
# 0.05 pF = 50 fF。
# ------------------------------------------------------------

set_load 0.050 [get_ports o_rd_data*]

set_load 0.050 [get_ports {o_rd_valid o_fifo_full o_fifo_empty}]

set_load 0.050 [get_ports o_data_count*]


# ------------------------------------------------------------
# 7. 设计规则约束
# ------------------------------------------------------------

set_max_transition 0.500 [current_design]

set_max_capacitance 1.000 [current_design]
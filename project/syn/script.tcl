# 1. 读入设计
read_verilog ../rtl/led_test.v

# 2. 读入时序约束 Yosys 软件该版本没有
#sdc_expand -sdc-in constraints.sdc -sdc-out build/constraints.expanded.sdc

# 3. 设置顶层并优化
synth -top led_test
proc; opt

# 4. 映射到 Nangate 标准单元
#    将 RTL 中的寄存器、组合逻辑映射到库的具体单元
techmap -map /dev/null                      # 清空内置映射
dfflibmap -liberty ../libs/Nangate45/NangateOpenCellLibrary_typical.lib
abc -liberty ../libs/Nangate45/NangateOpenCellLibrary_typical.lib

# 5. 清理与优化
opt

# 6. 写出门级网表
write_verilog led_test_netlist.v

# 7. 输出带真实面积的报告
stat -liberty ../libs/Nangate45/NangateOpenCellLibrary_typical.lib
#stat

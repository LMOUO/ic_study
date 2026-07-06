# 工具定义
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

# 文件定义
RTL      = ../rtl/led_test.v
TB       = ../tb/tb_led_test.sv
TOP      = tb_led_test
VCD      = wave.vcd

# 默认目标
all: sim

# 编译并运行仿真
sim: compile
	$(VVP) $(TOP).vvp

# 编译
compile:
	$(IVERILOG) -o $(TOP).vvp $(RTL) $(TB)

# 查看波形
view:
	$(GTKWAVE) $(VCD) &

# 清理生成文件
clean:
	rm -f $(TOP).vvp $(VCD)

.PHONY: all sim compile view clean

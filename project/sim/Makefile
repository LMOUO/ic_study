IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

#入口参数
TOP 	?= uart_tx
RTL     ?= ../rtl/$(TOP).v
TB      ?= ../tb/tb_$(TOP)_selfcheck.v

TB_TOP  ?= tb_$(TOP)_selfcheck

BUILD_DIR = build
WAVE_DIR  = waves
LOG_DIR   = logs

OUT = $(BUILD_DIR)/$(TB_TOP).vvp
LOG = $(LOG_DIR)/$(TB_TOP).log

.PHONY: all sim check view clean print

all: sim

sim:
	mkdir -p $(BUILD_DIR) $(WAVE_DIR) $(LOG_DIR)
	$(IVERILOG) -o $(OUT) $(RTL) $(TB)
	$(VVP) $(OUT) | tee $(LOG)

view:	
	$(GTKWAVE) $(WAVE_DIR)/$(TOP)_wave.vcd &

print:
	@echo "TOP      = $(TOP)"
	@echo "RTL      = $(RTL)"
	@echo "TB       = $(TB)"
	@echo "TB_TOP   = $(TB_TOP)"
	@echo "OUT      = $(OUT)"
	@echo "LOG      = $(LOG)"

clean:
	rm -rf $(BUILD_DIR) $(WAVE_DIR) $(LOG_DIR)
	rm -f *.vvp *.vcd
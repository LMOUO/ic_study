# syn/Makefile

YOSYS = yosys
STA   = sta

# 默认模块
TOP ?= uart_tx
RTL ?= ../rtl/$(TOP).v
SDC ?= $(TOP)_constraints.sdc

BUILD_DIR = build/$(TOP)
LOG_DIR   = logs

NETLIST = $(BUILD_DIR)/$(TOP)_netlist.v
SYN_LOG = $(LOG_DIR)/$(TOP)_syn.log
STA_LOG = $(LOG_DIR)/$(TOP)_sta.log

LIB = ../libs/Nangate45/NangateOpenCellLibrary_typical.lib

.PHONY: all syn sta clean print

all: syn sta

print:
	@echo "TOP      = $(TOP)"
	@echo "RTL      = $(RTL)"
	@echo "SDC      = $(SDC)"
	@echo "NETLIST  = $(NETLIST)"
	@echo "LIB      = $(LIB)"

syn:
	mkdir -p $(BUILD_DIR) $(LOG_DIR)
	TOP=$(TOP) RTL=$(RTL) NETLIST=$(NETLIST) LIB=$(LIB) \
	$(YOSYS) -c script.tcl | tee $(SYN_LOG)

sta:
	mkdir -p $(BUILD_DIR) $(LOG_DIR)
	TOP=$(TOP) NETLIST=$(NETLIST) SDC=$(SDC) LIB=$(LIB) \
	$(STA) -exit sta.tcl | tee $(STA_LOG)

clean:
	rm -rf build logs
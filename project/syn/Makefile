# syn/Makefile
YOSYS    = yosys
SCRIPT   = script.tcl
TOP      = led_test
NETLIST  = $(TOP)_netlist.v

all: syn

syn:
	$(YOSYS) -s $(SCRIPT) | tee syn.log

clean:
	rm -f $(NETLIST) *.log

.PHONY: all syn clean
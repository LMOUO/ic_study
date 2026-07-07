# syn/Makefile
YOSYS    = yosys
SCRIPT   = script.tcl
TOP      = led_test
NETLIST  = $(TOP)_netlist.v
STA 	 = sta.tcl

all: syn

syn:
	$(YOSYS) -s $(SCRIPT) | tee syn.log
	

sta:
	sta -exit $(STA) | tee sta.log

clean:
	rm -f $(NETLIST) *.log

.PHONY: all syn clean
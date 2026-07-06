
IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

RTL      = ../rtl/led_test.v
TB       = ../tb/tb_led_test.v
TOP      = tb_led_test
VCD      = wave.vcd

all: sim

sim: compile
	$(VVP) $(TOP).vvp

compile:
	$(IVERILOG) -o $(TOP).vvp $(RTL) $(TB)

view:
	$(GTKWAVE) $(VCD) &

clean:
	rm -f $(TOP).vvp $(VCD)

.PHONY: all sim compile view clean
EOF

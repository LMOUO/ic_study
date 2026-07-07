IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

RTL      = ../rtl/led_test.v
TB       = ../tb/tb_led_test.v
TB_CHECK = ../tb/tb_led_test_selfcheck.v

TOP      = tb_led_test
TOP_CHECK = tb_led_test_selfcheck

all: sim

sim:
	$(IVERILOG) -o $(TOP).vvp $(RTL) $(TB)
	$(VVP) $(TOP).vvp

check:
	$(IVERILOG) -o $(TOP_CHECK).vvp $(RTL) $(TB_CHECK)
	$(VVP) $(TOP_CHECK).vvp

view:
	$(GTKWAVE) wave.vcd &

clean:
	rm -f *.vvp *.vcd

.PHONY: all sim check view clean
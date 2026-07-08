IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

RTL      = ../rtl/uart_tx.v
TB       = ../tb/tb_uart_tx_selfcheck.v
TB_CHECK = ../tb/tb_uart_tx_selfcheck.v

TOP      = tb_uart_tx_selfcheck
TOP_CHECK = tb_uart_tx_selfcheck

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
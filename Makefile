.PHONY: all sim check syn sta clean

all: check syn sta

sim:
	cd project/sim && make sim

check:
	cd project/sim && make check

syn:
	cd project/syn && make syn

sta:
	cd project/syn && make sta

clean:
	cd project/sim && make clean
	cd project/syn && make clean
.PHONY: all sim check syn sta clean

all: check syn sta

sim:
	cd ./sim && make sim

check:
	cd ./sim && make check

syn:
	cd ./syn && make syn

sta:
	cd ./syn && make sta

back:
	cp ./syn/*.v ./backend_input/
	cp ./syn/*.log ./backend_input/
	cp ./syn/*.sdc ./backend_input/
	cp ./libs/Nangate45/*.lib ./backend_input/

clean:
	cd sim && make clean
	cd syn && make clean
	rm -f ./backend_input/*
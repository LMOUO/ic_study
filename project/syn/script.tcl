read_verilog ../rtl/led_test.v
synth -top led_test
write_verilog led_test_netlist.v
stat

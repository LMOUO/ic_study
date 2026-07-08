# ============================================================
# Generic OpenSTA timing analysis script
# ============================================================

set TOP     $::env(TOP)
set NETLIST $::env(NETLIST)
set SDC     $::env(SDC)
set LIB     $::env(LIB)

puts "============================================================"
puts "OPENSTA ANALYSIS"
puts "TOP     = $TOP"
puts "NETLIST = $NETLIST"
puts "SDC     = $SDC"
puts "LIB     = $LIB"
puts "============================================================"

read_liberty $LIB
read_verilog $NETLIST
link_design $TOP

read_sdc $SDC

check_setup

puts "\n================ SETUP TIMING REPORT ================\n"
report_checks \
    -path_delay max \
    -fields {slew cap input_pins nets fanout} \
    -digits 4 \
    -group_count 5

puts "\n================ HOLD TIMING REPORT =================\n"
report_checks \
    -path_delay min \
    -fields {slew cap input_pins nets fanout} \
    -digits 4 \
    -group_count 5

puts "\n================ TIMING SUMMARY ======================\n"

puts "\nWorst setup slack:"
report_worst_slack -max

puts "\nWorst hold slack:"
report_worst_slack -min

puts "\nTotal negative setup slack:"
report_tns -max

puts "\nTotal negative hold slack:"
report_tns -min

puts "\n================ STA FINISHED ========================\n"
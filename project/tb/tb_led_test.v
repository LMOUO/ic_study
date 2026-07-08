
`timescale 1ns / 1ps
module tb_led_test;

reg        sys_clk;
reg        sys_rst_n;
wire       o_led;

led_test u_dut (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .o_led      (o_led)
);

initial sys_clk = 0;
always #10 sys_clk = ~sys_clk;

initial begin
    $dumpfile("../sim/waves/wave.vcd");
    $dumpvars(0, tb_led_test);

    sys_rst_n = 0;
    #50 sys_rst_n = 1;
    #2000;
    $display("Simulation finished.");
    $finish;
end

endmodule

`timescale 1ns / 1ps

module tb_led_test_selfcheck;

reg  sys_clk;
reg  sys_rst_n;
wire o_led;

integer i;
reg [9:0] ref_cnt;

led_test u_dut (
    .sys_clk   (sys_clk),
    .sys_rst_n (sys_rst_n),
    .o_led     (o_led)
);

initial sys_clk = 0;
always #10 sys_clk = ~sys_clk;

initial begin
    $dumpfile("../sim/wave.vcd");
    $dumpvars(0, tb_led_test_selfcheck);

    sys_rst_n = 0;
    ref_cnt   = 10'd0;

    repeat (5) @(posedge sys_clk);

    // Release reset away from posedge to avoid race condition
    @(negedge sys_clk);
    sys_rst_n = 1;

    for (i = 0; i < 1100; i = i + 1) begin
        @(posedge sys_clk);

        if (sys_rst_n == 0)
            ref_cnt = 10'd0;
        else
            ref_cnt = ref_cnt + 10'd1;

        #1;

        if (o_led !== ref_cnt[9]) begin
            $display("ERROR: time=%0t, ref_cnt=%0d, expected o_led=%0b, got o_led=%0b",
                     $time, ref_cnt, ref_cnt[9], o_led);
            $fatal;
        end
    end

    $display("PASS: led_test self-check simulation passed.");
    $finish;
end

endmodule
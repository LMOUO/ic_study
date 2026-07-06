`timescale 1ns / 1ps
module tb_led_test;

reg        sys_clk;
reg        sys_rst_n;
wire       o_led;

// 实例化 DUT
led_test u_dut (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .o_led      (o_led)
);

// 50MHz 时钟生成
initial sys_clk = 0;
always #10 sys_clk = ~sys_clk;

// 测试序列
initial begin
    $dumpfile("sim/wave.vcd");     // 生成 VCD 波形文件
    $dumpvars(0, tb_led_test);     // 记录所有信号

    sys_rst_n = 0;
    #50 sys_rst_n = 1;

    // 运行足够长时间，观察 o_led 的变化
    #2000;

    $display("Simulation finished.");
    $finish;
end

endmodule

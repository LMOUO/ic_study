`timescale 1ns / 1ps

module tb_uart_tx_selfcheck;

localparam CLK_FREQ = 50_000_000;
localparam UART_BPS = 9600;
localparam BPS_CNT  = CLK_FREQ / UART_BPS;

reg        sys_clk;
reg        sys_rst_n;
reg        uart_en;
reg [7:0]  uart_din;

wire       uart_tx_busy;
wire       uart_txd;
reg [8*64-1:0] current_case;
integer test_pass_count;
integer test_fail_count;


integer i;

uart_tx #(
    .CLK_FREQ (CLK_FREQ),
    .UART_BPS (UART_BPS)
) u_uart_tx (
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),
    .uart_en      (uart_en),
    .uart_din     (uart_din),
    .uart_tx_busy (uart_tx_busy),
    .uart_txd     (uart_txd)
);

initial sys_clk = 1'b0;
always #10 sys_clk = ~sys_clk;   // 50 MHz

initial begin
    current_case    = "NONE";
    test_pass_count = 0;
    test_fail_count = 0;

    $dumpfile("../sim/uart_tx_wave.vcd");
    $dumpvars(0, tb_uart_tx_selfcheck);

    sys_rst_n = 1'b0;
    uart_en   = 1'b0;
    uart_din  = 8'd0;

    repeat (10) @(posedge sys_clk);
    sys_rst_n = 1'b1;
    repeat (10) @(posedge sys_clk);

    begin_case("TX_BASIC_55");
    send_and_check(8'h55);
    end_case();
    repeat (20) @(posedge sys_clk);
    
    begin_case("TX_BASIC_A5");
    send_and_check(8'hA5);
    end_case();
    repeat (20) @(posedge sys_clk);

    begin_case("TX_BASIC_00");
    send_and_check(8'h00);
    end_case();
    repeat (20) @(posedge sys_clk);

    begin_case("TX_BASIC_FF");
    send_and_check(8'hFF);
    end_case();
    repeat (20) @(posedge sys_clk);

    begin_case("TX_EN_LONG_1");
    send_long_en_and_check(46);
    end_case();
    repeat (20) @(posedge sys_clk);

    begin_case("TX_BUSY_RETRY");
    busy_retry_test;
    end_case();
    repeat (20) @(posedge sys_clk);

    begin_case("TX_RESET_TX");
    reset_during_tx_test;
    end_case();
    repeat (20) @(posedge sys_clk);


    $display("PASS: uart_tx self-check simulation passed.");
    $finish;
end

//触发串口发送数据
task send_byte;
    input [7:0] data;
    begin
        @(posedge sys_clk);
        uart_din <= data;
        uart_en  <= 1'b1;

        @(posedge sys_clk);
        uart_en  <= 1'b0;
        uart_din <= 8'd0;
    end
endtask

//检查串口发送数据正确与错误
task check_byte;
    input [7:0] expected_data;
    begin
        // 等待起始位下降沿
        @(negedge uart_txd);

        // 起始位中点采样
        repeat (BPS_CNT / 2) @(posedge sys_clk);
        if (uart_txd !== 1'b0) begin
            $display("ERROR: start bit wrong, time=%0t", $time);
            $fatal;
        end

        // 8 个数据位，UART 低位先发
        for (i = 0; i < 8; i = i + 1) begin
            repeat (BPS_CNT) @(posedge sys_clk);
            if (uart_txd !== expected_data[i]) begin
                $display("ERROR: data bit %0d wrong, expected=%0b, got=%0b, time=%0t",
                         i, expected_data[i], uart_txd, $time);
                $fatal;
            end
        end

        // 停止位
        repeat (BPS_CNT) @(posedge sys_clk);
        if (uart_txd !== 1'b1) begin
            $display("ERROR: stop bit wrong, time=%0t", $time);
            $fatal;
        end
    end
endtask

//发送数据并检查数据是否正确
task send_and_check;
    input [7:0] data;
    begin
        fork
            check_byte(data);
            send_byte(data);
        join

        wait (uart_tx_busy == 1'b0);
        repeat (5) @(posedge sys_clk);
    end
endtask


//测试使能信号拉高多个周期后是否只发一次数据
task send_long_en_and_check;
    input [7:0] data;
    begin
        fork
            check_byte(data);
            begin
                @(negedge sys_clk);
                uart_din = data;
                uart_en  = 1'b1;

                repeat (10) @(negedge sys_clk);
                uart_en  = 1'b0;
                uart_din = 8'd0;
            end
        join

        wait (uart_tx_busy == 1'b0);
        repeat (5) @(posedge sys_clk);
    end
endtask


//测试发送过程中是否会被新数据打断
task busy_retry_test;
    begin
        fork
            check_byte(8'h55);
            begin
                send_byte(8'h55);

                // 发送过程中尝试再发 0xAA
                repeat (BPS_CNT * 2) @(posedge sys_clk);
                @(negedge sys_clk);
                uart_din = 8'hAA;
                uart_en  = 1'b1;

                @(negedge sys_clk);
                uart_en  = 1'b0;
                uart_din = 8'd0;
            end
        join

        wait (uart_tx_busy == 1'b0);
        repeat (5) @(posedge sys_clk);
    end
endtask

//测试复位是否能打断串口发送
task reset_during_tx_test;
    begin
        @(negedge sys_clk);
        uart_din = 8'h55;
        uart_en  = 1'b1;

        @(negedge sys_clk);
        uart_en  = 1'b0;

        wait (uart_tx_busy == 1'b1);

        repeat (BPS_CNT * 2) @(posedge sys_clk);

        @(negedge sys_clk);
        sys_rst_n = 1'b0;

        repeat (5) @(posedge sys_clk);

        if (uart_txd !== 1'b1) begin
            $display("ERROR: uart_txd should return idle after reset");
            $fatal;
        end

        if (uart_tx_busy !== 1'b0) begin
            $display("ERROR: busy should be 0 after reset");
            $fatal;
        end

        @(negedge sys_clk);
        sys_rst_n = 1'b1;

        repeat (10) @(posedge sys_clk);

        send_and_check(8'hA5);
    end
endtask







task begin_case;
    input [8*64-1:0] name;
    begin
        current_case = name;
        $display("");
        $display("=================================================");
        $display("START CASE: %0s", current_case);
        $display("TIME      : %0t", $time);
        $display("=================================================");
    end
endtask

task end_case;
    begin
        test_pass_count = test_pass_count + 1;
        $display("PASS CASE : %0s, time=%0t", current_case, $time);
    end
endtask



endmodule
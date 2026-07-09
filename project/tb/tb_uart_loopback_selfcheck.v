`timescale 1ns/1ps
module tb_uart_loopback_selfcheck();

localparam CLK_FREQ = 50_000_000            ;
localparam UART_BPS = 9600                  ; 
localparam BPS_CNT  = CLK_FREQ / UART_BPS   ;


//产生时钟和复位
reg     sys_clk     ;
reg     sys_rst_n   ;

//产生测试相关打印日志
reg [8*64-1:0] current_case;
integer test_pass_count;
integer test_fail_count;

initial     sys_clk = 1'b0      ;
always #10  sys_clk = ~sys_clk  ;

//全局超时管理
initial begin
    #50000000                                                      ; // 50 ms, timescale 1ns
    $display("ERROR: simulation timeout, current_case=%0s, time=%0t",
             current_case, $time)                                   ;
    $fatal                                                          ;
end

//例化模块
reg     uart_rxd;
wire    uart_txd;
uart_loopback   
#(
    .CLK_FREQ(50000000),
    .UART_BPS(9600)
)
uart_loopback_inst
(
    .sys_clk    (sys_clk    ),
    .sys_rst_n  (sys_rst_n  ),

    .uart_rxd   (uart_rxd   ),
    .uart_txd   (uart_txd   )
);

//测试用例
initial begin
    current_case = "NULL";
    test_pass_count = 0;
    test_fail_count = 0;
    $dumpfile("../sim/waves/uart_loopback_wave.vcd");
    $dumpvars(0, tb_uart_loopback_selfcheck);

    sys_rst_n = 1'b0;
    uart_rxd  = 1'b1;
    repeat(5)@(posedge sys_clk);
    sys_rst_n = 1'b1;

	begin_case("loop_00");
	send_and_check(8'h00);
	end_case();    

	begin_case("loop_FF");
	send_and_check(8'hFF);
	end_case();    

	begin_case("loop_AA");
	send_and_check(8'hAA);
	end_case();    

	begin_case("loop_55");
	send_and_check(8'h55);
	end_case();    

	begin_case("loop_A5");
	send_and_check(8'hA5);
	end_case();    

	begin_case("loop_5A");
	send_and_check(8'h5A);
	end_case();    

    $display("PASS: uart_loopback self-check simulation passed.");
    $finish;
end


//编写任务
//发送数据
task send_data;
    input   [7:0] data;
    integer i;
    begin
        //空闲
        @(negedge sys_clk);
        uart_rxd = 1'b1;
        repeat(BPS_CNT) @(posedge sys_clk);

        //起始位
        @(negedge sys_clk);
        uart_rxd = 1'b0;
        repeat(BPS_CNT) @(posedge sys_clk);       

        //数据位
        for(i=0;i<8;i=i+1) begin
            @(negedge sys_clk);
                uart_rxd = data[i];
            repeat(BPS_CNT)@(posedge sys_clk);    
        end

        //停止位
        @(negedge sys_clk);
        uart_rxd = 1'b1;
        repeat(BPS_CNT) @(posedge sys_clk);             
    end
endtask

task send_and_check;
    input   [7:0] expect_data;
    integer i;
    begin
        fork
            send_data(expect_data);
            begin
                //等待起始位下降沿
                @(negedge uart_txd);

                //起始位中点采样
                repeat(BPS_CNT/2)@(posedge sys_clk);
                if(uart_txd !== 1'b0) begin
                    $display("ERROR CASE: %0s", current_case);
                    $display("ERROR INFO: start bit wrong");
                    $display("TIME      : %0t", $time);
                    $display("EXPECTED  : 0");
                    $display("GOT       : %0b", uart_txd);
                    $fatal;
                end

                for(i=0;i<8;i=i+1) begin
                    //等待一个波特率时间 开始核对数据 执行八次
                    repeat(BPS_CNT)@(posedge sys_clk);
                    if(uart_txd !== expect_data[i]) begin
                        $display("ERROR CASE: %0s", current_case);
                        $display("ERROR INFO: start bit wrong");
                        $display("TIME      : %0t", $time);
                        $display("EXPECTED  : 0");
                        $display("GOT       : %0b", uart_txd);
                        $fatal;
                    end
                end

                repeat(BPS_CNT)@(posedge sys_clk);
                if(uart_txd !== 1'b1) begin
                    $display("ERROR CASE: %0s", current_case);
                    $display("ERROR INFO: start bit wrong");
                    $display("TIME      : %0t", $time);
                    $display("EXPECTED  : 0");
                    $display("GOT       : %0b", uart_txd);
                    $fatal;                    
                end
            end
        join
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
    end
endtask

task end_case;
    begin
        test_pass_count = test_pass_count + 1;
        $display("PASS CASE : %0s, time=%0t", current_case, $time);
		$display("=================================================");
    end
endtask

endmodule

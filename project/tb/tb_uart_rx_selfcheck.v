`timescale 1ns/1ps
module tb_uart_rx_selfcheck();

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
    #1000000000                                                      ; // 100 ms, timescale 1ns
    $display("ERROR: simulation timeout, current_case=%0s, time=%0t",
             current_case, $time)                                   ;
    $fatal                                                          ;
end


//例化模块
reg             uart_rxd    ;

wire            uart_done   ;
wire            rx_flag     ;
wire    [3:0]   rx_cnt      ;
wire    [7:0]   rxdata      ;
wire    [7:0]   uart_data   ;

uart_rx    
#(
    .CLK_FREQ   (CLK_FREQ)   ,
    .UART_BPS   (UART_BPS)
)
 uart_rx_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟
    .sys_rst_n  (sys_rst_n  ),  //系统复位，低电平有效
    
    .uart_rxd   (uart_rxd   ),  //UART接收端口
    .uart_done	(uart_done  ),  //接收一帧数据完成标志
    .uart_data  (uart_data  )   //接收的数据
);

//开始编写测试用例
initial begin

    $dumpfile("../sim/waves/uart_rx_wave.vcd");
    $dumpvars(0, tb_uart_rx_selfcheck);

    current_case    = "NONE";
    test_pass_count = 0;
    test_fail_count = 0;
	
	sys_rst_n 		<= 1'b0;
	uart_rxd		<= 1'b1;
	
	repeat(5)@(posedge sys_clk)
	sys_rst_n <= 1'b1;

	begin_case("RX_00");
	send_and_check(8'h00);
	end_case();

	begin_case("RX_FF");
	send_and_check(8'hFF);
	end_case();
	
	begin_case("RX_55");
	send_and_check(8'h55);
	end_case();

	begin_case("RX_AA");
	send_and_check(8'hAA);
	end_case();
	
	begin_case("RX_A5");
	send_and_check(8'hA5);
	end_case();
	
	begin_case("RX_5A");
	send_and_check(8'h5A);
	end_case();
	
    $display("PASS: uart_rx self-check simulation passed.");
    $finish;

end


//编写task
//生成串口接收数据
task send_data;
    input [7:0] data;
	integer i;
    begin
	
		//空闲状态
		@(negedge  sys_clk);
        uart_rxd    =  1'b1;
        repeat(BPS_CNT)@(posedge  sys_clk);	
	
		//起始位
		@(negedge  sys_clk);
        uart_rxd    =  1'b0;
        repeat(BPS_CNT)@(posedge  sys_clk);
		
		//数据位
		for(i=0;i<8;i=i+1) begin
			@(negedge  sys_clk);
			uart_rxd	=	data[i];
			//$display("DATA bit[%0d] = %b, time=%0t", i, uart_rxd, $time);
			repeat(BPS_CNT)@(posedge  sys_clk);
		end
		
		//停止位
		@(negedge  sys_clk);
		uart_rxd	=	1'b1;
		repeat (BPS_CNT) @(posedge sys_clk);
		
    end
endtask

//发送数据并验证数据是否正确
task send_and_check;
    input [7:0] expect_data;
    begin
		fork
			send_data(expect_data); //发送数据
			begin
				wait(uart_done); //等待串口接收模块完成返回
				
				//检查接收数据是否正确
				if(uart_data !== expect_data) begin 
					$display("ERROR:expected=0x%02h, got=0x%02h, time=%0t", expect_data, uart_data, $time);
					$fatal;
				end
				else begin
					$display("PASS: expected=0x%02h, got=0x%02h, time=%0t", expect_data, uart_data, $time);
					test_pass_count = test_pass_count + 'd1;
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
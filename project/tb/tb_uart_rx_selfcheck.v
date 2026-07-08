`timescale 1ns/1ps
module tb_uart_rx_selfcheck();

localparam CLK_FREQ = 50_000_000;
localparam UART_BPS = 9600;
localparam BPS_CNT  = CLK_FREQ / UART_BPS;


//产生时钟和复位
reg     sys_clk     ;
reg     sys_rst_n   ;

initial     sys_clk = 1'b0;
always #10  sys_clk = ~sys_clk;

//全局超时管理
initial begin
    #100000000; // 100 ms, timescale 1ns
    $display("ERROR: simulation timeout, current_case=%0s, time=%0t",
             current_case, $time);
    $fatal;
end


//例化模块
reg             uart_rxd;

wire            uart_done;
wire            rx_flag;
wire    [3:0]   rx_cnt;
wire    [7:0]   rxdata;
wire    [7:0]   uart_data;

uart_rx    
#(
    .CLK_FREQ(CLK_FREQ),
    .UART_BPS(UART_BPS)
)
 uart_rx_inst
(
    .sys_clk    (sys_clk    ),  //系统时钟
    .sys_rst_n  (sys_rst_n  ),  //系统复位，低电平有效
    
    .uart_rxd   (uart_rxd   ),  //UART接收端口
    .uart_done	(uart_done  ),  //接收一帧数据完成标志
    .rx_flag	(rx_flag    ),  //接收过程标志信号
    .rx_cnt		(rx_cnt     ),  //接收数据计数器
    .rxdata		(rxdata     ),
    .uart_data  (uart_data  )   //接收的数据
);

//开始编写测试用例
initial begin


end






endmodule
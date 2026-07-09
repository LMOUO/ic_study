# ic_study
本项目用于学习数字 IC 前端完整流程，包括：

1. project/doc/     相关说明文档
2. project/ip/      使用的硬核
3. project/libs/    使用的工艺库
4. project/rtl/     设计源码
5. project/sim/     设计仿真和验证仿真 脚本和生成文件
6. project/syn/     综合(Yosys) 和 静态时序分析(OpenSTA)
7. project/tb/      仿真v文件
8. project/Makefile 一键执行脚本文件

push.sh     项目管理推送git脚本

开发进度：
2026年7月8日
源代码：
1. 模块功能：UART 发送模块

2. 输入输出端口说明
input	      sys_clk,                  //系统时钟
input         sys_rst_n,                //系统复位，低电平有效
input         uart_en,                  //发送使能信号
input  [7:0]  uart_din,                 //待发送数据
output        uart_tx_busy,             //发送忙状态标志 
output  reg   uart_txd                  //UART发送端口

3. 参数说明：
CLK_FREQ / UART_BPS
可配置，本次测试采用50M的CLK_FREQ和9600的UART_BPS

4. 帧格式：1 start + 8 data + 1 stop

5. 验证 case 列表
执行make后查询相关log文件

6. 综合结果：
cell 137  area 255.360000

7. STA 结果：
setup 通过，hold 有轻微 pre-layout violation

8. 结论：UART_TX 完成

脚本：
1. 综合和仿真脚本可参数化一键运行
2. 版本管理推送脚本修改简洁

2026年7月9日
1. 模块功能：UART 接收模块
2. 接口说明：
input			  sys_clk,                  //系统时钟
input             sys_rst_n,                //系统复位，低电平有效
    
input             uart_rxd,                 //UART接收端口
output  reg       uart_done,                //接收一帧数据完成标志
output  reg       rx_flag,                  //接收过程标志信号
output  reg [ 3:0] rx_cnt,                  //接收数据计数器
output  reg [ 7:0] rxdata,
output  reg [7:0] uart_data                 //接收的数据

3. 参数说明：
CLK_FREQ / UART_BPS
可配置，本次测试采用50M的CLK_FREQ和9600的UART_BPS

4. 帧格式：1 start + 8 data + 1 stop

5. 验证 case 列表
执行make后查询相关log文件

6. 综合结果：
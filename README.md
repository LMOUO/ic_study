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
2026年7月6日
安装Yosys和OpenSTA等相关开发环境

2026年7月7日
模块：
1. 模块功能：led_test 环境测试模块 led_test.v
2. 输入输出端口说明：见相关module
3. 参数说明：无
4. 验证 case 列表：执行make后查询相关log文件
6. 综合结果：cell 137  area 255.360000 具体信息查看相关log
7. STA 结果：setup 通过，hold 有轻微 pre-layout violation 具体信息查看相关log
8. 结论：led_test 完成

2026年7月8日
模块：
1. 模块功能：UART 发送模块 uart_tx.v
2. 输入输出端口说明：见相关module
3. 参数说明：CLK_FREQ / UART_BPS，可配置，本次测试采用50M的CLK_FREQ和9600的UART_BPS
4. 帧格式：1 start + 8 data + 1 stop
5. 验证 case 列表：执行make后查询相关log文件
6. 综合结果：cell 137  area 255.360000 具体信息查看相关log
7. STA 结果：setup 通过，hold 有轻微 pre-layout violation 具体信息查看相关log
8. 结论：UART_TX 完成
脚本：
1. 综合和仿真脚本可参数化一键运行
2. 版本管理推送脚本修改简洁

2026年7月9日
模块：UART 接收模块 uart_rx.v
1. 接口说明：见相关module
2. 参数说明：CLK_FREQ / UART_BPS，可配置，本次测试采用50M的CLK_FREQ和9600的UART_BPS
3. 帧格式：1 start + 8 data + 1 stop
4. 验证 case 列表：执行make后查询相关log文件
5. 综合结果：cell 154  area 329.042 具体信息查看相关log
6. STA 结果：setup 通过，hold 有微小 pre-layout violation 具体信息查看相关log
7. 结论：UART_RX 完成

模块：UART 回环模块 uart_loopback.v
1. 接口说明：见相关module
2. 参数说明：CLK_FREQ / UART_BPS，可配置，本次测试采用50M的CLK_FREQ和9600的UART_BPS
3. 帧格式：1 start + 8 data + 1 stop
4. 验证 case 列表：执行make后查询相关log文件
5. 综合结果：cell 365  area 744.534 具体信息查看相关log
6. STA 结果：setup 通过，hold 有微小 pre-layout violation 具体信息查看相关log
7. 结论：UART_LOOPBACK 完成

脚本：
1. 注意在现有环境下多个v文件编译需要在顶层中inclue，暂时未做多个v文件同时编译的脚本

2026年7月10日
模块：SYNC_FIFO 同步FIFO模块 sync_fifo_my.v
1. 接口说明：见相关module
2. 参数说明：位宽8字节，深度128，可配置
3. 验证 case 列表：执行make后查询相关log文件
5. 综合结果：cell 3774  area 8690 具体信息查看相关log
6. STA 结果：setup 通过，hold 巨大违例
原因：
128×8 memory 被展开成1032个DFF和大量MUX；
memory占面积约97.5%；
地址和写使能网络产生数百扇出；
输入hold违例被1024个存储位大量复制。
7. 结论：
综合通过，静态时序分析未通过，并且大量面积被memory占用
具体原因是Nangate45 标准单元库中没有配置可映射的 SRAM 宏
最后，不是按照mem的形式综合，被展开综合。




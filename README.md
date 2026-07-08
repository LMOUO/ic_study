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

2026年七月8日
1. 模块功能：UART 发送模块
2. 输入输出端口说明
3. 参数说明：CLK_FREQ / UART_BPS
4. 帧格式：1 start + 8 data + 1 stop
5. 验证 case 列表
6. 综合结果：cell 137  area 255.360000
7. STA 结果：setup 通过，hold 有轻微 pre-layout violation
8. 结论：UART_TX 完成



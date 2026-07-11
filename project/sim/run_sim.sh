#!/usr/bin/env bash

#严格错误检查 
#-e 任意命令返回失败状态时，脚本立即终止
#-u 使用未定义变量时立即报错
#-o pipefail 管道中任意命令失败，整个管道都视为失败
set -euo pipefail

#读取仿真模式参数
#$1：执行脚本时传入的第一个参数
#:-rtl：如果没有传参数，就默认使用 rtl  
MODE="${1:-rtl}"

#   计算工程根目录
#   ${BASH_SOURCE[0]} 表示当前脚本文件的路径
#   dirname "${BASH_SOURCE[0]}" 取脚本所在目录
#   "$(dirname "${BASH_SOURCE[0]}")/.."表示脚本目录的上一级，即工程根目录
#   cd ... && pwd 先进入工程根目录，然后用 pwd 输出绝对路径
#   $(...) 这是命令替换。它会执行里面的命令，并把输出保存到变量中
#   最后ROOT_DIR="/workspaces/ic_study/project"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

#   定义仿真目录   注意Shell变量赋值时，等号两边不能有空格
SIM_DIR="$ROOT_DIR/sim"

#   定义仿真顶层模块名
TOP_MODULE="tb_sync_fifo_my_selfcheck"

#   定义源文件路径
RTL_MEM="$ROOT_DIR/rtl/mem_sdp_sync.v"
RTL_FIFO="$ROOT_DIR/rtl/sync_fifo_my.v"
TESTBENCH="$ROOT_DIR/tb/tb_sync_fifo_my_selfcheck.v"

#   定义SRAM 模型路径
SRAM_MODEL="$ROOT_DIR/libs/SKY130/sky130_sram_1kbyte_1rw1r_8x1024_8.v"

#   创建输出目录
#   sim/build
#   sim/logs
#   sim/waves
mkdir -p "$SIM_DIR/build"
mkdir -p "$SIM_DIR/logs"
mkdir -p "$SIM_DIR/waves"

#   切换到仿真目录
#   脚本在这里后面的相对路径已经到了sim目录下
cd "$SIM_DIR"

#   根据 MODE 选择编译方式
case "$MODE" in

    rtl)
        echo "========================================"
        echo "FIFO simulation mode: RTL memory"
        echo "========================================"

        OUTPUT_FILE="build/tb_fifo_rtl.vvp"
        LOG_FILE="logs/tb_fifo_rtl.log"

        iverilog -g2012 -Wall -s "$TOP_MODULE" -o "$OUTPUT_FILE" "$RTL_MEM" "$RTL_FIFO" "$TESTBENCH";;





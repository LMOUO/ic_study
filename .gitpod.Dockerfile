FROM gitpod/workspace-full:latest

USER gitpod

# 安装 Icarus Verilog (仿真), GTKWave (波形), Yosys (综合), 及其他实用工具
RUN sudo apt-get update && \
    sudo apt-get install -y \
    iverilog \
    gtkwave \
    yosys \
    make \
    gcc \
    g++ \
    && sudo rm -rf /var/lib/apt/lists/*

#!/bin/bash
# 启动声纹识别服务

echo "======================================"
echo "启动声纹识别服务"
echo "======================================"
echo ""

# 检查是否已安装依赖
if ! python -c "import torch" 2>/dev/null; then
    echo "错误: 依赖未安装，请先运行 ./install.sh"
    exit 1
fi

# 检查配置文件
if [ ! -f "data/.voiceprint.yaml" ]; then
    echo "初始化配置文件..."
    mkdir -p data
    cp voiceprint.yaml data/.voiceprint.yaml
    echo "配置文件已创建: data/.voiceprint.yaml"
    echo ""
fi

# 选择运行模式
if [ "$1" = "prod" ] || [ "$1" = "production" ]; then
    echo "启动生产环境服务..."
    python start_server.py
else
    echo "启动开发环境服务..."
    echo "提示: 使用 './start.sh prod' 启动生产环境"
    echo ""
    python -m app.main
fi
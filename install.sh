#!/bin/bash
# 声纹识别API安装脚本 (CPU版本)

echo "======================================"
echo "声纹识别API安装脚本"
echo "======================================"

# 检查Python版本
python_version=$(python3 --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
echo "检测到Python版本: $python_version"

# 检查pip
if ! command -v pip &> /dev/null; then
    echo "错误: 未找到pip，请先安装pip"
    exit 1
fi

# 设置pip镜像（可选）
read -p "是否使用阿里云镜像源？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
    echo "已配置阿里云镜像源"
fi

echo ""
echo "开始安装..."
echo ""

# 步骤1: 安装PyTorch CPU版本
echo "[1/3] 安装PyTorch CPU版本 (约500MB)..."
pip install torch==2.2.2+cpu torchaudio==2.2.2+cpu -f https://download.pytorch.org/whl/torch_stable.html

if [ $? -ne 0 ]; then
    echo "PyTorch安装失败"
    exit 1
fi

# 步骤2: 安装pyarrow（先安装以避免版本冲突）
echo ""
echo "[2/3] 安装pyarrow..."
pip install pyarrow==11.0.0

# 步骤3: 安装其他依赖
echo ""
echo "[3/3] 安装其他依赖..."
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "依赖安装失败"
    exit 1
fi

# 创建必要的目录
echo ""
echo "3. 创建必要的目录..."
mkdir -p data tmp

# 复制配置文件
if [ ! -f "data/.voiceprint.yaml" ]; then
    echo "4. 初始化配置文件..."
    cp voiceprint.yaml data/.voiceprint.yaml
    echo "配置文件已创建: data/.voiceprint.yaml"
fi

echo ""
echo "======================================"
echo "安装完成！"
echo ""
echo "启动服务:"
echo "  开发环境: python -m app.main"
echo "  生产环境: python start_server.py"
echo ""
echo "API文档: http://localhost:8005/voiceprint/docs"
echo "======================================"
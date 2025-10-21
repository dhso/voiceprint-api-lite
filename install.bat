@echo off
REM 声纹识别API安装脚本 - Windows

echo ======================================
echo 声纹识别API安装脚本 (Windows)
echo ======================================
echo.

REM 检查Python
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Python，请先安装Python 3.10+
    pause
    exit /b 1
)

echo 检测到Python:
python --version
echo.

REM 步骤1: 安装PyTorch CPU版本
echo [1/3] 安装PyTorch CPU版本 (约500MB)...
pip install torch==2.2.2+cpu torchaudio==2.2.2+cpu -f https://download.pytorch.org/whl/torch_stable.html

if errorlevel 1 (
    echo PyTorch安装失败
    pause
    exit /b 1
)

REM 步骤2: 安装pyarrow（先安装以避免版本冲突）
echo.
echo [2/3] 安装pyarrow...
pip install pyarrow==11.0.0

REM 步骤3: 安装其他依赖
echo.
echo [3/3] 安装其他依赖...
pip install -r requirements.txt

if errorlevel 1 (
    echo 依赖安装失败
    pause
    exit /b 1
)

REM 创建必要的目录
echo.
echo 3. 创建必要的目录...
if not exist data mkdir data
if not exist tmp mkdir tmp

REM 复制配置文件
if not exist "data\.voiceprint.yaml" (
    echo 4. 初始化配置文件...
    copy voiceprint.yaml data\.voiceprint.yaml
    echo 配置文件已创建: data\.voiceprint.yaml
)

echo.
echo ======================================
echo 安装完成！
echo.
echo 启动服务:
echo   开发环境: python -m app.main
echo   生产环境: python start_server.py
echo.
echo API文档: http://localhost:8005/voiceprint/docs
echo ======================================
pause
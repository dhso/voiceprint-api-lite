@echo off
REM 启动声纹识别服务 - Windows

echo ======================================
echo 启动声纹识别服务
echo ======================================
echo.

REM 检查是否已安装依赖
python -c "import torch" 2>nul
if errorlevel 1 (
    echo 错误: 依赖未安装，请先运行 install.bat
    pause
    exit /b 1
)

REM 检查配置文件
if not exist "data\.voiceprint.yaml" (
    echo 初始化配置文件...
    if not exist data mkdir data
    copy voiceprint.yaml data\.voiceprint.yaml
    echo 配置文件已创建: data\.voiceprint.yaml
    echo.
)

REM 选择运行模式
if "%1"=="prod" goto production
if "%1"=="production" goto production

:development
echo 启动开发环境服务...
echo 提示: 使用 'start.bat prod' 启动生产环境
echo.
python -m app.main
goto end

:production
echo 启动生产环境服务...
python start_server.py

:end
pause
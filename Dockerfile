# 第一阶段：构建Python依赖
FROM python:3.10-slim AS builder

# 安装系统依赖，包括编译工具
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 安装依赖（CPU版本，减少镜像大小）
# 先安装PyTorch CPU版本
RUN pip install --no-cache-dir torch==2.2.2+cpu torchaudio==2.2.2+cpu -f https://download.pytorch.org/whl/torch_stable.html
# 安装固定版本的pyarrow以避免兼容性问题
RUN pip install --no-cache-dir pyarrow==11.0.0
# 再安装其他依赖
RUN pip install --no-cache-dir -r requirements.txt

# 第二阶段：运行阶段
FROM python:3.10-slim

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV TZ=Asia/Shanghai

# 设置工作目录
WORKDIR /app

# 从构建阶段复制Python依赖
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# 创建必要的目录和用户
RUN mkdir -p /app/tmp /app/data /app/logs && \
    useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# 复制应用代码（只复制必要的文件）
COPY --chown=appuser:appuser app/ ./app/
COPY --chown=appuser:appuser start_server.py .
COPY --chown=appuser:appuser voiceprint.yaml .

# 初始化配置文件
RUN cp voiceprint.yaml data/.voiceprint.yaml && \
    chown appuser:appuser data/.voiceprint.yaml

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8005

# 健康检查（使用curl或wget）
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8005/voiceprint/health')" || exit 1

# 启动命令
CMD ["python", "start_server.py"]
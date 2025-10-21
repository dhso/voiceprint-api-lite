# 3D-Speaker 声纹识别API

基于3D-Speaker模型的声纹识别服务，提供声纹注册、识别、删除等功能。

基于 [voiceprint-api](https://github.com/xinnan-tech/voiceprint-api) 重制轻量化部署，使用Sqlite替代Mysql，并且移除GPU支持，减少打包大小。

目前用于xiaozhi说话人识别，[xiaozhi-esp32-server](https://github.com/xinnan-tech/xiaozhi-esp32-server)

## 🛠️ 安装和配置

### 1. 安装依赖

#### 方式一：自动安装（推荐）

Linux/Mac:
```bash
./install.sh
```

Windows:
```bash
install.bat
```

#### 方式二：手动安装

```bash
# 1. 创建Python环境（可选，推荐使用conda）
conda create -n voiceprint-api python=3.10 -y
conda activate voiceprint-api

# 2. 安装PyTorch CPU版本（约500MB，无需GPU）
pip install torch==2.2.2+cpu torchaudio==2.2.2+cpu -f https://download.pytorch.org/whl/torch_stable.html

# 3. 安装其他依赖
pip install -r requirements.txt
```

### 2. 数据库配置
本项目使用SQLite数据库，无需安装额外的数据库服务。数据库文件会在首次运行时自动创建。

### 3. 配置文件
复制voiceprint.yaml到data目录，并编辑 `data/.voiceprint.yaml`：
```yaml
sqlite:
  database: "data/voiceprint.db"  # SQLite数据库文件路径
```

数据库表结构（自动创建）：
```sql
CREATE TABLE voiceprints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    speaker_id TEXT NOT NULL UNIQUE,
    feature_vector BLOB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

## 🚀 启动服务

### 快速启动

Linux/Mac:
```bash
./start.sh        # 开发环境
./start.sh prod   # 生产环境
```

Windows:
```bash
start.bat         # 开发环境
start.bat prod    # 生产环境
```

### 手动启动

```bash
# 开发环境（支持热重载）
python -m app.main

# 生产环境（性能优化）
python start_server.py
```

## 🐳 Docker部署

### 使用docker.sh脚本（推荐）

```bash
# 构建镜像
./docker.sh build

# 启动服务
./docker.sh up

# 查看日志
./docker.sh logs

# 停止服务
./docker.sh down
```

### 使用docker-compose

```bash
# 构建并启动
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 📚 API文档

启动服务后，访问以下地址查看API文档：
- Swagger UI: http://localhost:8005/voiceprint/docs

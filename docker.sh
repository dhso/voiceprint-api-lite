#!/bin/bash
# Docker管理脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
}

# 构建镜像
build() {
    print_info "开始构建Docker镜像..."
    docker-compose build --no-cache
    print_info "镜像构建完成！"
}

# 启动服务
up() {
    print_info "启动服务..."
    docker-compose up -d
    print_info "服务已启动！"
    print_info "API文档: http://localhost:8005/voiceprint/docs"
}

# 停止服务
down() {
    print_info "停止服务..."
    docker-compose down
    print_info "服务已停止！"
}

# 重启服务
restart() {
    print_info "重启服务..."
    docker-compose restart
    print_info "服务已重启！"
}

# 查看日志
logs() {
    docker-compose logs -f --tail=100
}

# 查看状态
status() {
    docker-compose ps
}

# 进入容器
shell() {
    print_info "进入容器shell..."
    docker-compose exec voiceprint-api /bin/bash
}

# 清理
clean() {
    print_warn "清理Docker资源..."
    docker-compose down -v
    docker system prune -f
    print_info "清理完成！"
}

# 帮助信息
help() {
    echo "使用方法: ./docker.sh [命令]"
    echo ""
    echo "可用命令:"
    echo "  build    - 构建Docker镜像"
    echo "  up       - 启动服务"
    echo "  down     - 停止服务"
    echo "  restart  - 重启服务"
    echo "  logs     - 查看日志"
    echo "  status   - 查看状态"
    echo "  shell    - 进入容器"
    echo "  clean    - 清理资源"
    echo "  help     - 显示帮助"
}

# 主程序
check_docker

case "$1" in
    build)
        build
        ;;
    up)
        up
        ;;
    down)
        down
        ;;
    restart)
        restart
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    shell)
        shell
        ;;
    clean)
        clean
        ;;
    help|"")
        help
        ;;
    *)
        print_error "未知命令: $1"
        help
        exit 1
        ;;
esac
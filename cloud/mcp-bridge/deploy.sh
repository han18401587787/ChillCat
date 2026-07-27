#!/usr/bin/env bash
#
# deploy.sh — 一键部署 AppDebug MCP Bridge 到云服务器
#
# 用法:
#   DEVICE_URL=http://10.0.0.5:9080 ./deploy.sh
#
# 前置:
#   - 云服务器已安装 Docker 26+
#   - iPhone 上 ChillCat Debug 已启动（AppDebugServer port 9080）
#   - iPhone 与云服务器网络互通（同 WiFi 或通过 iproxy 隧道）

set -euo pipefail

DEVICE_URL="${DEVICE_URL:-http://localhost:9080}"
CONTAINER_NAME="chillcat-mcp-bridge"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 部署 AppDebug MCP Bridge"
echo "   目标设备: ${DEVICE_URL}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查 Docker
if ! command -v docker &>/dev/null; then
  echo "❌ 需要 Docker，请先安装" >&2
  exit 1
fi

# 构建镜像
echo ""
echo "📦 构建 Docker 镜像..."
docker build -t chillcat-mcp-bridge:latest .

# 停止旧容器
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "🛑 停止旧容器..."
  docker stop "$CONTAINER_NAME" 2>/dev/null || true
  docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# 启动新容器
echo ""
echo "▶️  启动容器..."
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -e "DEVICE_URL=${DEVICE_URL}" \
  -e "TIMEOUT=15" \
  chillcat-mcp-bridge:latest

# 等待启动
sleep 2

# 检查状态
echo ""
echo "📊 容器状态:"
docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 检查日志
echo ""
echo "📝 最近日志:"
docker logs --tail 10 "$CONTAINER_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 部署完成"
echo "   容器: ${CONTAINER_NAME}"
echo "   查看日志: docker logs -f ${CONTAINER_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

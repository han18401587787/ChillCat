# ChillCat AppDebugServer MCP Bridge
# 部署在 Linux 云服务器上，桥接 iPhone AppDebugServer 到 MCP 协议
#
# 构建: docker build -t chillcat-mcp-bridge .
# 运行: docker run -d --name chillcat-mcp-bridge \
#          -e DEVICE_URL=http://10.0.0.5:9080 \
#          -p 9081:9081 \
#          chillcat-mcp-bridge
#
# 配合 USB 隧道 (iproxy):
#   iproxy 9080 9080  # Mac 上运行，将 iPhone USB 端口转发到 localhost:9080
#   docker run -d --name chillcat-mcp-bridge \
#     --network host \
#     -e DEVICE_URL=http://host.docker.internal:9080 \
#     chillcat-mcp-bridge

FROM python:3.11-slim

LABEL org.opencontainers.image.title="ChillCat AppDebug MCP Bridge"
LABEL org.opencontainers.image.description="Bridge between iOS AppDebugServer and MCP protocol"
LABEL org.opencontainers.image.version="1.0.0"

WORKDIR /app

# 安装依赖
RUN pip install --no-cache-dir aiohttp

# 复制源码
COPY app-debug-mcp-bridge.py .

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python3 -c "import asyncio,aiohttp; asyncio.run(aiohttp.ClientSession().get('${DEVICE_URL}/health', timeout=aiohttp.ClientTimeout(total=5)))" || exit 1

# MCP Bridge 通过 stdio 通信，Docker 容器内通过 stdin/stdout
# 如果作为独立 HTTP 服务暴露，可以用下面的 CMD 替代
# 默认：MCP stdio 模式（配合 mcp-server 框架使用）
CMD ["python3", "-u", "app-debug-mcp-bridge.py"]

#!/usr/bin/env python3
"""
AppDebugServer MCP Bridge �� 将 iPhone 上的 AppDebugServer 桥接到 MCP 协议

部署在 Linux 云服务器上，通过 WiFi 直连或 USB 隧道（iproxy）与 iPhone 通信，
以 MCP Tools 形式暴露 AppDebugServer 的 7 个路由给 AI Agent 使用。

MCP Tools:
  - health_check       → GET /health
  - take_screenshot    → GET /screenshot (返回 base64 PNG)
  - list_debug_actions → GET /list_actions
  - activate_action    → POST /activate
  - get_app_state      → GET /app_state
  - start_recording    → POST /record_start
  - stop_recording     → POST /record_stop

用法:
  # 直接运行（stdio MCP）
  python3 app-debug-mcp-bridge.py

  # 通过 Docker
  docker build -t chillcat-mcp-bridge .
  docker run -e DEVICE_URL=http://10.0.0.5:9080 chillcat-mcp-bridge

环境变量:
  DEVICE_URL  — iPhone AppDebugServer 地址（默认 http://localhost:9080）
  TIMEOUT     — HTTP 请求超时秒数（默认 15）
"""

import asyncio
import base64
import json
import os
import sys
from typing import Any

import aiohttp

# ── 配置 ──────────────────────────────────────────────

DEVICE_URL = os.environ.get("DEVICE_URL", "http://localhost:9080").rstrip("/")
TIMEOUT = int(os.environ.get("TIMEOUT", "15"))

# ── MCP 协议 ──────────────────────────────────────────

SERVER_NAME = "chillcat-app-debug"
SERVER_VERSION = "1.0.0"


async def send_jsonrpc(response: dict) -> None:
    """通过 stdout 发送 JSON-RPC 响应"""
    line = json.dumps(response, ensure_ascii=False)
    sys.stdout.write(line + "\n")
    sys.stdout.flush()


async def read_jsonrpc() -> dict | None:
    """从 stdin 读取 JSON-RPC 请求"""
    try:
        line = await asyncio.get_event_loop().run_in_executor(None, sys.stdin.readline)
        if not line:
            return None
        return json.loads(line.strip())
    except (json.JSONDecodeError, EOFError):
        return None


# ── HTTP 客户端 ───────────────────────────────────────

async def http_get(path: str, accept: str = "application/json") -> tuple[int, Any]:
    """GET 请求到 AppDebugServer"""
    url = f"{DEVICE_URL}{path}"
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(
                url,
                timeout=aiohttp.ClientTimeout(total=TIMEOUT),
                headers={"Accept": accept},
            ) as resp:
                if accept == "image/png":
                    data = await resp.read()
                    return resp.status, data
                else:
                    text = await resp.text()
                    try:
                        return resp.status, json.loads(text)
                    except json.JSONDecodeError:
                        return resp.status, {"raw": text}
    except aiohttp.ClientError as e:
        return 0, {"error": f"连接失败: {e}"}
    except asyncio.TimeoutError:
        return 0, {"error": f"请求超时 ({TIMEOUT}s)"}


async def http_post(path: str, body: dict) -> tuple[int, Any]:
    """POST 请求到 AppDebugServer"""
    url = f"{DEVICE_URL}{path}"
    try:
        async with aiohttp.ClientSession() as session:
            async with session.post(
                url,
                json=body,
                timeout=aiohttp.ClientTimeout(total=TIMEOUT),
                headers={"Content-Type": "application/json"},
            ) as resp:
                text = await resp.text()
                try:
                    return resp.status, json.loads(text)
                except json.JSONDecodeError:
                    return resp.status, {"raw": text}
    except aiohttp.ClientError as e:
        return 0, {"error": f"连接失败: {e}"}
    except asyncio.TimeoutError:
        return 0, {"error": f"请求超时 ({TIMEOUT}s)"}


# ── MCP Tools ─────────────────────────────────────────

TOOLS = [
    {
        "name": "health_check",
        "description": "检查 iPhone 上 ChillCat AppDebugServer 的健康状态",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "take_screenshot",
        "description": "截取 iPhone 当前屏幕，返回 base64 编码的 PNG 图片",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "list_debug_actions",
        "description": "列出 iPhone App 中所有已注册的 Debug Action（可远程触发的 UI 操作）",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "activate_action",
        "description": "激活指定的 Debug Action（例如点击按钮、切换页面等）",
        "inputSchema": {
            "type": "object",
            "properties": {
                "action_id": {
                    "type": "string",
                    "description": "Debug Action 的唯一标识符，如 'tab.switch'",
                }
            },
            "required": ["action_id"],
        },
    },
    {
        "name": "get_app_state",
        "description": "获取 App 运行时状态：当前页面、错误计数、内存使用等",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "start_recording",
        "description": "开始 ReplayKit 录屏（仅真机，模拟器不支持）",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "stop_recording",
        "description": "停止 ReplayKit 录屏，视频将保存到相册",
        "inputSchema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
]

# ── Tool 处理 ─────────────────────────────────────────

async def handle_tool_call(name: str, arguments: dict) -> list[dict]:
    """处理 MCP tool 调用，返回 content 列表"""
    if name == "health_check":
        status, data = await http_get("/health")
        if status == 200:
            return [{"type": "text", "text": json.dumps(data, ensure_ascii=False, indent=2)}]
        return [{"type": "text", "text": f"❌ 健康检查失败 (HTTP {status}): {data}"}]

    elif name == "take_screenshot":
        status, data = await http_get("/screenshot", accept="image/png")
        if status == 200 and isinstance(data, bytes):
            b64 = base64.b64encode(data).decode("ascii")
            return [
                {
                    "type": "image",
                    "data": b64,
                    "mimeType": "image/png",
                },
                {
                    "type": "text",
                    "text": f"✅ 截图成功 ({len(data)} bytes, {len(b64)} chars base64)",
                },
            ]
        return [{"type": "text", "text": f"❌ 截图失败 (HTTP {status}): {data}"}]

    elif name == "list_debug_actions":
        status, data = await http_get("/list_actions")
        if status == 200:
            if isinstance(data, list):
                text = f"📋 已注册 {len(data)} 个 Debug Action:\n\n"
                for action in data:
                    text += f"- **{action.get('id', '?')}** ({action.get('page', '?')}): {action.get('label', '')}\n"
                return [{"type": "text", "text": text}]
            return [{"type": "text", "text": json.dumps(data, ensure_ascii=False, indent=2)}]
        return [{"type": "text", "text": f"❌ 获取 Actions 失败 (HTTP {status}): {data}"}]

    elif name == "activate_action":
        action_id = arguments.get("action_id", "")
        if not action_id:
            return [{"type": "text", "text": "❌ 缺少 action_id 参数"}]
        status, data = await http_post("/activate", {"id": action_id})
        if status == 200:
            return [{"type": "text", "text": f"✅ 已激活 Debug Action: `{action_id}`"}]
        return [{"type": "text", "text": f"❌ 激活失败 (HTTP {status}): {data.get('message', data)}"}]

    elif name == "get_app_state":
        status, data = await http_get("/app_state")
        if status == 200:
            text = "📱 ChillCat App 状态:\n\n"
            text += f"| 字段 | 值 |\n"
            text += f"|------|----|\n"
            for key, value in data.items():
                text += f"| {key} | {value} |\n"
            return [{"type": "text", "text": text}]
        return [{"type": "text", "text": f"❌ 获取状态失败 (HTTP {status}): {data}"}]

    elif name == "start_recording":
        status, data = await http_post("/record_start", {})
        if status == 200:
            return [{"type": "text", "text": "🎬 录屏已开始"}]
        return [{"type": "text", "text": f"❌ 录屏启动失败 (HTTP {status}): {data}"}]

    elif name == "stop_recording":
        status, data = await http_post("/record_stop", {})
        if status == 200:
            return [{"type": "text", "text": "⏹️ 录屏已停止，视频已保存到相册"}]
        return [{"type": "text", "text": f"❌ 录屏停止失败 (HTTP {status}): {data}"}]

    else:
        return [{"type": "text", "text": f"❌ 未知工具: {name}"}]


# ── MCP 主循环 ────────────────────────────────────────

async def main():
    """MCP stdio 主循环"""
    # 启动时健康检查
    status, data = await http_get("/health")
    if status == 200:
        sys.stderr.write(f"[mcp-bridge] ✅ 已连接 AppDebugServer: {DEVICE_URL}\n")
        sys.stderr.write(f"[mcp-bridge]    App: {data.get('server', 'unknown')} v{data.get('version', '?')}\n")
    else:
        sys.stderr.write(f"[mcp-bridge] ⚠️ 无法连接 AppDebugServer ({DEVICE_URL}): {data}\n")
        sys.stderr.write(f"[mcp-bridge]    将继续运行，等待设备连接...\n")
    sys.stderr.flush()

    while True:
        request = await read_jsonrpc()
        if request is None:
            break

        req_id = request.get("id")
        method = request.get("method", "")

        # ── initialize ──
        if method == "initialize":
            await send_jsonrpc({
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "protocolVersion": "2024-11-05",
                    "serverInfo": {
                        "name": SERVER_NAME,
                        "version": SERVER_VERSION,
                    },
                    "capabilities": {
                        "tools": {},
                    },
                },
            })

        # ── notifications/initialized ──
        elif method == "notifications/initialized":
            # 无需响应
            pass

        # ── tools/list ──
        elif method == "tools/list":
            await send_jsonrpc({
                "jsonrpc": "2.0",
                "id": req_id,
                "result": {
                    "tools": TOOLS,
                },
            })

        # ── tools/call ──
        elif method == "tools/call":
            params = request.get("params", {})
            tool_name = params.get("name", "")
            arguments = params.get("arguments", {})

            try:
                content = await handle_tool_call(tool_name, arguments)
                await send_jsonrpc({
                    "jsonrpc": "2.0",
                    "id": req_id,
                    "result": {
                        "content": content,
                    },
                })
            except Exception as e:
                await send_jsonrpc({
                    "jsonrpc": "2.0",
                    "id": req_id,
                    "result": {
                        "content": [{"type": "text", "text": f"❌ 工具执行异常: {e}"}],
                        "isError": True,
                    },
                })

        # ── 未知方法 ──
        else:
            await send_jsonrpc({
                "jsonrpc": "2.0",
                "id": req_id,
                "error": {
                    "code": -32601,
                    "message": f"Method not found: {method}",
                },
            })


if __name__ == "__main__":
    asyncio.run(main())

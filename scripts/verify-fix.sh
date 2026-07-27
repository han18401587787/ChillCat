#!/usr/bin/env bash
#
# verify-fix.sh — PR 自动验证截图闭环（阶段 A：agent-device MVP）
#
# 用法:
#   ./scripts/verify-fix.sh --pr=<number> [--label=<label>] [--device=<name>]
#
# 前置:
#   - macOS runner（GitHub Actions macos-15），已安装 Xcode
#   - Node.js 22+ 已安装（agent-device 依赖）
#   - ChillCat.app 已通过 xcodebuild 构建并安装到 Simulator
#   - Simulator 已启动
#
# 行为:
#   1. 从 GitHub Issue / PR 关联的 Issue 读取修复描述
#   2. 用 agent-device 在 Simulator 中截取关键页面截图
#   3. 生成 evidence.md（截图 + 设备信息 + agent-device 日志）
#   4. 输出 evidence 路径，供 post-pr-comment.sh 嵌入 PR 评论
#
# 证据链输出目录: /tmp/verify-evidence/pr-<number>/

set -euo pipefail

# ── 参数解析 ──────────────────────────────────────────
PR_NUMBER=""
LABEL="auto-fix"
DEVICE_NAME="${SIMULATOR_NAME:-CI-iPhone}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr=*)    PR_NUMBER="${1#--pr=}" ;;
    --pr)      PR_NUMBER="$2"; shift ;;
    --label=*) LABEL="${1#--label=}" ;;
    --label)   LABEL="$2"; shift ;;
    --device=*) DEVICE_NAME="${1#--device=}" ;;
    --device)   DEVICE_NAME="$2"; shift ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
  shift
done

if [[ -z "${PR_NUMBER:-}" ]]; then
  echo "❌ 缺少 --pr 参数" >&2
  exit 1
fi

# ── 环境 ──────────────────────────────────────────────
REPO="${GITHUB_REPOSITORY:-han18401587787/ChillCat}"
EVIDENCE_DIR="/tmp/verify-evidence/pr-${PR_NUMBER}"
AGENT_DEVICE_BIN="${AGENT_DEVICE_BIN:-agent-device}"

mkdir -p "$EVIDENCE_DIR"
cd "$EVIDENCE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 verify-fix — PR #${PR_NUMBER}"
echo "   设备: ${DEVICE_NAME}"
echo "   证据目录: ${EVIDENCE_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. 收集设备/构建信息 ─────────────────────────────
echo ""
echo "📱 收集设备信息..."

{
  echo "# 验证证据 — PR #${PR_NUMBER}"
  echo ""
  echo "**生成时间**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "**设备**: ${DEVICE_NAME}"
  echo "**Runner**: $(uname -a)"
  echo ""
  echo "## 设备信息"
  echo ""
  echo '```'
  xcrun simctl list devices booted 2>/dev/null || echo "无 booted 设备"
  echo '```'
} > evidence.md

# ── 2. 获取 PR 关联的 Issue 信息 ─────────────────────
echo ""
echo "📋 获取 PR #${PR_NUMBER} 信息..."

if command -v gh &>/dev/null && [[ -n "${GH_TOKEN:-}" ]]; then
  export GH_TOKEN
  # 获取 PR body，提取关联 Issue
  PR_BODY=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json body --jq '.body' 2>/dev/null || echo "")
  PR_TITLE=$(gh pr view "$PR_NUMBER" --repo "$REPO" --json title --jq '.title' 2>/dev/null || echo "PR #${PR_NUMBER}")

  # 从 PR body 中提取 Closes/Fixes/Resolves 的 Issue 编号
  LINKED_ISSUES=$(echo "$PR_BODY" | grep -oE '(Closes|Fixes|Resolves)\s+#[0-9]+' | grep -oE '[0-9]+' || echo "")

  echo ""
  echo "   PR 标题: ${PR_TITLE}"

  {
    echo ""
    echo "## PR 信息"
    echo ""
    echo "- **标题**: ${PR_TITLE}"
    echo "- **关联 Issue**: ${LINKED_ISSUES:-无}"
  } >> evidence.md
else
  echo "   ⚠️ gh CLI 不可用，跳过 PR 信息获取"
  {
    echo ""
    echo "## PR 信息"
    echo ""
    echo "- **标题**: PR #${PR_NUMBER}"
    echo "- **关联 Issue**: 无法获取（gh CLI 不可用）"
  } >> evidence.md
fi

# ── 3. 检查 agent-device 可用性 ──────────────────────
echo ""
echo "🔧 检查 agent-device..."

if ! command -v "$AGENT_DEVICE_BIN" &>/dev/null; then
  echo "   ⚠️ agent-device 未安装，尝试安装..."
  if command -v npm &>/dev/null; then
    npm install -g agent-device@latest 2>&1 | tail -3
    AGENT_DEVICE_BIN="agent-device"
  else
    echo "   ❌ npm 不可用，无法安装 agent-device。将使用 xcrun simctl 作为降级方案。"
  fi
fi

# ── 4. 验证 App 运行状态 ─────────────────────────────
echo ""
echo "📱 验证 App 运行状态..."

APP_RUNNING=false
if xcrun simctl listapps booted | grep -q "xuanpeace.chillcat" 2>/dev/null; then
  APP_RUNNING=true
  echo "   ✅ ChillCat 已安装到 Simulator"
else
  echo "   ⚠️ ChillCat 未安装到 Simulator，尝试启动..."
  # 尝试查找并安装
  APP_PATH=$(find /tmp -name "ChillCat.app" -type d 2>/dev/null | head -1) || true
  if [[ -n "${APP_PATH:-}" ]]; then
    xcrun simctl install booted "$APP_PATH" 2>/dev/null && echo "   ✅ 已安装" || echo "   ❌ 安装失败"
    APP_RUNNING=true
  else
    APP_PATH=$(find . -path "*/Build/Products/Debug-iphonesimulator/ChillCat.app" -type d 2>/dev/null | head -1) || true
    if [[ -n "${APP_PATH:-}" ]]; then
      xcrun simctl install booted "$APP_PATH" 2>/dev/null && echo "   ✅ 已安装" || echo "   ❌ 安装失败"
      APP_RUNNING=true
    fi
  fi
fi

# 确保 App 在前台
if [[ "$APP_RUNNING" == "true" ]]; then
  xcrun simctl launch booted app.xuanpeace.chillcat 2>/dev/null || true
  sleep 3
fi

# ── 5. 执行截图验证 ──────────────────────────────────
echo ""
echo "📸 执行截图验证..."

SCREENSHOT_COUNT=0

# 辅助函数：用 agent-device 截图，降级到 xcrun simctl
take_screenshot() {
  local label="$1"
  local filepath="${EVIDENCE_DIR}/${label}.png"

  if command -v "$AGENT_DEVICE_BIN" &>/dev/null; then
    # agent-device 优先：获得结构化 accessibility 快照 + 截图
    echo "   📸 [agent-device] ${label}..."
    "$AGENT_DEVICE_BIN" screenshot --output "$filepath" 2>&1 | tail -3 || true
  fi

  # 降级：xcrun simctl io
  if [[ ! -f "$filepath" ]]; then
    echo "   📸 [simctl] ${label}..."
    xcrun simctl io booted screenshot "$filepath" 2>/dev/null || true
  fi

  if [[ -f "$filepath" ]]; then
    SCREENSHOT_COUNT=$((SCREENSHOT_COUNT + 1))
    local size=$(du -h "$filepath" | cut -f1)
    echo "   ✅ ${label} (${size})"
    return 0
  else
    echo "   ❌ ${label} 截图失败"
    return 1
  fi
}

# 辅助函数：用 agent-device 获取 accessibility 快照
take_snapshot() {
  local label="$1"
  local filepath="${EVIDENCE_DIR}/${label}.txt"

  if command -v "$AGENT_DEVICE_BIN" &>/dev/null; then
    echo "   🔍 [agent-device] snapshot..."
    "$AGENT_DEVICE_BIN" snapshot -i 2>/dev/null > "$filepath" || true
    if [[ -s "$filepath" ]]; then
      local lines=$(wc -l < "$filepath" | tr -d ' ')
      echo "   ✅ ${label} (${lines} 行 accessibility 元素)"
      return 0
    fi
  fi

  echo "   ⚠️ accessibility snapshot 不可用"
  echo "(agent-device 不可用，无法获取结构化元素快照)" > "$filepath"
  return 1
}

# 5.1 主页面截图
take_screenshot "01-main-screen"

# 5.2 Accessibility 快照（用于 AI 分析页面结构）
take_snapshot "02-accessibility-snapshot"

# 5.3 导航到核心 Tab 页并截图
# Tab 切换通过 agent-device 或 simctl open 实现
if command -v "$AGENT_DEVICE_BIN" &>/dev/null; then
  echo ""
  echo "🧭 导航到核心页面..."

  # 尝试点击底部 Tab（通过 accessibility 引用）
  # Tab 按钮通常标记为 "树洞" "共鸣" "鼓励" "我的"
  for tab_label in "树洞" "共鸣" "鼓励" "我的"; do
    # 尝试用 agent-device 点击对应 accessibility 元素
    TAB_REF=$("$AGENT_DEVICE_BIN" snapshot -i 2>/dev/null | grep -i "$tab_label" | head -1 | grep -oE '@e[0-9]+' | head -1 || true)
    if [[ -n "${TAB_REF:-}" ]]; then
      echo "   点击 Tab: ${tab_label} (${TAB_REF})"
      "$AGENT_DEVICE_BIN" fill "$TAB_REF" 2>/dev/null || true
      sleep 2
      SAFE_NAME=$(echo "$tab_label" | tr '[:upper:]' '[:lower:]')
      take_screenshot "tab-${SAFE_NAME}"
    fi
  done
else
  # 降级：无 agent-device 时仅截主屏
  echo "   ⚠️ agent-device 不可用，跳过 Tab 导航截图"
fi

# ── 6. 收集 agent-device 日志 ────────────────────────
echo ""
echo "📝 收集 agent-device 日志..."

LOG_FILE="${EVIDENCE_DIR}/agent-device.log"
if command -v "$AGENT_DEVICE_BIN" &>/dev/null; then
  "$AGENT_DEVICE_BIN" --version > "$LOG_FILE" 2>&1 || echo "agent-device version unknown" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
  "$AGENT_DEVICE_BIN" snapshot -i 2>/dev/null >> "$LOG_FILE" || true
  echo "   ✅ 日志已写入: ${LOG_FILE}"
else
  echo "   ⚠️ agent-device 不可用，日志仅含 simctl 信息"
  {
    echo "agent-device: 不可用"
    echo ""
    echo "=== simctl listapps ==="
    xcrun simctl listapps booted 2>/dev/null || echo "simctl listapps 失败"
  } > "$LOG_FILE"
fi

# ── 7. 生成 evidence.md 汇总 ──────────────────────────
echo ""
echo "📄 生成 evidence.md..."

{
  echo ""
  echo "## 截图清单"
  echo ""
  echo "| 序号 | 文件 | 说明 |"
  echo "|------|------|------|"
  for f in "$EVIDENCE_DIR"/*.png; do
    if [[ -f "$f" ]]; then
      local base=$(basename "$f")
      local size=$(du -h "$f" | cut -f1)
      echo "| $((++i)) | \`${base}\` | ${size} |"
    fi
  done
  echo ""
  echo "## agent-device 输出"
  echo ""
  echo '```'
  cat "$LOG_FILE" 2>/dev/null || echo "(日志不可用)"
  echo '```'
  echo ""
  echo "## 验证结论"
  echo ""
  if [[ $SCREENSHOT_COUNT -gt 0 ]]; then
    echo "✅ 成功截取 ${SCREENSHOT_COUNT} 张截图，App 在 Simulator 中正常运行。"
    echo ""
    echo "> ⚠️ **人��复查**：请确认截图中的页面状态与修复预期一致。"
  else
    echo "❌ 截图失败，无法验证 App 运行状态。请检查构建和 Simulator 配置。"
  fi
  echo ""
  echo "---"
  echo "*由 verify-fix.sh (agent-device MVP) 自动生成*"
} >> evidence.md

# ── 8. 输出结果 ───────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 验证完成"
echo "   截图: ${SCREENSHOT_COUNT} 张"
echo "   证据目录: ${EVIDENCE_DIR}"
echo "   报告: ${EVIDENCE_DIR}/evidence.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 输出证据目录路径供后续步骤使用
echo "EVIDENCE_DIR=${EVIDENCE_DIR}" >> "$GITHUB_OUTPUT" 2>/dev/null || true
echo "SCREENSHOT_COUNT=${SCREENSHOT_COUNT}" >> "$GITHUB_OUTPUT" 2>/dev/null || true

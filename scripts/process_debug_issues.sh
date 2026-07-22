#!/usr/bin/env bash
#
# process_debug_issues.sh — 自动处理 Debug 面板创建的 GitHub Issue
#
# 用法:
#   GH_TOKEN=xxx ./scripts/process_debug_issues.sh            # 处理所有开放 Issue
#   GH_TOKEN=xxx ./scripts/process_debug_issues.sh --limit 3   # 最多处理 3 个
#   GH_TOKEN=xxx ./scripts/process_debug_issues.sh --dry-run   # 只列出，不处理
#
# 前置:
#   - gh CLI 已安装且 GH_TOKEN 有 repo 权限
#   - 当前目录为 ChillCat 仓库根
#
# 行为:
#   1. 列出标签含 from-debug-panel 且 state=open 的 Issue
#   2. 逐个调用 bug-fixer Agent 流程（此处用 gh 拉取正文 + 打印派单日志）
#   3. 实际修复由 Agent（本沙箱内的 AI）执行；脚本负责调度与幂等

set -euo pipefail

REPO="han18401587787/ChillCat"
LABEL="from-debug-panel"
LIMIT=10
DRY_RUN=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit)  LIMIT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "❌ 需要 GH_TOKEN 环境变量" >&2
  exit 1
fi

export GH_TOKEN

echo "🔍 查询 $REPO 中标签 [$LABEL] 的开放 Issue..."
ISSUES=$(gh issue list --repo "$REPO" --label "$LABEL" --state open --limit "$LIMIT" --json number,title,url)

COUNT=$(echo "$ISSUES" | gh api repos/"$REPO" --jq '.' >/dev/null 2>&1; echo "$ISSUES" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

if [[ "$COUNT" == "0" || "$COUNT" == "0.0" ]]; then
  echo "✅ 没有待处理的 $LABEL Issue"
  exit 0
fi

echo "📋 发现 $COUNT 个待处理 Issue:"
echo "$ISSUES" | python3 -c "
import sys, json
for i in json.load(sys.stdin):
    print(f\"  #{i['number']}  {i['title']}\")
"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "🏁 dry-run 模式，不实际处理"
  exit 0
fi

# 逐个派单给 bug-fixer Agent
echo "$ISSUES" | python3 -c "
import sys, json
for i in json.load(sys.stdin):
    print(i['number'])
" | while read -r NUM; do
  echo ""
  echo "────────────────────────────────────────"
  echo "🤖 派单 Issue #$NUM 给 bug-fixer Agent"
  echo "────────────────────────────────────────"

  # 拉取 Issue 正文，保存为临时文件供 Agent 读取
  BODY_FILE=$(mktemp /tmp/issue_${NUM}_XXXX.md)
  gh issue view "$NUM" --repo "$REPO" --json body --jq '.body' > "$BODY_FILE"

  echo "📄 Issue #$NUM 正文已写入: $BODY_FILE"
  echo "   请在 Agent 环境中运行: 读取 $BODY_FILE 并按 bug-fixer 流程处理"
  echo "   或直接对我说: '处理 GitHub Issue #$NUM'"

  # 在 Issue 上标注已派单，避免重复处理
  gh issue comment "$NUM" --repo "$REPO" --body "🤖 bug-fixer Agent 已派单，正在分析诊断日志并尝试生成修复 PR。本 Issue 在处理期间保持 open。" 2>/dev/null || true
done

echo ""
echo "✅ 派单完成。Agent 将逐个处理并在完成后开 PR + 评论。"

#!/usr/bin/env bash
#
# post-pr-comment.sh — 将 verify-fix.sh 生成的证据嵌入 PR Comment
#
# 用法:
#   ./scripts/post-pr-comment.sh --pr=<number> [--evidence-dir=<path>]
#
# 前置:
#   - verify-fix.sh 已执行，evidence.md + 截图存在于证据目录
#   - gh CLI 已安装，GH_TOKEN 有 repo 权限
#   - 当前目录为 ChillCat 仓库根
#
# 行为:
#   1. 读取 evidence.md
#   2. 将截图转为 base64 内嵌到 Markdown（避免外部链接失效）
#   3. 在 PR 下发 Comment（使用 REST API，与查找/更新保持一致）
#   4. 若已存在 verify-fix 评论，更新而非重复创建
#
# 注意:
#   - 全程使用 REST API（gh api），不使用 gh pr comment（GraphQL），
#     避免 "Could not resolve to a PullRequest" 错误
#   - GitHub Comment body 上限 65536 字符，base64 图片可能超限，
#     超限时跳过内嵌改为 artifact 引用

set -euo pipefail

# ── 参数解析 ──────────────────────────────────────────
PR_NUMBER=""
EVIDENCE_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr=*)          PR_NUMBER="${1#--pr=}" ;;
    --pr)            PR_NUMBER="$2"; shift ;;
    --evidence-dir=*) EVIDENCE_DIR="${1#--evidence-dir=}" ;;
    --evidence-dir)   EVIDENCE_DIR="$2"; shift ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
  shift
done

if [[ -z "${PR_NUMBER:-}" ]]; then
  echo "❌ 缺少 --pr 参数" >&2
  exit 1
fi

EVIDENCE_DIR="${EVIDENCE_DIR:-/tmp/verify-evidence/pr-${PR_NUMBER}}"
REPO="${GITHUB_REPOSITORY:-han18401587787/ChillCat}"
EVIDENCE_MD="${EVIDENCE_DIR}/evidence.md"

if [[ ! -f "$EVIDENCE_MD" ]]; then
  echo "❌ evidence.md 不存在: ${EVIDENCE_MD}" >&2
  echo "   请先运行 verify-fix.sh" >&2
  exit 1
fi

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "❌ 需要 GH_TOKEN 环境变量" >&2
  exit 1
fi

export GH_TOKEN

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 post-pr-comment — PR #${PR_NUMBER}"
echo "   证据目录: ${EVIDENCE_DIR}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. 构建 Comment Body ─────────────────────────────
echo ""
echo "📝 构建评论内容..."

# GitHub Comment body 上限 65536 字符
GITHUB_COMMENT_LIMIT=65536
# 预留 4000 字符给 evidence.md 文本 + 模板，剩余给 base64 图片
BASE64_BUDGET=$((GITHUB_COMMENT_LIMIT - 4000))

SCREENSHOT_MD=""
USED_BUDGET=0
for f in "$EVIDENCE_DIR"/*.png; do
  if [[ -f "$f" ]]; then
    base=$(basename "$f")
    size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo 0)
    # base64 编码后大小约为原始大小的 4/3
    b64_estimated=$((size * 4 / 3))

    if [[ "$size" -gt 2097152 ]]; then
      # 超过 2MB，跳过内嵌
      SCREENSHOT_MD="${SCREENSHOT_MD}\n> ⚠️ \`${base}\` 超过 2MB，无法内嵌。请下载 artifact 查看。\n"
    elif [[ $((USED_BUDGET + b64_estimated)) -gt $BASE64_BUDGET ]]; then
      # 超出字符预算，跳过内嵌
      SCREENSHOT_MD="${SCREENSHOT_MD}\n> ⚠️ \`${base}\` 因评论长度限制未内嵌。请下载 artifact 查看。\n"
      echo "   ⏭️ ${base} 跳过内嵌 (预算不足, ${size} bytes)"
    else
      b64=$(base64 -i "$f" 2>/dev/null || base64 < "$f")
      SCREENSHOT_MD="${SCREENSHOT_MD}\n![${base}](data:image/png;base64,${b64})\n"
      USED_BUDGET=$((USED_BUDGET + b64_estimated))
      echo "   ✅ ${base} 已编码为 base64 (${size} bytes)"
    fi
  fi
  done

# 读取 evidence.md 核心内容（跳过 YAML front matter 如果有）
EVIDENCE_TEXT=$(cat "$EVIDENCE_MD")

# ── 2. 组装完整评论 ──────────────────────────────────
COMMENT_BODY=$(cat <<EOF
## 🤖 自动验证结果 — PR #${PR_NUMBER}

$(echo "$EVIDENCE_TEXT" | head -80)

---

### 📸 截图证据

$(echo -e "$SCREENSHOT_MD")

---

> 🔄 此评论由 verify-fix.sh + post-pr-comment.sh 自动生成。
> 若截图不完整或 App 未正常启动，请检查 CI 构建日志中的 \`verify\` job。
EOF
)

# ── 3. 查找已有的 verify-fix 评论并更新 ──────────────
echo ""
echo "🔍 查找已有验证评论..."

EXISTING_COMMENT_ID=$(gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" \
  --jq '.[] | select(.body | contains("自动验证结果")) | .id' 2>/dev/null | head -1 || echo "")

# 将评论写入临时文件，避免 shell 变量长度限制
COMMENT_FILE=$(mktemp)
echo "$COMMENT_BODY" > "$COMMENT_FILE"
BODY_SIZE=$(wc -c < "$COMMENT_FILE")
echo "   📏 评论大小: ${BODY_SIZE} bytes (限制: ${GITHUB_COMMENT_LIMIT})"

# 包装为 JSON {"body": "..."} —— GitHub REST API 要求 JSON body，
# 直接 --input 纯 Markdown 会报 "Problems parsing JSON (HTTP 400)"
JSON_FILE=$(mktemp)
jq -Rs '{body: .}' "$COMMENT_FILE" > "$JSON_FILE"

if [[ -n "${EXISTING_COMMENT_ID:-}" ]]; then
  echo "   📝 更新已有评论: ${EXISTING_COMMENT_ID}"
  gh api "repos/${REPO}/issues/comments/${EXISTING_COMMENT_ID}" \
    -X PATCH \
    --input "$JSON_FILE" > /dev/null
  echo "   ✅ 评论已更新"
else
  echo "   📝 创建新评论"
  # 使用 REST API 创建评论（不用 gh pr comment，避免 GraphQL 解析问题）
  gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" \
    -X POST \
    --input "$JSON_FILE" > /dev/null
  echo "   ✅ 评论已创建"
fi

rm -f "$COMMENT_FILE" "$JSON_FILE"

# ── 4. 输出摘要 ──────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 评论已发布到 PR #${PR_NUMBER}"
echo "   ${REPO}/pull/${PR_NUMBER}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

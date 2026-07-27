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
#   3. 在 PR 下发 Comment（使用 gh pr comment）
#   4. 若已存在 verify-fix 评论，更新而非重复创建

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

# 生成截图内嵌 Markdown（base64 图片，限制单张 ≤ 2MB）
SCREENSHOT_MD=""
for f in "$EVIDENCE_DIR"/*.png; do
  if [[ -f "$f" ]]; then
    local base=$(basename "$f")
    local size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo 0)

    if [[ "$size" -gt 2097152 ]]; then
      # 超过 2MB，跳过内嵌，改为文件引用
      SCREENSHOT_MD="${SCREENSHOT_MD}\n> ⚠️ \`${base}\` 超过 2MB，无法内嵌。请下载 artifact 查看。\n"
    else
      local b64=$(base64 -i "$f" 2>/dev/null || base64 < "$f")
      SCREENSHOT_MD="${SCREENSHOT_MD}\n![${base}](data:image/png;base64,${b64})\n"
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

if [[ -n "${EXISTING_COMMENT_ID:-}" ]]; then
  echo "   📝 更新已有评论: ${EXISTING_COMMENT_ID}"
  gh api "repos/${REPO}/issues/comments/${EXISTING_COMMENT_ID}" \
    -X PATCH \
    -f body="$COMMENT_BODY" > /dev/null
  echo "   ✅ 评论已更新"
else
  echo "   📝 创建新评论"
  echo "$COMMENT_BODY" | gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file -
  echo "   ✅ 评论已创建"
fi

# ── 4. 输出摘要 ──────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 评论已发布到 PR #${PR_NUMBER}"
echo "   ${REPO}/pull/${PR_NUMBER}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

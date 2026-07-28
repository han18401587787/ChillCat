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
#   2. 截图 push 到 ci-artifacts 分支，评论用 raw URL 引用
#      （base64 data URI 会被 GitHub sanitize 剥离，已验证不可行）
#   3. 在 PR 下发 Comment（使用 REST API，与查找/更新保持一致）
#   4. 若已存在 verify-fix 评论，更新而非重复创建
#
# 注意:
#   - 全程使用 REST API（gh api），不使用 gh pr comment（GraphQL），
#     避免 "Could not resolve to a PullRequest" 错误
#   - 评论 body 经 jq 包装为合法 JSON，避免 HTTP 400
#   - 需要 workflow 权限 contents: write（推送 ci-artifacts 分支）

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

# ── 1. 推送截图到 ci-artifacts 分支 ─────────────────
echo ""
echo "📝 构建评论内容..."

# 为什么不用 base64 内嵌:GitHub sanitize 会剥离 data: URI,
# 任何格式的 base64 图片在评论里都不会渲染(官方 /markdown API 已验证)。
# 方案:截图 push 到 ci-artifacts 孤儿分支,评论用 raw URL 引用。
ARTIFACT_BRANCH="ci-artifacts"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${ARTIFACT_BRANCH}/pr-${PR_NUMBER}"

SCREENSHOT_FILES=()
for f in "$EVIDENCE_DIR"/*.jpg; do
  [[ -f "$f" ]] && SCREENSHOT_FILES+=("$f")
done

SCREENSHOT_MD=""
if [[ ${#SCREENSHOT_FILES[@]} -gt 0 ]]; then
  echo "   📤 推送 ${#SCREENSHOT_FILES[@]} 张截图到 ${ARTIFACT_BRANCH} 分支..."
  PUSH_OK=false
  TMP_GIT=$(mktemp -d)
  if (
    set -e
    cd "$TMP_GIT"
    git init -q
    git config user.name "github-actions[bot]"
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git remote add origin "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git"
    if git fetch --depth 1 origin "$ARTIFACT_BRANCH" 2>/dev/null; then
      git checkout -q -b "$ARTIFACT_BRANCH" FETCH_HEAD
    else
      git checkout -q --orphan "$ARTIFACT_BRANCH"
      git rm -rf . 2>/dev/null || true
    fi
    mkdir -p "pr-${PR_NUMBER}"
    for f in "${SCREENSHOT_FILES[@]}"; do
      cp "$f" "pr-${PR_NUMBER}/"
    done
    git add "pr-${PR_NUMBER}"
    git commit -q -m "ci: PR #${PR_NUMBER} 验证截图 $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    git push -q origin "$ARTIFACT_BRANCH"
  ); then
    PUSH_OK=true
    echo "   ✅ 截图已推送"
  else
    echo "   ⚠️ 分支推送失败，评论将只保留 artifact 引用"
  fi
  rm -rf "$TMP_GIT"

  for f in "${SCREENSHOT_FILES[@]}"; do
    base=$(basename "$f")
    if [[ "$PUSH_OK" == "true" ]]; then
      SCREENSHOT_MD="${SCREENSHOT_MD}\n![${base}](${RAW_BASE}/${base})\n"
      echo "   🔗 ${base} → raw URL 已内嵌"
    else
      SCREENSHOT_MD="${SCREENSHOT_MD}\n> ⚠️ \`${base}\` 请下载 artifact 查看。\n"
    fi
  done
else
  SCREENSHOT_MD="\n> 无截图文件。\n"
fi

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
echo "   📏 评论大小: ${BODY_SIZE} bytes"

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

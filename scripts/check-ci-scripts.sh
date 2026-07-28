#!/usr/bin/env bash
#
# check-ci-scripts.sh — CI 脚本本地验证(不上 GitHub 也能提前抓 bug)
#
# 三层防御:
#   1. bash -n       语法检查(括号/引号/关键字)
#   2. shellcheck    静态分析(unbound var、local 误用、返回值掩盖等)
#   3. stub 模拟运行  用假命令替代 macOS/网络依赖(xcrun/agent-device/sips/gh/git),
#                     验证脚本流程能走完 —— 抓 set -e 中断、变量未初始化等运行时错误
#
# 用法: ./scripts/check-ci-scripts.sh
# 时机: 每次修改 scripts/*.sh 或 .github/workflows/*.yml 后、git push 前
#
# 注意: stub 只验证脚本流程逻辑,不能替代真机验证(agent-device 与 Simulator
#       的真实交互仍需 macOS CI 确认)

set -uo pipefail  # 故意不用 -e:收集所有错误,而不是遇错即停

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0
red()   { printf '\033[31m%s\033[0m\n' "$1"; }
green() { printf '\033[32m%s\033[0m\n' "$1"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$1"; }

SCRIPTS=(scripts/verify-fix.sh scripts/post-pr-comment.sh)

# ── 1/3 bash 语法检查 ────────────────────────────────
echo "━━ 1/3 bash 语法检查 ━━"
for s in "${SCRIPTS[@]}"; do
  if bash -n "$s" 2>/tmp/check-ci-err.log; then
    green "✅ $s"
  else
    red "❌ $s"; cat /tmp/check-ci-err.log; FAIL=1
  fi
done
echo ""

# ── 2/3 shellcheck 静态分析 ──────────────────────────
echo "━━ 2/3 shellcheck 静态分析 ━━"
if ! command -v shellcheck &>/dev/null; then
  yellow "⚠️ shellcheck 未安装,跳过 (Mac: brew install shellcheck)"
else
  for s in "${SCRIPTS[@]}"; do
    if shellcheck -S warning "$s"; then
      green "✅ $s"
    else
      red "❌ $s 存在 warning 及以上问题"; FAIL=1
    fi
  done
fi
echo ""

# ── 3/3 stub 模拟运行 ────────────────────────────────
echo "━━ 3/3 stub 模拟运行(流程逻辑验证) ━━"

STUB_DIR=$(mktemp -d)
trap 'rm -rf "$STUB_DIR" /tmp/verify-evidence/pr-99' EXIT

# --- stub: xcrun(simctl) ---
cat > "$STUB_DIR/xcrun" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  *"list devices booted"*) echo "  Stub-iPhone (Booted)" ;;
  *listapps*)              echo "com.qxjz.ChillCat: 12345" ;;
  *"io booted screenshot"*)
    out="${@: -1}"
    echo "fake-png-data" > "$out"
    ;;
  *) exit 0 ;;
esac
STUB

# --- stub: agent-device ---
cat > "$STUB_DIR/agent-device" <<'STUB'
#!/usr/bin/env bash
case "$1" in
  --version) echo "0.20.1" ;;
  open)      echo "session opened: ChillCat" ;;
  screenshot)
    out=""
    while [[ $# -gt 0 ]]; do
      if [[ "$1" == "--out" ]]; then out="$2"; shift 2; continue; fi
      shift
    done
    [[ -n "$out" ]] && echo "fake-png-data" > "$out"
    ;;
  snapshot)
    echo "@e1 button \"树洞\""
    echo "@e2 button \"共鸣\""
    ;;
  *) exit 0 ;;
esac
STUB

# --- stub: sips ---
cat > "$STUB_DIR/sips" <<'STUB'
#!/usr/bin/env bash
out=""; prev=""
for a in "$@"; do
  [[ "$prev" == "--out" ]] && out="$a"
  prev="$a"
done
[[ -n "$out" ]] && echo "fake-jpeg-data" > "$out"
exit 0
STUB

# --- stub: gh(拦截网络,绝不真发评论) ---
cat > "$STUB_DIR/gh" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  *"-X POST"*)   echo '{"id": 99001}' ;;
  *"-X PATCH"*)  echo '{"id": 99002}' ;;
  *comments*)    echo "[]" ;;
  *)             echo "{}" ;;
esac
exit 0
STUB

# --- stub: git(拦截 push,不实际推送分支) ---
cat > "$STUB_DIR/git" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB

chmod +x "$STUB_DIR"/*

export PATH="$STUB_DIR:$PATH"
export GH_TOKEN="stub-token-for-local-test"
export GITHUB_OUTPUT="/dev/null"
export SIMULATOR_NAME="Stub-iPhone"

# ── 运行 verify-fix.sh ──
echo "▶ verify-fix.sh --pr=99 (stub 环境)"
if ./scripts/verify-fix.sh --pr=99 --device=Stub-iPhone > /tmp/check-ci-verify.log 2>&1; then
  green "✅ 脚本走完(exit 0)"
else
  red "❌ 脚本中断(exit $?)"; tail -15 /tmp/check-ci-verify.log; FAIL=1
fi

# 关键断言:evidence.md 必须包含"截图清单"章节
# (此前 set -e + take_snapshot return 1 会导致脚本在第 5 节中断,第 7 节汇总缺失)
EVIDENCE_MD="/tmp/verify-evidence/pr-99/evidence.md"
if [[ -f "$EVIDENCE_MD" ]] && grep -q "截图清单" "$EVIDENCE_MD"; then
  green "✅ evidence.md 含完整汇总章节(截图清单)"
else
  red "❌ evidence.md 缺少汇总章节 —— 脚本中途被截断"; FAIL=1
fi

# ── 运行 post-pr-comment.sh ──
echo "▶ post-pr-comment.sh --pr=99 (stub 环境,不真发评论)"
if ./scripts/post-pr-comment.sh --pr=99 > /tmp/check-ci-post.log 2>&1; then
  if grep -q "评论已创建\|评论已更新" /tmp/check-ci-post.log; then
    green "✅ 评论流程走完(gh 已被 stub 拦截)"
  else
    red "❌ 未走到评论发布步骤"; tail -10 /tmp/check-ci-post.log; FAIL=1
  fi
else
  red "❌ 脚本失败(exit $?)"; tail -15 /tmp/check-ci-post.log; FAIL=1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $FAIL -eq 0 ]]; then
  green "✅ 全部通过,可以放心 push"
else
  red "❌ 存在问题,请修复后再 push(别等 GitHub CI 才发现)"
fi
exit $FAIL

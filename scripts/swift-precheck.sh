#!/bin/bash
# Swift 语法预检脚本 — 在推送前捕获常见编译错误
# 用法: bash scripts/swift-precheck.sh

set -e
PROJECT_DIR="${1:-/workspace/ChillCat/ChillCat}"
ERRORS=0

red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }

echo "🔍 Swift 语法预检 — $PROJECT_DIR"
echo ""

# 1. 检查括号匹配（大括号开闭数是否一致）
echo "📋 [1/6] 括号匹配检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    open=$(grep -c '{' "$f" 2>/dev/null || echo 0)
    close=$(grep -c '}' "$f" 2>/dev/null || echo 0)
    if [ "$open" != "$close" ]; then
        red "  ❌ $f — { $open 个 vs } $close 个"
        ERRORS=$((ERRORS + 1))
    fi
done
green "  ✅ 括号匹配检查完成"

# 2. 检查常见拼写错误（API 名称）
echo ""
echo "📋 [2/6] 常见 API 拼写检查..."
patterns=(
    "EmotionColors\.joy"            # 应为 happy
    "EmotionColors\.anxiety"        # 应为 anxious
    "\.truncated("                  # Swift 无此方法，应用 .prefix()
    "SpeechRecognizer()"            # 应为 SFSpeechRecognizer
    "CCMilestoneType\.milestone"    # 不存在，应为 .streak
)
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    for p in "${patterns[@]}"; do
        if grep -q "$p" "$f" 2>/dev/null; then
            red "  ❌ $f — 引用不存在的 API: $p"
            ERRORS=$((ERRORS + 1))
        fi
    done
done
green "  ✅ API 拼写检查完成"

# 3. 检查 @Environment ccAppTheme 协议属性引用
echo ""
echo "📋 [3/6] ccAppTheme 协议属性检查..."
# CCAppThemeProtocol 中实际定义的属性
VALID_THEME_PROPS="primary|primaryLight|primaryMuted|secondary|accent|background|surface|cardBackground|textPrimary|textSecondary|textMuted|border|error|success|warning|info|spacingXS|spacingSM|spacingMD|spacingLG|spacingXL|radiusSM|radiusMD|radiusLG|radiusXL|fontLargeTitle|fontTitle1|fontTitle2|fontTitle3|fontBody|fontCaption|fontFootnote|shadowColor|shadowOpacitySM|shadowRadiusSM|shadowYSM|durationFast|durationNormal|durationSlow"

for f in $(grep -rl "ccAppTheme" "$PROJECT_DIR" --include="*.swift" 2>/dev/null); do
    # 提取 theme.xxx 引用
    refs=$(grep -oP 'theme\.\w+' "$f" 2>/dev/null | sed 's/theme\.//' | sort -u)
    for ref in $refs; do
        if ! echo "$VALID_THEME_PROPS" | grep -qw "$ref"; then
            red "  ⚠️  $f — theme.$ref 可能不在 CCAppThemeProtocol 中"
            ERRORS=$((ERRORS + 1))
        fi
    done
done
green "  ✅ ccAppTheme 属性检查完成"

# 4. 检查 MainActor 隔离（Swift 6.2 模式）
echo ""
echo "📋 [4/6] MainActor 隔离检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    if grep -q "@MainActor" "$f" 2>/dev/null; then
        # 检查是否有从 nonisolated 上下文访问 @MainActor 属性的情况
        if grep -q "nonisolated.*func.*traceManager\|nonisolated.*func.*currentTraceID\|nonisolated.*func.*currentSpan" "$f" 2>/dev/null; then
            red "  ⚠️  $f — 可能存在 MainActor 隔离冲突"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
green "  ✅ MainActor 检查完成"

# 5. 检查 FlowLayout 声明完整性
echo ""
echo "📋 [5/6] FlowLayout 结构体检查..."
for f in $(grep -rl "func placeSubviews" "$PROJECT_DIR" --include="*.swift" 2>/dev/null); do
    # 确保 placeSubviews 前有 struct 声明
    if ! grep -B5 "func placeSubviews" "$f" 2>/dev/null | grep -q "struct.*Layout"; then
        red "  ❌ $f — placeSubviews 缺少 struct XXX: Layout 声明"
        ERRORS=$((ERRORS + 1))
    fi
done
green "  ✅ FlowLayout 检查完成"

# 6. 检查 Codable 元组问题
echo ""
echo "📋 [6/6] Codable 结构体检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    if grep -q ": Codable" "$f" 2>/dev/null; then
        # 检查 struct 内是否有元组属性（元组不遵循 Codable）
        if grep -P '^\s+let\s+\w+:\s*\[\(.*\)\]' "$f" 2>/dev/null; then
            red "  ❌ $f — Codable struct 包含不兼容的元组属性"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
green "  ✅ Codable 检查完成"

# 汇总
echo ""
echo "═══════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    green "✅ 预检通过！未发现常见错误。"
else
    red "❌ 发现 $ERRORS 个潜在问题，请在推送前修复。"
fi
echo "═══════════════════════════════════════════"

exit $ERRORS

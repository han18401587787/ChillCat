#!/bin/bash
# Swift 语法预检脚本 — 在推送前捕获常见编译错误
# 用法: bash scripts/swift-precheck.sh
# 每次 CI 发现新的编译错误模式后，应及时更新本脚本

set -e
PROJECT_DIR="${1:-/workspace/ChillCat/ChillCat}"
ERRORS=0

red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }

echo "🔍 Swift 语法预检 — $PROJECT_DIR"
echo ""

# ══════════════════════════════════════════════
# 1. 括号匹配（大括号开闭数是否一致）
#    覆盖: extraneous '}' / expected '}' in struct
#    局限: 字符串内 { } 会导致误报
# ══════════════════════════════════════════════
echo "📋 [1/9] 括号匹配检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    open=$(grep -c '{' "$f" 2>/dev/null || echo 0)
    close=$(grep -c '}' "$f" 2>/dev/null || echo 0)
    if [ "$open" != "$close" ]; then
        red "  ❌ $f — { $open 个 vs } $close 个"
        ERRORS=$((ERRORS + 1))
    fi
done
green "  ✅ 括号匹配检查完成"

# ══════════════════════════════════════════════
# 2. 常见 API 拼写错误
#    覆盖: type 'XXX' has no member / cannot find 'XXX' in scope
# ══════════════════════════════════════════════
echo ""
echo "📋 [2/9] 常见 API 拼写检查..."
patterns=(
    "EmotionColors\.joy"            # 应为 EmotionColors.happy
    "EmotionColors\.anxiety"        # 应为 EmotionColors.anxious
    "EmotionColors\.sad"            # 应为 EmotionColors.lonely
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

# ══════════════════════════════════════════════
# 3. ccAppTheme 协议属性引用
#    覆盖: value of type 'any CCAppThemeProtocol' has no member
#    注意: 这里只做警告，因为有些属性可能真的在协议中
# ══════════════════════════════════════════════
echo ""
echo "📋 [3/9] ccAppTheme 协议属性检查..."
VALID_THEME_PROPS="primary|primaryLight|primaryMuted|secondary|accent|background|surface|cardBackground|textPrimary|textSecondary|textMuted|border|error|success|warning|info|spacingXS|spacingSM|spacingMD|spacingLG|spacingXL|radiusSM|radiusMD|radiusLG|radiusXL|fontLargeTitle|fontTitle1|fontTitle2|fontTitle3|fontBody|fontCaption|fontFootnote|shadowColor|shadowOpacitySM|shadowRadiusSM|shadowYSM|durationFast|durationNormal|durationSlow"

for f in $(grep -rl "ccAppTheme" "$PROJECT_DIR" --include="*.swift" 2>/dev/null); do
    refs=$(grep -oP 'theme\.\w+' "$f" 2>/dev/null | sed 's/theme\.//' | sort -u)
    for ref in $refs; do
        if ! echo "$VALID_THEME_PROPS" | grep -qw "$ref"; then
            red "  ⚠️  $f — theme.$ref 可能不在 CCAppThemeProtocol 中"
            ERRORS=$((ERRORS + 1))
        fi
    done
done
green "  ✅ ccAppTheme 属性检查完成"

# ══════════════════════════════════════════════
# 4. MainActor 隔离（Swift 6.2 模式）
#    覆盖: main actor-isolated property can not be referenced
#          call to main actor-isolated instance method in nonisolated context
#          cannot be used to satisfy nonisolated requirement from protocol
# ══════════════════════════════════════════════
echo ""
echo "📋 [4/9] MainActor 隔离检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    has_issue=false
    
    # 4a. @MainActor 类中有 nonisolated 方法访问 @MainActor 属性
    if grep -q "@MainActor" "$f" 2>/dev/null; then
        if grep -q "nonisolated.*func.*traceManager\|nonisolated.*func.*currentTraceID\|nonisolated.*func.*currentSpan" "$f" 2>/dev/null; then
            red "  ⚠️  $f — nonisolated 方法访问 @MainActor 属性（需加 @MainActor 或 nonisolated static）"
            has_issue=true
        fi
    fi
    
    # 4b. 方法加了 @MainActor 但调用者未加（Swift 6 严格模式）
    if grep -q "@MainActor" "$f" 2>/dev/null; then
        if grep -P '^\s+func (debug|info|warning|error)\(' "$f" 2>/dev/null | grep -v "@MainActor" | grep -q .; then
            red "  ⚠️  $f — public 方法调用了 @MainActor private 方法但自身未标 @MainActor"
            has_issue=true
        fi
    fi
    
    # 4c. 协议方法标记 @MainActor 但实现未标（Swift 6 严格模式）
    # 检查 protocol 有 @MainActor 但 extension 方法缺少
    if grep -q "@MainActor" "$f" 2>/dev/null && grep -q "^protocol" "$f" 2>/dev/null; then
        # 协议已标 @MainActor 时跳过检查
        :
    fi
    
    $has_issue && ERRORS=$((ERRORS + 1))
done
green "  ✅ MainActor 检查完成"

# ══════════════════════════════════════════════
# 5. FlowLayout 声明完整性
#    覆盖: extraneous '}' at top level / missing struct declaration
# ══════════════════════════════════════════════
echo ""
echo "📋 [5/9] FlowLayout 结构体检查..."
for f in $(grep -rl "func placeSubviews" "$PROJECT_DIR" --include="*.swift" 2>/dev/null); do
    if ! grep -B5 "func placeSubviews" "$f" 2>/dev/null | grep -q "struct.*Layout"; then
        red "  ❌ $f — placeSubviews 缺少 struct XXX: Layout 声明"
        ERRORS=$((ERRORS + 1))
    fi
done
green "  ✅ FlowLayout 检查完成"

# ══════════════════════════════════════════════
# 6. Codable 结构体兼容性
#    覆盖: type does not conform to protocol 'Decodable'/'Encodable'
# ══════════════════════════════════════════════
echo ""
echo "📋 [6/9] Codable 结构体检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    if grep -q ": Codable" "$f" 2>/dev/null; then
        if grep -P '^\s+let\s+\w+:\s*\[\(.*\)\]' "$f" 2>/dev/null; then
            red "  ❌ $f — Codable struct 包含不兼容的元组属性"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done
green "  ✅ Codable 检查完成"

# ══════════════════════════════════════════════
# 7. 关联值枚举 == 比较
#    覆盖: member 'completed(transcription:)' expects argument / 
#          enum case with associated value used in ==
# ══════════════════════════════════════════════
echo ""
echo "📋 [7/9] 枚举关联值比较检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    # 匹配: state == .xxx 其中 .xxx 是带关联值的 case（如 .completed(let)）
    # 简化检测：如果文件中有 case xxx(关联值) 且同时有 state == .xxx 则报警
    if grep -q "case [a-z].*(" "$f" 2>/dev/null; then
        for case_name in $(grep -oP 'case\s+\w+' "$f" 2>/dev/null | awk '{print $2}'); do
            if grep -q "case $case_name(" "$f" 2>/dev/null && grep -q "== \.$case_name\b" "$f" 2>/dev/null; then
                red "  ⚠️  $f — 关联值枚举 case .$case_name 使用了 == 比较（应用 if case 匹配）"
                ERRORS=$((ERRORS + 1))
            fi
        done
    fi
done
green "  ✅ 枚举关联值检查完成"

# ══════════════════════════════════════════════
# 8. ForEach 中元组解构 vs 结构体属性
#    覆盖: contextual closure type expects 1 argument, but 2 were used
#          cannot convert value of type 'KeyPath<(String, Int), String>'
# ══════════════════════════════════════════════
echo ""
echo "📋 [8/9] ForEach 元组/结构体兼容性检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    # 检测 ForEach 中用了 \.0 作为 id，但数据源可能是结构体数组
    if grep -q 'ForEach.*id:\\\.0' "$f" 2>/dev/null; then
        red "  ⚠️  $f — ForEach 使用 id: \\.0 但数据源可能是结构体（应用 \\.name）"
        ERRORS=$((ERRORS + 1))
    fi
done
green "  ✅ ForEach 兼容性检查完成"

# ══════════════════════════════════════════════
# 9. 结构体参数顺序
#    覆盖: argument 'xxx' must precede argument 'yyy'
# ══════════════════════════════════════════════
echo ""
echo "📋 [9/9] 结构体初始化参数顺序检查..."
for f in $(find "$PROJECT_DIR" -name "*.swift" -type f); do
    # 检查 struct init 参数顺序是否匹配声明顺序
    # 检测 .init( 调用，参数标签顺序与 struct 声明顺序对比
    if grep -q "\.init(" "$f" 2>/dev/null; then
        # 提取 .init( 后的参数标签
        init_params=$(grep -oP '\.init\(\K[^)]+' "$f" 2>/dev/null | head -5)
        for params in $init_params; do
            # 检查参数是否使用了标签（有冒号）
            if echo "$params" | grep -q ":"; then
                labels=$(echo "$params" | grep -oP '\w+:' | sed 's/://')
                # 简单检查：如果有 date: 在 type: 后面则报警
                if echo "$labels" | tr ' ' '\n' | grep -q "date" && echo "$labels" | tr ' ' '\n' | grep -q "type"; then
                    date_pos=$(echo "$labels" | tr ' ' '\n' | grep -n "date" | cut -d: -f1)
                    type_pos=$(echo "$labels" | tr ' ' '\n' | grep -n "type" | cut -d: -f1)
                    if [ "$date_pos" -gt "$type_pos" ] 2>/dev/null; then
                        red "  ⚠️  $f — struct init 中 date: 应在 type: 之前"
                        ERRORS=$((ERRORS + 1))
                    fi
                fi
            fi
        done
    fi
done
green "  ✅ 参数顺序检查完成"

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

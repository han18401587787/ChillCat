#!/bin/bash
# 测试结果解析工具
# 用法: ./parse_test_results.sh <xcresult路径>
# 输出: 可读的测试报告 + 失败用例清单

XCRESULT="${1:-ui-test-results.xcresult}"

echo "🧪 解析测试结果: $XCRESULT"
echo ""

# 获取测试计划摘要
echo "=== 测试套件状态 ==="
xcrun xcresulttool get --path "$XCRESULT" --format json 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    metrics = data.get('metrics', {})
    print(f\"  总测试数: {metrics.get('testsCount', '?')}\")
    print(f\"  失败: {metrics.get('testsFailedCount', '?')}\")
    print(f\"  跳过: {metrics.get('testsSkippedCount', '?')}\")
except:
    print('  无法解析 (xcresult格式可能已变更)')
" 2>/dev/null

echo ""
echo "=== 失败用例 ==="
# 用 xcresulttool 列出所有失败的测试
xcrun xcresulttool get --path "$XCRESULT" --format json 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    issues = data.get('issues', {}).get('testFailureSummaries', {}).get('_values', [])
    if not issues:
        print('  ✅ 没有失败的测试')
    for issue in issues:
        name = issue.get('testCaseName', {}).get('_value', 'Unknown')
        msg = issue.get('message', {}).get('_value', '')[:120]
        print(f'  ❌ {name}')
        print(f'     {msg}')
except Exception as e:
    print(f'  解析失败: {e}')
" 2>/dev/null

echo ""
echo "=== 失败截图 ==="
SCREENSHOT_DIR="/tmp/VisualDiffFailures"
if [ -d "$SCREENSHOT_DIR" ] && [ "$(ls -A "$SCREENSHOT_DIR" 2>/dev/null)" ]; then
    for f in "$SCREENSHOT_DIR"/*.png; do
        echo "  📸 $(basename "$f")"
    done
else
    echo "  无失败截图"
fi

echo ""
echo "=== 修复建议 ==="
echo "  1. 在 Xcode 中双击 .xcresult 文件查看详细失败信息"
echo "  2. 对照 failure-screenshots/ 中的截图定位视觉差异"
echo "  3. 修改代码后重新运行测试验证"

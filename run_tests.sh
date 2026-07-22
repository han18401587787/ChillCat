#!/bin/bash
# 绪安 v3.0 沙箱自动化测试脚本
# 用法: bash run_tests.sh
# 每次运行自动生成测试报告并提交到 Git

set -e
TIMESTAMP=$(date +%Y%m%d-%H%M)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="/workspace/ChillCat-Server/ChillCat-Server"
IOS_DIR="$SCRIPT_DIR"
REPORT_DIR="$IOS_DIR/docs/tests"
REPORT_FILE="$REPORT_DIR/test-report-$TIMESTAMP.md"

mkdir -p "$REPORT_DIR"

echo "# 绪安 v3.0 自动化测试报告" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "> 运行时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "> iOS 分支: $(cd "$IOS_DIR" && git branch --show-current)" >> "$REPORT_FILE"
echo "> Server 分支: $(cd "$SERVER_DIR" && git branch --show-current)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PASS=0
FAIL=0

echo "## Go 后端测试" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "🧪 运行 Go 单元测试..."
cd "$SERVER_DIR"
TEST_OUTPUT=$(go test ./internal/service/ -count=1 -v 2>&1)
SERVICE_PASS=$(echo "$TEST_OUTPUT" | grep -c -- "--- PASS:" || true)
SERVICE_FAIL=$(echo "$TEST_OUTPUT" | grep -c -- "--- FAIL:" || true)
echo "| Go Service Tests | $SERVICE_PASS PASS | $SERVICE_FAIL FAIL |" >> "$REPORT_FILE"
PASS=$((PASS + SERVICE_PASS)); FAIL=$((FAIL + SERVICE_FAIL))

INTEG_OUTPUT=$(go test ./tests/integration/ -count=1 -v 2>&1)
INTEG_PASS=$(echo "$INTEG_OUTPUT" | grep -c -- "--- PASS:" || true)
INTEG_FAIL=$(echo "$INTEG_OUTPUT" | grep -c -- "--- FAIL:" || true)
echo "| Go Integration Tests | $INTEG_PASS PASS | $INTEG_FAIL FAIL |" >> "$REPORT_FILE"
PASS=$((PASS + INTEG_PASS)); FAIL=$((FAIL + INTEG_FAIL))

echo "" >> "$REPORT_FILE"
echo "## 汇总" >> "$REPORT_FILE"
echo "| 指标 | 数值 |" >> "$REPORT_FILE"
echo "|------|------|" >> "$REPORT_FILE"
echo "| 总通过 | $PASS |" >> "$REPORT_FILE"
echo "| 总失败 | $FAIL |" >> "$REPORT_FILE"
if [ $((PASS + FAIL)) -gt 0 ]; then
    echo "| 通过率 | $(( PASS * 100 / (PASS + FAIL) ))% |" >> "$REPORT_FILE"
fi

if [ $FAIL -gt 0 ]; then
    echo "## ⚠️ 发现异常，请检查失败测试并修复" >> "$REPORT_FILE"
fi

cat "$REPORT_FILE"

# 提交
cd "$IOS_DIR"
git add docs/tests/ .github/workflows/ ChillCatUITests/ChillCatV3UITests.swift run_tests.sh
git commit -m "test: 自动化测试报告 $TIMESTAMP — $PASS PASS / $FAIL FAIL" 2>/dev/null && git push origin v3.0-dev 2>/dev/null || true

cd "$SERVER_DIR"
mkdir -p docs/tests && cp "$REPORT_FILE" docs/tests/
git add docs/tests/
git commit -m "test: 自动化测试报告 $TIMESTAMP — $PASS PASS / $FAIL FAIL" 2>/dev/null && git push origin v3.0-dev 2>/dev/null || true

echo "✅ 测试完成: $PASS PASS, $FAIL FAIL"
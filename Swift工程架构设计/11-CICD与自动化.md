# 11 - CI/CD 与自动化

> **版本：** v1.0 | **作者：** doudou.han | **日期：** 2025-07-16

---

## 1. CI/CD 流程总览

### 1.1 流程概览

```
代码提交 → Lint → Unit Test → Build → Integration Test → Deploy
    │         │        │          │           │             │
    ▼         ▼        ▼          ▼           ▼             ▼
   PR     SwiftLint  XCTest    xcodebuild   XCTest      TestFlight
         SwiftFormat                        (E2E)      /App Store
```

### 1.2 环境说明

| 环境 | 触发方式 | 用途 | 部署目标 |
|------|----------|------|----------|
| **Development** | Push develop | 开发验证 | Simulator Build |
| **Staging** | PR → develop | 集成测试 | TestFlight Internal |
| **Release** | PR → main | 发布候选 | TestFlight External |
| **Production** | Tag 推送 | 正式发布 | App Store |

---

## 2. GitHub Actions CI

### 2.1 完整 CI 配置

```yaml
# .github/workflows/ci.yml

name: CI

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  DEVELOPER_DIR: /Applications/Xcode_16.0.app/Contents/Developer

jobs:
  # ========== Lint ==========
  lint:
    name: Lint
    runs-on: macos-14
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4

      - name: SwiftLint
        run: |
          brew install swiftlint
          swiftlint --strict --reporter github-actions-logging

      - name: SwiftFormat
        run: |
          brew install swiftformat
          swiftformat --lint --lenient .

  # ========== Unit Tests ==========
  unit-tests:
    name: Unit Tests
    runs-on: macos-14
    needs: lint
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'

      - name: Resolve Dependencies
        run: xcodebuild -resolvePackageDependencies -scheme ProjectName

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme ProjectName \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
            -only-testing:ProjectNameUnitTests \
            -resultBundlePath UnitTestResults \
            -derivedDataPath DerivedData \
            | xcpretty --report junit --output build/reports/junit.xml

      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: unit-test-results
          path: UnitTestResults.xcresult

      - name: Upload Code Coverage
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: code-coverage
          path: build/reports

  # ========== Build ==========
  build:
    name: Build
    runs-on: macos-14
    needs: unit-tests
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'

      - name: Build
        run: |
          xcodebuild build \
            -scheme ProjectName \
            -sdk iphonesimulator \
            -destination 'generic/platform=iOS Simulator' \
            -derivedDataPath DerivedData \
            | xcpretty

  # ========== UI Tests ==========
  ui-tests:
    name: UI Tests
    runs-on: macos-14
    needs: build
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'

      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme ProjectName \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
            -only-testing:ProjectNameUITests \
            -resultBundlePath UITestResults \
            | xcpretty

      - name: Upload UI Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: ui-test-results
          path: UITestResults.xcresult
```

### 2.2 发布流水线

```yaml
# .github/workflows/release.yml

name: Release

on:
  push:
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'

jobs:
  release:
    name: Release to App Store
    runs-on: macos-14
    timeout-minutes: 60
    steps:
      - uses: actions/checkout@v4

      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'

      - name: Install Provisioning Profile
        env:
          PROVISIONING_PROFILE: ${{ secrets.APP_STORE_PROVISIONING_PROFILE }}
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROVISIONING_PROFILE" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

      - name: Install Certificates
        env:
          BUILD_CERTIFICATE_BASE64: ${{ secrets.APP_STORE_CERTIFICATE }}
          P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
        run: |
          echo "$BUILD_CERTIFICATE_BASE64" | base64 --decode > /tmp/cert.p12
          security create-keychain -p temp temp.keychain
          security default-keychain -s temp.keychain
          security unlock-keychain -p temp temp.keychain
          security import /tmp/cert.p12 -k temp.keychain -P "$P12_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k temp temp.keychain

      - name: Archive
        run: |
          xcodebuild archive \
            -scheme ProjectName \
            -configuration Release \
            -archivePath build/ProjectName.xcarchive \
            -destination 'generic/platform=iOS' \
            -allowProvisioningUpdates

      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath build/ProjectName.xcarchive \
            -exportPath build/ \
            -exportOptionsPlist ExportOptions.plist \
            -allowProvisioningUpdates

      - name: Upload to TestFlight
        env:
          APP_STORE_CONNECT_USERNAME: ${{ secrets.APP_STORE_CONNECT_USERNAME }}
          APP_STORE_CONNECT_PASSWORD: ${{ secrets.APP_STORE_CONNECT_PASSWORD }}
        run: |
          xcrun altool --upload-app \
            -f build/ProjectName.ipa \
            -u "$APP_STORE_CONNECT_USERNAME" \
            -p "$APP_STORE_CONNECT_PASSWORD" \
            --type ios
```

---

## 3. 自动化脚本

### 3.1 项目初始化脚本

```bash
#!/bin/bash
# Scripts/setup.sh - 项目初始化

set -e

echo "🚀 项目初始化开始..."

# 检查 Xcode 版本
XCODE_VERSION=$(xcodebuild -version | head -n 1 | awk '{print $2}')
echo "📱 Xcode 版本: $XCODE_VERSION"

# 安装依赖工具
echo "📦 安装依赖工具..."
if ! command -v swiftlint &> /dev/null; then
    brew install swiftlint
fi

if ! command -v swiftformat &> /dev/null; then
    brew install swiftformat
fi

if ! command -v xcodegen &> /dev/null; then
    brew install xcodegen
fi

# 安装 Git Hooks
echo "🔗 安装 Git Hooks..."
if [ -d .git/hooks ]; then
    cp Scripts/git-hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    cp Scripts/git-hooks/commit-msg .git/hooks/commit-msg
    chmod +x .git/hooks/commit-msg
    echo "✅ Git Hooks 安装完成"
else
    echo "⚠️  .git 目录不存在，跳过 Git Hooks"
fi

# 生成 Xcode 项目
if [ -f project.yml ]; then
    echo "🛠 生成 Xcode 项目..."
    xcodegen generate
    echo "✅ Xcode 项目生成完成"
fi

# 解析 SPM 依赖
echo "📦 解析 SPM 依赖..."
xcodebuild -resolvePackageDependencies -list

echo ""
echo "✅ 初始化完成！"
echo "📖 使用 'open ProjectName.xcodeproj' 打开项目"
```

### 3.2 Git Hooks

```bash
#!/bin/bash
# Scripts/git-hooks/pre-commit

echo "🔍 运行 pre-commit 检查..."

# 获取暂存的文件
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.swift$')

if [ -z "$STAGED_FILES" ]; then
    echo "  • 没有 Swift 文件需要检查"
    exit 0
fi

# SwiftFormat 检查
echo "  • SwiftFormat..."
if command -v swiftformat &> /dev/null; then
    swiftformat --lint $STAGED_FILES 2>&1 | grep "error"
    if [ $? -eq 0 ]; then
        echo "❌ SwiftFormat 检查失败，请运行: swiftformat ."
        exit 1
    fi
fi

# SwiftLint 检查
echo "  • SwiftLint..."
if command -v swiftlint &> /dev/null; then
    swiftlint lint --strict $STAGED_FILES
    if [ $? -ne 0 ]; then
        echo "❌ SwiftLint 检查失败"
        exit 1
    fi
fi

echo "✅ pre-commit 检查通过！"
```

```bash
#!/bin/bash
# Scripts/git-hooks/commit-msg

# commit-msg hook: 校验 commit message 格式

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# 正则：type(scope): subject
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\(.+\))?: .{1,100}$"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo ""
    echo "❌ 无效的 Commit Message 格式"
    echo ""
    echo "正确格式: <type>(<scope>): <subject>"
    echo ""
    echo "示例:"
    echo "  feat(auth): 添加手机号登录"
    echo "  fix(login): 修复空密码崩溃"
    echo "  docs: 更新 README"
    echo ""
    echo "Type 类型: feat, fix, docs, style, refactor, perf, test, chore, ci"
    exit 1
fi

echo "✅ Commit Message 格式正确"
```

### 3.3 版本号管理脚本

```bash
#!/bin/bash
# Scripts/version.sh - 版本号管理

set -e

# 读取当前版本
CURRENT_VERSION=$(cat Project.xcconfig | grep "MARKETING_VERSION" | cut -d'=' -f2 | tr -d ' ')
CURRENT_BUILD=$(cat Project.xcconfig | grep "CURRENT_PROJECT_VERSION" | cut -d'=' -f2 | tr -d ' ')

echo "当前版本: $CURRENT_VERSION ($CURRENT_BUILD)"

case "${1:-}" in
    major)
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1+1".0.0"}')
        ;;
    minor)
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2+1".0"}')
        ;;
    patch)
        NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."$3+1}')
        ;;
    build)
        NEW_BUILD=$((CURRENT_BUILD + 1))
        sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_BUILD/CURRENT_PROJECT_VERSION = $NEW_BUILD/" Project.xcconfig
        echo "✅ Build 号更新: $CURRENT_BUILD → $NEW_BUILD"
        exit 0
        ;;
    *)
        echo "用法: ./Scripts/version.sh [major|minor|patch|build]"
        exit 1
        ;;
esac

# 更新版本号
sed -i '' "s/MARKETING_VERSION = $CURRENT_VERSION/MARKETING_VERSION = $NEW_VERSION/" Project.xcconfig

# 重置 Build 号
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_BUILD/CURRENT_PROJECT_VERSION = 1/" Project.xcconfig

echo "✅ 版本更新: $CURRENT_VERSION → $NEW_VERSION (build 1)"
```

---

## 4. 代码质量门禁

### 4.1 PR 检查清单

```yaml
# .github/workflows/pr-checks.yml

name: PR Checks

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  pr-checks:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      # 检查 PR 标题格式
      - name: Check PR Title
        env:
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: |
          if ! echo "$PR_TITLE" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\(.+\))?: .+"; then
            echo "❌ PR 标题格式不正确"
            echo "正确格式: <type>(<scope>): <description>"
            exit 1
          fi

      # 检查分支命名
      - name: Check Branch Name
        env:
          BRANCH_NAME: ${{ github.head_ref }}
        run: |
          if ! echo "$BRANCH_NAME" | grep -qE "^(feature|bugfix|refactor|release|hotfix)/.+"; then
            echo "⚠️  分支命名不规范: $BRANCH_NAME"
            echo "推荐格式: feature/xxx, bugfix/xxx, refactor/xxx"
          fi

      # 检查变更文件数量
      - name: Check Changed Files
        run: |
          CHANGED_FILES=$(git diff --name-only origin/${{ github.base_ref }}...HEAD | wc -l)
          if [ "$CHANGED_FILES" -gt 20 ]; then
            echo "⚠️  变更文件过多 ($CHANGED_FILES)，建议拆分 PR"
          fi
```

### 4.2 Danger 配置

```swift
// Dangerfile.swift

import Danger

let danger = Danger()

// 检查 PR 大小
let allChanges = danger.git.createdFiles.count +
    danger.git.modifiedFiles.count +
    danger.git.deletedFiles.count

if allChanges > 300 {
    danger.warn("⚠️ PR 变更量较大 (\(allChanges) 个文件)，建议拆分为多个小 PR")
}

// 检查新增文件是否有 TODO
let todoFiles = danger.git.createdFiles.filter {
    FileManager.default.contents(atPath: $0)?.contains("TODO") ?? false
}
if !todoFiles.isEmpty {
    danger.warn("📝 以下文件包含 TODO: \(todoFiles.joined(separator: ", "))")
}

// 检查是否有强制解包
let forceUnwrapFiles = danger.git.modifiedFiles.filter { file in
    guard let content = try? String(contentsOfFile: file) else { return false }
    return content.contains("!")
}
if !forceUnwrapFiles.isEmpty {
    danger.warn("⚠️ 以下文件可能包含强制解包: \(forceUnwrapFiles.joined(separator: ", "))")
}

// 检查测试覆盖
let testFiles = danger.git.modifiedFiles.filter { $0.contains("Tests/") }
let sourceFiles = danger.git.modifiedFiles.filter { $0.contains("Sources/") }

if sourceFiles.count > testFiles.count * 2 {
    danger.warn("📝 建议为新增代码添加单元测试")
}
```

---

## 5. 自动化工具

### 5.1 XcodeGen 配置

```yaml
# project.yml

name: ProjectName
options:
  bundleIdPrefix: com.example
  deploymentTarget:
    iOS: "15.0"
  xcodeVersion: "16.0"
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    SWIFT_STRICT_CONCURRENCY: complete
    ENABLE_USER_SCRIPT_SANDBOXING: NO

targets:
  ProjectName:
    type: application
    platform: iOS
    sources:
      - path: App
      - path: Core
      - path: Domain
      - path: Data
      - path: Presentation
    settings:
      base:
        INFOPLIST_FILE: Resources/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.example.project
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: 1
      configs:
        Debug:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: DEBUG
        Staging:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: STAGING
        Release:
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: RELEASE
    dependencies:
      - framework: Alamofire
      - framework: Kingfisher
    preBuildScripts:
      - name: SwiftLint
        script: |
          if which swiftlint >/dev/null; then
            swiftlint
          fi
      - name: SwiftFormat
        script: |
          if which swiftformat >/dev/null; then
            swiftformat .
          fi

  ProjectNameUnitTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - Tests/UnitTests
      - Tests/Mocks
    dependencies:
      - target: ProjectName

  ProjectNameUITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - Tests/UITests
    dependencies:
      - target: ProjectName
```

### 5.2 Fastlane 配置（可选）

```ruby
# fastlane/Fastfile

default_platform(:ios)

platform :ios do
  desc "运行所有测试"
  lane :test do
    run_tests(
      scheme: "ProjectName",
      devices: ["iPhone 16"],
      ensure_devices_found: true,
      output_types: "junit,html",
      output_files: "report",
      result_bundle: true,
      code_coverage: true
    )
  end

  desc "构建并上传到 TestFlight"
  lane :beta do
    increment_build_number(
      build_number: number_of_commits
    )
    build_app(scheme: "ProjectName")
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "提交 App Store 审核"
  lane :release do
    match(type: "appstore")
    increment_build_number(
      build_number: number_of_commits
    )
    build_app(scheme: "ProjectName")
    upload_to_app_store(
      skip_metadata: true,
      skip_screenshots: true
    )
  end
end
```

---

> **关联文档：** [03-开发规范.md](03-开发规范.md) | [10-测试策略.md](10-测试策略.md) | [12-可维护性与可扩展性.md](12-可维护性与可扩展性.md)

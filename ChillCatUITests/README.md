# ChillCat 绪安 UI 测试套件

## 架构

```
ChillCatUITests/
├── ChillCatUITests.swift                    # 主入口 - sanity + E2E + 视觉回归
├── Helpers/
│   ├── VisualTesting.swift                  # 视觉回归引擎（像素比对）
│   └── XCUIApplication+Extensions.swift     # 页面元素访问器 & 快捷操作
├── Tests/
│   ├── WelcomeFlowTests.swift               # 欢迎页 & 登录流程
│   ├── HomeFlowTests.swift                  # 首页情绪打卡
│   ├── TreeHoleFlowTests.swift              # 树洞匿名社区
│   └── NavigationTests.swift                # Tab导航 & 页面跳转
└── Screenshots/Baseline/                    # 基线截图（首次运行自动生成）
```

## 快速开始

### 1. 添加 UI Test Target（Xcode 中）

- 打开 `ChillCat.xcodeproj`
- `File → New → Target → UI Testing Bundle`
- Target Name: `ChillCatUITests`
- 把 `ChillCatUITests/` 下所有文件拖入 target

### 2. 运行所有测试

```bash
xcodebuild test \
  -project ChillCat.xcodeproj \
  -scheme ChillCat \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:ChillCatUITests
```

### 3. 首次运行（创建基线）

```bash
xcodebuild test \
  -project ChillCat.xcodeproj \
  -scheme ChillCat \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:ChillCatUITests/ChillCatUITests/test_visual_welcomePage
```

基线截图保存在 `Screenshots/Baseline/`，后续运行自动比对。

### 4. 更新基线

重构 UI 后，删除旧基线重新生成：

```bash
rm -rf ChillCatUITests/Screenshots/Baseline/*
xcodebuild test ...
```

## 测试覆盖

| 测试 | 类型 | 覆盖 |
|:--|:--|:--|
| WelcomeFlow | UI + Visual | 欢迎页渲染、按钮存在、匿名登录、导航到登录页 |
| HomeFlow | UI + Visual | 10种情绪按钮、打卡流程、打卡成功确认 |
| TreeHoleFlow | UI + Visual | 帖子列表、发帖、匿名切换 |
| Navigation | UI + Visual | 4个Tab切换、探索卡片、登出流程 |
| ChillCatUITests | E2E + Visual | 完整用户旅程 + 全页面视觉回归 |

## CI/CD 集成

```yaml
# .github/workflows/ui-tests.yml
- name: Run UI Tests
  run: |
    xcodebuild test \
      -project ChillCat.xcodeproj \
      -scheme ChillCat \
      -destination 'platform=iOS Simulator,name=iPhone 16e' \
      -only-testing:ChillCatUITests
```

## 视觉回归原理

`VisualTesting.swift` 逐像素比对当前截图与基线：

1. 截取屏幕 → CGImage
2. 对每个像素计算 RGB 差异
3. 差异像素数 / 总像素数 = 差异百分比
4. > 0.5% → 测试失败，保存差异截图到 `/tmp/VisualDiffFailures/`

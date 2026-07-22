# ChillCat 绪安 UI 测试套件

## 架构

```
ChillCatUITests/
├── ChillCatV3UITests.swift                  # v3.0 综合 E2E 测试（30+ 用例）
├── CCInteractionTests.swift                 # 交互验证（控件类型、点击区域、导航）
├── ChillCatVisualRegressionTests.swift      # 视觉回归（AI 视觉校验 + 像素比对）
├── ChillCatUITestsLaunchTests.swift         # 启动测试
├── Helpers/
│   ├── XCUIApplication+Extensions.swift     # 页面元素访问器（accessibilityIdentifier）
│   ├── CCDiagnosticHelper.swift             # 诊断工具（API 连通性自检、元素诊断）
│   ├── VisualTesting.swift                  # 视觉回归引擎（像素比对）
│   └── CCVisionTypes.swift                  # 视觉接口类型
├── Screenshots/Baseline/                    # 基线截图
└── README.md
```

## 单元测试

```
ChillCatTests/
├── Core/
│   ├── Networking/
│   │   ├── CCNetworkConfigTests.swift       # 网络配置、重试延迟
│   │   └── CCAPIErrorTests.swift            # 错误码映射
│   └── Logging/
│       └── CCLoggerTests.swift              # 日志模块、级别过滤
├── Domain/
│   └── UseCases/
│       └── CCLoginUseCaseTests.swift        # 登录输入校验
└── Helpers/
    ├── MockURLProtocol.swift                # 网络 Mock
    └── TestHelpers.swift                    # 测试辅助函数
```

## 快速开始

### 运行单元测试

```bash
xcodebuild test \
  -workspace ChillCat.xcworkspace \
  -scheme ChillCat \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:ChillCatTests
```

### 运行 UI 测试

```bash
xcodebuild test \
  -workspace ChillCat.xcworkspace \
  -scheme ChillCat \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:ChillCatUITests
```

## 测试覆盖

| 套件 | 类型 | 覆盖 |
|:--|:--|:--|
| ChillCatV3UITests | E2E | 全功能流程：Tab 导航、情绪打卡、AI 倾听、树洞、工具箱、个人中心、危机热线 |
| CCInteractionTests | 交互 | 控件类型正确性、点击区域 ≥44pt、导航正确性、输入框可编辑、Toggle/Slider |
| ChillCatVisualRegressionTests | 视觉 | 全页面视觉回归（AI 校验 + 像素比对） |
| CCNetworkConfigTests | 单元 | 退避延迟计算、重试逻辑、配置常量 |
| CCAPIErrorTests | 单元 | 业务码映射、错误描述 |
| CCLoggerTests | 单元 | 日志模块分级、级别过滤 |
| CCLoginUseCaseTests | 单元 | 登录输入校验、边界场景 |

## 测试编写规范

参考 `.codebuddy/skills/swift-testing-expert/SKILL.md`：
- 默认不加 `@MainActor`（仅 UI 绑定测试需要）
- 禁止 `.serialized` 作为默认架构（优先隔离状态）
- 优先使用 `@Test(arguments:)` 参数化测试
- 网络层必须 Mock（禁止连真实服务器）

## CI/CD 集成

```yaml
- name: Run Unit Tests
  run: |
    xcodebuild test \
      -workspace ChillCat.xcworkspace \
      -scheme ChillCat \
      -destination 'platform=iOS Simulator,name=iPhone 16e' \
      -only-testing:ChillCatTests

- name: Run UI Tests
  run: |
    xcodebuild test \
      -workspace ChillCat.xcworkspace \
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

---
globs: "**/*"
description: 绪安 ChillCat v3.0 全栈编码规范与决策原则 — 所有开发必须遵守
alwaysApply: true
---

# 绪安 ChillCat v3.0 编码规范与决策原则

> 所有决策涉及到的原则都沉淀在此，后续开发默认遵守。

---

## 一、命名规范

### 1.1 iOS 客户端（Swift）

1. **所有新增自定义类/结构体/枚举/协议必须以 `CC` 开头**
   - View: `CC{功能}View`（如 `CCHomeView`, `CCHealingPlanView`）
   - ViewModel: `CC{功能}ViewModel`（如 `CCLoginViewModel`）
   - Model: `CC{功能}Model`（如 `CCUserModel`）
   - Manager: `CC{功能}Manager`（如 `CCThemeManager`）
   - Service: `CC{功能}Service`
   - Protocol: `CC{功能}Protocol`
   - Coordinator: `CC{功能}Coordinator`

2. **例外情况（不加 CC 前缀）**：
   - `AppDelegate`、`SceneDelegate`（系统入口）
   - 纯扩展文件（extension）
   - Widget 入口（如 `XuanWidget.swift`）

3. **文件名 = 主类型名**，如 `CCAppTheme.swift` 包含 `enum AppTheme` 但文件名以主入口类型命名

4. **新增文件头注释**：
```swift
//
//  {文件名}.swift
//  ChillCat
//
//  Created by doudou.han on {真实日期}
//
```

### 1.2 Go 服务端

1. **文件名**：`{module}_{role}.go` 模式
   - handler: `{module}_handler.go`
   - service: `{module}_service.go`
   - repository: `{module}_repo.go`
   - model: `{module}.go`

2. **类型名**：Go 标准 PascalCase，通过包名做命名空间，**不需要 CC 前缀**

3. **包名**：小写单词，简洁明了

---

## 二、架构规范

### 2.1 iOS 架构

- **架构模式**：Clean Architecture + Coordinator + MVVM
- **分层**：App → Presentation → Domain → Data → Core
- **依赖注入**：手动 DI（`CCAppDependencyContainer`）
- **网络层**：`CCAPIClient`（自建 URLSession）+ `CCXuanAPI`（Alamofire）
- **设计系统**：统一使用 `AppTheme`（enum + 静态属性，Ardot 规范色板）
- **暗色模式**：通过 `CCThemeManager` 管理，`CCLightTheme` / `CCDarkTheme`

### 2.2 Go 服务端架构

- **架构模式**：Gin + GORM，Handler → Service → Repository 三层
- **依赖注入**：在 `router.Setup()` 中手动组装
- **统一响应**：`{code, message, data}` JSON 格式，使用 `pkg/response`
- **错误码**：1xxxx 通用 / 2xxxx 用户 / 3xxxx 会员 / 4xxxx 新增模块
- **中间件链**：Logger → CORS → RateLimit → SlowRequestLog → Recovery → Auth

### 2.3 新增 Go 模块必须遵循

1. 在 `internal/` 下按 handler/service/repository 三层组织
2. Handler 通过 `getUserID(c)` 获取当前用户
3. Service 返回 `(result, errorCode, error)` 三值
4. Repository 持有 `*gorm.DB`，通过 `NewXxxRepo(db)` 构造
5. 在 `router/router.go` 的 `Setup()` 中注册路由和组装依赖

---

## 三、设计规范

### 3.1 设计系统（Ardot 规范）

| 元素 | 值 |
|------|-----|
| 主色 | `#5A7A8A`（蓝灰） |
| 背景 | `#F9F6F2`（暖白） |
| 表面 | `#F0EDE8` |
| 文字主 | `#2D2D2D` |
| 文字次 | `#7A7A7A` |
| 文字辅 | `#AAAAAA` |
| 间距 | 6 / 10 / 16 / 24 / 32 |
| 圆角 | 8 / 12 / 16 / 24 |
| 情绪色板 | 10 色（平静/开心/疲惫/焦虑/委屈/孤独/烦躁/迷茫/易怒/内耗） |

### 3.2 UI 设计原则

1. **以新版本（v3.0 Ardot 规范）为准**，新旧页面统一
2. **全量替换**旧设计系统，不做桥接共存
3. 暖色调 + 治愈风格，圆润线条，柔和色彩

---

## 四、编码安全规范

### 4.1 iOS 安全编码

1. **禁止强制解包**：使用 `guard let` / `if let` / `??`
2. **循环引用防护**：闭包中使用 `[weak self]`
3. **最小化访问权限**：优先 `private`，需要时 `private(set)`
4. **Certificate Pinning**：所有网络请求必须验证证书公钥指纹
5. **敏感数据**：Token 存 Keychain，日记内容 AES-256-GCM 加密

### 4.2 日志系统

- 使用 `LogD/LogI/LogW/LogE/LogF` 全局函数
- 按模块分类：`.network` / `.auth` / `.ui` / `.storage` / `.database` / `.safe`
- 生产环境仅记录 Warning 及以上级别
- 全链路追踪：使用 `TraceManager` 生成 TraceID/SpanID

---

## 五、Git 规范

### 5.1 分支策略

```
main          # 生产分支（只接受 release/hotfix 合入）
├── develop   # 开发主分支
├── v3.0-dev  # v3.0 功能开发分支
└── feature/* # 功能分支
```

### 5.2 Commit 格式

```
<type>(<scope>): <subject>

<body>
```

Type: `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`

### 5.3 高风险操作（必须用户同意）

1. ❌ Force push 到 main
2. ❌ 删除/覆盖原始项目已有文件
3. ❌ 修改 `go.mod` / `Package.swift` 依赖
4. ❌ 修改路由/认证/数据库核心逻辑
5. ❌ 合并 main 分支

---

## 六、决策记录

| 日期 | 决策 | 原因 |
|------|------|------|
| 2026-06-17 | iOS 设计系统全量替换为 Ardot 规范 | UI 一致性是产品体验根基 |
| 2026-06-17 | 新增 iOS 文件以 CC 前缀命名 | 原始项目 87.7% 文件遵循此规范 |
| 2026-06-17 | Go 服务端沿用原始命名惯例 | Go 生态通过包名做命名空间 |
| 2026-06-17 | 新增 Go 模块遵循 Handler→Service→Repo 三层 | 保持架构一致性 |
| 2026-06-17 | 新代码放 v3.0-dev 分支 | 方便异常时回滚 |
| 2026-06-17 | 情绪打卡率 Phase 1 目标修正为 35%-45% | 正常 APP 起量阶段目标值 |
| 2026-06-17 | AI 供应商：通义千问(主) + 文心(备) + 讯飞(语音) | 性价比和中文能力最优 |
| 2026-06-17 | AppTheme 保留 v2 兼容别名（primaryMuted/warm/softGreen 等） | 38 个原始文件无需改变视觉意图即可迁移 |
| 2026-06-17 | CCAppThemeProtocol → AppTheme（enum+静态属性） | 消除协议开销，直接静态分发 |
| 2026-06-17 | theme.spacingXS → AppSpacing.xs（等间距/圆角映射） | 与 Ardot 规范命名对齐 |
| 2026-06-17 | AppSpacing 新增 xxl(48)/xxxl(64) | v3 新页面需要的更大间距 Token |
| 2026-06-17 | CCThemeManager 改为管理暗色模式覆盖 | 适配 AppTheme 静态属性的新架构 |
| 2026-06-17 | .environment(\\.ccAppTheme) 全局移除 | AppTheme 为静态属性，不再需要 Environment 注入 |

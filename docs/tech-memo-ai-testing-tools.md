# 技术备忘：AI 测试工具调研 — 对 ChillCat 的适用性评估

> 调研日期：2026-07-15
> 状态：备忘，非立即执行
> 版本：v1.0

---

## 一、调研背景

ChillCat 当前 XCTest 套件存在稳定性问题（P0/P1 已在 `0995c6b` 修复），团队在探索是否有更高效的测试方案。本文档综合评估三款 AI 测试工具/方案。

---

## 二、三款工具横向对比

| 维度 | simctl + cliclick | Revyl CLI | Alumnium |
|------|-------------------|-----------|----------|
| **定位** | 命令行脚手架 | 云端真机测试平台 | AI 原生测试库 |
| **来源** | [微信文章1](https://mp.weixin.qq.com/s/yVAcD8pC-K5vIA4BOhET2Q) | [微信文章2](https://mp.weixin.qq.com/s/vtfHlsecw2WWAuKtI0-oxg) | [微信文章3](https://mp.weixin.qq.com/s/4g7yEVIkyeihg_1S4rdnvw) |
| **侵入性** | 零侵入 | 低（CLI 工具） | 中（需集成库） |
| **iOS 支持** | ✅ simctl 原生 | ✅ 云端真机 | ✅ Appium → XCUITest |
| **AI 能力** | 无 | 自然语言 + Agent Skills | 自然语言 + Planner + MCP |
| **测试定义** | Shell 脚本 | YAML 文件 | Python/TS/Java 代码 |
| **真机 vs 模拟器** | 模拟器 | 云端真机 | 取决于 Appium 配置 |
| **离线可用** | ✅ | ❌ 依赖云服务 | ✅ Ollama 本地模型 |
| **学习成本** | 低 | 中 | 低 |
| **成熟度** | 成熟（Apple 官方工具） | 新项目（2026.7） | 新项目（2026.5） |
| **WebVoyager 精度** | N/A | N/A | 98.5% SOTA |
| **GitHub** | N/A | github.com/RevylAI/revyl-cli | github.com/alumnium-hq/alumnium |

---

## 三、设计模式借鉴

### 3.1 Agent Skills 封装模式（Revyl）

Revyl 将测试能力封装为 AI 编程工具的 Skills，分为三类：

| Skill 类别 | 职责 | ChillCat 类比 |
|-----------|------|--------------|
| **开发循环** (Dev Loop) | 启动设备 → 截图确认状态 → 操作 → 报告 | simctl + cliclick 脚手架 |
| **测试创建** | 编写 YAML 测试 → 校验 → 推送 → 运行 → 迭代 | 当前 XCTest 手写 |
| **登录绕过** | 针对不同技术栈配置测试态鉴权 | ✅ `-UITEST_SKIP_WELCOME` / `-UITEST_AUTO_LOGIN` 已实现 |

**设计原则**：Skill = 任务目标 + 工具调用顺序 + 验收标准，而非一句模糊 prompt。

### 3.2 MCP Server 标准化（Alumnium）

Alumnium 通过 MCP（Model Context Protocol）将测试能力暴露为标准化工具：

| 工具 | 功能 | ChillCat 可类比 |
|------|------|----------------|
| `start` / `stop` | 启动/停止浏览器或 App | `xcrun simctl boot/shutdown` |
| `do` | 执行自然语言目标 | `xcodebuild test -only-testing:...` |
| `check` | 验证断言 | XCTest Assert |
| `get` | 提取页面数据 | `xcrun simctl screenshot` |
| `fetch_accessibility_tree` | 获取 a11y tree | Lookin 层级查看 |

**启示**：如果未来 ChillCat 需要 AI 辅助测试，封装一个 MCP Server 暴露 `xcodebuild test` / `xcrun simctl` 等操作，比引入第三方测试框架更务实。

### 3.3 Accessibility Tree 优先策略（Alumnium）

这是 Alumnium 最值得借鉴的设计决策——**基于 accessibility tree 定位元素，而非 DOM/坐标/文本**：

> "优先 accessibility tree（比 DOM 更稳定、抗 UI 变动）"

XCUITest 的 `XCUIElement` 本质上就是 accessibility tree 的映射。这意味着：
- `accessibilityIdentifier` 是 XCTest 稳定性的根基
- 每个可交互元素都应有明确的 identifier
- 文本匹配（`buttons["登录"]`）应仅作为兜底策略

**ChillCat 当前状态**：已有 26 处 `accessibilityIdentifier`，覆盖 TabBar、首页入口、树洞发布、共鸣墙等关键路径。仍需补全：设置页、会员页、冥想详情等次要页面。

### 3.4 Planner + Change Analysis（Alumnium）

```
用户: al.do("search for Mercury element and press Enter")
AI:
  1. [Plan] 找到搜索框 → 输入关键词 → 按 Enter
  2. [Execute] 逐步执行
  3. [Analyze] 对比前后 accessibility tree，生成变更报告
```

多步操作的可靠性来自"先规划再执行 + 执行后验证"，而非一次性 prompt。

---

## 四、对 ChillCat 的分阶段建议

### 短期（当前已完成 ✅）

| 行动 | 状态 |
|------|------|
| 修复 P0：TabBar accessibilityIdentifier 双重设置 | ✅ `0995c6b` |
| 修复 P0：skipWelcomeAndLaunch 错误 identifier | ✅ `0995c6b` |
| 修复 P1：CCApp UITest 状态机 | ✅ `0995c6b` |
| 修复 P1：AI 聊天页元素定位 | ✅ `0995c6b` |
| 消除 sleep() 硬编码 | ✅ `0995c6b` |

### 中期（建议下个迭代）

| 行动 | 优先级 | 借鉴来源 |
|------|--------|---------|
| 补全所有页面的 `accessibilityIdentifier` | 🔴 高 | Alumnium a11y tree 策略 |
| 用 Lookin 检查 accessibility 层级，修复遮挡/不可点击元素 | 🟠 中 | Alumnium a11y tree 策略 |
| 将关键用户路径写成 YAML/JSON 描述文档 | 🟡 低 | Revyl YAML 测试定义 |
| 封装 `xcodebuild test` 为带参数的便捷脚本 | 🟡 低 | Revyl Agent Skills |

### 长期（v3.1+，按需引入）

| 场景 | 工具选择 | 理由 |
|------|---------|------|
| 白噪音/音频真机验证 | Revyl 或本地真机 | 模拟器行为不同 |
| 推送通知测试 | 本地真机 + XCUITest | 无需云服务 |
| AI 辅助测试编写 | MCP Server 封装 XCTest | 不替换现有框架 |
| 跨平台测试（如需 Android） | Appium + Alumnium | 统一 API |

---

## 五、核心结论

> **三款工具分别解决不同阶段的问题：simctl 应急取证 → XCTest 稳定回归 → AI 工具提效。ChillCat 当前处于第二阶段，不应跳跃到第三阶段。**

测试稳定性的根基不是 AI，而是：
1. **完整的 accessibilityIdentifier 覆盖**（Alumnium 的 a11y tree 策略验证了这一点）
2. **可靠的元素等待机制**（`waitForExistence` 而非 `sleep`）
3. **明确的应用状态管理**（UITest 模式下显式控制登录态/网络态）

---

## 六、参考链接

- simctl 文章: https://mp.weixin.qq.com/s/yVAcD8pC-K5vIA4BOhET2Q
- Revyl CLI: https://github.com/RevylAI/revyl-cli | https://mp.weixin.qq.com/s/vtfHlsecw2WWAuKtI0-oxg
- Alumnium: https://github.com/alumnium-hq/alumnium | https://mp.weixin.qq.com/s/4g7yEVIkyeihg_1S4rdnvw
- ChillCat CI 配置: `.github/workflows/ci.yml`
- ChillCat 测试脚本: `run_tests.sh`

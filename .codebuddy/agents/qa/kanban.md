# ChillCat QA 工作流看板

> 参考 Hermes 模式，将 QA 流程拆分为 5 个阶段，每个阶段由专门的 AI 分身负责。

## 看板列定义

```
📥 需求澄清 → 🧪 测试设计 → 💻 脚本开发 → ▶️ 测试执行 → ✅ 完成
```

| 列 | 负责分身 | 输入 | 输出 |
|----|----------|------|------|
| 📥 需求澄清 | bug-hunter / test-designer | PRD + 代码 diff | 测试点清单 + 澄清问题 |
| 🧪 测试设计 | test-designer | 测试点清单 | 详细测试用例（TC-xxx） |
| 💻 脚本开发 | senior-developer | 测试用例 + identifier 表 | XCUITest / Unit Test 代码 |
| ▶️ 测试执行 | bug-hunter | 测试脚本 + 运行日志 | 测试报告 + Bug 清单 |
| ✅ 完成 | — | 全部通过 | 验收签字 |

## 工作流触发方式

### 方式一：手动对话模式（灵活）

逐个调用分身，适合复杂需求：

```
1. @test-designer 分析 PRD → 生成测试点
2. @test-designer 设计用例 → 生成详细用例
3. @senior-developer 编写脚本 → 生成测试代码
4. 运行测试 → 收集日志
5. @bug-hunter 分析日志 → 定位失败根因
```

### 方式二：Workflow 模式（标准化）

对于标准需求（新增页面、修改现有功能），使用预定义流程：

```yaml
# .codebuddy/workflows/qa-standard.yml
name: QA 标准流程
steps:
  - agent: test-designer
    prompt: "分析以下变更的测试影响面：{diff}"
    output: test_points.md
  - agent: test-designer
    prompt: "基于测试点设计详细用例：{test_points}"
    output: test_cases.md
  - agent: senior-developer
    prompt: "基于用例编写 XCUITest 脚本：{test_cases}"
    output: "ChillCatUITests/*.swift"
  - agent: bug-hunter
    prompt: "分析测试运行日志：{test_logs}"
    output: bug_report.md
```

## 卡片模板

每张看板卡片包含：

```markdown
# [需求名称]
- PRD: {链接}
- 分支: {git branch}
- 变更文件: {文件列表}
- 创建时间: {日期}
- 当前阶段: 📥 需求澄清
- 负责人: {分身名称}
```

## 使用示例

### 场景：新增"情绪趋势图"功能

1. **📥 需求澄清**：test-designer 读取 PRD → 输出 15 个测试点 + 3 个澄清问题
2. **🧪 测试设计**：test-designer 基于测试点 → 输出 TC-TREND-001 ~ TC-TREND-020
3. **💻 脚本开发**：senior-developer 基于用例 → 编写 XCUITest + Unit Test
4. **▶️ 测试执行**：运行测试 → bug-hunter 分析日志
5. **✅ 完成**：全部通过 → 验收

## 与项目资料库的集成

- 每个阶段的输出自动保存到 `docs/qa/` 目录
- 测试用例关联到 `docs/xctest-identifier-validation.md`
- Bug 报告关联到 TAPD/CNB 事项

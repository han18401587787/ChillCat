# 技术备忘：Revyl CLI — Agent Skills 设计模式 & YAML 测试定义

> 来源：[《让 AI 自己测 App：Revyl CLI 把移动端测试接进 Agent 工作流》](https://mp.weixin.qq.com/s/vtfHlsecw2WWAuKtI0-oxg)
> 日期：2026-07-15
> 状态：备忘，非立即执行

---

## 一、核心借鉴点

### 1. Agent Skills 封装模式

Revyl 将测试能力封装为 AI 编程工具（Codex/Claude Code/Cursor）的 Skills，分为三类：

| Skill 类别 | 职责 | ChillCat 类比 |
|-----------|------|--------------|
| **开发循环** (Dev Loop) | 启动设备 → 截图确认状态 → 操作 → 报告 | 类似我们讨论的 simctl + cliclick 脚手架 |
| **测试创建** | 编写 YAML 测试 → 校验 → 推送 → 运行 → 迭代 | 当前 XCTest 手写，可考虑抽象层 |
| **登录绕过** | 针对不同技术栈配置测试态鉴权 | 当前 `-UITEST_SKIP_WELCOME` / `-UITEST_AUTO_LOGIN` 已实现 |

**设计原则**：Skill = 任务目标 + 工具调用顺序 + 验收标准，而非一句模糊 prompt。

### 2. YAML 测试定义（测试即资产）

```
revyl test create login-flow --from-file ./login-flow.yaml
revyl workflow create smoke-tests --tests login-flow,checkout
revyl workflow run smoke-tests
```

测试定义独立于实现框架，纳入版本控制。工作流负责组合用例。

### 3. 开发回路 (revyl dev)

本地代码 → 隧道连接云端设备 → 自动安装构建 → 即时验证。消除"打包→装机→找设备→重现路径"的摩擦。

---

## 二、对 ChillCat 的远期适用性评估

### 适合引入的场景（v3.1+）

- **白噪音/音频功能**：模拟器行为与真机不同，需真机验证
- **推送通知**：Simulator 不支持完整推送链路
- **HealthKit 集成**：模拟器数据受限

### 不适合的场景

- **核心 UI 回归**：当前 XCTest + Simulator 已覆盖，换 YAML 是重复投资
- **需要数据隔离的测试**：云端设备上的测试数据不可控

### 建议的引入时机

1. XCTest 套件稳定通过（P0/P1 修复完成）
2. Unit Tests 补全
3. 出现"模拟器无法覆盖"的真机特有问题时

---

## 三、可立即采用的轻量实践

无需引入 Revyl，借鉴其思想即可：

1. **测试路径文档化**：将关键用户路径（登录→打卡→树洞→治愈空间→个人中心）写成 YAML/JSON 描述，与 XCTest 代码并存
2. **Agent 可调用脚本**：将 `xcodebuild test` 封装为带参数的 shell 脚本，AI 助手可一键触发
3. **失败分类标签**：测试失败时自动打标签（元素找不到 / 超时 / 视觉差异 / API 不可达），加速分类定位

---

## 四、参考链接

- Revyl CLI GitHub: https://github.com/RevylAI/revyl-cli
- 项目本地 CI 配置: `.github/workflows/ci.yml`
- 项目本地测试脚本: `run_tests.sh`

# Bug 自动修复闭环（阶段二）设计文档

> 从「App 内标记 Bug」到「GitHub Issue」再到「Agent 自动开 PR」的端到端自动化机制。

## 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          ChillCat iOS App                              │
│                                                                       │
│  用户摇晃 → 诊断面板 → Bug 草稿 → [提交到 GitHub Issue]               │
│                                    │  (CCGitHubIssueReporter)          │
│                                    │  ├─ 成功 → Issue 创建             │
│                                    │  └─ 失败 → 本地队列 → 冷启补传    │
└────────────────────────────────────┼──────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          GitHub (han18401587787/ChillCat)              │
│                                                                       │
│  Issue (labels: bug, from-debug-panel)                                │
│    ├─ debug-issue-triage.yml → 自动打 auto-triage 标签 + 分诊评论     │
│    └─ 正文含: 页面/设备/诊断日志/@file:line 锚点                      │
└────────────────────────────────────┼──────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   bug-fixer Agent (本沙箱内 AI)                        │
│                                                                       │
│  触发方式（任选其一）:                                                │
│    A. 手动:   用户对 Agent 说 "处理 GitHub Issue #N"                  │
│    B. 脚本:   ./scripts/process_debug_issues.sh --limit 5            │
│    C. 定时:   cron 每天跑一次脚本（需自托管 runner 有 Agent 环境）    │
│                                                                       │
│  流程（见 .codebuddy/agents/bug-fixer.md）:                          │
│    1. 可行性判定 — LOW 置信度跳过，MEDIUM 标注待确认                  │
│    2. 代码定位 — 用 @file:line 直接打开对应文件                      │
│    3. 最小修复 — 只改日志指向处，复用既有基建                        │
│    4. 开 PR     — fix/issue-N-slug 分支，PR 描述含关联 + 自动声明    │
│    5. 兜底     — 无法定位则不开 PR，评论说明原因                     │
└────────────────────────────────────┼──────────────────────────────────┘
                                       │
                                       ▼
                          PR (Closes #N) → 人工 Review → 合并
```

## 三层职责划分

| 层 | 职责 | 实现 |
|----|------|------|
| **App 层** | 高质量 Issue 生产（日志+截图+页面名）+ 失败重试/补传 | `CCGitHubIssueReporter` + `CCBugSubmissionQueue` |
| **GitHub 层** | Issue 生命周期 + 轻量分诊 | `debug-issue-triage.yml` |
| **Agent 层** | 读 Issue → 分析 → 修复 → 开 PR | `bug-fixer.md` + `process_debug_issues.sh` |

## 护栏（硬约束）

1. **绝不自动合并** — 任何 PR 必须人工 Review
2. **置信度分级** — LOW 不开 PR；MEDIUM 标注【待人工确认】；HIGH 直接开
3. **最小改动** — 只改诊断日志指向的代码，禁止顺手重构
4. **单 Issue 单 PR** — 不批量处理，避免 Review 困难
5. **分支隔离** — 全部基于 `main` 创建 `fix/issue-N-slug`（PR 指向 `main`），但绝不自动合并（见护栏 1）
6. **幂等** — 脚本处理前在 Issue 评论"已派单"，避免重复派单；GitHub Action 打 `auto-triage` 标签
7. **失败可见** — 任何跳过/失败都在 Issue 评论说明原因

## 触发方式对比

| 方式 | 实时性 | 依赖 | 适用 |
|------|--------|------|------|
| 手动（用户叫 Agent） | 按需 | 无 | 当前阶段（沙箱无 webhook 接收） |
| 脚本（cron + 自托管 runner） | 定时 | runner 装 Agent 环境 | 团队有 CI 机器时 |
| GitHub Action 直接调 Agent | 实时 | Agent 可暴露为 service | 未来接入 |

**当前推荐**：手动触发 + 脚本辅助。用户在沙箱里对我说"处理 Issue #N"，我按 `bug-fixer.md` 执行。脚本用于批量列 Issue 和幂等派单。

## 使用步骤（当前）

```bash
# 1. 列出待处理 Issue（dry-run）
GH_TOKEN=xxx ./scripts/process_debug_issues.sh --dry-run

# 2. 处理（Agent 在沙箱内执行实际修复）
#    方式 A: 直接对 Agent 说 "处理 GitHub Issue #N"
#    方式 B: 跑脚本派单，Agent 逐个读取 Issue 正文处理

# 3. Agent 完成后: PR 自动创建 + Issue 评论通知
# 4. 人工在 GitHub Review PR → 合并
```

## 端到端验证（待首个真实 Issue）

1. App 内摇晃 → 标记一个真实 Bug → 提交
2. 确认 GitHub 出现 Issue（标签 `bug` + `from-debug-panel`）
3. 确认 `debug-issue-triage.yml` 自动打 `auto-triage` + 评论
4. 对 Agent 说"处理 Issue #N"
5. 确认生成 `fix/issue-N-*` 分支 + PR（含关联声明）
6. 人工 Review + 合并
7. 确认 Issue 被 `Closes #N` 自动关闭

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| Agent 改错代码 | 最小改动 + PR 人工 Review + 不自动合并 |
| 置信度误判开 PR | LOW 跳过机制 + MEDIUM 标注 |
| Token 泄露 | Token 仅本地/Secret，不入代码；App 端 Token 存 UserDefaults 仅 DEBUG |
| 重复派单 | 脚本派单前评论 + Action 打标签 |
| 大量 Issue 刷屏 | `--limit` 限流 + 手动触发为主 |

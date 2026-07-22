# Skill 1: 页面结构分析文档

> ChillCat 全部页面的 accessibilityIdentifier 覆盖与自动化可行性分析

## 分析方法

对每个页面评估以下维度：

| 维度 | 说明 |
|------|------|
| 页面类型 | Native SwiftUI / 混合渲染 |
| identifier 覆盖 | 关键控件是否有稳定的 accessibilityIdentifier |
| 定位稳定性 | 控件是否容易被 UI 变更影响 |
| 自动化可行性 | ✅ 可自动化 / ⚠️ 部分可自动化 / ❌ 不适合自动化 |
| 特殊注意 | 动态列表、异步加载、条件渲染等 |

## 页面清单与评估

### Tab 主页

| 页面 | 类型 | identifier 覆盖 | 可行性 | 备注 |
|------|------|-----------------|--------|------|
| CCMainTabView | Native | ✅ 4 Tab | ✅ | Tab 切换稳定 |
| CCHomeView | Native | ✅ 情绪按钮、打卡、AI 入口 | ✅ | 10 种情绪按钮全部覆盖 |
| CCTreeHoleView | Native | ✅ 发帖、列表、匿名切换 | ⚠️ | 列表动态加载，需等待 |
| CCHealingSpaceView | Native | ✅ 治愈动画、入口 | ✅ | Lottie 动画层已正确设置 allowsHitTesting(false) |
| CCProfileView | Native | ✅ 设置、会员、安全计划 | ✅ | — |

### 核心流程

| 页面 | 类型 | identifier 覆盖 | 可行性 | 备注 |
|------|------|-----------------|--------|------|
| CCWelcomeView | Native | ✅ 匿名入口、登录入口 | ✅ | — |
| CCLoginView | Native | ✅ 手机号、验证码、登录按钮 | ✅ | 含 `.disabled(isLoading)` |
| CCAIListenerCard | Native | ✅ 发送按钮、输入框 | ⚠️ | 真实 AI 接口，响应时间不确定 |
| CCEmotionDecoderView | Native | ✅ 输入框、解码按钮 | ✅ | — |
| CCVoiceCheckinView | Native | ✅ 录音、上传 | ⚠️ | 依赖麦克风权限 |

### 工具箱

| 页面 | 类型 | identifier 覆盖 | 可行性 | 备注 |
|------|------|-----------------|--------|------|
| CCCBTView | Native | ✅ 全部步骤控件 | ✅ | 多步骤流程，每步独立 identifier |
| CCBodyScanView | Native | ✅ 开始、暂停、跳过 | ✅ | — |
| CCGratitudeJournalView | Native | ✅ 日期、emoji、输入框、提交 | ✅ | — |
| CCValuesExplorerView | Native | ✅ 卡片、排序、反思 | ✅ | 多步骤 |
| CCBehavioralActivationView | Native | ✅ 活动列表、新增、评分 | ⚠️ | 评分浮层背景点击会误提交 |
| CCPMRView | Native | ✅ 开始、暂停、重置 | ✅ | — |
| CCCoursesView | Native | ✅ 课程列表 | ✅ | 动态列表 |
| CCCourseDetailView | Native | ✅ 进度 | ✅ | — |

### 社区与社交

| 页面 | 类型 | identifier 覆盖 | 可行性 | 备注 |
|------|------|-----------------|--------|------|
| CCResonanceView | Native | ✅ 列表、共鸣按钮 | ✅ | — |
| CCMutualAidGroupView | Native | ✅ 群组列表 | ✅ | — |
| CCEncourageChainView | Native | ✅ 鼓励链列表 | ✅ | — |
| CCEncourageDiscoverView | Native | ✅ 发现页卡片 | ⚠️ | ScrollView 内 onTapGesture |

### 个人中心

| 页面 | 类型 | identifier 覆盖 | 可行性 | 备注 |
|------|------|-----------------|--------|------|
| CCSettingsView | Native | ✅ 设置项列表 | ✅ | — |
| CCPrivacyView | Native | ✅ 隐私项 | ✅ | — |
| CCMemberCenterView | Native | ✅ 会员信息 | ✅ | — |
| CCPaymentConfirmSheet | Native | ✅ 确认/取消 | ⚠️ | 涉及真实支付 |
| CCExportDataView | Native | ✅ 导出格式、范围、确认 | ✅ | — |
| CCDeleteAccountView | Native | ✅ 删除确认 | ⚠️ | 涉及真实删除 |
| CCFeedbackView | Native | ✅ 反馈类型、内容、提交 | ✅ | — |
| CCSafetyPlanView | Native | ✅ 安全计划 | ✅ | — |
| CCCrisisHotlineView | Native | ✅ 热线列表 | ✅ | — |
| CCProfessionalResourceView | Native | ✅ 资源列表 | ✅ | — |
| CCDataManagementView | Native | ✅ 数据管理操作 | ⚠️ | 涉及真实数据操作 |

### 成长与记录

| 页面 | 类型 | identifier 覆盖 | 可行性 | 备注 |
|------|------|-----------------|--------|------|
| CCJournalView | Native | ✅ 日历、列表 | ⚠️ | ScrollView 内 onTapGesture |
| CCTrendsView | Native | ✅ 趋势图 | ✅ | — |
| CCGrowthReportView | Native | ✅ 报告内容 | ⚠️ | 分享功能未实现 |
| CCThankYouLetterView | Native | ✅ 信件列表 | ✅ | — |

## 不适合自动化的场景

| 场景 | 原因 | 替代方案 |
|------|------|----------|
| 真实支付流程 | 涉及资金安全 | 沙箱支付 + 接口 mock |
| 真实删除账号 | 不可逆操作 | 仅验证 UI 流程，不执行最终确认 |
| 语音录音 | 依赖硬件权限 | Mock 音频数据 |
| 分享功能 | 系统级 UI（UIActivityViewController） | 验证按钮存在，不验证分享面板 |
| 推送通知 | 系统级 | 通过接口验证推送状态 |

## 维护说明

- 每次新增页面后，更新此文档
- 每次 UI 重构后，重新评估可行性
- 标注为 ⚠️ 的页面是自动化维护重点

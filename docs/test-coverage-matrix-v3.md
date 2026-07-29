# 绪安 v3.0 测试用例覆盖矩阵（SSOT）

> 📅 生成日期： 2026-07-29 | 阶段： agent-device MVP 验证能力（阶段 A）
>
> **依据来源（三方交叉核对）**：
> 1. 《绪安v3.0产品需求文档-深度打磨版》（PRD，EARS 规范）
> 2. Ardot 设计资料库页面截图（home / ai_chat / safety / profile）+《设计标注总览》
> 3. 代码实测：a11y identifier 全量清单 + 导航路由表 + CI #279 失败现场 UI hierarchy
>
> **核心结论**：测试用例的编写依据已切换为「设计图 + PRD」为准，代码仅用于核对真实可达路径。
> 此前 11 个用例基于代码反推或凭空假设 identifier，已全部按设计/PRD 重写或删除。

---

## 一、PRD P0（MVP）功能覆盖矩阵

| PRD 功能（条款） | 实现状态 | 真实可达路径 | 覆盖用例 | 覆盖度 |
|---|---|---|---|---|
| 每日情绪意图 4 选项（6.1.1，ER-INT-001） | ✅ 首页意图卡 `home_need_<标题>` | 首页直出 | CC:`test_Home_NeedButtonsAreButtons` | ✅ 存在性 |
| 今日心情打卡 → 成功页 + AI 回应（5.2，6.1.3） | ✅ `home_checkin_button` → CCCheckinResultView | 首页直出 | V3:`test_EmotionCheckinFlow`（本批修正为硬断言） | ✅ 主流程 |
| 语音情绪日记（6.1.2，ER-002~011） | ⚠️ 页面存在，**入口在 AI 倾听官页输入栏**（`ai_listen` 图标），非 PRD 所述打卡流程内 | 首页→AI倾听官→语音图标 | V3:`test_VoiceCheckinFlow`（本批修正路径） | ⚠️ 仅可达性，录音交互未覆盖（模拟器无麦克风） |
| AI 共情回应 - 输入发送（6.1.3，ER-013） | ✅ CCAIListenerCard `ai_listener_input`/`ai_listener_send` | 首页「和绪安聊聊」`home_ai_listener_entry` | CC:`test_Home_NavigateToAIListener`；V3:`testAIListenerInput`（本批修正 identifier） | ✅ 输入链路 |
| AI 回应时效 ≤2s / 有帮助反馈（ER-013/014/015） | ⚠️ 未验证 | — | 无 | ❌ 缺口（建议性能断言+反馈按钮用例） |
| 情绪解码（6.2.1，ER-023） | ✅ 情绪探索卡 `home_emotion_explore` → 解码页 | 首页直出 | CC:`test_Home_NavigateToEmotionDecoder`；V3:`testHomeExploreEntriesExist`（本批修正） | ✅ 导航 |
| 稳情计划（6.2.2，ER-030~038） | ✅ 首页稳情计划卡（当前为静态展示） | 首页直出 | 视觉回归：`testVisual_StablePlan` | ⚠️ 仅视觉，练习步骤/评分交互未覆盖 |
| 共鸣墙浏览与发布入口（6.3.1，ER-039/041） | ✅ `resonance_compose_fab`、卡片列表 | Tab 直出 | CC:`test_Resonance_NotAloneBanner`、`test_Resonance_FABButton` | ✅ 存在性 |
| 共鸣互动-长按/双击发送共鸣（5.4，ER-042） | ✅ `resonance_detail_resonate` | 共鸣墙→详情 | 无手势用例 | ❌ 缺口（长按手势可测） |
| 鼓励链（6.3.2，ER-050/051） | ✅ `encourage_chain_input`/`encourage_chain_relay` | 共鸣墙联动/我的善意 | 无 | ❌ 缺口（建议补 1 个接力用例） |
| 危机关键词检测 + 热线弹出（6.4，PRD 安全基线） | ✅ AI 倾听官本地关键词检测 → `ai_listener_crisis_hotline` + 安全计划入口 | 危机触发式（设计如此） | V3:`testCrisisHotlineTriggeredByKeywords`、`testSafetyPlanAccessible`（本批新增，按 PRD 触发路径写） | ✅ 触发链路 |
| 情绪标签纠错机制（P0，6.1.4 表内） | ❓ 未发现实现入口 | — | 无 | ❌ **疑似实现缺失，待产品/研发确认** |
| 今日暖心内容位（P0） | ✅ 首页静态卡 | 首页直出 | 视觉回归覆盖 | ⚠️ 仅视觉 |
| 情绪探索轮播（P0） | ✅ 单卡片（非轮播） | 首页直出 | V3:`testHomeExploreEntriesExist` | ⚠️ 实现为单卡，**与 PRD「3-5 篇轮播」不符，待确认** |
| 共鸣墙精选内容位（P0） | ❓ 未见精选标识 | — | 无 | ❌ 待确认 |
| 治愈音频内容位（P0） | ✅ `healing_audio_<标题>` | 治愈空间 Tab | CC:`test_Healing_AudioCardsAreButtons`；V3:`testHealingSpaceMeditationVisible`（本批修正） | ✅ 存在性 |

---

## 二、本批修正的不准确用例（11 个）

依据：设计图裁决入口位置 + 代码实测真实 identifier + CI #279 失败现场证据。

| 用例 | 原假设（错误） | 修正后依据 | 处理 |
|---|---|---|---|
| CC `test_Home_NavigateToAIListener` | `ai_listener_input` 是 textView | CI #279 UI hierarchy 实测为 **TextField** 类型 | 改查询类型 |
| CC `test_Login_PhoneInputIsTextField` | 用户卡片必跳登录页 | 深层根因：匿名登录自举使 `user` 恒非 nil，跳登录分支实际不可达（缺陷 B1）；测试改为 `-UITEST_SHOW_LOGIN` hook 直达验证登录页渲染 | 重写 |
| V3 `test_LoginPage_IdentifiersExist` | 同上 | 同上 | 重写 |
| V3 `testHomeExploreEntriesExist` | 首页有 `home_resonance_entry` | 设计图首页只有「情绪探索」内容位（`home_emotion_explore`）→ 情绪解码页 | 重写硬断言 |
| V3 `testNavigateToHealingFromHome` | 首页有 `home_healing_entry` | 设计图治愈空间是 **Tab**（设计名「治愈」/实现名「治愈空间」） | 重写为 Tab 路径 |
| V3 `testAIListenerInput` | 首页直查 `ai_chat_input` | `ai_chat_input` 属死页面 AIChatView；真实页是 CCAIListenerCard | 重写完整链路 |
| V3 `testHealingSpaceMeditationVisible` | 查 `toolbox_*` | toolbox 属死页面；治愈空间真实 id 为 `meditation_session_*`/`healing_audio_*`/`healing_breathing_button` | 重写 |
| V3 `testGrowthArchiveAccessible` | 个人中心直查 `growth_archive_report` | 该 id 在档案页内部；入口是个人中心「治愈记录」行 | 重写 |
| V3 `testSafetyPlanAccessible`/`test_SafetyPlanFlow`/`test_CrisisHotlineFlow`/`testProfessionalResourcesNavigate` | 个人中心有 `profile_safety_plan` | PRD 6.4：安全守护是**危机触发式**入口（AI 倾听官页发危机关键词后出现） | 合并重写为 2 个触发式用例 |
| V3 `test_ToolboxEntryFlow` | 首页有 `home_toolbox_entry` | v3.0 设计以治愈空间替代工具箱；CCToolboxView 无入口 | 重写为治愈空间呼吸训练 |
| V3 `test_VoiceCheckinFlow` | 首页有 `home_voice_checkin_entry` | 真实入口在 AI 倾听官页输入栏（`ai_listen` 图标） | 重写 |
| V3 `test_EmotionCheckinFlow` | 断言恒真（emotion_ 按钮或任意导航栏） | PRD 5.2 + CCCheckinResultView 实测文案 | 改硬断言「今日已打卡」「绪安的回应」 |

---

## 三、实现缺口与缺陷（建议创建事项）

### 🔴 缺陷（测试发现的真实 Bug）

| # | 缺陷 | 根因 | 建议处理 |
|---|---|---|---|
| B1 | **个人中心「点击登录」入口实际不可达**：游客（匿名）状态下用户卡片不显示「点击登录」徽章，点击也不跳登录页 | 匿名登录自举：`CCTokenProvider.refreshToken()` 在无 refresh token 时自动匿名登录 → 联网下 `fetchProfile` 总会成功 → `viewModel.user` 恒非 nil → `if user == nil { navigate(.login) }` 分支成为死代码（CI #279/#280 失败现场证实：卡片显示「匿名用户」） | 产品确认：匿名用户是否应显示「点击登录」并允许升级正式账号？若是，`user == nil` 判断需改为「匿名或未登录」 |
| B2 | **Welcome 页「已有账号登录」按钮不导航登录页**，仅置 `hasSeenWelcome` 进游客主页 | `CCWelcomeView` 按钮 action 只改状态 | 产品确认文案与行为（PRD 5.1 新用户流程含登录步骤） |

### 🟡 死页面（导航图无入口）

| 页面 | 状态 | PRD 依据 | 建议 |
|---|---|---|---|
| **AIChatView**（完整多轮对话页，`ai_chat_input`） | 导航图无任何入口 | PRD 5.3 AI 对话流程（10 轮上下文/三级分层） | 确认接入导航 or 废弃 |
| **CCProfessionalResourceView**（专业求助资源，`pro_resource_*`） | 导航图无任何入口 | PRD 6.2.1 ER-027 / 6.4 专业求助资源 | 确认入口位置（个人中心？解码结果页？） |
| **CCToolboxView**（CBT/PMR/身体扫描/感恩日记等 6 个子工具） | 导航图无任何入口 | PRD 6.2.5 CBT 自助工坊（P2） | v3.0 设计用治愈空间替代，确认是否废弃 |

> 登录页渲染验证已改用 `-UITEST_SHOW_LOGIN` 测试 hook 直达（test-only 分支，不影响生产逻辑）。

## 四、PRD 与实现差异（待产品确认）

1. **打卡流程不一致**：PRD 5.2 = 选意图 → 语音/文字 → AI 回应；当前实现 = 一键打卡直达成功页（语音在 AI 倾听官页内）。
2. **情绪探索为单卡片**，PRD 要求 3-5 篇轮播。
3. **命名冲突**：情绪解码页 navigationTitle 是「情绪地图」，与 PRD 6.3.4「情绪地图（P1，地理分布）」重名，建议改名避免歧义。
4. **Tab 命名**：设计图「共鸣/治愈/我的」 vs 实现「共鸣墙/治愈空间/个人中心」。
5. 设计资料库中「个人中心」截图实为共鸣详情页，**正确个人中心设计图待补传**。

## 五、测试用例编写依据（团队约定）

> 1. **入口与页面结构以最新设计图为准**；设计图没有的路径不得在测试中假设。
> 2. **功能行为以 PRD（EARS）为准**；触发式功能（如危机干预）按 PRD 触发条件编写。
> 3. **identifier 以代码实测清单为准**（本文档第二节已附核对过程）；查询元素类型以 CI 失败现场 UI hierarchy 为准。
> 4. 禁止 `if exists { XCTAssertTrue(true) }` 式假断言——查不到即失败，失败即信号。

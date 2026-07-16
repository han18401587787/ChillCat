# XCTest accessibilityIdentifier 全覆盖审计报告

> 生成时间：2025-07-17 | 分支：v3.0-dev | 提交：8243714

---

## 一、总体覆盖率

| 指标 | 数值 | 评估 |
|---|---|---|
| **View 文件总数** | 50 | — |
| **纯展示页（无控件）** | 11 | 无需 identifier |
| **有控件需补全的文件** | 39 | — |
| **已覆盖 identifier 的文件** | 14 / 39 | **36% 文件级** |
| **零 identifier 文件（待补全）** | **25 / 39** | **64% 未覆盖** |
| **可交互控件总数** | **~210** | 含 Button/TextField/Toggle/NavigationLink/onTapGesture |
| **已设置 identifier** | **78** | 含动态插值 |
| **控件级覆盖率** | **78 / ~210** | **约 37%** |

---

## 二、已覆盖页面（14 个文件，78 处 identifier）

| 文件 | 控件数 | ID数 | 覆盖率 | 覆盖要点 |
|---|---|---|---|---|
| CCSettingsView | ~24 | 18 | 75% | 账号信息/安全/密码/通知/勿扰/隐私/匿名/深色模式/版本/协议/FAQ/反馈/数据/注销/退出 |
| CCEmotionDecoderView | ~10 | 9 | 90% | 周期切换/雷达图/进度条×5/AI洞察标签×2 |
| CCLoginView | ~14 | 8 | 57% | 手机号/验证码/发送验证码/登录/微信/Apple/协议×2 |
| CCHomeView | ~12 | 6 | 50% | 头像/打卡/情绪探索/AI入口/温暖查看全部/需求卡片×n |
| CCResonanceDetailView | ~15 | 6 | 40% | 共鸣/鼓励/回复输入/表情/发送/帖子卡片 |
| CCPrivacyView | ~4 | 4 | 100% | 加密存储/匿名保护/数据删除/不出售 |
| CCTreeHoleView | ~9 | 3 | 33% | 发布按钮/共鸣按钮×n/快速模板 |
| CCTreeHolePostDetailView | ~6 | 3 | 50% | 共鸣按钮/回复输入/发送鼓励 |
| CCResonanceView | ~11 | 3 | 27% | 拥抱/跳过/FAB 发布 |
| CCMeditationView | ~6 | 3 | 50% | 冥想卡片×n/音频卡片×3/呼吸按钮 |
| CCMutualAidGroupView | ~6 | 3 | 50% | 分类筛选×n/小组卡片×n/加入按钮×n |
| CCEmotionDecodeResultView | ~4 | 2 | 50% | 继续对话/匿名分享 |
| CCProfileView | ~6 | 2 | 33% | 用户卡片/会员横幅 |
| CCMemberCenterView | ~5 | 3 | 60% | 权益网格×n/套餐卡片×n/购买记录 |
| **CCMainTabView** (Navigation) | ~5 | 5 | 100% | tab_首页/树洞/共鸣墙/治愈空间/个人中心 |

---

## 三、未覆盖页面（25 个文件，需补全）

### 🔴 P0 — 核心流程页面（6 个，约 44 个控件）

| 文件 | 控件数 | 关键遗漏控件 |
|---|---|---|
| **CCWelcomeView** | 1 | `匿名进入`、`已有账号登录` — 启动入口 |
| **CCSafetyPlanView** | 12 | `添加安抚策略`、`添加联系人`、`分享安全计划`、3 个 TextField |
| **CCVoiceCheckinView** | 12 | `按住说话…`、`正在聆听…`、`AI 正在理解…`、`添加标签…` TextField |
| **CCAIListenerCard** | 3 | `今天想和我说什么？`、`拨打心理援助热线`、聊天 TextField |
| **CCEncourageChainView** | 4 | `写下你的鼓励…` TextField、`写下你的鼓励，传递下去` |
| **CCDeleteAccountView** | 5 | `确认注销`、`我再想想，先不注销` |

### 🟡 P1 — 常用功能页面（9 个，约 22 个控件）

| 文件 | 控件数 | 关键遗漏控件 |
|---|---|---|
| **CCJournalView** | 4 | 年月切换、日期单元格、`有涂鸦` |
| **CCMeditationPlayerView** | 2 | `定时关闭`、播放控制 |
| **CCRainSoundView** | 5 | `雨声助眠`、`定时关闭`、15s 快进快退 |
| **CCGrowthArchiveView** | 1 | `查看完整报告`、`成就徽章` |
| **CCGrowthReportView** | 2 | `分享成长报告` |
| **CCToolboxView** | 1 | 工具卡片列表（CBT/感恩/行为激活等入口） |
| **CCExportDataView** | 3 | `导出格式`、`时间范围` |
| **CCFeedbackView** | 3 | `反馈类型`、`详细描述`、`提交反馈`、邮箱 TextField |
| **CCPaymentConfirmSheet** | 1 | 确认支付按钮 |

### 🟢 P2 — 工具箱子页面（7 个，约 17 个控件）

| 文件 | 控件数 | 关键遗漏控件 |
|---|---|---|
| **CCBehavioralActivationView** | 3 | 活动 TextField、活动完成 Toggle |
| **CCBodyScanView** | 2 | 扫描设置、区域切换 |
| **CCCBTView** | 3 | 情境 TextField、认知扭曲选择、情绪强度 |
| **CCGratitudeJournalView** | 3 | 好事 TextField×2、`记录今天的好事` |
| **CCValuesExplorerView** | 2 | 价值观选择、一致性评分 |
| **CCCoursesView** | 1 | 课程卡片 |
| **CCCourseDetailView** | 1 | 课程进度 |

### 🔵 P3 — 低频/辅助页面（3 个，约 4 个控件）

| 文件 | 控件数 | 关键遗漏控件 |
|---|---|---|
| **CCThankYouLetterView** | 2 | `去传递温暖` |
| **CCCrisisHotlineView** | 1 | 热线拨号按钮 |
| **CCProfessionalResourceView** | 1 | `我的安全计划` |
| **CCMyEncourageChainsView** | 1 | `查看详情` |

---

## 四、78 处 identifier 覆盖的功能点位明细

### TabBar（5 处）
`tab_首页` `tab_树洞` `tab_共鸣墙` `tab_治愈空间` `tab_个人中心`

### 首页 CCHomeView（6 处）
`home_avatar` `home_checkin_button` `home_emotion_explore` `home_ai_listener_entry` `home_warmth_view_all` `home_need_{title}`(动态)

### AI 对话 CCAIChatView（1 处）
`ai_chat_input`

### 情绪解码（11 处）
`decoder_period_本周` `decoder_period_本月` `decoder_period_switcher` `decoder_radar_chart` `decoder_radar_section` `decoder_progress_{label}`(×5动态) `decoder_progress_section` `decoder_ai_insight` `decoder_insight_improving` `decoder_insight_meditation` `decode_continue_chat` `decode_share_anonymous`

### 树洞（6 处）
`treehole_publish_button` `treehole_resonate_{id}`(动态) `treehole_quick_template` `treehole_detail_resonate` `treehole_detail_reply_input` `treehole_detail_send_reply`

### 共鸣墙（9 处）
`resonance_card_hug` `resonance_card_pass_{id}`(动态) `resonance_compose_fab` `resonance_detail_resonate` `resonance_detail_encourage` `resonance_detail_reply_input` `resonance_detail_emoji` `resonance_detail_send` `resonance_detail_post_card`

### 治愈空间（4 处）
`meditation_session_{title}`(动态) `healing_audio_{title}`(×3动态) `healing_breathing_button`

### 个人中心（2 处）
`profile_user_card` `profile_vip_banner`

### 登录（8 处）
`login_phone_field` `login_code_field` `login_send_code` `login_submit_button` `login_wechat` `login_apple` `login_user_agreement` `login_privacy_policy`

### 设置（18 处）
`settings_account_info` `settings_security` `settings_password` `settings_notifications` `settings_notifications_toggle` `settings_dnd` `settings_privacy` `settings_anonymous` `settings_dark_mode` `settings_dark_mode_toggle` `settings_version` `settings_user_agreement` `settings_privacy_policy` `settings_faq` `settings_feedback` `settings_data_management` `settings_delete_account` `settings_logout`

### 隐私（4 处）
`privacy_encryption` `privacy_anonymous` `privacy_data_deletion` `privacy_no_sale`

### 会员中心（3 处）
`member_privilege_{title}`(动态) `member_purchase_{name}`(动态) `member_purchase_history`

### 互助小组（3 处）
`mutual_aid_category_{name}`(动态) `mutual_aid_group_{id}`(动态) `mutual_aid_join_{id}`(动态)

---

## 五、结论与建议

### 诚实评估
- **78 处 identifier 不是"全覆盖"**，是约 **37% 控件级覆盖率**、**36% 文件级覆盖率**
- 已覆盖的是 **最高频的核心交互路径**：首页、TabBar、登录、设置、树洞/共鸣发布、情绪解码
- **25 个文件（64%）完全未覆盖**，涉及语音打卡、安全计划、AI 对话卡片、工具箱全部子页面、成长档案、鼓励链等

### 补全优先级建议

| 优先级 | 文件数 | 控件数 | 说明 |
|---|---|---|---|
| **P0（本次迭代）** | 6 | ~44 | WelcomeView / SafetyPlan / VoiceCheckin / AIListenerCard / EncourageChain / DeleteAccount |
| **P1（下迭代）** | 9 | ~22 | Journal / MeditationPlayer / RainSound / Growth / Toolbox / Export / Feedback / Payment |
| **P2（后续）** | 7 | ~17 | 工具箱全部子页面 (CBT/Gratitude/Behavioral/BodyScan/Values) + Courses |
| **P3（可选）** | 3 | ~4 | ThankYouLetter / CrisisHotline / ProfessionalResource |

### 建议
> 💡 当前阶段已完成核心流程覆盖，建议按 P0→P1→P2 分批补全，每批提交后同步更新测试代码中的中文文本匹配为 identifier 引用。不建议一次性全部补全，避免改动过大导致冲突。

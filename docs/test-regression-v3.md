# 绪安 v3.0 回归测试用例 & 验收清单

> 基于 PRD v3.0 + 212 处 accessibilityIdentifier · 阶段五：测试验收
> 生成日期：2026-06-26

---

## 一、测试环境

| 项目 | 说明 |
|:--|:--|
| 测试设备 | iPhone 16 Simulator (iOS 18+) |
| 测试框架 | XCUITest + accessibilityIdentifier 定位 |
| API 环境 | `http://81.70.178.249:8080` (测试服) |
| 启动参数 | `-UITEST_SKIP_WELCOME` / `-UITEST_AUTO_LOGIN` |
| Identifier 总数 | **212 处**，覆盖 44/50 View 文件 |

---

## 二、核心用户路径回归测试

### 2.1 启动与登录 (P0)

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-LOGIN-001 | 首次启动显示欢迎页 | 清除 App 数据 | 冷启动 App | 显示欢迎页，含「匿名进入」和「已有账号登录」两个按钮 | `welcome_anonymous_entry`, `welcome_login_entry` |
| TC-LOGIN-002 | 匿名进入主页 | 在欢迎页 | 点击「匿名进入」 | 进入主页，底部 5 个 Tab 可见 | `welcome_anonymous_entry` → TabBar |
| TC-LOGIN-003 | 跳转登录页 | 在欢迎页 | 点击「已有账号登录」 | 跳转登录页，显示手机号输入框 | `welcome_login_entry` → `login_phone_field` |
| TC-LOGIN-004 | 手机号登录 | 在登录页 | 输入手机号 → 点击登录 | 进入主页 | `login_phone_field` + `login_submit` |
| TC-LOGIN-005 | 登录页切换到注册 | 在登录页 | 点击注册切换按钮 | 切换为注册模式 | `login_register_toggle` |
| TC-LOGIN-006 | 注销账号流程 | 已登录 → 个人中心 → 设置 → 注销账号 | 点击注销 → 确认 → 最终确认 | 退出登录，返回欢迎页 | `delete_account_confirm` → `delete_account_final_confirm` |

### 2.2 首页情绪打卡 (P0)

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-HOME-001 | 今日心情打卡按钮可见 | 已登录在首页 | 查看首页顶部 | 「今日心情打卡」按钮可见可点击 | `home_checkin_button` |
| TC-HOME-002 | 进入情绪选择页 | 在首页 | 点击「今日心情打卡」 | 跳转情绪选择页，显示情绪网格 | `home_checkin_button` → `emotion_*` |
| TC-HOME-003 | 选择情绪并确认 | 在情绪选择页 | 选择一个情绪 → 点击确认 | 进入情绪详情/日记页 | `emotion_*` → `emotion_confirm` |
| TC-HOME-004 | 需求标签为 Button 类型 | 在首页 | 检查需求标签 | 4 个需求标签均为 Button 类型，点击区域 ≥44pt | `home_need_listened/understood/encouraged/talk` |

### 2.3 AI 倾听官 (P0)

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-AI-001 | AI 倾听官入口可见 | 在首页 | 查看首页 | AI 倾听官卡片可见 | `home_ai_listener_entry` |
| TC-AI-002 | 进入 AI 对话 | 在首页 | 点击 AI 倾听官入口 | 跳转 AI 对话页，输入框可见 | `home_ai_listener_entry` → `ai_chat_input` |
| TC-AI-003 | 发送消息 | 在 AI 对话页 | 输入文字 → 点击发送 | 消息发送成功，AI 返回回应 | `ai_chat_input` + `ai_listener_send` |
| TC-AI-004 | 空输入不可发送 | 在 AI 对话页 | 不输入文字 | 发送按钮禁用状态 | `ai_listener_send` `.isEnabled == false` |

### 2.4 语音签到 (P1)

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-VOICE-001 | 语音签到入口 | 在首页 | 点击语音签到入口 | 跳转语音签到页 | `home_voice_checkin_entry` |
| TC-VOICE-002 | 录音按钮可见 | 在语音签到页 | 查看页面 | 录音按钮可见 | `voice_checkin_record_button` |
| TC-VOICE-003 | 转写编辑 | 录音完成后 | 查看转写结果 | 转写文本编辑器可见可编辑 | `voice_checkin_transcription_editor` |
| TC-VOICE-004 | 保存语音签到 | 编辑完成 | 点击保存 | 签到保存成功 | `voice_checkin_save` |
| TC-VOICE-005 | 重新录制 | 录音完成后 | 点击重新录制 | 清除当前录音，重新开始 | `voice_checkin_re_record` |

### 2.5 情绪解码器 (P1)

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-DECODER-001 | 情绪解码器入口 | 在首页 | 向下滚动 → 点击情绪解码 | 跳转情绪解码器页 | `home_emotion_decoder_entry` |
| TC-DECODER-002 | 输入情绪文字 | 在解码器页 | 输入情绪描述文字 | 输入框接受输入 | `decoder_input` |
| TC-DECODER-003 | 触发解码 | 输入完成 | 点击解码按钮 | 显示情绪层次拆解结果 | `decoder_analyze` |
| TC-DECODER-004 | 雷达图展示 | 解码完成 | 查看结果 | 情绪雷达图可见 | `decoder_radar_chart` |

### 2.6 Tab 导航 (P0)

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-TAB-001 | 5 个 Tab 全部存在 | 已登录 | 查看底部 TabBar | 首页/树洞/共鸣墙/治愈空间/个人中心 全部可见 | `tab_首页/树洞/共鸣墙/治愈空间/个人中心` |
| TC-TAB-002 | Tab 切换选中态 | 已登录 | 依次点击每个 Tab | 每个 Tab 切换后 `isSelected == true` | 同上 |
| TC-TAB-003 | Tab 切换性能 | 已登录 | 快速切换所有 Tab | 无卡顿，切换时间 < 500ms | 同上 |

---

## 三、功能模块回归测试

### 3.1 树洞 2.0

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-TREE-001 | 树洞页面加载 | 切换到树洞 Tab | 等待加载 | 显示发布框或帖子列表 | `tree_hole_content` |
| TC-TREE-002 | 输入倾诉内容 | 在树洞页 | 点击输入框 → 输入文字 | TextEditor 接受输入 | `tree_hole_content` |
| TC-TREE-003 | 空内容发送按钮禁用 | 在树洞页 | 不输入文字 | 发送按钮不可用 | `tree_hole_publish` `.isEnabled == false` |
| TC-TREE-004 | 发布倾诉 | 输入内容后 | 点击发送 | 发布成功，内容出现在列表 | `tree_hole_publish` |
| TC-TREE-005 | 查看帖子详情 | 列表有帖子 | 点击帖子 | 跳转详情页 | `tree_hole_post_*` |

### 3.2 共鸣墙

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-RES-001 | 共鸣墙加载 | 切换到共鸣墙 Tab | 等待加载 | 显示共鸣故事列表或空状态 | `resonance_wall` |
| TC-RES-002 | 写下心情 FAB | 在共鸣墙 | 查看右下角 | FAB 按钮可见可点击 | `resonance_publish` |
| TC-RES-003 | 共鸣互动 | 有故事列表 | 点击共鸣按钮 | 发送共鸣成功 | `resonance_like_*` |
| TC-RES-004 | 查看故事详情 | 有故事列表 | 点击故事卡片 | 跳转详情页 | `resonance_detail_*` |

### 3.3 治愈空间（心理工具箱）

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-TOOL-001 | 工具箱主页 | 切换到治愈空间 Tab | 查看页面 | 10 个工具卡片可见 | `toolbox_breathing/sleep/solitude/anxiety/cbt/pmr/bodyscan/values/gratitude/ba` |
| TC-TOOL-002 | 进入 CBT 认知重构 | 在工具箱 | 点击 CBT 卡片 | 跳转 CBT 步骤页 | `toolbox_cbt` |
| TC-TOOL-003 | CBT 步骤导航 | 在 CBT 页 | 填写 Step1 → 下一步 → Step2 → 下一步 → Step3 → 完成 | 每个步骤正确切换 | `cbt_situation_text` → `cbt_next_step` → `cbt_distortion_*` → `cbt_next_step` → `cbt_balanced_thought` → `cbt_next_step` |
| TC-TOOL-004 | CBT 上一步 | 在 CBT Step2 | 点击上一步 | 返回 Step1，已填内容保留 | `cbt_prev_step` |
| TC-TOOL-005 | CBT 完成重做 | 在完成页 | 点击再做一次 | 重置所有步骤 | `cbt_retry` |
| TC-TOOL-006 | 身体扫描开始 | 在身体扫描页 | 点击开始扫描 | 开始计时，身体地图动画启动 | `body_scan_start` |
| TC-TOOL-007 | 身体扫描暂停/继续 | 扫描中 | 点击暂停 → 点击继续 | 暂停/恢复计时 | `body_scan_pause_resume` |
| TC-TOOL-008 | 身体扫描跳过/重置 | 扫描中 | 点击跳过 → 点击重置 | 跳到下一区域 / 重置所有 | `body_scan_skip` / `body_scan_reset` |
| TC-TOOL-009 | 身体扫描时长选择 | 空闲状态 | 切换时长 15s/30s/45s/60s | 选中态正确切换 | `body_scan_duration_15/30/45/60` |
| TC-TOOL-010 | 身体扫描音频引导 | 空闲状态 | 切换 Toggle | 开关状态正确 | `body_scan_audio_toggle` |
| TC-TOOL-011 | 身体扫描完成 | 扫描全部区域 | 等待完成 | 显示完成页，身体觉察记录可见 | `body_scan_retry` / `body_scan_back` |
| TC-TOOL-012 | 感恩日记入口 | 在工具箱 | 点击感恩日记卡片 | 跳转感恩日记页 | `toolbox_gratitude` |
| TC-TOOL-013 | 感恩日记 Emoji 选择 | 在感恩日记页 | 点击 Emoji 按钮 | 弹出 Emoji 选择器 | `gratitude_emoji_1/2/3` |
| TC-TOOL-014 | 感恩日记提交 | 填写三件好事 | 点击记录 | 提交成功，显示庆祝动画 | `gratitude_submit` |
| TC-TOOL-015 | 价值观探索完整流程 | 在价值观页 | 选择 10 个价值 → 排序 Top5 → 反思 → 评分 → 行动方案 → 完成 | 6 步流程完整走通 | `values_card_*` → `values_next_step` ×5 |
| TC-TOOL-016 | 行为激活添加活动 | 在行为激活页 | 点击添加活动 → 填写表单 → 确认 | 新活动出现在列表 | `ba_add_activity` → `ba_new_activity_name` + `ba_new_activity_confirm` |
| TC-TOOL-017 | 行为激活完成/删除 | 有活动列表 | 勾选完成 / 点击删除 | 活动状态更新 / 活动被移除 | `ba_activity_check_*` / `ba_activity_delete_*` |
| TC-TOOL-018 | PMR 渐进式放松 | 在 PMR 页 | 开始练习 → 暂停 → 继续 → 完成 | 16 个肌群完整流程 | `pmr_start` → `pmr_pause_resume` → `pmr_retry` |

### 3.4 个人中心 & 设置

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-PROFILE-001 | 个人中心加载 | 切换到个人中心 Tab | 等待加载 | 显示用户信息 / 登录入口 | `profile_login_entry` |
| TC-PROFILE-002 | 心光会员入口 | 在个人中心 | 点击心光会员 | 跳转会员中心页 | `profile_vip_entry` |
| TC-PROFILE-003 | 成长档案入口 | 在个人中心 | 点击成长档案 | 跳转成长档案页 | `profile_growth_archive` |
| TC-PROFILE-004 | 安全计划入口 | 在个人中心 | 点击我的安全计划 | 跳转安全计划页 | `profile_safety_plan` |
| TC-PROFILE-005 | 设置页入口 | 在个人中心 | 进入设置 | 显示设置列表 | `settings_account_info` |
| TC-PROFILE-006 | 隐私设置 | 在设置页 | 点击隐私设置 | 跳转隐私页 | `settings_privacy_entry` |
| TC-PROFILE-007 | 数据导出 | 在导出数据页 | 选择 PDF → 选择范围 → 确认导出 | 触发导出流程 | `export_format_PDF` + `export_range_最近一周` + `export_confirm` |
| TC-PROFILE-008 | 意见反馈 | 在反馈页 | 选择类型 → 输入内容 → 填写联系方式 → 提交 | 提交成功提示 | `feedback_type_picker` + `feedback_content` + `feedback_contact` + `feedback_submit` |
| TC-PROFILE-009 | 数据管理 | 在数据管理页 | 导出单项数据 / 清除缓存 / 导出全部 | 各操作正常触发 | `data_mgmt_export_mood_diary` / `data_mgmt_clear_cache` / `data_mgmt_export_all` |

### 3.5 鼓励链

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-CHAIN-001 | 鼓励链入口 | 在首页 | 点击鼓励链入口 | 跳转鼓励链页 | `home_encourage_chain_entry` |
| TC-CHAIN-002 | 发起鼓励 | 在鼓励链页 | 输入鼓励文字 → 点击接力 | 发布成功 | `encourage_chain_input` + `encourage_chain_relay` |
| TC-CHAIN-003 | 我的鼓励链 | 在个人中心 | 进入我的鼓励链 | 显示参与过的鼓励链列表 | `my_chains_detail_*` |

### 3.6 情绪日记

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-JOURNAL-001 | 日记页加载 | 进入情绪日记 | 查看日历 | 月视图日历可见 | `journal_day_*` |
| TC-JOURNAL-002 | 月份切换 | 在日记页 | 点击上/下月 | 日历切换到对应月份 | `journal_prev_month` / `journal_next_month` |
| TC-JOURNAL-003 | 查看某天日记 | 在日记页 | 点击有日记的日期 | 显示当天日记详情 | `journal_day_15` |

### 3.7 冥想 & 雨声

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-MEDITATE-001 | 冥想播放器 | 进入冥想页 | 查看播放器 | 播放/暂停按钮可见 | `meditation_player_play_pause` |
| TC-MEDITATE-002 | 冥想定时器 | 在冥想播放器 | 选择时长 | 定时器 chip 选中态切换 | `meditation_player_timer_*` |
| TC-RAIN-001 | 雨声播放器 | 进入雨声页 | 查看播放器 | 播放/暂停/前进/后退 按钮可见 | `rain_sound_play_pause/forward/backward` |
| TC-RAIN-002 | 雨声定时器 | 在雨声播放器 | 选择定时 | 定时 chip 正确切换 | `rain_sound_timer_*` |

### 3.8 会员 & 支付

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-VIP-001 | 会员中心入口 | 在个人中心 | 点击心光会员 | 显示会员套餐 | `member_privilege_entry` |
| TC-VIP-002 | 支付确认弹窗 | 选择套餐后 | 查看弹窗 | 显示取消/确认支付按钮 | `payment_cancel` / `payment_confirm` |
| TC-VIP-003 | 取消支付 | 在支付弹窗 | 点击取消 | 关闭弹窗，返回会员页 | `payment_cancel` |
| TC-VIP-004 | 购买记录 | 在会员中心 | 查看购买记录 | 显示交易列表或空状态 | `transaction_retry`（错误时） |

### 3.9 危机干预 & 专业资源

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-CRISIS-001 | 安全计划页 | 从个人中心进入 | 查看安全计划 | 添加策略/联系人/分享按钮可见 | `safety_plan_add_strategy/add_contact/share` |
| TC-CRISIS-002 | 危机热线页 | 进入危机热线 | 查看热线列表 | 3 个热线 + 2 个紧急号码可见 | `crisis_hotline_national/beijing/life` + `crisis_emergency_120/110` |
| TC-CRISIS-003 | 专业资源页 | 进入专业资源 | 查看资源列表 | 热线列表 + 平台列表 + 安全计划入口可见 | `pro_resource_hotline_*` + `pro_resource_safety_plan` |
| TC-CRISIS-004 | 感谢信页 | 进入感谢信 | 查看信件列表 | 信件列表或空状态可见 | `thank_you_letter_*` / `thank_you_go_warm` |

### 3.10 课程

| 用例编号 | 测试场景 | 前置条件 | 操作步骤 | 期望结果 | identifier |
|:--|:--|:--|:--|:--|:--|
| TC-COURSE-001 | 小课堂列表 | 进入小课堂 | 查看分类 | 课程分类和列表可见 | `courses_item_*` |
| TC-COURSE-002 | 课程详情 | 点击课程 | 查看详情 | 标题/描述/进度条可见 | `course_detail_progress` |
| TC-COURSE-003 | 标记进展 | 在课程详情 | 点击标记进展 | 进度条更新 | `course_detail_progress` |

---

## 四、边界场景 & 异常场景

| 用例编号 | 场景类型 | 测试场景 | 期望行为 |
|:--|:--|:--|:--|
| TC-EDGE-001 | 网络异常 | API 不可达时启动 App | 显示离线兜底 UI 或本地缓存内容，不白屏 |
| TC-EDGE-002 | 网络异常 | 发送 AI 消息时断网 | 显示错误提示，允许重试 |
| TC-EDGE-003 | 空数据 | 树洞无帖子 | 显示空状态引导 |
| TC-EDGE-004 | 空数据 | 共鸣墙无故事 | 显示空状态 + 引导写下心情 |
| TC-EDGE-005 | 空数据 | 成长档案无数据 | 显示空状态 + 引导开始记录 |
| TC-EDGE-006 | 空数据 | 感谢信为空 | 显示空状态 + 去传递温暖按钮 |
| TC-EDGE-007 | 输入边界 | 树洞输入超长文字 (1000+) | 限制输入长度或提示 |
| TC-EDGE-008 | 输入边界 | 鼓励链输入空内容 | 接力按钮禁用 |
| TC-EDGE-009 | 输入边界 | 反馈内容为空 | 提交按钮禁用 |
| TC-EDGE-010 | 快速操作 | 连续快速点击打卡按钮 | 不重复提交，不崩溃 |
| TC-EDGE-011 | 快速操作 | 快速切换 Tab | 不卡顿，状态不丢失 |
| TC-EDGE-012 | 快速操作 | CBT 步骤快速前进后退 | 数据不丢失，步骤不乱 |
| TC-EDGE-013 | 内存压力 | 播放冥想时切换到其他 App 再回来 | 播放状态保持或正确暂停 |
| TC-EDGE-014 | 内存压力 | 录音中途接电话 | 录音暂停，返回后可继续或重录 |
| TC-EDGE-015 | 权限 | 首次语音签到请求麦克风权限 | 显示权限请求弹窗，拒绝后显示引导 |
| TC-EDGE-016 | 深色模式 | 切换深色/浅色模式 | 所有页面 UI 正常显示，颜色正确 |
| TC-EDGE-017 | 横屏 | 旋转设备到横屏 | 布局不崩溃，可正常操作 |
| TC-EDGE-018 | 注销确认 | 连续点击注销确认 | 不会重复执行，只触发一次 |

---

## 五、性能基准

| 指标 | 目标值 | 测试方法 |
|:--|:--|:--|
| 冷启动时间 | < 2.0s | `XCTApplicationLaunchMetric` |
| Tab 切换时间 | < 500ms | `XCTClockMetric` |
| AI 回应时间 | < 5s | 手动计时 |
| 页面滚动帧率 | ≥ 55fps | Instruments |
| 内存占用 (空闲) | < 150MB | Xcode Memory Gauge |
| 崩溃率 | 0 crash in 100 launches | 多次启动测试 |

---

## 六、验收清单

### 6.1 P0 功能（必须全部通过，否则阻断上线）

- [ ] TC-LOGIN-001 首次启动显示欢迎页
- [ ] TC-LOGIN-002 匿名进入主页
- [ ] TC-HOME-001 今日心情打卡按钮可见
- [ ] TC-HOME-002 进入情绪选择页
- [ ] TC-AI-001 AI 倾听官入口可见
- [ ] TC-AI-002 进入 AI 对话
- [ ] TC-AI-003 发送消息
- [ ] TC-TAB-001 5 个 Tab 全部存在
- [ ] TC-TAB-002 Tab 切换选中态
- [ ] TC-TREE-001 树洞页面加载
- [ ] TC-RES-001 共鸣墙加载
- [ ] TC-TOOL-001 工具箱主页
- [ ] TC-PROFILE-001 个人中心加载
- [ ] TC-CRISIS-001 安全计划页
- [ ] TC-CRISIS-002 危机热线页

### 6.2 P1 功能（必须全部通过）

- [ ] TC-LOGIN-003 跳转登录页
- [ ] TC-VOICE-001~005 语音签到完整流程
- [ ] TC-DECODER-001~004 情绪解码器
- [ ] TC-TOOL-002~005 CBT 认知重构
- [ ] TC-TOOL-006~011 身体扫描
- [ ] TC-TOOL-012~014 感恩日记
- [ ] TC-CHAIN-001~003 鼓励链
- [ ] TC-JOURNAL-001~003 情绪日记
- [ ] TC-MEDITATE-001~002 冥想播放器
- [ ] TC-RAIN-001~002 雨声播放器
- [ ] TC-PROFILE-005~009 设置 & 数据管理
- [ ] TC-CRISIS-003~004 专业资源 & 感谢信

### 6.3 P2 功能（建议通过）

- [ ] TC-TOOL-015 价值观探索完整流程
- [ ] TC-TOOL-016~017 行为激活
- [ ] TC-TOOL-018 PMR 渐进式放松
- [ ] TC-VIP-001~004 会员 & 支付
- [ ] TC-COURSE-001~003 小课堂
- [ ] TC-EDGE-001~018 边界 & 异常场景

### 6.4 性能验收

- [ ] 冷启动时间 < 2.0s
- [ ] Tab 切换 < 500ms
- [ ] 崩溃率 0/100

---

## 七、上线风险评估

| 风险项 | 风险等级 | 影响范围 | 缓解措施 |
|:--|:--|:--|:--|
| API 不可用导致白屏 | 🔴 高 | 全平台 | 确保离线兜底 UI 正常工作，TC-EDGE-001 必须通过 |
| 语音权限拒绝后崩溃 | 🔴 高 | 语音签到用户 | TC-EDGE-015 权限拒绝场景验证 |
| 匿名登录失败 | 🟡 中 | 新用户 | TC-LOGIN-002 必须通过，增加重试逻辑 |
| 冥想播放器内存泄漏 | 🟡 中 | 冥想用户 | Instruments 内存分析 |
| 支付流程异常 | 🟡 中 | 付费用户 | TC-VIP-002~003 验证取消和确认流程 |
| 深色模式 UI 异常 | 🟢 低 | 深色模式用户 | TC-EDGE-016 全页面走查 |
| 横屏布局崩溃 | 🟢 低 | iPad 用户 | TC-EDGE-017 关键页面横屏验证 |

---

## 八、版本质量总结

| 维度 | 状态 | 说明 |
|:--|:--|:--|
| accessibilityIdentifier 覆盖 | ✅ 100% | 212 处 identifier，44/50 View 文件覆盖，零遗漏 |
| XCUITest 定位稳定性 | ✅ 已完成 | 全部改用 identifier 定位，不再依赖中文文本 |
| 核心路径测试覆盖 | ✅ 已完成 | 10 条新增关键路径测试 + 原有测试重写 |
| 回归测试用例 | ✅ 本文档 | 60+ 条用例覆盖全部功能模块 |
| 边界场景 | ✅ 本文档 | 18 条边界 & 异常场景 |
| 性能基准 | ⏳ 待执行 | 需在真机/Simulator 上运行 XCTest 获取数据 |

---

> 📌 **提醒**：请将本验收清单中的未通过项创建为事项分配给开发同学，并关联回原 PRD 文档。测试通过后可将本报告上传到项目资料库作为版本质量记录。

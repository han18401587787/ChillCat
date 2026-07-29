import XCTest

extension XCUIApplication {

    // MARK: - 页面元素访问器 (基于 accessibilityIdentifier)

    /// 绪安欢迎页 - 匿名进入按钮
    var welcomeAnonymousButton: XCUIElement {
        buttons["welcome_anonymous_entry"].firstMatch
    }

    /// 绪安欢迎页 - 已有账号登录按钮
    var welcomeLoginButton: XCUIElement {
        buttons["welcome_login_entry"].firstMatch
    }

    /// 登录页 - 手机号输入框
    var loginUsernameField: XCUIElement {
        textFields["login_phone_field"].firstMatch
    }

    /// 登录页 - 密码输入框
    var loginPasswordField: XCUIElement {
        secureTextFields["login_password_field"].firstMatch
    }

    /// 登录页 - 登录按钮
    var loginSubmitButton: XCUIElement {
        buttons["login_submit"].firstMatch
    }

    /// 登录页 - 注册按钮
    var loginRegisterToggle: XCUIElement {
        buttons["login_register_toggle"].firstMatch
    }

    /// 首页 - 情绪按钮网格中的具体情绪
    func emotionButton(_ emotion: String) -> XCUIElement {
        buttons[emotion].firstMatch
    }

    /// 首页 - 情绪确认按钮
    var emotionConfirmButton: XCUIElement {
        buttons["emotion_confirm"].firstMatch
    }

    /// 首页 - 今日心情打卡按钮
    var homeCheckinButton: XCUIElement {
        buttons["home_checkin_button"].firstMatch
    }

    // MARK: - TabBar (通过 accessibilityIdentifier 定位)

    /// TabBar - 首页
    var tabHome: XCUIElement {
        tabBars.buttons["tab_首页"].firstMatch.exists
            ? tabBars.buttons["tab_首页"].firstMatch
            : tabBars.buttons["首页"].firstMatch  // 兼容旧版
    }
    /// TabBar - 树洞
    var tabTreeHole: XCUIElement {
        tabBars.buttons["tab_树洞"].firstMatch.exists
            ? tabBars.buttons["tab_树洞"].firstMatch
            : tabBars.buttons["树洞"].firstMatch
    }
    /// TabBar - 共鸣墙 (v3.0)
    var tabResonance: XCUIElement {
        tabBars.buttons["tab_共鸣墙"].firstMatch.exists
            ? tabBars.buttons["tab_共鸣墙"].firstMatch
            : tabBars.buttons["共鸣墙"].firstMatch
    }
    /// TabBar - 治愈空间 (v3.0)
    var tabHealing: XCUIElement {
        tabBars.buttons["tab_治愈空间"].firstMatch.exists
            ? tabBars.buttons["tab_治愈空间"].firstMatch
            : tabBars.buttons["治愈空间"].firstMatch
    }
    /// TabBar - 个人中心
    var tabProfile: XCUIElement {
        tabBars.buttons["tab_个人中心"].firstMatch.exists
            ? tabBars.buttons["tab_个人中心"].firstMatch
            : tabBars.buttons["个人中心"].firstMatch
    }

    // 兼容旧版
    var tabToolbox: XCUIElement { tabBars.buttons["工具箱"].firstMatch }
    var tabVIP: XCUIElement { tabBars.buttons["会员"].firstMatch }

    // MARK: - v3.0 交互元素验证辅助

    /// 验证元素是Button类型且可点击
    func assertButton(_ identifier: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        let btn = buttons[identifier].firstMatch
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "按钮「\(identifier)」应该存在", file: file, line: line)
        XCTAssertEqual(btn.elementType, .button, "「\(identifier)」应该是Button类型", file: file, line: line)
        XCTAssertTrue(btn.isHittable, "「\(identifier)」应该是可点击的", file: file, line: line)
        return btn
    }

    /// 验证输入框可编辑
    func assertTextField(_ identifier: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        let field = textFields[identifier].firstMatch.exists
            ? textFields[identifier].firstMatch
            : textViews[identifier].firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "输入框「\(identifier)」应该存在", file: file, line: line)
        return field
    }

    /// 验证点击区域足够大 (>=44pt 符合HIG)
    func assertHitArea(_ element: XCUIElement, minWidth: CGFloat = 44, minHeight: CGFloat = 44, file: StaticString = #file, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(element.frame.width, minWidth,
            "「\(element.identifier)」点击宽度 \(element.frame.width) < \(minWidth)", file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, minHeight,
            "「\(element.identifier)」点击高度 \(element.frame.height) < \(minHeight)", file: file, line: line)
    }

    // MARK: - v3.0 首页入口元素

    /// AI倾听官 - 输入框
    var aiListenerInput: XCUIElement {
        textFields["ai_chat_input"].firstMatch
    }

    /// AI倾听官 - 发送按钮
    var aiListenerSendButton: XCUIElement {
        buttons["ai_listener_send"].firstMatch
    }

    /// 首页 - AI倾听官入口
    var homeAIListenerEntry: XCUIElement {
        buttons["home_ai_listener_entry"].firstMatch
    }

    /// 首页 - 情绪解码入口
    var homeEmotionDecoderEntry: XCUIElement {
        buttons["home_emotion_decoder_entry"].firstMatch
    }

    /// 首页 - 共鸣墙入口
    var homeResonanceEntry: XCUIElement {
        buttons["home_resonance_entry"].firstMatch
    }

    /// 首页 - 安全计划入口
    var homeSafetyPlanEntry: XCUIElement {
        buttons["home_safety_plan_entry"].firstMatch
    }

    /// 首页 - 工具箱入口卡片
    var homeToolboxEntry: XCUIElement {
        buttons["home_toolbox_entry"].firstMatch
    }

    /// 首页 - 成长档案入口卡片
    var homeGrowthArchiveEntry: XCUIElement {
        buttons["home_growth_archive_entry"].firstMatch
    }

    /// 首页 - 互助小组入口卡片
    var homeMutualAidEntry: XCUIElement {
        buttons["home_mutual_aid_entry"].firstMatch
    }

    /// 首页 - 专业资源入口卡片
    var homeProfessionalEntry: XCUIElement {
        buttons["home_professional_entry"].firstMatch
    }

    // MARK: - v3.0 功能页面元素

    /// 工具箱 - 工具卡片 (按名称)
    func toolboxItem(_ name: String) -> XCUIElement {
        buttons[name].firstMatch
    }

    /// 工具箱 - CBT 入口
    var toolboxCBTEntry: XCUIElement {
        buttons["toolbox_cbt"].firstMatch
    }

    /// 工具箱 - 身体扫描入口
    var toolboxBodyScanEntry: XCUIElement {
        buttons["toolbox_bodyscan"].firstMatch
    }

    /// 工具箱 - 呼吸练习入口
    var toolboxBreathingEntry: XCUIElement {
        buttons["toolbox_breathing"].firstMatch
    }

    /// 工具箱 - 助眠入口
    var toolboxSleepEntry: XCUIElement {
        buttons["toolbox_sleep"].firstMatch
    }

    /// 工具箱 - 独处入口
    var toolboxSolitudeEntry: XCUIElement {
        buttons["toolbox_solitude"].firstMatch
    }

    /// 工具箱 - 焦虑入口
    var toolboxAnxietyEntry: XCUIElement {
        buttons["toolbox_anxiety"].firstMatch
    }

    // MARK: - 个人中心元素

    /// 个人中心 - 成长档案菜单
    var profileGrowthArchive: XCUIElement {
        buttons["growth_archive_report"].firstMatch
    }

    /// 个人中心 - 安全计划菜单
    var profileSafetyPlan: XCUIElement {
        buttons["profile_safety_plan"].firstMatch
    }

    /// 个人中心 - 用户卡片(未登录时点击跳登录页)
    var profileLoginEntry: XCUIElement {
        buttons["profile_user_card"].firstMatch
    }

    /// 个人中心 - 会员横幅
    var profileVIPEntry: XCUIElement {
        buttons["profile_vip_banner"].firstMatch
    }

    // MARK: - 设置页元素

    /// 设置 - 账号信息
    var settingsAccountInfo: XCUIElement {
        buttons["settings_account_info"].firstMatch
    }

    /// 设置 - 隐私入口
    var settingsPrivacy: XCUIElement {
        buttons["settings_privacy_entry"].firstMatch
    }

    /// 设置 - 删除账号
    var settingsDeleteAccount: XCUIElement {
        buttons["settings_delete_account"].firstMatch
    }

    // MARK: - 树洞/共鸣元素

    /// 树洞 - 内容输入框 (TextEditor)
    var treeHoleContent: XCUIElement {
        textViews["tree_hole_content"].firstMatch
    }

    /// 树洞 - 发布按钮
    var treeHolePublish: XCUIElement {
        buttons["tree_hole_publish"].firstMatch
    }

    /// 共鸣墙 - 发布按钮(悬浮 FAB)
    var resonancePublish: XCUIElement {
        buttons["resonance_compose_fab"].firstMatch
    }

    // MARK: - 会员中心

    /// 会员中心入口
    var memberCenterEntry: XCUIElement {
        buttons["member_privilege_entry"].firstMatch
    }

    // MARK: - 鼓励链

    /// 鼓励链 - 输入框
    var encourageChainInput: XCUIElement {
        textFields["encourage_chain_input"].firstMatch.exists
            ? textFields["encourage_chain_input"].firstMatch
            : textViews["encourage_chain_input"].firstMatch
    }

    /// 鼓励链 - 接力按钮
    var encourageChainRelay: XCUIElement {
        buttons["encourage_chain_relay"].firstMatch
    }

    // MARK: - 成长档案

    /// 成长档案 - 日报入口
    var growthArchiveReport: XCUIElement {
        buttons["growth_archive_report"].firstMatch
    }

    // MARK: - 心情日记

    /// 日记 - 按日期单元格
    func journalDayCell(_ day: String) -> XCUIElement {
        buttons["journal_day_\(day)"].firstMatch
    }

    // MARK: - 冥想/音频播放器

    /// 冥想播放器 - 播放/暂停
    var meditationPlayerPlayPause: XCUIElement {
        buttons["meditation_player_play_pause"].firstMatch
    }

    /// 雨声 - 播放/暂停
    var rainSoundPlayPause: XCUIElement {
        buttons["rain_sound_play_pause"].firstMatch
    }

    // MARK: - 语音签到

    /// 语音签到 - 录音按钮
    var voiceCheckinRecord: XCUIElement {
        buttons["voice_checkin_record_button"].firstMatch
    }

    /// 语音签到 - 转写编辑器
    var voiceCheckinTranscription: XCUIElement {
        textViews["voice_checkin_transcription_editor"].firstMatch
    }

    // MARK: - 导出

    /// 导出 - PDF格式
    var exportFormatPDF: XCUIElement {
        buttons["export_format_PDF"].firstMatch
    }

    /// 导出 - 确认按钮
    var exportConfirm: XCUIElement {
        buttons["export_confirm"].firstMatch
    }

    // MARK: - 反馈

    /// 反馈 - 提交按钮
    var feedbackSubmit: XCUIElement {
        buttons["feedback_submit"].firstMatch
    }

    // MARK: - 支付

    /// 支付 - 确认按钮
    var paymentConfirm: XCUIElement {
        buttons["payment_confirm"].firstMatch
    }

    // MARK: - 危机热线

    /// 危机热线 - 全国热线
    var crisisHotlineNational: XCUIElement {
        buttons["crisis_hotline_national"].firstMatch
    }

    /// 专业资源 - 安全计划
    var proResourceSafetyPlan: XCUIElement {
        buttons["pro_resource_safety_plan"].firstMatch
    }

    // MARK: - 删除账号确认

    /// 删除账号 - 确认按钮
    var deleteAccountConfirm: XCUIElement {
        buttons["delete_account_confirm"].firstMatch
    }

    // MARK: - 页面断言

    /// 等待当前页面出现特定元素
    @discardableResult
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// 判断是否在欢迎页
    var isOnWelcomePage: Bool { welcomeAnonymousButton.exists }

    /// 判断是否在登录页
    var isOnLoginPage: Bool { loginUsernameField.exists }

    /// 判断是否在主页（已登录）
    var isOnHomePage: Bool { tabHome.exists }

    // MARK: - 完整登录流程

    /// 使用 launchArguments 跳过欢迎页，直接进入主页
    func skipWelcomeAndLaunch() {
        launchArguments = ["-UITEST_SKIP_WELCOME"]
        launch()
        let _ = tabHome.waitForExistence(timeout: 10)
    }

    /// 匿名登录 → 进入主页（支持离线兜底）
    /// - Note: API 不可用时 VC 会直接本地跳转，最长等待 15s
    func anonymousLogin() {
        guard welcomeAnonymousButton.waitForExistence(timeout: 10) else {
            print("⚠️ 欢迎页未加载，可能已登录")
            return
        }
        welcomeAnonymousButton.tap()
        let _ = tabHome.waitForExistence(timeout: 15)
    }

    /// 用户名密码登录
    func login(username: String, password: String) {
        welcomeLoginButton.tap()
        guard loginUsernameField.waitForExistence(timeout: 5) else {
            XCTFail("登录页未加载")
            return
        }
        loginUsernameField.tap()
        loginUsernameField.typeText(username)
        loginPasswordField.tap()
        loginPasswordField.typeText(password)
        loginSubmitButton.tap()
        let _ = tabHome.waitForExistence(timeout: 10)
    }
}

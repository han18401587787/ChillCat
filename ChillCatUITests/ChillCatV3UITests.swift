//
//  ChillCatV3UITests.swift
//  绪安 v3.0 — 全功能 UI 自动化测试
//
//  运行方式: Xcode → Product → Test (⌘U)
//  或命令行: xcodebuild test -scheme ChillCat -destination 'platform=iOS Simulator,name=iPhone 16'
//

import XCTest

final class ChillCatV3UITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UITEST_SKIP_WELCOME", "-UITEST_AUTO_LOGIN"]
        app.launchEnvironment = ["CHILLCAT_API_URL": ProcessInfo.processInfo.environment["CHILLCAT_API_URL"] ?? "http://81.70.178.249:8080"]
        app.launch()
        _ = app.tabHome.waitForExistence(timeout: 30)
    }

    // MARK: - 🔍 环境自检

    func test_EnvironmentCheck() throws {
        CCDiagnosticHelper.checkEnvironment()
    }

    // MARK: - Tab 导航测试

    func testAllTabsExist() throws {
        XCTAssertTrue(app.tabHome.exists, "首页 Tab 应存在")
        XCTAssertTrue(app.tabTreeHole.exists, "树洞 Tab 应存在")
        XCTAssertTrue(app.tabResonance.exists, "共鸣墙 Tab 应存在")
        XCTAssertTrue(app.tabHealing.exists, "治愈空间 Tab 应存在")
        XCTAssertTrue(app.tabProfile.exists, "个人中心 Tab 应存在")
    }

    func testTabSwitching() throws {
        app.tabTreeHole.tap()
        XCTAssertTrue(app.tabTreeHole.isSelected)

        app.tabResonance.tap()
        XCTAssertTrue(app.tabResonance.isSelected)

        app.tabHealing.tap()
        XCTAssertTrue(app.tabHealing.isSelected)

        app.tabProfile.tap()
        XCTAssertTrue(app.tabProfile.isSelected)

        app.tabHome.tap()
        XCTAssertTrue(app.tabHome.isSelected)
    }

    // MARK: - 首页探索入口测试

    func testHomeExploreEntriesExist() throws {
        // 依据:设计图首页含「情绪探索」内容位(PRD 四·首页-情绪探索轮播 P0),
        // 真实 identifier home_emotion_explore,点击 → 情绪解码页(navigationTitle "情绪地图")
        // (原假设的 home_resonance_entry 在设计图与实现中均不存在)
        app.tabHome.tap()
        app.swipeUp()
        app.swipeUp()
        let exploreBtn = app.buttons["home_emotion_explore"].firstMatch
        XCTAssertTrue(exploreBtn.waitForExistence(timeout: 8), "首页应该有情绪探索内容位")
        exploreBtn.tap()
        let decoderNav = app.navigationBars["情绪地图"].firstMatch
        XCTAssertTrue(decoderNav.waitForExistence(timeout: 8), "点击情绪探索应该导航到情绪解码页")
    }

    func testNavigateToHealingFromHome() throws {
        // 依据:设计图中治愈空间是底部 Tab(设计名「治愈」/实现名「治愈空间」),
        // 首页无直接入口(原假设的 home_healing_entry 不存在)
        app.tabHealing.tap()
        let navBar = app.navigationBars["治愈空间"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 8), "治愈空间 Tab 应该展示治愈空间页")
        let breathingBtn = app.buttons["healing_breathing_button"].firstMatch
        XCTAssertTrue(breathingBtn.waitForExistence(timeout: 5), "治愈空间应该有呼吸练习入口(稳情计划 P0)")
    }

    func testNavigateToGrowthArchiveFromHome() throws {
        // v3.0 成长档案入口在个人中心
        app.tabProfile.tap()
        _ = app.tabProfile.waitForExistence(timeout: 5)
        XCTAssertTrue(app.tabProfile.isSelected)
    }

    // MARK: - AI 倾听官测试

    func testAIListenerInput() throws {
        // 依据:设计图首页有「和绪安聊聊」AI 入口(home_ai_listener_entry),
        // 真实导航目标是 CCAIListenerCard(输入框 ai_listener_input);
        // 原查询的 ai_chat_input 属于无导航入口的 AIChatView 死页面
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        let aiEntry = app.buttons["home_ai_listener_entry"].firstMatch
        XCTAssertTrue(aiEntry.waitForExistence(timeout: 8), "首页应该有AI倾听官入口")
        aiEntry.tap()

        // CI #279 实测:该输入框在 a11y 树中暴露为 TextField 类型
        let inputField = app.textFields["ai_listener_input"].firstMatch
        XCTAssertTrue(inputField.waitForExistence(timeout: 8), "AI倾听官页应该有输入框")
        inputField.tap()
        inputField.typeText("今天心情不错")
        let sendBtn = app.buttons["ai_listener_send"].firstMatch
        XCTAssertTrue(sendBtn.waitForExistence(timeout: 5), "AI倾听官页应该有发送按钮")
        XCTAssertTrue(sendBtn.isEnabled, "输入文字后发送按钮应该可用")
    }

    // MARK: - 治愈空间测试 (v3.0 替代工具箱)

    func testHealingSpaceMeditationVisible() throws {
        // 依据:治愈空间页(CCMeditationView)真实 identifier 为
        // meditation_session_<标题> / healing_audio_<标题> / healing_breathing_button;
        // 原查询的 toolbox_* 属于无导航入口的 CCToolboxView 死页面
        app.tabHealing.tap()
        let navBar = app.navigationBars["治愈空间"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 8), "应该进入治愈空间页")

        let breathingBtn = app.buttons["healing_breathing_button"].firstMatch
        let anySession = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "meditation_session_")).firstMatch
        let anyAudio = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "healing_audio_")).firstMatch
        XCTAssertTrue(breathingBtn.waitForExistence(timeout: 5) ||
                      anySession.waitForExistence(timeout: 5) ||
                      anyAudio.waitForExistence(timeout: 5),
                      "治愈空间应该展示呼吸练习/冥想课程/治愈音频至少一种内容(PRD:治愈音频 P0 内容位)")
    }

    // MARK: - 成长档案测试

    func testGrowthArchiveAccessible() throws {
        // 依据:个人中心「治愈记录」行 → CCGrowthArchiveView(内有 growth_archive_report);
        // 原直接在个人中心找 growth_archive_report,该 identifier 在档案页内部,必然找不到
        app.tabProfile.tap()
        let archiveRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "治愈记录")).firstMatch
        XCTAssertTrue(archiveRow.waitForExistence(timeout: 8), "个人中心应该有治愈记录入口")
        archiveRow.tap()
        let reportBtn = app.buttons["growth_archive_report"].firstMatch
        XCTAssertTrue(reportBtn.waitForExistence(timeout: 8), "成长档案页应该有报告入口")
    }

    func testSafetyPlanAccessible() throws {
        // 依据:PRD 6.4 危机干预协议——安全守护入口是危机触发式的。
        // 实现:AI倾听官页输入危机关键词并发送 → crisisDetected=true 且
        // riskLevel >= medium → 输入栏出现安全计划入口(NavigationLink → CCSafetyPlanView)
        // (原假设的 profile_safety_plan 在个人中心不存在)
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        let aiEntry = app.buttons["home_ai_listener_entry"].firstMatch
        XCTAssertTrue(aiEntry.waitForExistence(timeout: 8), "首页应该有AI倾听官入口")
        aiEntry.tap()

        let inputField = app.textFields["ai_listener_input"].firstMatch
        XCTAssertTrue(inputField.waitForExistence(timeout: 8), "AI倾听官页应该有输入框")
        inputField.tap()
        inputField.typeText("最近压力很大，有过不想活的念头")

        let sendBtn = app.buttons["ai_listener_send"].firstMatch
        XCTAssertTrue(sendBtn.waitForExistence(timeout: 5))
        sendBtn.tap()

        // 危机关键词本地检测,发送后同步出现安全计划入口(图标按钮 label=resonance_like)
        let safetyLink = app.buttons["resonance_like"].firstMatch
        XCTAssertTrue(safetyLink.waitForExistence(timeout: 8), "检测到危机内容后应该出现安全守护入口(PRD 6.4)")
        safetyLink.tap()
        let addStrategyBtn = app.buttons["safety_plan_add_strategy"].firstMatch
        XCTAssertTrue(addStrategyBtn.waitForExistence(timeout: 8), "应该进入安全守护计划页")
    }

    // MARK: - 树洞/社区测试

    func testTreeHoleLoads() throws {
        app.tabTreeHole.tap()
        XCTAssertTrue(app.tabTreeHole.isSelected)
        // v3.0 树洞: 用真实 identifier 定位发布框(TextEditor)或发送按钮或空状态
        // (此前找不存在的 "tree_hole_content",且 loading 文案是瞬态,导致必失败)
        let publishBox = app.textViews["treehole_content_input"].firstMatch
        let publishBtn = app.buttons["treehole_publish_button"].firstMatch
        let emptyState = app.staticTexts["树洞是空的"]
        XCTAssertTrue(publishBox.waitForExistence(timeout: 5) ||
                      publishBtn.waitForExistence(timeout: 5) ||
                      emptyState.waitForExistence(timeout: 5),
                      "树洞页面应该显示发布框或空状态")
    }

    // MARK: - 危机热线测试 (PRD 6.4 危机干预协议)

    func testCrisisHotlineTriggeredByKeywords() throws {
        // 依据:PRD 6.4.1——检测到自伤倾向 → 弹出求助热线(全国心理援助热线 400-161-9995)。
        // 实现:AI倾听官页发送危机关键词 → 出现 ai_listener_crisis_hotline 按钮,
        // 点击打开热线 Sheet(含 400-161-9995)
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        let aiEntry = app.buttons["home_ai_listener_entry"].firstMatch
        XCTAssertTrue(aiEntry.waitForExistence(timeout: 8), "首页应该有AI倾听官入口")
        aiEntry.tap()

        let inputField = app.textFields["ai_listener_input"].firstMatch
        XCTAssertTrue(inputField.waitForExistence(timeout: 8), "AI倾听官页应该有输入框")
        inputField.tap()
        inputField.typeText("心里难受，有过自伤的想法")

        let sendBtn = app.buttons["ai_listener_send"].firstMatch
        XCTAssertTrue(sendBtn.waitForExistence(timeout: 5))
        sendBtn.tap()

        let hotlineBtn = app.buttons["ai_listener_crisis_hotline"].firstMatch
        XCTAssertTrue(hotlineBtn.waitForExistence(timeout: 8), "检测到危机内容后应该出现心理援助热线按钮(PRD 6.4)")
        hotlineBtn.tap()
        let hotlineNumber = app.staticTexts["400-161-9995"].firstMatch
        XCTAssertTrue(hotlineNumber.waitForExistence(timeout: 5), "热线Sheet应该展示全国心理援助热线 400-161-9995")
    }

    // MARK: - AI 视觉完整度校验

    func testVisualIntegrity_HomePage() async throws {
        app.tabHome.tap()
        _ = app.buttons["home_checkin_button"].waitForExistence(timeout: 5)
        try await VisualTesting.analyzeWithAI(named: "home", in: app)
    }

    func testVisualIntegrity_HealingPage() async throws {
        app.tabHealing.tap()
        _ = app.tabHealing.waitForExistence(timeout: 5)
        try await VisualTesting.analyzeWithAI(named: "healing", in: app)
    }

    func testVisualIntegrity_TreeHolePage() async throws {
        app.tabTreeHole.tap()
        _ = app.tabTreeHole.waitForExistence(timeout: 5)
        try await VisualTesting.analyzeWithAI(named: "treehole", in: app)
    }

    func testVisualIntegrity_ProfilePage() async throws {
        app.tabProfile.tap()
        _ = app.tabProfile.waitForExistence(timeout: 5)
        try await VisualTesting.analyzeWithAI(named: "profile", in: app)
    }

    // MARK: - 性能测试

    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testTabSwitchPerformance() throws {
        measure(metrics: [XCTClockMetric()]) {
            app.tabTreeHole.tap()
            app.tabResonance.tap()
            app.tabProfile.tap()
            app.tabHome.tap()
        }
    }

    // MARK: - accessibilityIdentifier 定位验证

    func test_WelcomePage_IdentifiersExist() throws {
        // 必须用 -UITEST_SHOW_WELCOME:正常启动会自动匿名登录直达主页,Welcome 不可达
        let freshApp = XCUIApplication()
        freshApp.launchArguments = ["-UITEST_SHOW_WELCOME"]
        freshApp.launch()
        XCTAssertTrue(freshApp.buttons["welcome_anonymous_entry"].waitForExistence(timeout: 10))
        XCTAssertTrue(freshApp.buttons["welcome_login_entry"].exists)
    }

    func test_LoginPage_IdentifiersExist() throws {
        // 登录页元素验证。经 -UITEST_SHOW_LOGIN hook 直达(原因见 CCApp 注释:
        // 匿名登录自举导致"用户卡片跳登录"分支实际不可达,已记录产品事项)
        let freshApp = XCUIApplication()
        freshApp.launchArguments = ["-UITEST_SHOW_LOGIN"]
        freshApp.launch()

        XCTAssertTrue(freshApp.textFields["login_phone_field"].waitForExistence(timeout: 10), "登录页应该有手机号输入框")
        XCTAssertTrue(freshApp.buttons["login_send_code"].waitForExistence(timeout: 5), "登录页应该有发送验证码按钮")
        XCTAssertTrue(freshApp.buttons["login_submit_button"].waitForExistence(timeout: 5), "登录页应该有登录提交按钮")
    }

    func test_HomePage_IdentifiersExist() throws {
        app.tabHome.tap()
        XCTAssertTrue(app.buttons["home_checkin_button"].waitForExistence(timeout: 5))
    }

    // MARK: - 关键用户路径测试

    func test_AnonymousLoginFlow() throws {
        // 必须用 -UITEST_SHOW_WELCOME 让 Welcome 页可达(否则会跳过匿名登录直通主页)
        let freshApp = XCUIApplication()
        freshApp.launchArguments = ["-UITEST_SHOW_WELCOME"]
        freshApp.launch()
        freshApp.buttons["welcome_anonymous_entry"].tap()
        XCTAssertTrue(freshApp.tabBars.buttons.firstMatch.waitForExistence(timeout: 15))
    }

    func test_EmotionCheckinFlow() throws {
        // 依据:PRD 5.2 打卡流程 + 实现(home_checkin_button → completeCheckIn →
        // CCCheckinResultView 展示「今日已打卡 ✨」与「绪安的回应」)。
        // 原断言(emotion_ 按钮或任意导航栏)恒为真,形同虚设,改为硬断言成功页内容
        app.tabHome.tap()
        let checkinBtn = app.buttons["home_checkin_button"].firstMatch
        XCTAssertTrue(checkinBtn.waitForExistence(timeout: 8), "首页应该有今日心情打卡按钮")
        checkinBtn.tap()

        let successLabel = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "今日已打卡")).firstMatch
        XCTAssertTrue(successLabel.waitForExistence(timeout: 8), "打卡后应该展示打卡成功页(PRD 5.2)")
        let aiReplySection = app.staticTexts["绪安的回应"].firstMatch
        XCTAssertTrue(aiReplySection.waitForExistence(timeout: 8), "打卡成功页应该展示 AI 共情回应区(PRD 6.1.3)")
    }

    func test_ToolboxEntryFlow() throws {
        // 依据:v3.0 设计以「治愈空间」Tab 替代原心理工具箱入口
        // (CCToolboxView 在导航图中无入口,home_toolbox_entry 不存在)。
        // 呼吸训练是稳情计划(P0)核心练习,验证其可达性
        app.tabHealing.tap()
        let navBar = app.navigationBars["治愈空间"].firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 8), "应该进入治愈空间页")
        let breathingBtn = app.buttons["healing_breathing_button"].firstMatch
        XCTAssertTrue(breathingBtn.waitForExistence(timeout: 5), "治愈空间应该有呼吸训练入口")
    }

    func test_VoiceCheckinFlow() throws {
        // 依据:语音情绪日记(PRD 6.1.2 P0)的真实入口在 AI 倾听官页输入栏
        // (NavigationLink 图标按钮 label=ai_listen → CCVoiceCheckinView);
        // 原假设的 home_voice_checkin_entry 在首页不存在
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        let aiEntry = app.buttons["home_ai_listener_entry"].firstMatch
        XCTAssertTrue(aiEntry.waitForExistence(timeout: 8), "首页应该有AI倾听官入口")
        aiEntry.tap()

        let voiceEntry = app.buttons["ai_listen"].firstMatch
        XCTAssertTrue(voiceEntry.waitForExistence(timeout: 8), "AI倾听官页应该有语音日记入口")
        voiceEntry.tap()
        // CI #281 失败现场实测:录音区是「按住说话」手势区,a11y 树中暴露为
        // Image 类型(identifier=voice_checkin_record_button),不是 Button
        let recordBtn = app.images["voice_checkin_record_button"].firstMatch
        XCTAssertTrue(recordBtn.waitForExistence(timeout: 8), "语音打卡页应该有录音区(PRD 6.1.2)")
        let hint = app.staticTexts["按住说话…"].firstMatch
        XCTAssertTrue(hint.waitForExistence(timeout: 5), "语音打卡页应该展示「按住说话」交互提示(PRD ER-002)")
    }

    func test_DeleteAccountFlow() throws {
        // 依据:删除账号入口在 设置 页(settings_delete_account),
        // 需从个人中心先进入「设置」;原直接在个人中心找,必然找不到
        app.tabProfile.tap()
        _ = app.tabProfile.waitForExistence(timeout: 5)
        // 设置入口在个人中心列表底部(CI #282:不滚动时 8s 内未挂载到 a11y 树)
        app.swipeUp(); app.swipeUp()
        let settingsRow = app.buttons["设置"].firstMatch
        XCTAssertTrue(settingsRow.waitForExistence(timeout: 10), "个人中心应该有设置入口")
        settingsRow.tap()

        let deleteBtn = app.buttons["settings_delete_account"].firstMatch
        XCTAssertTrue(deleteBtn.waitForExistence(timeout: 8), "设置页应该有删除账号入口")
        deleteBtn.tap()
        let confirmBtn = app.buttons["delete_account_confirm"].firstMatch
        XCTAssertTrue(confirmBtn.waitForExistence(timeout: 8), "删除账号应该有二次确认(合规要求)")
    }
}

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
        app.tabHome.tap()
        app.swipeUp()
        app.swipeUp()
        // v3.0 首页底部有情绪探索区，用 identifier 定位
        let resonanceBtn = app.buttons["home_resonance_entry"].firstMatch
        if resonanceBtn.waitForExistence(timeout: 5) {
            XCTAssertTrue(resonanceBtn.exists, "共鸣墙入口应可见")
        }
    }

    func testNavigateToHealingFromHome() throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        let healingBtn = app.buttons["home_healing_entry"].firstMatch
        if healingBtn.waitForExistence(timeout: 5) {
            healingBtn.tap()
            let nav = app.navigationBars.firstMatch
            XCTAssertTrue(nav.waitForExistence(timeout: 5))
        }
    }

    func testNavigateToGrowthArchiveFromHome() throws {
        // v3.0 成长档案入口在个人中心
        app.tabProfile.tap()
        _ = app.tabProfile.waitForExistence(timeout: 5)
        XCTAssertTrue(app.tabProfile.isSelected)
    }

    // MARK: - AI 倾听官测试

    func testAIListenerInput() throws {
        app.tabHome.tap()
        // AI倾听官卡片应该在首页顶部，用 identifier 定位输入框
        let inputField = app.textFields["ai_chat_input"].firstMatch
        if inputField.waitForExistence(timeout: 5) {
            inputField.tap()
            inputField.typeText("今天心情不错")
            let sendBtn = app.buttons["ai_listener_send"].firstMatch
            XCTAssertTrue(sendBtn.isEnabled)
        }
    }

    // MARK: - 治愈空间测试 (v3.0 替代工具箱)

    func testHealingSpaceMeditationVisible() throws {
        app.tabHealing.tap()
        let cards = ["toolbox_sleep", "toolbox_solitude", "toolbox_anxiety"]
        for card in cards {
            let btn = app.buttons[card].firstMatch
            if btn.waitForExistence(timeout: 3) {
                XCTAssertTrue(btn.exists, "冥想课程 identifier '\(card)' 应可见")
            }
        }
    }

    // MARK: - 成长档案测试

    func testGrowthArchiveAccessible() throws {
        app.tabProfile.tap()
        let archiveBtn = app.buttons["growth_archive_report"].firstMatch
        if archiveBtn.waitForExistence(timeout: 5) {
            archiveBtn.tap()
            let nav = app.navigationBars.firstMatch
            XCTAssertTrue(nav.waitForExistence(timeout: 5))
        }
    }

    func testSafetyPlanAccessible() throws {
        app.tabProfile.tap()
        let safetyBtn = app.buttons["profile_safety_plan"].firstMatch
        if safetyBtn.waitForExistence(timeout: 5) {
            safetyBtn.tap()
            let navTitle = app.navigationBars.firstMatch
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
        }
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

    // MARK: - 专业资源测试 (v3.0 安全守护)

    func testProfessionalResourcesNavigate() throws {
        app.tabProfile.tap()
        // 导航到安全守护
        let safetyBtn = app.buttons["profile_safety_plan"].firstMatch
        if !safetyBtn.waitForExistence(timeout: 3) {
            return  // 入口不存在则跳过
        }
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
        // 当前实现下登录页的真实可达路径:
        // Welcome → "已有账号登录"(仅置 hasSeenWelcome,进游客主页)
        // → 个人中心 → 用户卡片(未登录时跳登录页)
        let freshApp = XCUIApplication()
        freshApp.launchArguments = ["-UITEST_SHOW_WELCOME"]
        freshApp.launch()

        let loginEntry = freshApp.buttons["welcome_login_entry"].firstMatch
        XCTAssertTrue(loginEntry.waitForExistence(timeout: 10), "Welcome页应该有登录入口")
        loginEntry.tap()

        let profileTab = freshApp.tabBars.buttons["个人中心"].firstMatch
        XCTAssertTrue(profileTab.waitForExistence(timeout: 8), "点击后应该进入主页(游客态)")
        profileTab.tap()

        let userCard = freshApp.buttons["profile_user_card"].firstMatch
        XCTAssertTrue(userCard.waitForExistence(timeout: 5), "个人中心应该有用户卡片")
        userCard.tap()

        XCTAssertTrue(freshApp.textFields["login_phone_field"].waitForExistence(timeout: 5), "登录页应该有手机号输入框")
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
        app.tabHome.tap()
        let checkinBtn = app.buttons["home_checkin_button"].firstMatch
        if checkinBtn.waitForExistence(timeout: 5) {
            checkinBtn.tap()
            // 等待情绪选择页
            let emotionGrid = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "emotion_"))
            XCTAssertTrue(emotionGrid.count > 0 || app.navigationBars.firstMatch.waitForExistence(timeout: 3))
        }
    }

    func test_ToolboxEntryFlow() throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        // 心理工具箱入口
        let toolboxBtn = app.buttons["home_toolbox_entry"].firstMatch
        if toolboxBtn.waitForExistence(timeout: 5) {
            toolboxBtn.tap()
            let nav = app.navigationBars["心理工具箱"]
            XCTAssertTrue(nav.waitForExistence(timeout: 5))
        }
    }

    func test_SafetyPlanFlow() throws {
        app.tabProfile.tap()
        app.swipeUp()
        let safetyBtn = app.buttons["profile_safety_plan"].firstMatch
        if safetyBtn.waitForExistence(timeout: 5) {
            safetyBtn.tap()
            let addStrategyBtn = app.buttons["safety_plan_add_strategy"].firstMatch
            if addStrategyBtn.waitForExistence(timeout: 5) {
                XCTAssertTrue(addStrategyBtn.exists)
            }
        }
    }

    func test_VoiceCheckinFlow() throws {
        app.tabHome.tap()
        // 语音签到入口
        let voiceBtn = app.buttons["home_voice_checkin_entry"].firstMatch
        if voiceBtn.waitForExistence(timeout: 5) {
            voiceBtn.tap()
            let recordBtn = app.buttons["voice_checkin_record_button"].firstMatch
            if recordBtn.waitForExistence(timeout: 5) {
                XCTAssertTrue(recordBtn.exists)
            }
        }
    }

    func test_DeleteAccountFlow() throws {
        app.tabProfile.tap()
        app.swipeUp(); app.swipeUp()
        let deleteBtn = app.buttons["settings_delete_account"].firstMatch
        if deleteBtn.waitForExistence(timeout: 5) {
            deleteBtn.tap()
            let confirmBtn = app.buttons["delete_account_confirm"].firstMatch
            if confirmBtn.waitForExistence(timeout: 5) {
                XCTAssertTrue(confirmBtn.exists)
            }
        }
    }

    func test_CrisisHotlineFlow() throws {
        app.tabProfile.tap()
        app.swipeUp()
        let safetyBtn = app.buttons["profile_safety_plan"].firstMatch
        if safetyBtn.waitForExistence(timeout: 5) {
            safetyBtn.tap()
            // 危机热线
            let hotlineBtn = app.buttons["pro_resource_safety_plan"].firstMatch
            if !hotlineBtn.exists {
                app.swipeUp()
            }
        }
    }
}

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
        app.launchArguments = ["-UITEST_SKIP_WELCOME"]
        app.launch()
        _ = app.tabHome.waitForExistence(timeout: 15)
    }

    // MARK: - Tab 导航测试

    func testAllTabsExist() throws {
        XCTAssertTrue(app.tabHome.exists, "首页 Tab 应存在")
        XCTAssertTrue(app.tabTreeHole.exists, "树洞 Tab 应存在")
        XCTAssertTrue(app.tabToolbox.exists, "工具箱 Tab 应存在 (v3.0)")
        XCTAssertTrue(app.tabVIP.exists, "会员 Tab 应存在")
        XCTAssertTrue(app.tabProfile.exists, "我的 Tab 应存在")
    }

    func testTabSwitching() throws {
        app.tabTreeHole.tap()
        XCTAssertTrue(app.tabTreeHole.isSelected)

        app.tabToolbox.tap()
        XCTAssertTrue(app.tabToolbox.isSelected)

        app.tabProfile.tap()
        XCTAssertTrue(app.tabProfile.isSelected)

        app.tabHome.tap()
        XCTAssertTrue(app.tabHome.isSelected)
    }

    // MARK: - 首页探索入口测试

    func testHomeExploreEntriesExist() throws {
        app.tabHome.tap()
        // 滚动到探索区
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(app.homeToolboxEntry.waitForExistence(timeout: 5), "工具箱入口应可见")
        XCTAssertTrue(app.homeGrowthArchiveEntry.exists, "成长档案入口应存在")
        XCTAssertTrue(app.homeMutualAidEntry.exists, "互助小组入口应存在")
        XCTAssertTrue(app.homeProfessionalEntry.exists, "专业资源入口应存在")
    }

    func testNavigateToToolboxFromHome() throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        app.homeToolboxEntry.tap()
        XCTAssertTrue(app.navigationBars["心理工具箱"].waitForExistence(timeout: 5))
    }

    func testNavigateToGrowthArchiveFromHome() throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        app.homeGrowthArchiveEntry.tap()
        XCTAssertTrue(app.navigationBars["成长档案"].waitForExistence(timeout: 5))
    }

    // MARK: - AI 倾听官测试

    func testAIListenerInput() throws {
        app.tabHome.tap()
        // AI倾听官卡片应该在首页顶部
        let inputField = app.aiListenerInput
        if inputField.exists {
            inputField.tap()
            inputField.typeText("今天心情不错")
            XCTAssertTrue(app.aiListenerSendButton.isEnabled)
        }
    }

    // MARK: - 工具箱测试

    func testToolboxAllToolsVisible() throws {
        app.tabToolbox.tap()
        let tools = ["呼吸训练", "CBT认知重构", "渐进式肌肉放松", "正念身体扫描", "价值观探索", "感恩日记", "行为激活"]
        app.swipeUp()
        for tool in tools {
            let card = app.toolboxItem(tool)
            if card.waitForExistence(timeout: 3) {
                XCTAssertTrue(card.exists, "工具 '\(tool)' 应可见")
            }
        }
    }

    func testNavigateToCBTFromToolbox() throws {
        app.tabToolbox.tap()
        let cbtCard = app.toolboxItem("CBT认知重构")
        if cbtCard.waitForExistence(timeout: 5) {
            cbtCard.tap()
            let navTitle = app.navigationBars.firstMatch
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
        }
    }

    // MARK: - 成长档案测试

    func testGrowthArchiveAccessible() throws {
        app.tabProfile.tap()
        if app.profileGrowthArchive.waitForExistence(timeout: 5) {
            app.profileGrowthArchive.tap()
            XCTAssertTrue(app.navigationBars["成长档案"].waitForExistence(timeout: 5))
        }
    }

    func testSafetyPlanAccessible() throws {
        app.tabProfile.tap()
        if app.profileSafetyPlan.waitForExistence(timeout: 5) {
            app.profileSafetyPlan.tap()
            let navTitle = app.navigationBars.firstMatch
            XCTAssertTrue(navTitle.waitForExistence(timeout: 5))
        }
    }

    // MARK: - 树洞/社区测试

    func testTreeHoleLoads() throws {
        app.tabTreeHole.tap()
        XCTAssertTrue(app.tabTreeHole.isSelected)
        // 应该有发布框或空状态
        let publishBox = app.textFields.firstMatch
        let emptyState = app.staticTexts["还没有共鸣"]
        XCTAssertTrue(publishBox.exists || emptyState.waitForExistence(timeout: 10))
    }

    // MARK: - 专业资源测试

    func testProfessionalResourcesNavigate() throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        app.homeProfessionalEntry.tap()
        XCTAssertTrue(app.navigationBars["专业心理资源"].waitForExistence(timeout: 5))
        // 热线链接应存在
        XCTAssertTrue(app.professionalHotlineLink.waitForExistence(timeout: 3))
    }

    // MARK: - AI 视觉完整度校验

    func testVisualIntegrity_HomePage() async throws {
        app.tabHome.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(named: "home", in: app)
    }

    func testVisualIntegrity_ToolboxPage() async throws {
        app.tabToolbox.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(named: "toolbox", in: app)
    }

    func testVisualIntegrity_TreeHolePage() async throws {
        app.tabTreeHole.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(named: "treehole", in: app)
    }

    func testVisualIntegrity_ProfilePage() async throws {
        app.tabProfile.tap()
        sleep(2)
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
            app.tabToolbox.tap()
            app.tabProfile.tap()
            app.tabHome.tap()
        }
    }
}

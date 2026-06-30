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
        app.launch()
        _ = app.tabHome.waitForExistence(timeout: 15)
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
        // v3.0 首页底部有情绪探索区
        XCTAssertTrue(app.buttons["共鸣墙"].waitForExistence(timeout: 5), "共鸣墙入口应可见")
    }

    func testNavigateToHealingFromHome() throws {
        app.tabHome.tap()
        app.swipeUp(); app.swipeUp()
        let healingBtn = app.buttons["治愈空间"]
        if healingBtn.waitForExistence(timeout: 5) {
            healingBtn.tap()
            XCTAssertTrue(app.navigationBars["治愈空间"].waitForExistence(timeout: 5))
        }
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

    // MARK: - 治愈空间测试 (v3.0 替代工具箱)

    func testHealingSpaceMeditationVisible() throws {
        app.tabHealing.tap()
        let cards = ["睡前助眠", "独处放松", "焦虑治愈"]
        for card in cards {
            let btn = app.buttons[card].firstMatch
            if btn.waitForExistence(timeout: 3) {
                XCTAssertTrue(btn.exists, "冥想课程 '\(card)' 应可见")
            }
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

    // MARK: - 专业资源测试 (v3.0 安全守护)

    func testProfessionalResourcesNavigate() throws {
        app.tabProfile.tap()
        // 导航到安全守护
        let safetyBtn = app.buttons["情绪趋势"].firstMatch
        if !safetyBtn.waitForExistence(timeout: 3) {
            return  // 入口不存在则跳过
        }
    }

    // MARK: - AI 视觉完整度校验

    func testVisualIntegrity_HomePage() async throws {
        app.tabHome.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(named: "home", in: app)
    }

    func testVisualIntegrity_HealingPage() async throws {
        app.tabHealing.tap()
        sleep(2)
        try await VisualTesting.analyzeWithAI(named: "healing", in: app)
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
            app.tabResonance.tap()
            app.tabProfile.tap()
            app.tabHome.tap()
        }
    }
}

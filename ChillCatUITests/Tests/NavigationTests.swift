import XCTest

/// Tab导航 & 页面跳转测试
final class NavigationTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.skipWelcomeAndLaunch()
    }

    func test_allFourTabs_exist() {
        XCTAssertTrue(app.tabHome.exists)
        XCTAssertTrue(app.tabTreeHole.exists)
        XCTAssertTrue(app.tabVIP.exists)
        XCTAssertTrue(app.tabProfile.exists)
    }

    func test_tabNavigation_switchesPages() {
        // 树洞
        app.tabTreeHole.tap()
        XCTAssertTrue(app.staticTexts["树洞"].waitForExistence(timeout: 3))

        // 会员
        app.tabVIP.tap()
        XCTAssertTrue(app.staticTexts["会员中心"].waitForExistence(timeout: 3))

        // 我的
        app.tabProfile.tap()
        XCTAssertTrue(app.staticTexts["我的"].waitForExistence(timeout: 3))

        // 回到首页
        app.tabHome.tap()
        XCTAssertTrue(app.staticTexts["现在是什么感受？"].waitForExistence(timeout: 3))
    }

    func test_homeExploreCards_navigateCorrectly() {
        // 滑动到探索区域
        app.swipeUp(); app.swipeUp(); app.swipeUp()

        // 测试日记入口
        let journalCard = app.buttons["情绪日记"].firstMatch
        if journalCard.waitForExistence(timeout: 3) {
            journalCard.tap()
            XCTAssertTrue(app.staticTexts["情绪日记"].waitForExistence(timeout: 3))
            app.navigationBars.buttons.firstMatch.tap() // 返回
        }
    }

    func test_profile_navigatesToVIP() {
        app.tabProfile.tap()
        let vipEntry = app.buttons["会员中心"].firstMatch
        if vipEntry.waitForExistence(timeout: 3) {
            vipEntry.tap()
            XCTAssertTrue(app.staticTexts["会员中心"].waitForExistence(timeout: 3))
        }
    }

    func test_profile_logout_returnsToWelcome() {
        app.tabProfile.tap()
        let logout = app.buttons["退出登录"].firstMatch
        if logout.waitForExistence(timeout: 3) {
            logout.tap()
            XCTAssertTrue(app.welcomeAnonymousButton.waitForExistence(timeout: 5))
        }
    }

    func test_visual_snapshot_allTabs() {
        let tabs: [(String, XCUIElement)] = [
            ("tab_home", app.tabHome),
            ("tab_treehole", app.tabTreeHole),
            ("tab_vip", app.tabVIP),
            ("tab_profile", app.tabProfile),
        ]
        for (name, tab) in tabs {
            tab.tap()
            sleep(2) // 等待渲染完成
            VisualTesting.compareWithBaseline(named: name, in: app)
        }
    }
}

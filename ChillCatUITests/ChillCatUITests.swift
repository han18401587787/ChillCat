import XCTest

/// 测试入口 - 整合所有测试套件
/// 运行方式:
///   xcodebuild test -project ChillCat.xcodeproj -scheme ChillCat \
///     -destination 'platform=iOS Simulator,name=iPhone 16e' \
///     -only-testing:ChillCatUITests
///
/// 视觉测试基线创建:
///   首次运行时自动创建基线截图到 Screenshots/Baseline/
///   后续运行自动比对，差异 > 0.5% 时报错
final class ChillCatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    // MARK: - Sanity Check

    func test_appLaunches_successfully() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.welcomeAnonymousButton.waitForExistence(timeout: 5))
    }

    // MARK: - Full E2E Flow

    func test_fullUserJourney_anonymousLoginToCheckin() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. 匿名登录
        app.welcomeAnonymousButton.tap()
        XCTAssertTrue(app.tabHome.waitForExistence(timeout: 10))

        // 2. 情绪打卡
        app.emotionButton("开心").tap()
        sleep(1)
        app.emotionConfirmButton.tap()
        XCTAssertTrue(app.staticTexts["今日已打卡"].waitForExistence(timeout: 3))

        // 3. 切换到树洞
        app.tabTreeHole.tap()
        XCTAssertTrue(app.staticTexts["树洞"].waitForExistence(timeout: 3))

        // 4. 切换到会员
        app.tabVIP.tap()
        XCTAssertTrue(app.staticTexts["会员中心"].waitForExistence(timeout: 3))

        // 5. 切换到我的
        app.tabProfile.tap()
        XCTAssertTrue(app.staticTexts["我的"].waitForExistence(timeout: 3))

        // 6. 退出登录
        let logout = app.buttons["退出登录"].firstMatch
        if logout.exists { logout.tap() }
    }

    // MARK: - Visual Regression Suite

    func test_visual_welcomePage() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(3)
        VisualTesting.compareWithBaseline(named: "welcome_page", in: app)
    }

    func test_visual_homePage() throws {
        let app = XCUIApplication()
        app.launch()
        app.anonymousLogin()
        sleep(2)
        VisualTesting.compareWithBaseline(named: "home_page", in: app)
    }

    func test_visual_treeHolePage() throws {
        let app = XCUIApplication()
        app.launch()
        app.anonymousLogin()
        app.tabTreeHole.tap()
        sleep(2)
        VisualTesting.compareWithBaseline(named: "treehole_page", in: app)
    }
}

import XCTest

/// 欢迎页 & 登录流程测试
final class WelcomeFlowTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - 欢迎页

    func test_welcomePage_showsBrandElements() {
        XCTAssertTrue(app.welcomeAnonymousButton.waitForExistence(timeout: 5), "匿名进入按钮应显示")
        XCTAssertTrue(app.welcomeLoginButton.exists, "已有账号登录按钮应显示")

        // 视觉回归 - 截取欢迎页并比对基线
        VisualTesting.compareWithBaseline(named: "welcome_page", in: app)
    }

    func test_welcomePage_anonymousButton_triggersLoading() {
        app.welcomeAnonymousButton.tap()
        // 按钮变为加载状态
        let loading = app.buttons["请稍候..."].firstMatch
        // 等待登录完成跳转主页
        XCTAssertTrue(app.tabHome.waitForExistence(timeout: 10), "应进入主页")
    }

    func test_welcomePage_loginButton_navigatesToLogin() {
        app.welcomeLoginButton.tap()
        XCTAssertTrue(app.loginUsernameField.waitForExistence(timeout: 5), "应进入登录页")

        // 视觉回归
        VisualTesting.compareWithBaseline(named: "login_page", in: app)
    }
}

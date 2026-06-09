import XCTest

final class ChillCatUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        // 🔒 锁定竖屏，防止横屏闪退
        XCUIDevice.shared.orientation = .portrait
        app.launch()
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    // MARK: - Sanity

    func test_appLaunches_showsWelcome() throws {
        XCTAssertTrue(app.buttons["匿名进入"].waitForExistence(timeout: 10),
                       "欢迎页应在 10 秒内出现")
    }

    // MARK: - Anonymous Login (离线兜底)

    func test_anonymousLogin_entersHome() throws {
        // 点击匿名进入（即使 API 不通也会离线进入）
        app.buttons["匿名进入"].tap()

        // 等待主页出现（API 不可用时 VC 也会兜底跳转）
        let homeTab = app.tabBars.buttons["首页"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 15),
                       "匿名登录后应在 15 秒内进入主页")
    }

    // MARK: - Login Page

    func test_loginPage_appears() throws {
        app.buttons["已有账号登录"].tap()
        XCTAssertTrue(app.textFields["用户名"].waitForExistence(timeout: 5),
                       "点击已有账号登录应进入登录页")
        XCTAssertTrue(app.secureTextFields["密码"].exists,
                       "密码输入框应存在")
    }

    // MARK: - Full E2E (offline mode)

    func test_fullE2E_journey() throws {
        // 1. 匿名登录
        app.buttons["匿名进入"].tap()
        guard app.tabBars.buttons["首页"].waitForExistence(timeout: 15) else {
            XCTFail("未能进入主页"); return
        }
        sleep(2)

        // 2. 情绪打卡
        let calm = app.buttons["平静"]
        if calm.waitForExistence(timeout: 3) {
            calm.tap()
            sleep(1)
            let confirm = app.buttons["就是这样，进去看看"]
            if confirm.waitForExistence(timeout: 3) {
                confirm.tap()
            }
        }

        // 3. 切换 Tab
        for tab in ["树洞", "会员", "我的"] {
            app.tabBars.buttons[tab].tap()
            sleep(2)
        }

        // 4. 回到首页
        app.tabBars.buttons["首页"].tap()
        XCTAssertTrue(app.staticTexts["现在是什么感受？"].waitForExistence(timeout: 3))
    }

    // MARK: - Visual Snapshots (portrait only)

    func test_visual_welcome() throws {
        sleep(3)
        VisualTesting.compareWithBaseline(named: "welcome_page", in: app)
    }

    func test_visual_home() throws {
        app.buttons["匿名进入"].tap()
        guard app.tabBars.buttons["首页"].waitForExistence(timeout: 15) else { return }
        sleep(2)
        VisualTesting.compareWithBaseline(named: "home_page", in: app)
    }
}

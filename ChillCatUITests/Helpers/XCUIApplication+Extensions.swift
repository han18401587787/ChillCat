import XCTest

extension XCUIApplication {

    // MARK: - 页面元素访问器

    /// 绪安欢迎页 - 匿名进入按钮
    var welcomeAnonymousButton: XCUIElement {
        buttons["匿名进入"].firstMatch
    }

    /// 绪安欢迎页 - 已有账号登录按钮
    var welcomeLoginButton: XCUIElement {
        buttons["已有账号登录"].firstMatch
    }

    /// 登录页 - 用户名输入框
    var loginUsernameField: XCUIElement {
        textFields["用户名"].firstMatch
    }

    /// 登录页 - 密码输入框
    var loginPasswordField: XCUIElement {
        secureTextFields["密码"].firstMatch
    }

    /// 登录页 - 登录按钮
    var loginSubmitButton: XCUIElement {
        buttons["登录"].firstMatch
    }

    /// 登录页 - 注册按钮
    var loginRegisterToggle: XCUIElement {
        buttons["没有账号？去注册"].firstMatch
    }

    /// 首页 - 情绪按钮网格中的具体情绪
    func emotionButton(_ emotion: String) -> XCUIElement {
        buttons[emotion].firstMatch
    }

    /// 首页 - 情绪确认按钮
    var emotionConfirmButton: XCUIElement {
        buttons["就是这样，进去看看"].firstMatch
    }

    /// TabBar - 首页
    var tabHome: XCUIElement { tabBars.buttons["首页"].firstMatch }
    /// TabBar - 树洞
    var tabTreeHole: XCUIElement { tabBars.buttons["树洞"].firstMatch }
    /// TabBar - 会员
    var tabVIP: XCUIElement { tabBars.buttons["会员"].firstMatch }
    /// TabBar - 我的
    var tabProfile: XCUIElement { tabBars.buttons["我的"].firstMatch }

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

    /// 匿名登录 → 进入主页（支持离线兜底）
    /// - Note: API 不可用时 VC 会直接本地跳转，最长等待 15s
    func anonymousLogin() {
        guard welcomeAnonymousButton.waitForExistence(timeout: 10) else {
            print("⚠️ 欢迎页未加载，可能已登录")
            return
        }
        welcomeAnonymousButton.tap()
        // API 不可用时会离线兜底直接进入主页，给足时间
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

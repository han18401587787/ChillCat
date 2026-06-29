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
    /// TabBar - 共鸣墙 (v3.0)
    var tabResonance: XCUIElement { tabBars.buttons["共鸣墙"].firstMatch }
    /// TabBar - 治愈空间 (v3.0)
    var tabHealing: XCUIElement { tabBars.buttons["治愈空间"].firstMatch }
    /// TabBar - 个人中心
    var tabProfile: XCUIElement { tabBars.buttons["个人中心"].firstMatch }

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
    func assertTextField(_ placeholder: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        let field = textFields[placeholder].firstMatch.exists
            ? textFields[placeholder].firstMatch
            : textViews.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5), "输入框「\(placeholder)」应该存在", file: file, line: line)
        return field
    }

    /// 验证点击区域足够大 (>=44pt 符合HIG)
    func assertHitArea(_ element: XCUIElement, minWidth: CGFloat = 44, minHeight: CGFloat = 44, file: StaticString = #file, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(element.frame.width, minWidth,
            "「\(element.identifier)」点击宽度 \(element.frame.width) < \(minWidth)", file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, minHeight,
            "「\(element.identifier)」点击高度 \(element.frame.height) < \(minHeight)", file: file, line: line)
    }

    // MARK: - v3.0 新功能页面元素

    /// AI倾听官 - 输入框
    var aiListenerInput: XCUIElement {
        textFields.firstMatch
    }

    /// AI倾听官 - 发送按钮
    var aiListenerSendButton: XCUIElement {
        buttons["sparkles"].firstMatch
    }

    /// 首页 - 工具箱入口卡片
    var homeToolboxEntry: XCUIElement {
        buttons["工具箱"].firstMatch
    }

    /// 首页 - 成长档案入口卡片
    var homeGrowthArchiveEntry: XCUIElement {
        buttons["成长档案"].firstMatch
    }

    /// 首页 - 互助小组入口卡片
    var homeMutualAidEntry: XCUIElement {
        buttons["互助小组"].firstMatch
    }

    /// 首页 - 专业资源入口卡片
    var homeProfessionalEntry: XCUIElement {
        buttons["专业资源"].firstMatch
    }

    /// 工具箱 - 工具卡片 (按名称)
    func toolboxItem(_ name: String) -> XCUIElement {
        buttons[name].firstMatch
    }

    /// 成长档案 - 成就徽章
    var growthArchiveBadge: XCUIElement {
        staticTexts["成就徽章"].firstMatch
    }

    /// 互助小组 - 加入按钮
    var mutualAidJoinButton: XCUIElement {
        buttons["加入"].firstMatch
    }

    /// 专业资源 - 热线链接
    var professionalHotlineLink: XCUIElement {
        links.firstMatch
    }

    /// 个人中心 - 成长档案菜单
    var profileGrowthArchive: XCUIElement {
        buttons["成长档案"].firstMatch
    }

    /// 个人中心 - 安全计划菜单
    var profileSafetyPlan: XCUIElement {
        buttons["我的安全计划"].firstMatch
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
        let _ = buttons["tab_home"].waitForExistence(timeout: 10)
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

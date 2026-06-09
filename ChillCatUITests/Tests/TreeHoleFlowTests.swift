import XCTest

/// 树洞 - 匿名社区测试
final class TreeHoleFlowTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
        app.anonymousLogin()
        app.tabTreeHole.tap()
    }

    func test_treeHolePage_showsPosts() {
        XCTAssertTrue(app.tabTreeHole.waitForExistence(timeout: 3), "树洞Tab应存在")
        XCTAssertTrue(app.staticTexts["树洞"].exists, "应显示标题")
        VisualTesting.compareWithBaseline(named: "treehole_page", in: app)
    }

    func test_treeHole_createPost() {
        let inputField = app.textFields.firstMatch
        guard inputField.waitForExistence(timeout: 3) else { return }
        inputField.tap()
        inputField.typeText("这是一条测试帖子")

        // 发布按钮
        let sendButton = app.buttons.firstMatch
        sendButton.tap()

        // 验证帖子出现在列表中
        XCTAssertTrue(app.staticTexts["这是一条测试帖子"].waitForExistence(timeout: 5))
    }

    func test_treeHole_toggleAnonymous() {
        let anonButton = app.buttons["匿名"].firstMatch
        if anonButton.exists {
            anonButton.tap()
            XCTAssertTrue(app.buttons["实名"].waitForExistence(timeout: 2))
        }
    }
}

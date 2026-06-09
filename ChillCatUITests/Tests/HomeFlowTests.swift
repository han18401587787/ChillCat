import XCTest

/// 首页 - 情绪打卡流程测试
final class HomeFlowTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
        app.anonymousLogin()
    }

    func test_homePage_showsEmotionGrid() {
        XCTAssertTrue(app.tabHome.exists, "首页Tab应存在")

        // 验证10个情绪按钮
        let emotions = ["平静", "开心", "疲惫", "焦虑", "委屈", "孤独", "烦躁", "迷茫", "易怒", "内耗"]
        for emotion in emotions {
            XCTAssertTrue(app.buttons[emotion].exists, "情绪「\(emotion)」按钮应存在")
        }

        VisualTesting.compareWithBaseline(named: "home_emotion_grid", in: app)
    }

    func test_emotionCheckin_completeFlow() {
        // 选择情绪
        app.emotionButton("平静").tap()
        // 笔记输入框出现
        let noteField = app.textFields.firstMatch
        XCTAssertTrue(noteField.waitForExistence(timeout: 2), "笔记输入框应出现")

        // 输入笔记
        noteField.tap()
        noteField.typeText("今天天气很好")

        // 确认打卡
        app.emotionConfirmButton.tap()

        // 应显示打卡成功
        XCTAssertTrue(app.staticTexts["今日已打卡"].waitForExistence(timeout: 3), "应显示打卡成功")
    }

    func test_homePage_showsExploreCards() {
        // 滑动到探索区域
        app.swipeUp()
        app.swipeUp()

        XCTAssertTrue(app.staticTexts["探索更多可能"].exists, "应显示探索区域")
    }
}

import XCTest

final class ChillCatUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launch()
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    func test_appLaunches_showsWelcome() {
        XCTAssertTrue(app.buttons["匿名进入"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["已有账号登录"].exists)
    }

    func test_visual_welcome() {
        sleep(3)
        VisualTesting.compareWithBaseline(named: "welcome_page", in: app)
    }
}

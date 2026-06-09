import XCTest
@testable import ChillCat

final class CCEmotionViewModelTests_V2: XCTestCase {
    var sut: CCEmotionViewModel!

    override func setUp() {
        super.setUp()
        sut = CCEmotionViewModel()
    }

    func test_init_hasDefaultQuote() {
        XCTAssertFalse(sut.quote.isEmpty)
    }

    func test_selectEmotion_setsSelected() {
        sut.selectEmotion(.calm)
        XCTAssertEqual(sut.selectedEmotion, .calm)
    }

    func test_completeDailyTask_setsCompleted() {
        sut.completeDailyTask()
        XCTAssertTrue(sut.dailyTaskCompleted)
    }

    func test_init_hasDailyTask() {
        XCTAssertEqual(sut.dailyTask, "记录一件今天微小的开心事")
    }

    func test_allTenEmotions_selectable() {
        for emotion in CCEmotion.allCases {
            sut.selectEmotion(emotion)
            XCTAssertEqual(sut.selectedEmotion, emotion)
        }
    }
}

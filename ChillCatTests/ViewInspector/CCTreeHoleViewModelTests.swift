import XCTest
@testable import ChillCat

final class CCTreeHoleViewModelTests_V2: XCTestCase {
    var sut: CCTreeHoleViewModel!

    override func setUp() {
        super.setUp()
        sut = CCTreeHoleViewModel()
    }

    func test_init_defaultAnonymous() {
        XCTAssertTrue(sut.isAnonymous)
    }

    func test_toggleAnonymous_switchesMode() {
        sut.toggleAnonymous()
        XCTAssertFalse(sut.isAnonymous)
        sut.toggleAnonymous()
        XCTAssertTrue(sut.isAnonymous)
    }

    func test_publishPost_emptyText_doesNotPublish() {
        sut.newPostText = "   "
        let preCount = sut.posts.count
        sut.publishPost()
        XCTAssertEqual(sut.posts.count, preCount)
    }

    func test_newPostText_cleared_afterPublish() {
        sut.newPostText = "Hello"
        sut.publishPost()
        XCTAssertEqual(sut.newPostText, "")
    }
}

import XCTest
@testable import ChillCat

final class CCSearchViewModelTests: XCTestCase {
    var mockRepo: MockFeedRepository!
    var sut: CCSearchViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockFeedRepository()
        sut = CCSearchViewModel(fetchFeedsUseCase: CCFetchFeedsUseCase(repository: mockRepo))
    }

    func test_search_withEmptyQuery_doesNothing() async {
        sut.query = "   "
        await sut.search()
        XCTAssertFalse(sut.hasSearched)
    }

    func test_search_success_setsResults() async {
        let items = TestHelpers.makeFeedItems(count: 3)
        mockRepo.searchResult = .success((items, 3, false))
        sut.query = "ChillCat"
        await sut.search()
        XCTAssertEqual(sut.results.count, 3)
        XCTAssertTrue(sut.hasSearched)
    }

    func test_search_failure_setsError() async {
        mockRepo.searchResult = .failure(CCAppError.unknown)
        sut.query = "nothing"
        await sut.search()
        XCTAssertNotNil(sut.errorMessage)
    }
}

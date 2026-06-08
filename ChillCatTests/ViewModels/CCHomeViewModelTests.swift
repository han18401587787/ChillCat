import XCTest
@testable import ChillCat

final class CCHomeViewModelTests: XCTestCase {
    var mockRepo: MockFeedRepository!
    var sut: CCHomeViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockFeedRepository()
        sut = CCHomeViewModel(fetchFeedsUseCase: CCFetchFeedsUseCase(repository: mockRepo))
    }

    func test_loadItems_success_populatesItems() async {
        let items = TestHelpers.makeFeedItems(count: 5)
        mockRepo.feedResult = .success((items, 15, true))
        await sut.loadItems()
        XCTAssertEqual(sut.items.count, 5)
        XCTAssertTrue(sut.hasMore)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadItems_empty_populatesNoItems() async {
        mockRepo.feedResult = .success(([], 0, false))
        await sut.loadItems()
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertFalse(sut.hasMore)
    }

    func test_loadItems_failure_setsError() async {
        mockRepo.feedResult = .failure(CCAppError.unknown)
        await sut.loadItems()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_refresh_resetsPage() async {
        let items = TestHelpers.makeFeedItems(count: 3)
        mockRepo.feedResult = .success((items, 3, false))
        await sut.refresh()
        XCTAssertEqual(sut.items.count, 3)
        XCTAssertFalse(sut.isRefreshing)
    }

    func test_loadMore_appendsItems() async {
        let first = TestHelpers.makeFeedItems(count: 10)
        mockRepo.feedResult = .success((first, 20, true))
        await sut.loadItems()
        XCTAssertEqual(sut.items.count, 10)

        let second = TestHelpers.makeFeedItems(count: 10)
        mockRepo.feedResult = .success((second, 20, false))
        await sut.loadMore()
        XCTAssertEqual(sut.items.count, 20)
        XCTAssertFalse(sut.hasMore)
    }

    func test_loadMore_whenNoMore_doesNothing() async {
        mockRepo.feedResult = .success((TestHelpers.makeFeedItems(count: 5), 5, false))
        await sut.loadItems()
        let count = sut.items.count
        await sut.loadMore()
        XCTAssertEqual(sut.items.count, count)
    }
}

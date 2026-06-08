import XCTest
@testable import ChillCat

final class CCFetchFeedsUseCaseTests: XCTestCase {
    var mockRepo: MockFeedRepository!
    var sut: CCFetchFeedsUseCase!

    override func setUp() {
        super.setUp()
        mockRepo = MockFeedRepository()
        sut = CCFetchFeedsUseCase(repository: mockRepo)
    }

    func test_execute_returnsItems() async throws {
        let items = TestHelpers.makeFeedItems(count: 10)
        mockRepo.feedResult = .success((items, 20, true))
        let result = try await sut.execute(page: 1, pageSize: 10)
        XCTAssertEqual(result.items.count, 10)
        XCTAssertEqual(result.total, 20)
        XCTAssertTrue(result.hasMore)
    }

    func test_execute_lastPage_hasNoMore() async throws {
        let items = TestHelpers.makeFeedItems(count: 3)
        mockRepo.feedResult = .success((items, 3, false))
        let result = try await sut.execute(page: 3, pageSize: 10)
        XCTAssertFalse(result.hasMore)
    }

    func test_search_returnsResults() async throws {
        let items = TestHelpers.makeFeedItems(count: 2)
        mockRepo.searchResult = .success((items, 2, false))
        let result = try await sut.search(query: "ChillCat", page: 1)
        XCTAssertEqual(result.items.count, 2)
    }
}

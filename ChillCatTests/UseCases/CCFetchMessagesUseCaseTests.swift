import XCTest
@testable import ChillCat

final class CCFetchMessagesUseCaseTests: XCTestCase {
    var mockRepo: MockMessageRepository!
    var sut: CCFetchMessagesUseCase!

    override func setUp() {
        super.setUp()
        mockRepo = MockMessageRepository()
        sut = CCFetchMessagesUseCase(repo: mockRepo)
    }

    func test_fetchMessages_returnsItems() async throws {
        let msgs = TestHelpers.makeMessages(count: 5)
        mockRepo.messagesResult = .success((msgs, 5, false))
        let result = try await sut.fetchMessages(page: 1)
        XCTAssertEqual(result.items.count, 5)
    }

    func test_fetchUnreadCount_returnsCount() async throws {
        mockRepo.unreadCountResult = .success(3)
        let count = try await sut.fetchUnreadCount()
        XCTAssertEqual(count, 3)
    }
}

import XCTest
@testable import ChillCat

final class CCMessageViewModelTests: XCTestCase {
    var mockRepo: MockMessageRepository!
    var sut: CCMessageViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockMessageRepository()
        sut = CCMessageViewModel(useCase: CCFetchMessagesUseCase(repo: mockRepo))
    }

    func test_load_success_populatesMessages() async {
        let msgs = TestHelpers.makeMessages(count: 3)
        mockRepo.messagesResult = .success((msgs, 3, false))
        mockRepo.unreadCountResult = .success(2)
        await sut.load()
        XCTAssertEqual(sut.messages.count, 3)
        XCTAssertEqual(sut.unreadCount, 2)
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_failure_setsError() async {
        mockRepo.messagesResult = .failure(CCAppError.unknown)
        await sut.load()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_markRead_updatesMessage() async {
        let msgs = TestHelpers.makeMessages(count: 1, isRead: false)
        mockRepo.messagesResult = .success((msgs, 1, false))
        mockRepo.unreadCountResult = .success(1)
        await sut.load()
        XCTAssertEqual(sut.unreadCount, 1)

        await sut.markRead(msgs[0])
        XCTAssertTrue(sut.messages[0].isRead)
        XCTAssertEqual(sut.unreadCount, 0)
    }

    func test_markRead_alreadyRead_doesNotDecrement() async {
        let msgs = TestHelpers.makeMessages(count: 1, isRead: true)
        mockRepo.messagesResult = .success((msgs, 1, false))
        mockRepo.unreadCountResult = .success(0)
        await sut.load()
        await sut.markRead(msgs[0])
        XCTAssertEqual(sut.unreadCount, 0)
    }
}

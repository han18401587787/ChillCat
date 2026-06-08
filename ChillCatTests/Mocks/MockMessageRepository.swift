import Foundation
@testable import ChillCat

final class MockMessageRepository: CCMessageRepositoryProtocol {
    var messagesResult: Result<(items: [CCMessage], total: Int64, hasMore: Bool), Error> = .success(([], 0, false))
    var unreadCountResult: Result<Int64, Error> = .success(0)

    func fetchMessages(page: Int, pageSize: Int) async throws -> (items: [CCMessage], total: Int64, hasMore: Bool) {
        switch messagesResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }

    func fetchUnreadCount() async throws -> Int64 {
        switch unreadCountResult {
        case .success(let c): return c
        case .failure(let e): throw e
        }
    }

    func markRead(id: String) async throws {}
}

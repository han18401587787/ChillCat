//
//  CCFetchMessagesUseCase.swift
//  ChillCat
//

import Foundation

final class CCFetchMessagesUseCase {
    private let repo: CCMessageRepositoryProtocol
    init(repo: CCMessageRepositoryProtocol) { self.repo = repo }

    func fetchMessages(page: Int, pageSize: Int = 20) async throws -> (items: [CCMessage], total: Int64, hasMore: Bool) {
        try await repo.fetchMessages(page: page, pageSize: pageSize)
    }
    func fetchUnreadCount() async throws -> Int64 { try await repo.fetchUnreadCount() }
    func markRead(id: String) async throws { try await repo.markRead(id: id) }
}

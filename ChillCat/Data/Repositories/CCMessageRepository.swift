//
//  CCMessageRepository.swift
//  ChillCat
//

import Foundation

final class CCMessageRepository: CCMessageRepositoryProtocol {
    private let remote: CCMessageRemoteDataSource
    init(remote: CCMessageRemoteDataSource) { self.remote = remote }

    func fetchMessages(page: Int, pageSize: Int) async throws -> (items: [CCMessage], total: Int64, hasMore: Bool) {
        let dto = try await remote.fetchMessages(page: page, pageSize: pageSize)
        return (dto.list.map(CCMessageDTOMapper.toEntity), dto.total, (dto.page * dto.page_size) < dto.total)
    }

    func fetchUnreadCount() async throws -> Int64 { try await remote.fetchUnreadCount() }
    func markRead(id: String) async throws { try await remote.markRead(id: id) }
}

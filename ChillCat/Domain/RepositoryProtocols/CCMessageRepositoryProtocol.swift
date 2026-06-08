//
//  CCMessageRepositoryProtocol.swift
//  ChillCat
//

import Foundation

protocol CCMessageRepositoryProtocol {
    func fetchMessages(page: Int, pageSize: Int) async throws -> (items: [CCMessage], total: Int64, hasMore: Bool)
    func fetchUnreadCount() async throws -> Int64
    func markRead(id: String) async throws
}

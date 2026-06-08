//
//  CCFeedRepositoryProtocol.swift
//  ChillCat
//

import Foundation

protocol CCFeedRepositoryProtocol {
    func fetchFeeds(page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool)
    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool)
}

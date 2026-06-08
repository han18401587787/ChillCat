//
//  CCFetchFeedsUseCase.swift
//  ChillCat
//

import Foundation

final class CCFetchFeedsUseCase {
    private let repository: CCFeedRepositoryProtocol

    init(repository: CCFeedRepositoryProtocol) {
        self.repository = repository
    
    func search(query: String, page: Int, pageSize: Int = 10) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        try await repository.searchFeeds(query: query, page: page, pageSize: pageSize)
    }
}

    func execute(page: Int, pageSize: Int = 10) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        try await repository.fetchFeeds(page: page, pageSize: pageSize)
    
    func search(query: String, page: Int, pageSize: Int = 10) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        try await repository.searchFeeds(query: query, page: page, pageSize: pageSize)
    }
}

    func search(query: String, page: Int, pageSize: Int = 10) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        try await repository.searchFeeds(query: query, page: page, pageSize: pageSize)
    }
}

//
//  CCFeedRepository.swift
//  ChillCat
//

import Foundation

final class CCFeedRepository: CCFeedRepositoryProtocol {
    private let remoteDataSource: CCFeedRemoteDataSource

    init(remoteDataSource: CCFeedRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    
    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        let dto = try await remoteDataSource.searchFeeds(query: query, page: page, pageSize: pageSize)
        let items = dto.list.map(CCFeedDTOMapper.toEntity)
        let hasMore = (dto.page * dto.page_size) < dto.total
        return (items, dto.total, hasMore)
    }
}

    func fetchFeeds(page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        let dto = try await remoteDataSource.fetchFeeds(page: page, pageSize: pageSize)
        let items = dto.list.map(CCFeedDTOMapper.toEntity)
        let hasMore = (dto.page * dto.page_size) < dto.total
        return (items, dto.total, hasMore)
    
    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        let dto = try await remoteDataSource.searchFeeds(query: query, page: page, pageSize: pageSize)
        let items = dto.list.map(CCFeedDTOMapper.toEntity)
        let hasMore = (dto.page * dto.page_size) < dto.total
        return (items, dto.total, hasMore)
    }
}

    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> (items: [CCFeedItem], total: Int64, hasMore: Bool) {
        let dto = try await remoteDataSource.searchFeeds(query: query, page: page, pageSize: pageSize)
        let items = dto.list.map(CCFeedDTOMapper.toEntity)
        let hasMore = (dto.page * dto.page_size) < dto.total
        return (items, dto.total, hasMore)
    }
}

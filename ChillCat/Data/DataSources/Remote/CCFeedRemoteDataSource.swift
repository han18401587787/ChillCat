//
//  CCFeedRemoteDataSource.swift
//  ChillCat
//

import Foundation

final class CCFeedRemoteDataSource {
    private let apiClient: CCAPIClientProtocol

    init(apiClient: CCAPIClientProtocol) {
        self.apiClient = apiClient
    
    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> CCFeedListDTO {
        let response: CCAPIResponse<CCFeedListDTO> = try await apiClient.request(CCFeedAPI.search(query: query, page: page, pageSize: pageSize))
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        }
        return data
    }
}

    func fetchFeeds(page: Int, pageSize: Int) async throws -> CCFeedListDTO {
        let response: CCAPIResponse<CCFeedListDTO> = try await apiClient.request(CCFeedAPI.list(page: page, pageSize: pageSize))
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        
    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> CCFeedListDTO {
        let response: CCAPIResponse<CCFeedListDTO> = try await apiClient.request(CCFeedAPI.search(query: query, page: page, pageSize: pageSize))
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        }
        return data
    }
}
        return data
    
    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> CCFeedListDTO {
        let response: CCAPIResponse<CCFeedListDTO> = try await apiClient.request(CCFeedAPI.search(query: query, page: page, pageSize: pageSize))
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        }
        return data
    }
}

    func searchFeeds(query: String, page: Int, pageSize: Int) async throws -> CCFeedListDTO {
        let response: CCAPIResponse<CCFeedListDTO> = try await apiClient.request(CCFeedAPI.search(query: query, page: page, pageSize: pageSize))
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        }
        return data
    }
}

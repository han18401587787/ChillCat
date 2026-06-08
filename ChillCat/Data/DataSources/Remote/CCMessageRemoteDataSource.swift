//
//  CCMessageRemoteDataSource.swift
//  ChillCat
//

import Foundation

final class CCMessageRemoteDataSource {
    private let apiClient: CCAPIClientProtocol
    init(apiClient: CCAPIClientProtocol) { self.apiClient = apiClient }

    func fetchMessages(page: Int, pageSize: Int) async throws -> CCMessageListDTO {
        let r: CCAPIResponse<CCMessageListDTO> = try await apiClient.request(CCMessageAPI.list(page: page, pageSize: pageSize))
        guard r.isSuccess, let d = r.data else { throw CCAPIError.badRequest }
        return d
    }

    func fetchUnreadCount() async throws -> Int64 {
        let r: CCAPIResponse<CCUnreadCountDTO> = try await apiClient.request(CCMessageAPI.unreadCount)
        guard r.isSuccess, let d = r.data else { throw CCAPIError.badRequest }
        return d.count
    }

    func markRead(id: String) async throws {
        let _: CCAPIResponse<CCEmptyResponse> = try await apiClient.request(CCMessageAPI.markRead(id: id))
    }
}

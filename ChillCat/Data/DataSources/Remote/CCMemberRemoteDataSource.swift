//
//  CCMemberRemoteDataSource.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCMemberRemoteDataSource {
    private let apiClient: CCAPIClientProtocol

    init(apiClient: CCAPIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchMemberInfo() async throws -> CCMemberInfoDTO {
        let response: CCAPIResponse<CCMemberInfoDTO> = try await apiClient.request(CCMemberAPI.info)
        guard response.isSuccess, let data = response.data else {
            throw mapAPIError(code: response.code)
        }
        return data
    }

    func fetchProducts() async throws -> [CCMemberProductDTO] {
        let response: CCAPIResponse<[CCMemberProductDTO]> = try await apiClient.request(CCMemberAPI.products)
        return response.data ?? []
    }

    func fetchPrivileges() async throws -> [CCMemberPrivilegeDTO] {
        let response: CCAPIResponse<[CCMemberPrivilegeDTO]> = try await apiClient.request(CCMemberAPI.privileges)
        return response.data ?? []
    }

    func purchase(productId: String) async throws -> CCMemberInfoDTO {
        let response: CCAPIResponse<CCMemberInfoDTO> = try await apiClient.request(CCMemberAPI.purchase(productId: productId))
        guard response.isSuccess, let data = response.data else {
            throw mapAPIError(code: response.code)
        }
        return data
    }

    private func mapAPIError(code: Int?) -> CCAPIError {
        guard let code else { return .serverError(0) }
        switch code {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 409: return .conflict
        case 422: return .unprocessableEntity
        case 429: return .tooManyRequests
        case 500...599: return .serverError(code)
        default: return .unexpectedStatusCode(code)
        }
    }
}

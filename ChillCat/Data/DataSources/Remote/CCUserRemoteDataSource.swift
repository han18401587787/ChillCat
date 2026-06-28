//
//  CCUserRemoteDataSource.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCUserRemoteDataSource {
    private let apiClient: CCAPIClientProtocol

    init(apiClient: CCAPIClientProtocol) {
        self.apiClient = apiClient
    }

    func login(username: String, password: String) async throws -> CCUserDTO {
        let response: CCAPIResponse<CCUserDTO> = try await apiClient.request(CCUserAPI.login(username: username, password: password))
        guard response.isSuccess, let data = response.data else {
            throw mapAPIError(code: response.code)
        }
        return data
    }

    func register(username: String, password: String, email: String) async throws -> CCUserDTO {
        let response: CCAPIResponse<CCUserDTO> = try await apiClient.request(CCUserAPI.register(username: username, password: password, email: email))
        guard response.isSuccess, let data = response.data else {
            throw mapAPIError(code: response.code)
        }
        return data
    }

    func fetchProfile() async throws -> CCUserDTO {
        let response: CCAPIResponse<CCUserDTO> = try await apiClient.request(CCUserAPI.profile)
        // code=10002 表示未登录，不应抛异常，返回空让上层用默认值
        guard response.isSuccess else {
            if response.code == 10002 {
                throw CCAPIError.unauthorized
            }
            throw mapAPIError(code: response.code)
        }
        guard let data = response.data else {
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

    func logout() async throws {
        let _: CCAPIResponse<CCEmptyResponse> = try await apiClient.request(CCUserAPI.logout)
    }

    func deleteAccount() async throws {
        let _: CCAPIResponse<CCEmptyResponse> = try await apiClient.request(CCUserAPI.deleteAccount)
    }
}

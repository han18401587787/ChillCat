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
            throw CCAPIError.badRequest
        }
        return data
    }

    func register(username: String, password: String, email: String) async throws -> CCUserDTO {
        let response: CCAPIResponse<CCUserDTO> = try await apiClient.request(CCUserAPI.register(username: username, password: password, email: email))
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        }
        return data
    }

    func fetchProfile() async throws -> CCUserDTO {
        let response: CCAPIResponse<CCUserDTO> = try await apiClient.request(CCUserAPI.profile)
        guard response.isSuccess, let data = response.data else {
            throw CCAPIError.badRequest
        }
        return data
    }

    func logout() async throws {
        let _: CCAPIResponse<CCEmptyResponse> = try await apiClient.request(CCUserAPI.logout)
    }

    func deleteAccount() async throws {
        let _: CCAPIResponse<CCEmptyResponse> = try await apiClient.request(CCUserAPI.deleteAccount)
    }
}

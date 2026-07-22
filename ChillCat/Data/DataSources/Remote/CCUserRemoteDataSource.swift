//
//  CCUserRemoteDataSource.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCUserRemoteDataSource {

    func login(username: String, password: String) async throws -> CCUserDTO {
        try await CCXuanAPI.login(username: username, password: password)
    }

    func register(username: String, password: String, email: String) async throws -> CCUserDTO {
        try await CCXuanAPI.register(username: username, password: password, email: email)
    }

    func fetchProfile() async throws -> CCUserDTO {
        do {
            return try await CCXuanAPI.getProfile()
        } catch let error as CCAPIError {
            // 401 / unauthorized → 让上层用默认值
            if error == .unauthorized { throw CCAPIError.unauthorized }
            throw error
        }
    }

    func logout() async throws {
        try await CCXuanAPI.logout()
    }

    func deleteAccount() async throws {
        try await CCXuanAPI.deleteAccount()
    }
}

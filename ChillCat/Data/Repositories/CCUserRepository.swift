//
//  CCUserRepository.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation
import KeychainAccess

final class CCUserRepository: CCUserRepositoryProtocol {
    private let remoteDataSource: CCUserRemoteDataSource
    private let localDataSource: CCUserLocalDataSource
    private let keychain = Keychain(service: "app.xuanpeace.token")

    init(
        remoteDataSource: CCUserRemoteDataSource,
        localDataSource: CCUserLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func login(username: String, password: String) async throws -> CCUser {
        let dto = try await remoteDataSource.login(username: username, password: password)
        let user = CCUserDTOMapper.toEntity(dto)
        try? await localDataSource.saveUser(user)
        // 将 token 写入 Keychain，CCXuanAPI 的 XuanAuthInterceptor 需要
        if let token = dto.token {
            keychain["access_token"] = token
            LogI("Token已缓存", module: .auth, category: "Login")
        }
        return user
    }

    func register(username: String, password: String, email: String) async throws -> CCUser {
        let dto = try await remoteDataSource.register(username: username, password: password, email: email)
        let user = CCUserDTOMapper.toEntity(dto)
        try? await localDataSource.saveUser(user)
        return user
    }

    func fetchProfile() async throws -> CCUser {
        if let cached = try? await localDataSource.getCachedUser() {
            return cached
        }
        let dto = try await remoteDataSource.fetchProfile()
        let user = CCUserDTOMapper.toEntity(dto)
        try? await localDataSource.saveUser(user)
        return user
    }

    func updateProfile(_ user: CCUser) async throws -> CCUser {
        let updatedUser = user
        try? await localDataSource.saveUser(updatedUser)
        return updatedUser
    }

    func logout() async {
        try? await remoteDataSource.logout()
        await localDataSource.clearUser()
    }

    func deleteAccount() async throws {
        try await remoteDataSource.deleteAccount()
        await localDataSource.clearUser()
    }
}

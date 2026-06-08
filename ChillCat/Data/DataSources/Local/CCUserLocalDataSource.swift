//
//  CCUserLocalDataSource.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

final class CCUserLocalDataSource {
    private let keychainManager: CCKeychainManagerProtocol

    init(keychainManager: CCKeychainManagerProtocol) {
        self.keychainManager = keychainManager
    }

    func saveUser(_ user: CCUser) async throws {
        guard let data = try? JSONEncoder().encode(user) else { return }
        try keychainManager.set(String(data: data, encoding: .utf8) ?? "", for: "cached_user")
    }

    func getCachedUser() async throws -> CCUser? {
        guard let jsonString = try keychainManager.get("cached_user"),
              let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CCUser.self, from: data)
    }

    func clearUser() async {
        try? keychainManager.delete("cached_user")
    }
}

//
//  CCTokenProvider.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

protocol CCTokenProviderProtocol: AnyObject {
    func getAccessToken() async -> String?
    func getRefreshToken() async -> String?
    func saveTokens(access: String, refresh: String) async throws
    func refreshToken() async throws
    func clearTokens() async
}

final class CCTokenProvider: CCTokenProviderProtocol {
    private let keychain: CCKeychainManagerProtocol

    private enum CCKeys {
        static let accessToken = "com.chillcat.token.access"
        static let refreshToken = "com.chillcat.token.refresh"
    }

    init(keychain: CCKeychainManagerProtocol) {
        self.keychain = keychain
    }

    func getAccessToken() async -> String? {
        try? keychain.get(CCKeys.accessToken)
    }

    func getRefreshToken() async -> String? {
        try? keychain.get(CCKeys.refreshToken)
    }

    func saveTokens(access: String, refresh: String) async throws {
        try keychain.set(access, for: CCKeys.accessToken)
        try keychain.set(refresh, for: CCKeys.refreshToken)
    }

    func refreshToken() async throws {
        // Token refresh will be implemented when auth API is available
        throw CCAppError.authentication
    }

    func clearTokens() async {
        try? keychain.delete(CCKeys.accessToken)
        try? keychain.delete(CCKeys.refreshToken)
    }
}

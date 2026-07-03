//
//  CCTokenProvider.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
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
    private let refreshLock = NSLock()
    private var isRefreshing = false

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

    /// 刷新 Token — 带并发保护，防止多个请求同时触发刷新
    func refreshToken() async throws {
        // 并发保护：如果正在刷新中，等待完成
        refreshLock.lock()
        if isRefreshing {
            refreshLock.unlock()
            // 等待正在进行的刷新完成（轮询检查，最多等待 10 秒）
            for _ in 0..<20 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                refreshLock.lock()
                if !isRefreshing {
                    refreshLock.unlock()
                    return
                }
                refreshLock.unlock()
            }
            throw CCAppError.tokenExpired
        }
        isRefreshing = true
        refreshLock.unlock()

        defer {
            refreshLock.lock()
            isRefreshing = false
            refreshLock.unlock()
        }

        // 获取 refresh token
        guard let refreshTokenValue = await getRefreshToken() else {
            // 没有 refresh token，尝试匿名登录获取新 token
            print("🔄 [Token] 无 refresh token，尝试匿名登录")
            do {
                let resp = try await CCXuanAPI.anonymousLogin()
                try keychain.set(resp.token, for: CCKeys.accessToken)
                print("✅ [Token] 匿名登录获取新 token 成功")
                return
            } catch {
                print("❌ [Token] 匿名登录获取新 token 失败: \(error)")
                await clearTokens()
                throw CCAppError.authentication
            }
        }

        // 调用刷新接口
        print("🔄 [Token] 开始刷新 token")
        do {
            let resp = try await CCXuanAPI.refreshToken(refreshToken: refreshTokenValue)
            try await saveTokens(access: resp.accessToken, refresh: resp.refreshToken)
            print("✅ [Token] 刷新成功")
        } catch {
            print("❌ [Token] 刷新失败: \(error)")
            // 刷新失败，清除旧 token，需要重新登录
            await clearTokens()
            throw CCAppError.tokenExpired
        }
    }

    func clearTokens() async {
        try? keychain.delete(CCKeys.accessToken)
        try? keychain.delete(CCKeys.refreshToken)
    }
}

//
//  CCTokenInterceptor.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//

import Foundation

final class CCTokenInterceptor: CCRequestInterceptor {
    private let tokenProvider: CCTokenProviderProtocol
    private let retryLimit = 2
    private var retryCount = 0

    init(tokenProvider: CCTokenProviderProtocol) {
        self.tokenProvider = tokenProvider
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard let token = await tokenProvider.getAccessToken() else {
            return request
        }
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }

    func handle(response: HTTPURLResponse, data: Data) async throws {
        if response.statusCode == 401 {
            guard retryCount < retryLimit else {
                // 重试次数用尽，清除 token 并抛错
                await tokenProvider.clearTokens()
                throw CCAPIError.unauthorized
            }
            retryCount += 1
            print("🔄 [TokenInterceptor] 401 触发 token 刷新 (attempt \(retryCount)/\(retryLimit))")
            do {
                try await tokenProvider.refreshToken()
                print("✅ [TokenInterceptor] token 刷新成功，请求将重试")
            } catch {
                print("❌ [TokenInterceptor] token 刷新失败: \(error)")
                await tokenProvider.clearTokens()
                throw CCAPIError.unauthorized
            }
        }
    }

    /// 重置重试计数（在成功的请求后调用）
    func resetRetryCount() {
        retryCount = 0
    }
}

//
//  CCTokenInterceptor.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
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
                throw CCAPIError.unauthorized
            }
            retryCount += 1
            try await tokenProvider.refreshToken()
        }
    }
}

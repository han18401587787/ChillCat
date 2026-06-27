//
//  CCAppEnvironment.swift
//  ChillCat
//
//  Created by doudou.han on 2026/6/8.
//
//

import Foundation

enum CCAppEnvironment {
    case development
    case staging
    case production

    static var current: CCAppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://api.chillcatgo.com")!
        case .staging:
            return URL(string: "https://staging-api.chillcatgo.com")!
        case .production:
            return URL(string: "https://api.chillcatgo.com")!
        }
    }

    var logLevel: CCLogLevel {
        switch self {
        case .development: return .debug
        case .staging: return .info
        case .production: return .error
        }
    }

    var isDebugMode: Bool {
        switch self {
        case .development: return true
        case .staging, .production: return false
        }
    }

    /// SSL证书SHA256哈希（Base64编码），空集合表示不固定
    var pinnedCertHashes: Set<String> {
        switch self {
        case .development:
            return []
        case .staging:
            return [
                // 替换为实际的 Staging 证书哈希
                // "ABC123..."
            ]
        case .production:
            return [
                // 替换为实际的生产证书哈希
                // "XYZ789..."
            ]
        }
    }
}

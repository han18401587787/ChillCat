//
//  CCNetworkConfig.swift
//  ChillCat
//
//  Created for v3.0 network layer unification
//

import Foundation

/// 统一网络配置 — 所有网络请求共用此配置
enum CCNetworkConfig {
    /// 单次请求超时（秒）
    static let requestTimeout: TimeInterval = 30

    /// 总资源超时（秒）
    static let resourceTimeout: TimeInterval = 60

    /// 最大重试次数（用于指数退避）
    static let maxRetryCount = 3

    /// 重试基础延迟（秒）
    static let retryBaseDelay: TimeInterval = 1.0

    /// 最大重试延迟上限（秒）
    static let retryMaxDelay: TimeInterval = 10.0

    /// Content-Type 默认值
    static let defaultContentType = "application/json"

    /// Accept 默认值
    static let defaultAccept = "application/json"
}

// MARK: - 指数退避延迟计算

extension CCNetworkConfig {
    /// 计算第 N 次重试的延迟（指数退避 + 随机抖动）
    /// - Parameter attempt: 第几次重试（1-based）
    /// - Returns: 延迟秒数
    static func retryDelay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = retryBaseDelay * pow(2.0, Double(attempt - 1))
        let jitter = Double.random(in: 0...0.5)  // 0~0.5秒随机抖动
        return min(exponentialDelay + jitter, retryMaxDelay)
    }

    /// 带指数退避的异步重试包装器
    /// - Parameters:
    ///   - maxAttempts: 最大尝试次数
    ///   - operation: 要执行的异步操作
    /// - Returns: 操作结果
    static func withRetry<T>(
        maxAttempts: Int = maxRetryCount,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    let delay = retryDelay(for: attempt)
                    print("⏳ [Retry] 第 \(attempt) 次失败，\(String(format: "%.1f", delay))s 后重试: \(error.localizedDescription)")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? CCAPIError.networkFailure(NSError(domain: "CCNetworkConfig", code: -1))
    }
}

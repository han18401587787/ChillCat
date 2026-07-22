import Foundation
import Testing
@testable import ChillCat

/// 测试辅助函数集合
enum TestHelpers {

    /// 创建测试用的 CCAPIResponse
    static func makeAPIResponse<T: Encodable>(code: Int = 0, message: String = "success", data: T) -> CCAPIResponse<T> {
        return CCAPIResponse(code: code, message: message, data: data)
    }

    /// 创建测试用的 JSON Data
    static func jsonData<T: Encodable>(_ value: T) throws -> Data {
        return try JSONEncoder().encode(value)
    }

    /// 等待异步条件满足（最多等待指定秒数）
    static func waitFor(
        timeout: TimeInterval = 3.0,
        interval: TimeInterval = 0.1,
        condition: @escaping () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        return false
    }
}

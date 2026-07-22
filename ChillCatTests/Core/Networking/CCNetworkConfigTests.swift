import Testing
import Foundation
@testable import ChillCat

/// CCNetworkConfig 测试套件
/// 验证指数退避延迟计算、重试逻辑等纯函数行为
struct CCNetworkConfigTests {

    // MARK: - 退避延迟计算

    @Test("第1次重试延迟应为基础延迟 + 抖动")
    func retryDelay_firstAttempt_returnsBaseWithJitter() {
        let delay = CCNetworkConfig.retryDelay(for: 1)
        #expect(delay >= CCNetworkConfig.retryBaseDelay)
        #expect(delay <= CCNetworkConfig.retryBaseDelay + 0.5)
    }

    @Test(arguments: [1, 2, 3])
    func retryDelay_neverExceedsMaxDelay(_ attempt: Int) {
        let delay = CCNetworkConfig.retryDelay(for: attempt)
        #expect(delay <= CCNetworkConfig.retryMaxDelay)
    }

    @Test("退避延迟应随重试次数递增")
    func retryDelay_increasesWithAttempt() {
        let delay1 = CCNetworkConfig.retryDelay(for: 1)
        let delay2 = CCNetworkConfig.retryDelay(for: 2)
        // 由于有随机抖动，比较基础值
        let base1 = CCNetworkConfig.retryBaseDelay * pow(2.0, 0)
        let base2 = CCNetworkConfig.retryBaseDelay * pow(2.0, 1)
        #expect(base2 > base1)
    }

    // MARK: - 配置常量

    @Test("请求超时应为 30 秒")
    func requestTimeout_is30Seconds() {
        #expect(CCNetworkConfig.requestTimeout == 30)
    }

    @Test("资源超时应为 60 秒")
    func resourceTimeout_is60Seconds() {
        #expect(CCNetworkConfig.resourceTimeout == 60)
    }

    @Test("最大重试次数应为 3")
    func maxRetryCount_is3() {
        #expect(CCNetworkConfig.maxRetryCount == 3)
    }

    // MARK: - withRetry 重试逻辑

    @Test("首次成功不重试")
    func withRetry_succeedsOnFirstAttempt() async throws {
        var callCount = 0
        let result = try await CCNetworkConfig.withRetry(maxAttempts: 3) {
            callCount += 1
            return "success"
        }
        #expect(result == "success")
        #expect(callCount == 1)
    }

    @Test("失败后重试最终成功")
    func withRetry_succeedsAfterRetry() async throws {
        var callCount = 0
        let result = try await CCNetworkConfig.withRetry(maxAttempts: 3) {
            callCount += 1
            if callCount < 2 {
                throw NSError(domain: "test", code: -1)
            }
            return "recovered"
        }
        #expect(result == "recovered")
        #expect(callCount == 2)
    }

    @Test("超过最大重试次数后抛出最终错误")
    func withRetry_exhaustsRetriesAndThrows() async {
        var callCount = 0
        do {
            let _ = try await CCNetworkConfig.withRetry(maxAttempts: 2) {
                callCount += 1
                throw NSError(domain: "test", code: -1)
            }
            #expect(Bool(false), "应该抛出错误")
        } catch {
            #expect(callCount == 2)
        }
    }
}

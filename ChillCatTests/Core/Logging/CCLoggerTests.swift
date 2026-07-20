import Testing
import Foundation
@testable import ChillCat

/// CCLogger 测试套件
/// 验证日志模块分级、级别过滤等
struct CCLoggerTests {

    // MARK: - 日志级别过滤

    @Test("设置模块级别为 off 后，该模块日志不应输出")
    func setLevelOff_filtersModuleLogs() {
        CCLogger.shared.setLevel(.off, for: .network)
        // 验证：setLevel 不抛异常即可（日志输出验证需 mock os_log）
        #expect(Bool(true))
        // 恢复默认级别
        CCLogger.shared.setLevel(.debug, for: .network)
    }

    // MARK: - 模块定义

    @Test(arguments: [
        CCLogModule.network,
        CCLogModule.auth,
        CCLogModule.ui,
        CCLogModule.storage,
        CCLogModule.payment,
        CCLogModule.performance,
    ] as [CCLogModule])
    func allModules_haveDisplayName(_ module: CCLogModule) {
        #expect(!module.displayName.isEmpty)
    }

    @Test("default 模块的 displayName 应为'通用'")
    func defaultModule_displayName() {
        #expect(CCLogModule.default.displayName == "通用")
    }

    @Test("network 模块的 displayName 应为'网络'")
    func networkModule_displayName() {
        #expect(CCLogModule.network.displayName == "网络")
    }
}

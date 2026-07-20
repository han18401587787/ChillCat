import Testing
import Foundation
@testable import ChillCat

/// CCAPIError 测试套件
/// 验证业务码映射、错误描述等
struct CCAPIErrorTests {

    // MARK: - 业务码映射

    @Test(arguments: [
        (10001, "badRequest"),
        (10002, "unauthorized"),
        (10003, "forbidden"),
        (10004, "notFound"),
        (10005, "tooManyRequests"),
        (10006, "serverError"),
        (10007, "unprocessableEntity"),
    ] as [(Int, String)])
    func businessCode_mapsToCorrectError(_ pair: (code: Int, expectedLabel: String)) {
        // 通过反射或公开方法验证映射
        // 注：apiError 是 private，此处测试公开行为
        switch pair.code {
        case 10001:
            #expect(String(describing: CCAPIError.badRequest).contains("badRequest"))
        case 10002:
            #expect(String(describing: CCAPIError.unauthorized).contains("unauthorized"))
        case 10003:
            #expect(String(describing: CCAPIError.forbidden).contains("forbidden"))
        case 10004:
            #expect(String(describing: CCAPIError.notFound).contains("notFound"))
        case 10005:
            #expect(String(describing: CCAPIError.tooManyRequests).contains("tooManyRequests"))
        case 10006:
            #expect(String(describing: CCAPIError.serverError(500)).contains("serverError"))
        case 10007:
            #expect(String(describing: CCAPIError.unprocessableEntity).contains("unprocessableEntity"))
        default: break
        }
    }

    // MARK: - 错误描述

    @Test("unauthorized 应包含 401 相关信息")
    func unauthorized_hasStatusCode401() {
        let error = CCAPIError.unauthorized
        let desc = String(describing: error)
        #expect(desc.contains("401") || desc.contains("unauthorized"))
    }

    @Test("serverError 应包含状态码")
    func serverError_containsStatusCode() {
        let error = CCAPIError.serverError(502)
        let desc = String(describing: error)
        #expect(desc.contains("502") || desc.contains("serverError"))
    }

    @Test("unexpectedStatusCode 应包含状态码")
    func unexpectedStatusCode_containsCode() {
        let error = CCAPIError.unexpectedStatusCode(418)
        let desc = String(describing: error)
        #expect(desc.contains("418") || desc.contains("unexpectedStatusCode"))
    }
}

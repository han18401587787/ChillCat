import Foundation
import Testing
@testable import ChillCat

/// Mock URLProtocol 用于网络层单元测试
/// 拦截 Alamofire 请求并返回预设响应
final class MockURLProtocol: URLProtocol {
    /// 响应处理器 — 测试用例设置此闭包来控制 mock 行为
    nonisolated(unsafe) static var responseHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.responseHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "responseHandler not set"]))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Mock 响应构造器

extension MockURLProtocol {
    /// 构造成功的 JSON 响应
    static func successResponse<T: Encodable>(_ body: T, statusCode: Int = 200) throws -> (HTTPURLResponse, Data) {
        let data = try JSONEncoder().encode(body)
        let response = HTTPURLResponse(
            url: URL(string: "https://api.test")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (response, data)
    }

    /// 构造错误响应
    static func errorResponse(statusCode: Int, message: String = "Error") -> (HTTPURLResponse, Data) {
        let body = #"{"code":\#(statusCode),"message":"\#(message)","data":null}"#
        let data = body.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://api.test")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        return (response, data)
    }
}

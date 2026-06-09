import Foundation
import Alamofire
import KeychainAccess

/// 绪安 API 客户端
/// - Alamofire 处理请求链/重试/响应校验
/// - KeychainAccess 管理 Token 安全存储
enum CCXuanAPI {

    // MARK: - Session

    private static let session: Session = {
        let interceptor = XuanAuthInterceptor()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5   // 5秒超时，快速失败
        config.timeoutIntervalForResource = 8
        return Session(
            configuration: config,
            interceptor: interceptor,
            serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:])
        )
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Auth

    struct AnonymousResponse: Decodable {
        let token: String; let userId: Int64; let username: String; let nickname: String?
    }

    static func anonymousLogin() async throws -> AnonymousResponse {
        try await post("/api/v1/auth/anonymous", body: Optional<String>.none)
    }

    // MARK: - Emotion

    struct CheckinRequest: Encodable { let emotion: String; let note: String }
    struct TodayResponse: Decodable { let id: Int64; let emotion: String; let note: String; let checkinDate: String; let streakDays: Int64 }
    struct JournalEntry: Decodable, Identifiable { let id: Int64; let emotion: String; let note: String; let hasDoodle: Bool; let checkinDate: String; let createdAt: String }
    struct JournalPage: Decodable { let list: [JournalEntry]; let total: Int64 }
    struct WeeklyStats: Decodable { let entries: [JournalEntry]; let totalCount: Int64; let streakDays: Int64; let topEmotion: String; let insight: String }

    static func checkin(emotion: String, note: String) async throws -> TodayResponse {
        try await post("/api/v1/emotion/checkin", body: CheckinRequest(emotion: emotion, note: note))
    }
    static func getToday() async throws -> TodayResponse { try await get("/api/v1/emotion/today") }
    static func getJournal(month: String, page: Int = 1) async throws -> JournalPage {
        try await get("/api/v1/emotion/journal?month=\(month)&page=\(page)")
    }
    static func getWeeklyStats() async throws -> WeeklyStats { try await get("/api/v1/emotion/weekly-stats") }

    // MARK: - TreeHole

    struct PostRequest: Encodable { let content: String; let scope: String; let isAnonymous: Bool }
    struct PostResponse: Decodable, Identifiable { let id: Int64; let content: String; let scope: String; let isAnonymous: Bool; let hugs: Int64; let createdAt: String; let displayName: String }
    struct PostPage: Decodable { let list: [PostResponse]; let total: Int64 }

    static func createPost(content: String, scope: String, isAnonymous: Bool) async throws -> PostResponse {
        try await post("/api/v1/treehole/posts", body: PostRequest(content: content, scope: scope, isAnonymous: isAnonymous))
    }
    static func listPosts(page: Int = 1) async throws -> PostPage { try await get("/api/v1/treehole/posts?page=\(page)") }
    static func hugPost(id: Int64) async throws {
        let _ = try await session.request(fullURL("/api/v1/treehole/posts/\(id)/hug"), method: .post)
            .validate().serializingData().value
    }

    // MARK: - Courses

    struct CourseItem: Decodable, Identifiable { let id: Int64; let title: String; let description: String; let duration: Int; let category: String; let tag: String }

    static func getCourses(category: String = "") async throws -> [CourseItem] {
        try await get("/api/v1/courses" + (category.isEmpty ? "" : "?category=\(category)"))
    }

    // MARK: - Internal helpers

    private static let keychain = Keychain(service: "app.xuanpeace.token")

    private static func fullURL(_ path: String) -> URL {
        URL(string: CCAppEnvironment.current.baseURL.absoluteString + path)!
    }

    private static func get<T: Decodable>(_ path: String) async throws -> T {
        let data = try await session.request(fullURL(path)).validate().serializingData().value
        let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
        guard resp.isSuccess, let d = resp.data else { throw CCAPIError.badRequest }
        return d
    }

    private static func post<T: Decodable, B: Encodable>(_ path: String, body: B?) async throws -> T {
        let data = try await session.request(fullURL(path), method: .post, parameters: body, encoder: JSONParameterEncoder.default).validate().serializingData().value
        let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
        guard resp.isSuccess, let d = resp.data else { throw CCAPIError.badRequest }
        return d
    }
}

// MARK: - Auth Interceptor

final class XuanAuthInterceptor: RequestInterceptor {
    private let keychain = Keychain(service: "app.xuanpeace.token")

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        if let token = keychain["access_token"] {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(req))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < 3,
              let afError = error.asAFError,
              afError.isResponseValidationError || afError.isSessionTaskError else {
            completion(.doNotRetry); return
        }
        completion(.retryWithDelay(1.0))
    }
}

// MARK: - Network Logger

import OSLog
final class XuanNetworkLogger: EventMonitor {
    private let logger = Logger(subsystem: "app.xuanpeace", category: "API")

    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        logger.debug("→ \(urlRequest.httpMethod ?? "?") \(urlRequest.url?.path ?? "")")
    }

    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        if let e = error { logger.error("✗ \(task.originalRequest?.url?.path ?? ""): \(e.localizedDescription)") }
        else { logger.debug("✓ \(task.originalRequest?.url?.path ?? "") \(task.response.map { "\(($0 as? HTTPURLResponse)?.statusCode ?? 0)" } ?? "")") }
    }
}

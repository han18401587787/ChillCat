import Foundation

/// 绪安 API 客户端 — 自动注入 Keychain 中的 JWT Token
enum CCXuanAPI {
    static let baseURL = CCAppEnvironment.current.baseURL

    // MARK: - Auth

    struct AnonymousResponse: Decodable {
        let token: String; let user_id: Int64; let username: String; let nickname: String?
    }

    static func anonymousLogin() async throws -> AnonymousResponse {
        try await post("/api/v1/auth/anonymous", body: nil as String?)
    }

    // MARK: - Emotion

    struct CheckinRequest: Encodable {
        let emotion: String; let note: String
    }
    struct TodayResponse: Decodable {
        let id: Int64; let emotion: String; let note: String; let checkin_date: String; let streak_days: Int64
    }
    struct JournalEntry: Decodable, Identifiable {
        let id: Int64; let emotion: String; let note: String; let has_doodle: Bool; let checkin_date: String; let created_at: String
    }
    struct JournalPage: Decodable {
        let list: [JournalEntry]; let total: Int64
    }
    struct WeeklyStats: Decodable {
        let entries: [JournalEntry]; let total_count: Int64; let streak_days: Int64; let top_emotion: String; let insight: String
    }

    static func checkin(emotion: String, note: String) async throws -> TodayResponse {
        try await post("/api/v1/emotion/checkin", body: CheckinRequest(emotion: emotion, note: note))
    }
    static func getToday() async throws -> TodayResponse {
        try await get("/api/v1/emotion/today")
    }
    static func getJournal(month: String, page: Int = 1) async throws -> JournalPage {
        try await get("/api/v1/emotion/journal?month=\(month)&page=\(page)")
    }
    static func getWeeklyStats() async throws -> WeeklyStats {
        try await get("/api/v1/emotion/weekly-stats")
    }

    // MARK: - TreeHole

    struct PostRequest: Encodable {
        let content: String; let scope: String; let is_anonymous: Bool
    }
    struct PostResponse: Decodable, Identifiable {
        let id: Int64; let content: String; let scope: String; let is_anonymous: Bool
        let hugs: Int64; let created_at: String; let display_name: String
    }
    struct PostPage: Decodable {
        let list: [PostResponse]; let total: Int64
    }

    static func createPost(content: String, scope: String, isAnonymous: Bool) async throws -> PostResponse {
        try await post("/api/v1/treehole/posts", body: PostRequest(content: content, scope: scope, is_anonymous: isAnonymous))
    }
    static func listPosts(page: Int = 1) async throws -> PostPage {
        try await get("/api/v1/treehole/posts?page=\(page)")
    }
    static func hugPost(id: Int64) async throws {
        let _: CCEmptyResponse = try await post("/api/v1/treehole/posts/\(id)/hug", body: nil as String?)
    }

    // MARK: - Courses

    struct CourseItem: Decodable, Identifiable {
        let id: Int64; let title: String; let description: String
        let duration: Int; let category: String; let tag: String
    }

    static func getCourses(category: String = "") async throws -> [CourseItem] {
        let q = category.isEmpty ? "" : "?category=\(category)"
        return try await get("/api/v1/courses\(q)")
    }

    // MARK: - Internal

    private static var authToken: String? {
        CCKeychainManager().get("access_token")
    }

    private static func authHeader() -> [String: String] {
        if let token = authToken { return ["Authorization": "Bearer \(token)"] }
        return [:]
    }

    private static func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        for (k, v) in authHeader() { req.setValue(v, forHTTPHeaderField: k) }
        let (data, _) = try await URLSession.shared.data(for: req)
        let resp = try JSONDecoder().decode(CCAPIResponse<T>.self, from: data)
        guard resp.isSuccess, let d = resp.data else { throw CCAPIError.badRequest }
        return d
    }

    private static func post<T: Decodable, B: Encodable>(_ path: String, body: B?) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (k, v) in authHeader() { req.setValue(v, forHTTPHeaderField: k) }
        if let body = body { req.httpBody = try JSONEncoder().encode(body) }
        let (data, _) = try await URLSession.shared.data(for: req)
        let resp = try JSONDecoder().decode(CCAPIResponse<T>.self, from: data)
        guard resp.isSuccess, let d = resp.data else { throw CCAPIError.badRequest }
        return d
    }
}

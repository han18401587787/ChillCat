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
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
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
    struct JournalEntry: Decodable, Identifiable, Hashable { let id: Int64; let emotion: String; let note: String; let hasDoodle: Bool; let checkinDate: String; let createdAt: String }
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

    struct CourseItem: Decodable, Identifiable, Hashable { let id: Int64; let title: String; let description: String; let duration: Int; let category: String; let tag: String }

    static func getCourses(category: String = "") async throws -> [CourseItem] {
        try await get("/api/v1/courses" + (category.isEmpty ? "" : "?category=\(category)"))
    }

    // MARK: - AI Empathy (AI 倾听官)

    struct EmpathyRequest: Encodable { let text: String }
    struct EmpathyResponse: Decodable { let responses: [String] }
    struct EmpathyFeedbackRequest: Encodable { let responseIndex: Int; let helpful: Bool }

    static func getEmpathyResponses(text: String) async throws -> EmpathyResponse {
        try await post("/api/v1/ai/empathy", body: EmpathyRequest(text: text))
    }
    static func sendEmpathyFeedback(responseIndex: Int, helpful: Bool) async throws {
        let _: CCEmptyResponse = try await post("/api/v1/ai/empathy/feedback", body: EmpathyFeedbackRequest(responseIndex: responseIndex, helpful: helpful))
    }

    // MARK: - Voice Diary (语音日记)

    struct VoiceDiaryResult: Decodable {
        let emotion: String; let confidence: Double; let transcription: String; let tags: [String]; let insight: String?
    }
    struct VoiceAnalysisRequest: Encodable { let audioData: String; let duration: Int }

    static func analyzeVoice(audioData: String, duration: Int) async throws -> VoiceDiaryResult {
        try await post("/api/v1/ai/voice-diary", body: VoiceAnalysisRequest(audioData: audioData, duration: duration))
    }
    static func saveVoiceDiary(audioData: String, duration: Int, transcription: String, tags: [String]) async throws -> TodayResponse {
        try await post("/api/v1/emotion/checkin/voice", body: VoiceAnalysisRequest(audioData: audioData, duration: duration))
    }

    // 语音日记简化版 (Phase 1: 模拟录音，不传音频数据)
    struct VoiceDiaryAnalysisResponse: Decodable {
        let emotion: String; let confidence: Double; let transcription: String; let tags: [String]
    }
    struct VoiceDiarySaveRequest: Encodable {
        let emotion: String; let transcription: String; let tags: [String]
        let confidence: Double; let duration: Int
    }

    static func analyzeVoiceDiary(duration: Int) async throws -> VoiceDiaryAnalysisResponse {
        try await get("/api/v1/ai/voice-diary/analyze?duration=\(duration)")
    }
    static func saveVoiceDiary(emotion: String, transcription: String, tags: [String],
                               confidence: Double, duration: Int) async throws -> TodayResponse {
        try await post("/api/v1/voice-diary/save", body: VoiceDiarySaveRequest(
            emotion: emotion, transcription: transcription, tags: tags,
            confidence: confidence, duration: duration
        ))
    }

    // MARK: - Emotion Decoder (情绪解码器)

    struct DecodeRequest: Encodable { let text: String }
    struct DecodeResponse: Decodable {
        struct Layer: Decodable { let label: String; let icon: String; let confidence: Double? }
        struct Suggestion: Decodable { let type: String; let title: String; let description: String }
        let surfaceEmotion: Layer
        let middleEmotions: [Layer]
        let deepNeeds: [Layer]
        let suggestions: [Suggestion]
    }

    static func decodeEmotion(text: String) async throws -> DecodeResponse {
        try await post("/api/v1/ai/decode", body: DecodeRequest(text: text))
    }

    // MARK: - Resonance Wall (共鸣墙)

    struct ResonanceItem: Decodable, Identifiable, Hashable {
        let id: Int64; let content: String; let emotion: String; let emotionColor: String
        let resonanceCount: Int64; let createdAt: String; let isAnonymous: Bool; let displayName: String
    }
    struct ResonancePage: Decodable { let list: [ResonanceItem]; let total: Int64; let onlineCount: Int64 }
    struct ResonanceDetailResponse: Decodable { let item: ResonanceItem; let replies: [ResonanceReply] }
    struct ResonanceReply: Decodable, Identifiable { let id: Int64; let content: String; let createdAt: String }
        struct ResonancePostRequest: Encodable { let emotion: String; let content: String; let isAnonymous: Bool }

    static func listResonance(page: Int = 1) async throws -> ResonancePage {
        try await get("/api/v1/resonance?page=\(page)")
    }
    static func getResonanceDetail(id: Int64) async throws -> ResonanceDetailResponse {
        try await get("/api/v1/resonance/\(id)")
    }
    static func hugResonance(id: Int64, message: String? = nil) async throws {
        let _ = try await session.request(fullURL("/api/v1/resonance/\(id)/hug"), method: .post,
            parameters: ["message": message].compactMapValues { $0 }, encoder: JSONParameterEncoder.default)
            .validate().serializingData().value
    }
    static func createResonancePost(emotion: String, content: String, isAnonymous: Bool) async throws -> ResonanceItem {
        try await post("/api/v1/resonance/posts", body: ResonancePostRequest(emotion: emotion, content: content, isAnonymous: isAnonymous))
    }

    // MARK: - Encourage Chain (鼓励链)

    struct ChainLink: Decodable, Identifiable, Hashable {
        let id: Int64; let chainId: Int64; let content: String; let position: Int; let createdAt: String
    }
    struct ChainResponse: Decodable { let chainId: Int64; let links: [ChainLink]; let participantCount: Int64 }
    struct ChainParticipateRequest: Encodable { let content: String }

    static func getCurrentChain() async throws -> ChainResponse {
        try await get("/api/v1/encourage-chain/current")
    }
    static func getChain(id: Int64) async throws -> ChainResponse {
        try await get("/api/v1/encourage-chain/\(id)")
    }
    static func participateInChain(content: String) async throws -> ChainLink {
        try await post("/api/v1/encourage-chain/participate", body: ChainParticipateRequest(content: content))
    }
    static func getMyChains() async throws -> [ChainResponse] {
        try await get("/api/v1/encourage-chain/my")
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

import Foundation
import Alamofire
@preconcurrency import KeychainAccess

/// 绪安 API 客户端
/// - Alamofire 处理请求链/重试/响应校验
/// - KeychainAccess 管理 Token 安全存储
enum CCXuanAPI {

    // MARK: - Session

    private static let session: Session = {
        let interceptor = XuanAuthInterceptor()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15   // 单个请求超时15s
        config.timeoutIntervalForResource = 30  // 总资源超时30s
        // 不使用 waitsForConnectivity — 模拟器中不稳定
        return Session(
            configuration: config,
            interceptor: interceptor,
            serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:]),
            eventMonitors: [XuanNetworkLogger()]
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

    /// 情绪预警
    struct EmotionAlert: Decodable, Identifiable { let id: Int64; let type: String; let level: String; let message: String; let createdAt: String }
    static func getEmotionAlerts() async throws -> [EmotionAlert] { try await get("/api/v1/emotion/alerts") }

    // MARK: - TreeHole

    struct PostRequest: Encodable { let content: String; let scope: String; let isAnonymous: Bool }
    struct PostResponse: Decodable, Identifiable { let id: Int64; let content: String; let scope: String; let isAnonymous: Bool; let hugs: Int64; let createdAt: String; let displayName: String }
    struct PostPage: Decodable { let list: [PostResponse]; let total: Int64 }

    static func createPost(content: String, scope: String, isAnonymous: Bool) async throws -> PostResponse {
        try await post("/api/v1/treehole/posts", body: PostRequest(content: content, scope: scope, isAnonymous: isAnonymous))
    }
    static func listPosts(page: Int = 1) async throws -> PostPage { try await get("/api/v1/treehole/posts?page=\(page)") }
    static func hugPost(id: Int64) async throws {
        let path = "/api/v1/treehole/posts/\(id)/hug"
        let start = CFAbsoluteTimeGetCurrent()
        print("🌐 [API] → POST \(path)")
        do {
            let _ = try await session.request(fullURL(path), method: .post)
                .validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            print("✅ [API] ← 200 \(path) (\(elapsed)ms)")
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            print("❌ [API] ← error \(path): \(error.localizedDescription) (\(elapsed)ms)")
            throw error
        }
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

    // MARK: - AI Analyze (AI 分析)

    struct AnalyzeRequest: Encodable { let text: String }
    struct AnalyzeResponse: Decodable {
        let emotion: String; let confidence: Double; let tags: [String]; let insight: String?
    }

    static func analyze(text: String) async throws -> AnalyzeResponse {
        try await post("/api/v1/ai/analyze", body: AnalyzeRequest(text: text))
    }

    // MARK: - Voice Diary (语音日记)

    struct VoiceAnalysisRequest: Encodable { let audioData: String; let duration: Int }
    struct VoiceUploadResult: Decodable {
        let uploadId: String; let status: String
    }
    struct VoiceStatusResult: Decodable {
        let status: String; let emotion: String?; let transcription: String?; let tags: [String]?; let insight: String?
    }

    /// 上传语音日记
    static func uploadVoice(audioData: String, duration: Int) async throws -> VoiceUploadResult {
        try await post("/api/v1/voice/upload", body: VoiceAnalysisRequest(audioData: audioData, duration: duration))
    }
    /// 查询语音处理状态
    static func getVoiceStatus(id: String) async throws -> VoiceStatusResult {
        try await get("/api/v1/voice/\(id)/status")
    }

    // MARK: - Emotion Decoder (情绪解码器)

    struct DecodeRequest: Encodable { let text: String }
    struct DecodeResponse: Decodable {
        struct Layer: Decodable { let label: String; let icon: String; let confidence: Double? }
        struct Suggestion: Decodable { let type: String; let title: String; let description: String }
        let surface: Layer
        let middle: [Layer]
        let deep: [Layer]
        let suggestions: [Suggestion]
    }

    static func decodeEmotion(text: String) async throws -> DecodeResponse {
        try await post("/api/v1/emotion/decode", body: DecodeRequest(text: text))
    }

    // MARK: - Resonance Wall (共鸣墙)

    struct ResonanceItem: Decodable, Identifiable, Hashable {
        let id: Int64; let content: String
        let emotionType: String?  // 服务端返回 emotion_type
        let isAnonymous: Bool; let resonanceCount: Int64
        let createdAt: String; let displayName: String?
    }
    struct ResonancePage: Decodable { let list: [ResonanceItem]; let total: Int64; let onlineCount: Int64? }
    struct ResonanceDetailResponse: Decodable { let item: ResonanceItem; let replies: [ResonanceReply] }
    struct ResonanceReply: Decodable, Identifiable { let id: Int64; let content: String; let createdAt: String }
    struct ResonancePostRequest: Encodable { let emotion: String; let content: String; let isAnonymous: Bool }

    static func listResonance(page: Int = 1) async throws -> ResonancePage {
        try await get("/api/v1/resonance/stories?page=\(page)")
    }
    static func getResonanceDetail(id: Int64) async throws -> ResonanceDetailResponse {
        try await get("/api/v1/resonance/stories/\(id)")
    }
    static func hugResonance(id: Int64, message: String? = nil) async throws {
        let path = "/api/v1/resonance/stories/\(id)/resonate"
        let start = CFAbsoluteTimeGetCurrent()
        print("🌐 [API] → POST \(path)")
        do {
            let _ = try await session.request(fullURL(path), method: .post,
                parameters: ["message": message].compactMapValues { $0 }, encoder: JSONParameterEncoder.default)
                .validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            print("✅ [API] ← 200 \(path) (\(elapsed)ms)")
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            print("❌ [API] ← error \(path): \(error.localizedDescription) (\(elapsed)ms)")
            throw error
        }
    }
    static func createResonancePost(emotion: String, content: String, isAnonymous: Bool) async throws -> ResonanceItem {
        try await post("/api/v1/resonance/stories", body: ResonancePostRequest(emotion: emotion, content: content, isAnonymous: isAnonymous))
    }

    // MARK: - Encourage Chain (鼓励链)

    struct ChainLink: Decodable, Identifiable, Hashable {
        let id: Int64; let chainId: Int64; let content: String; let position: Int; let createdAt: String
    }
    struct ChainResponse: Decodable { let chainId: Int64; let links: [ChainLink]; let participantCount: Int64 }
    struct ChainCreateRequest: Encodable { let status: String; let category: String }
    struct ChainParticipateRequest: Encodable { let content: String }

    static func listChains(status: String? = nil, category: String? = nil, page: Int = 1) async throws -> [ChainResponse] {
        var path = "/api/v1/encourage/chains?page=\(page)"
        if let status { path += "&status=\(status)" }
        if let category { path += "&category=\(category)" }
        return try await get(path)
    }
    static func getChain(id: Int64) async throws -> ChainResponse {
        try await get("/api/v1/encourage/chains/\(id)")
    }
    static func createChain(status: String, category: String) async throws -> ChainResponse {
        try await post("/api/v1/encourage/chains", body: ChainCreateRequest(status: status, category: category))
    }
    static func joinChain(id: Int64, content: String) async throws -> ChainLink {
        try await post("/api/v1/encourage/chains/\(id)/join", body: ChainParticipateRequest(content: content))
    }
    static func getMyChains() async throws -> [ChainResponse] {
        try await get("/api/v1/encourage/my-chains")
    }

    // MARK: - Healing Plan (稳情计划)

    struct HealingPlanResponse: Decodable {
        let id: Int64; let name: String; let description: String; let tasks: [HealingTask]?
    }
    struct HealingTask: Decodable, Identifiable {
        let id: Int64; let title: String; let description: String; let isCompleted: Bool; let sortOrder: Int
    }
    struct HealingPlanGenerateResponse: Decodable {
        let plan: HealingPlanResponse
    }
    struct HealingTaskCompleteResponse: Decodable {
        let task: HealingTask
    }

    /// 获取当前稳情计划
    static func getHealingPlan() async throws -> HealingPlanResponse {
        try await get("/api/v1/healing/plan")
    }
    /// 生成稳情计划
    static func generateHealingPlan() async throws -> HealingPlanResponse {
        let resp: HealingPlanGenerateResponse = try await post("/api/v1/healing/plan/generate", body: Optional<String>.none)
        return resp.plan
    }
    /// 完成任务
    static func completeHealingTask(id: Int64) async throws -> HealingTask {
        let resp: HealingTaskCompleteResponse = try await post("/api/v1/healing/plan/tasks/\(id)/complete", body: Optional<String>.none)
        return resp.task
    }

    // MARK: - Crisis & Safety

    // Crisis resource models
    struct CrisisResourceItem: Decodable, Identifiable {
        let id: Int64
        let name: String
        let phone: String
        let type: String
        let region: String
        let description: String
    }

    struct CrisisResourceListResponse: Decodable {
        let resources: [CrisisResourceItem]
    }

    // Tool usage models
    struct ToolUsageRecord: Encodable {
        let toolType: String
        let duration: Int
        let completed: Bool
    }

    /// 记录工具使用
    static func recordToolUsage(toolType: String, duration: Int, completed: Bool) async throws {
        let record = ToolUsageRecord(toolType: toolType, duration: duration, completed: completed)
        let _: CCEmptyResponse = try await post("/api/v1/tools/usage", body: record)
    }

    // MARK: - Warm Templates

    struct WarmTemplateResponse: Decodable {
        let id: String; let content: String; let emoji: String; let category: String
    }

    static func fetchWarmTemplates() async throws -> [CCWarmResponseTemplate] {
        let raw: [WarmTemplateResponse] = (try? await get("/api/v1/community/warm-templates")) ?? []
        return raw.map { CCWarmResponseTemplate(id: $0.id, content: $0.content, emoji: $0.emoji, category: $0.category) }
    }

    // MARK: - Mutual Aid Groups

    struct MutualAidGroupResponse: Decodable {
        let id: Int64; let name: String; let description: String; let category: String
        let memberCount: Int64; let iconName: String; let isJoined: Bool
    }

    static func fetchMutualAidGroups() async throws -> [CCMutualAidGroup] {
        let raw: [MutualAidGroupResponse] = try await get("/api/v1/community/mutual-aid-groups")
        return raw.map {
            CCMutualAidGroup(id: $0.id, name: $0.name, description: $0.description,
                             category: $0.category, memberCount: $0.memberCount,
                             iconName: $0.iconName, isJoined: $0.isJoined)
        }
    }

    static func joinMutualAidGroup(id: Int64) async throws {
        let path = "/api/v1/community/mutual-aid-groups/\(id)/join"
        let _: CCEmptyResponse = try await post(path, body: Optional<String>.none)
    }

    static func leaveMutualAidGroup(id: Int64) async throws {
        let path = "/api/v1/community/mutual-aid-groups/\(id)/leave"
        let _: CCEmptyResponse = try await post(path, body: Optional<String>.none)
    }

    // MARK: - Growth & Achievement

    // Achievement models
    struct AchievementVO: Decodable, Identifiable {
        let id: Int64
        let code: String
        let name: String
        let description: String
        let iconName: String
        let category: String
        let isUnlocked: Bool
        let progress: Int
        let targetValue: Int
        let progressPercent: Double
        let unlockedAt: String?
    }

    struct AchievementListResponse: Decodable {
        let achievements: [AchievementVO]
    }

    // Milestone models
    struct MilestoneVO: Decodable, Identifiable {
        let id: Int64
        let title: String
        let description: String
        let milestoneType: String
        let createdAt: String
    }

    struct MilestoneListResponse: Decodable {
        let milestones: [MilestoneVO]
    }

    // Growth stats models
    struct GrowthStatsVO: Decodable {
        let totalCheckins: Int64
        let streakDays: Int64
        let emotionTypes: Int64
        let toolUsageCount: Int64
        let communityInteractions: Int64
        let totalDays: Int64
    }

    /// 获取所有成就及用户进度
    static func getAchievements() async throws -> [AchievementVO] {
        let response: AchievementListResponse = try await get("/api/v1/achievements")
        return response.achievements
    }

    /// 获取里程碑列表
    static func getMilestones() async throws -> [MilestoneVO] {
        let response: MilestoneListResponse = try await get("/api/v1/milestones")
        return response.milestones
    }

    /// 获取成长统计
    static func getGrowthStats() async throws -> GrowthStatsVO {
        return try await get("/api/v1/growth/stats")
    }

    // MARK: - Internal helpers

    private static let keychain = Keychain(service: "app.xuanpeace.token")

    private static func fullURL(_ path: String) -> URL {
        URL(string: CCAppEnvironment.current.baseURL.absoluteString + path)!
    }

    private static func get<T: Decodable>(_ path: String) async throws -> T {
        let start = CFAbsoluteTimeGetCurrent()
        print("🌐 [API] → GET \(path)")
        do {
            let data = try await session.request(fullURL(path)).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            // 检测 HTML 响应（DNS 劫持/备案拦截）
            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                print("⚠️ [API] ← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else {
                print("❌ [API] ← code=\(resp.code) \(resp.message) (\(elapsed)ms)")
                throw CCAPIError.badRequest
            }
            print("✅ [API] ← 200 \(path) (\(elapsed)ms)")
            return d
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            print("❌ [API] ← error \(path): \(error.localizedDescription) (\(elapsed)ms)")
            throw error
        }
    }

    private static func post<T: Decodable, B: Encodable>(_ path: String, body: B?) async throws -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let bodyPreview: String = {
            guard let body else { return "nil" }
            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(body),
                  let str = String(data: json, encoding: .utf8) else { return "<encodable>" }
            return String(str.prefix(200))
        }()
        print("🌐 [API] → POST \(path)")
        if body != nil { print("   📤 \(bodyPreview)") }
        do {
            let data = try await session.request(fullURL(path), method: .post, parameters: body, encoder: JSONParameterEncoder.default).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            // 检测 HTML 响应
            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                print("⚠️ [API] ← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else {
                print("❌ [API] ← code=\(resp.code) \(resp.message) (\(elapsed)ms)")
                throw CCAPIError.badRequest
            }
            print("✅ [API] ← 200 \(path) (\(elapsed)ms)")
            return d
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            print("❌ [API] ← error \(path): \(error.localizedDescription) (\(elapsed)ms)")
            throw error
        }
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
        // 添加 Content-Type
        if req.value(forHTTPHeaderField: "Content-Type") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        completion(.success(req))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // 401 时尝试重新匿名登录获取新 token
        if let statusCode = request.response?.statusCode, statusCode == 401 {
            if request.retryCount == 0 {
                print("🔄 [Auth] 401 自动重试匿名登录...")
                Task {
                    do {
                        let resp = try await CCXuanAPI.anonymousLogin()
                        keychain["access_token"] = resp.token
                        print("✅ [Auth] 重试登录成功")
                        completion(.retry)
                    } catch {
                        print("❌ [Auth] 重试登录失败: \(error)")
                        completion(.doNotRetryWithError(error))
                    }
                }
                return
            }
            completion(.doNotRetry)
            return
        }

        // 只对连接错误重试1次，超时/取消不重试
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut,
                 NSURLErrorCancelled,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorCannotFindHost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorNotConnectedToInternet:
                completion(.doNotRetry)  // 超时/DNS/无网络不重试
                return
            default:
                break
            }
        }

        guard request.retryCount < 1 else {
            completion(.doNotRetry); return
        }
        completion(.retryWithDelay(0.5))
    }
}

// MARK: - Network Logger

import OSLog
final class XuanNetworkLogger: EventMonitor {
    private let logger = Logger(subsystem: "app.xuanpeace", category: "API")
    nonisolated(unsafe) private var requestStartTimes: [UUID: CFAbsoluteTime] = [:]
    private let lock = NSLock()

    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        lock.lock()
        requestStartTimes[request.id] = CFAbsoluteTimeGetCurrent()
        lock.unlock()

        let method = urlRequest.httpMethod ?? "?"
        let fullPath = urlRequest.url?.absoluteString ?? urlRequest.url?.path ?? ""
        var msg = "→ \(method) \(fullPath)"

        if let body = urlRequest.httpBody,
           let bodyStr = String(data: body, encoding: .utf8)?.prefix(500) {
            msg += "\n  Body: \(bodyStr)"
        }
        logger.debug("\(msg)")
    }

    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        let elapsed: Int = {
            lock.lock()
            let start = requestStartTimes.removeValue(forKey: request.id)
            lock.unlock()
            guard let start else { return -1 }
            return Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
        }()

        let fullPath = task.originalRequest?.url?.absoluteString
            ?? task.originalRequest?.url?.path ?? ""

        if let e = error {
            let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 0
            logger.error("✗ \(statusCode) \(fullPath) (\(elapsed)ms): \(e.localizedDescription)")
        } else {
            let statusCode = (task.response as? HTTPURLResponse)?.statusCode ?? 0
            logger.debug("✓ \(statusCode) \(fullPath) (\(elapsed)ms)")
        }
    }
}

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

    static func listResonance(page: Int = 1) async throws -> PostPage {
        try await get("/api/v1/treehole/posts?page=\(page)")
    }
    static func getResonanceDetail(id: Int64) async throws -> ResonanceDetailResponse {
        try await get("/api/v1/treehole/posts/\(id)")
    }
    static func hugResonance(id: Int64, message: String? = nil) async throws {
        let path = "/api/v1/treehole/posts/\(id)/hug"
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
        try await post("/api/v1/treehole/posts", body: ResonancePostRequest(emotion: emotion, content: content, isAnonymous: isAnonymous))
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

    // Safety plan models
    struct SafetyPlanData: Codable {
        var warningSigns: [String]
        var strategies: [String]
        var contacts: [String]
        var resources: [String]
    }

    struct SafetyPlanResponse: Decodable {
        let id: Int64
        let warningSigns: [String]
        let strategies: [String]
        let contacts: [String]
        let resources: [String]
    }

    // Tool usage models
    struct ToolUsageRecord: Encodable {
        let toolType: String
        let duration: Int
        let completed: Bool
    }

    struct ToolUsageStats: Decodable {
        let totalCount: Int64
        let totalDuration: Int64
        let lastUsedAt: String?
    }

    /// 获取危机资源列表
    static func getCrisisResources(type: String = "") async throws -> [CrisisResourceItem] {
        let path = "/api/v1/crisis/resources" + (type.isEmpty ? "" : "?type=\(type)")
        let response: CrisisResourceListResponse = try await get(path)
        return response.resources
    }

    /// 获取用户安全计划
    static func getSafetyPlan() async throws -> SafetyPlanResponse {
        try await get("/api/v1/crisis/safety-plan")
    }

    /// 创建/更新安全计划
    static func updateSafetyPlan(_ plan: SafetyPlanData) async throws -> SafetyPlanResponse {
        try await post("/api/v1/crisis/safety-plan", body: plan)
    }

    /// 记录工具使用
    static func recordToolUsage(toolType: String, duration: Int, completed: Bool) async throws {
        let record = ToolUsageRecord(toolType: toolType, duration: duration, completed: completed)
        let _: CCEmptyResponse = try await post("/api/v1/tools/usage", body: record)
    }

    /// 获取工具使用统计
    static func getToolUsageStats(toolType: String) async throws -> ToolUsageStats {
        try await get("/api/v1/tools/usage/stats?toolType=\(toolType)")
    }

    // MARK: - Warm Templates

    struct WarmTemplateResponse: Decodable {
        let id: String; let content: String; let emoji: String; let category: String
    }

    static func fetchWarmTemplates() async throws -> [CCWarmResponseTemplate] {
        let raw: [WarmTemplateResponse] = try await get("/api/v1/community/warm-templates")
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

    // Growth report models
    struct GrowthReportVO: Decodable {
        let stats: GrowthStatsVO
        let topEmotions: [String]?
        let toolDistribution: [String: Int64]?
        let milestones: [MilestoneVO]?
        let insights: [String]?
    }

    /// 获取所有成就及用户进度
    static func getAchievements() async throws -> [AchievementVO] {
        let response: AchievementListResponse = try await get("/api/v1/achievements")
        return response.achievements
    }

    /// 获取已解锁成就
    static func getUnlockedAchievements() async throws -> [AchievementVO] {
        let response: AchievementListResponse = try await get("/api/v1/achievements/unlocked")
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

    /// 获取成长报告
    static func getGrowthReport(period: String = "month") async throws -> GrowthReportVO {
        return try await get("/api/v1/growth/report?period=\(period)")
    }

    // MARK: - Community

    struct MutualAidGroupVO: Decodable, Identifiable {
        let id: Int64
        let name: String
        let description: String
        let category: String
        let memberCount: Int64
        let iconName: String
        let isJoined: Bool
    }

    struct MutualAidGroupListResponse: Decodable {
        let groups: [MutualAidGroupVO]
    }

    struct MutualAidGroupDetailResponse: Decodable {
        let group: MutualAidGroupVO
    }

    struct WarmTemplateVO: Decodable, Identifiable {
        let id: Int64
        let content: String
        let emoji: String
        let category: String
    }

    struct WarmTemplateListResponse: Decodable {
        let templates: [WarmTemplateVO]
    }

    /// 获取互助小组列表
    static func listMutualAidGroups(category: String = "") async throws -> [MutualAidGroupVO] {
        let path = category.isEmpty ? "/community/groups" : "/community/groups?category=\(category)"
        let response: MutualAidGroupListResponse = try await get(path)
        return response.groups
    }

    /// 获取小组详情
    static func getGroupDetail(id: Int64) async throws -> MutualAidGroupVO {
        let response: MutualAidGroupDetailResponse = try await get("/community/groups/\(id)")
        return response.group
    }

    /// 加入小组
    static func joinGroup(id: Int64) async throws {
        let _: CCEmptyResponse = try await post("/community/groups/\(id)/join", body: Optional<String>.none)
    }

    /// 退出小组
    static func leaveGroup(id: Int64) async throws {
        let _: CCEmptyResponse = try await post("/community/groups/\(id)/leave", body: Optional<String>.none)
    }

    /// 获取我的小组
    static func getMyGroups() async throws -> [MutualAidGroupVO] {
        let response: MutualAidGroupListResponse = try await get("/community/my-groups")
        return response.groups
    }

    /// 获取温暖回应模板
    static func getWarmTemplates() async throws -> [WarmTemplateVO] {
        let response: WarmTemplateListResponse = try await get("/community/warm-templates")
        return response.templates
    }

    // MARK: - Analytics

    struct CCInsightsResponse: Decodable {
        let insights: [String]
    }

    struct EmotionTrendVO: Decodable {
        let labels: [String]
        let values: [Double]
        let dominantEmotion: String?
    }

    struct ToolUsageItemVO: Decodable, Identifiable {
        var id: String { toolType }
        let toolType: String
        let count: Int64
        let totalDuration: Int64
    }

    struct ToolUsageDistributionResponse: Decodable {
        let items: [ToolUsageItemVO]
    }

    struct DashboardVO: Decodable {
        let totalCheckins: Int64
        let streakDays: Int64
        let topEmotion: String?
        let toolUsageCount: Int64
        let groupCount: Int64
        let totalDays: Int64
    }

    /// 获取情绪趋势
    static func getEmotionTrend(period: String = "week") async throws -> EmotionTrendVO {
        return try await get("/analytics/emotion-trend?period=\(period)")
    }

    /// 获取工具使用分布
    static func getToolUsageDistribution() async throws -> [ToolUsageItemVO] {
        let response: ToolUsageDistributionResponse = try await get("/analytics/tool-usage")
        return response.items
    }

    /// 获取仪表盘数据
    static func getDashboard() async throws -> DashboardVO {
        return try await get("/analytics/dashboard")
    }

    /// 获取AI洞察
    static func getInsights() async throws -> [String] {
        let response: CCInsightsResponse = try await get("/analytics/insights")
        return response.insights
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
            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else { throw CCAPIError.badRequest }
            let preview = String(data: data, encoding: .utf8)?.prefix(200) ?? ""
            print("✅ [API] ← 200 \(path) (\(elapsed)ms)")
            if !preview.isEmpty { print("   📦 \(preview)") }
            return d
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
            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else { throw CCAPIError.badRequest }
            let preview = String(data: data, encoding: .utf8)?.prefix(200) ?? ""
            print("✅ [API] ← 200 \(path) (\(elapsed)ms)")
            if !preview.isEmpty { print("   📦 \(preview)") }
            return d
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
    private var requestStartTimes: [UUID: CFAbsoluteTime] = [:]
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

// MARK: - Mock Data Provider (开发/演示用)

enum CCMockData {

    private static let emotions: [(String, String)] = [
        ("平静", "66BB6A"), ("开心", "FFC107"), ("焦虑", "D4C8E8"),
        ("委屈", "E8B8C8"), ("孤独", "7A9AAA"), ("烦躁", "FF7043"),
        ("迷茫", "90A4AE"), ("疲惫", "78909C"), ("感恩", "FFAB91"),
        ("期待", "81D4FA"), ("满足", "A5D6A7"), ("失落", "BDBDBD"),
        ("感动", "F48FB1"), ("紧张", "FFCC80"), ("释然", "80CBC4"),
    ]

    private static let notes: [String] = [
        "今天阳光很好，心情也跟着亮了起来。",
        "早上喝了一杯好喝的咖啡，小小确幸。",
        "下雨天适合窝在家里看书。",
        "工作上解决了一个难题，有成就感。",
        "朋友突然发消息说想我了，心里暖暖的。",
        "今天运动了30分钟，感觉充满能量。",
        "地铁上看到一个可爱的小朋友对我笑。",
        "晚上做了一顿好吃的饭，很满足。",
        "收到了一个意外的礼物，好惊喜。",
        "今天有点累，但想想明天就是周五了。",
        "和妈妈通了电话，她说她很好。",
        "刚看完一本好书，想推荐给所有人。",
        "今天效率很高，把所有待办都清完了。",
        "失眠了，脑子里太多事情在转。",
        "面试前紧张得手心出汗，但发挥得还行。",
        "又想家了，虽然已经离开很多年了。",
        "和闺蜜吵架了，心里很难受。",
        "被人误解了，解释不清楚，算了。",
        "看到朋友圈大家都在晒幸福，有点羡慕。",
        "今天不想说话，只想一个人待着。",
        "在地铁上看到一个女孩偷偷擦眼泪。",
        "加班到很晚，楼下保安说辛苦了。",
        "做了一个很美好的梦，醒来有点失落。",
        "突然想起很久没联系的老朋友。",
        "三十岁了还在迷茫，正常吗？",
        "今天不对自己说任何负面的话。打卡！",
        "同事说我最近气色很好，开心。",
        "终于鼓起勇气去看了心理咨询师。",
        "今天散步时看到一只流浪猫，喂了它。",
        "买了一束花放在书桌上，看着心情好。",
        "今天把拖延了三个月的事情终于做完了。",
        "有人说我的笑容很有感染力。",
        "在公司楼下遇到一只会蹭人的猫。",
        "睡了一个很好的午觉，醒来精神饱满。",
        "小区里的桂花开了，好香。",
        "今天穿了一件新衣服，同事都夸好看。",
        "看了夕阳，觉得世界还是很美好的。",
        "把手机屏幕时间减少了，感觉轻松了。",
        "第一次自己做了蛋糕，虽然丑但好吃。",
        "早上起晚了但发现是周六，虚惊一场。",
        "学会了一个新的技能，觉得自己好棒。",
        "大扫除后家里干净整洁，心情舒畅。",
        "一个陌生人帮我扶住了电梯门。",
        "加班到12点，到家发现室友留了宵夜。",
        "收到的工资比预期多，虽然只多了200。",
        "下雨天，在家里点蜡烛听音乐。",
        "今天什么也没发生，平淡但安心。",
        "又看了一遍最爱的电影，还是忍不住哭。",
        "半夜饿了煮了泡面，加了一个蛋。",
        "工作汇报做得很成功，领导表扬了。",
        "今天打了疫苗，胳膊有点疼但值得。",
        "在二手书店淘到了一本绝版书。",
        "给未来的自己写了一封信。",
        "和对象一起看了落日，没有拍照。",
        "在小区楼下捡到一只迷路的小狗。",
        "戒咖啡第三天，头痛但坚持下来了。",
        "今天学会了拒绝别人，感觉好爽。",
        "看到一首诗，泪流满面。",
        "去游乐园坐过山车，尖叫了一整天。",
        "在家躺了一天，什么都没做。",
        "第一次尝试冥想，5分钟就睡着了。",
        "和朋友视频通话聊到凌晨两点。",
        "买了新耳机，音质好极了。",
        "参加了一个线上读书会，认识了新朋友。",
        "今天剪了头发，换了个风格。",
        "在小红书上分享了一篇笔记，有人点赞。",
        "家里的绿植开了第一朵花。",
        "今天把房间重新布置了，像换了个家。",
        "学了一道新菜，味道还不错。",
        "被一只路过的猫选中，它蹭了我的腿。",
        "在直播间里中了9.9包邮的福袋。",
        "花了两个小时整理照片，回忆满满。",
        "路边摊买的糖炒栗子特别甜。",
        "今天决定开始学吉他，买了第一把。",
        "收到了十年前写给自己的信。",
        "在公司年会上抽到了一个加湿器。",
        "下雪了，南方人第一次看到雪。",
        "出差在外的第二个晚上，想家了。",
        "今天帮助了一个迷路的老人找到家人。",
        "早上出门前发现车胎没气了，晚了半小时。",
        "在机场看到一对情侣拥抱告别。",
        "做了一个详细的旅行计划，期待出发。",
        "今天开始写日记，这是第一篇。",
        "去健身房办了卡，希望能坚持。",
        "生日那天一个人去了海边。",
        "年底了，回顾这一年感觉自己成长了很多。",
        "今天和同事一起加班，互相吐槽。",
        "看了最喜欢的乐队的live演出。",
        "在菜市场买到了很新鲜的水果。",
        "把攒了很久的快递盒子送去回收。",
        "今天走了15000步，打破了自己的纪录。",
        "晚上睡不着，起来看星星。",
        "公交车上给一个老人让了座。",
        "和朋友一起去野餐，带了我做的三明治。",
        "今天开始尝试素食，坚持了一天。",
        "下雨天叫了外卖，配送小哥全身湿透。",
        "学会了一句手语：「你很棒」。",
        "被一条温暖的评论治愈了。",
    ]

    // MARK: - 100 Journal Entries

    static func generateJournalEntries(count: Int = 100) -> [CCXuanAPI.JournalEntry] {
        let calendar = Calendar.current
        let today = Date()
        var entries: [CCXuanAPI.JournalEntry] = []

        for i in 0..<count {
            let daysAgo = count - 1 - i
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            let checkinDate = dateFormatter.string(from: date)
            let createdAt = isoFormatter.string(from: date)
            let (emotion, _) = emotions.randomElement()!
            let note = notes.randomElement()!

            entries.append(CCXuanAPI.JournalEntry(
                id: Int64(1000 + i),
                emotion: emotion,
                note: note,
                hasDoodle: i % 7 == 0,
                checkinDate: checkinDate,
                createdAt: createdAt
            ))
        }
        return entries
    }

    // MARK: - Today's Emotion

    static func generateToday() -> CCXuanAPI.TodayResponse {
        let (emotion, _) = emotions.randomElement()!
        return CCXuanAPI.TodayResponse(
            id: 9999,
            emotion: emotion,
            note: notes.randomElement()!,
            checkinDate: dateFormatter.string(from: Date()),
            streakDays: Int64.random(in: 1...21)
        )
    }

    // MARK: - Weekly Stats

    static func generateWeeklyStats() -> CCXuanAPI.WeeklyStats {
        let entries = Array(generateJournalEntries(count: 7).prefix(7))
        let emotionCounts = Dictionary(grouping: entries, by: { $0.emotion })
        let topEmotion = emotionCounts.max(by: { $0.value.count < $1.value.count })?.key ?? "平静"
        let insight = "这周你的情绪以「\(topEmotion)」为主。记录本身就是一种疗愈。"
        return CCXuanAPI.WeeklyStats(
            entries: entries,
            totalCount: Int64(entries.count),
            streakDays: Int64.random(in: 3...21),
            topEmotion: topEmotion,
            insight: insight
        )
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()
}

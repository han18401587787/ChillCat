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
        let id: Int64; let content: String; let emotion: String; let emotionColor: String
        let resonanceCount: Int64; let createdAt: String; let isAnonymous: Bool; let displayName: String
    }
    struct ResonancePage: Decodable { let list: [ResonanceItem]; let total: Int64; let onlineCount: Int64 }
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

    // MARK: - Letters (感谢信)

    struct LetterResponse: Decodable, Identifiable {
        let id: Int64; let content: String; let senderName: String; let receiverName: String?
        let isPublic: Bool; let createdAt: String
    }
    struct LetterPage: Decodable { let list: [LetterResponse]; let total: Int64 }

    /// 发送感谢信
    static func sendLetter(content: String, receiverName: String? = nil, isPublic: Bool = false) async throws -> LetterResponse {
        try await post("/api/v1/letters", body: LetterSendRequest(content: content, receiverName: receiverName, isPublic: isPublic))
    }
    /// 我发出的信
    static func getSentLetters(page: Int = 1) async throws -> LetterPage {
        try await get("/api/v1/letters/sent?page=\(page)")
    }
    /// 我收到的信
    static func getReceivedLetters(page: Int = 1) async throws -> LetterPage {
        try await get("/api/v1/letters/received?page=\(page)")
    }
    /// 信件详情
    static func getLetter(id: Int64) async throws -> LetterResponse {
        try await get("/api/v1/letters/\(id)")
    }

    struct LetterSendRequest: Encodable {
        let content: String; let receiverName: String?; let isPublic: Bool
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

    // MARK: - Member

    struct MemberInfoVO: Decodable {
        let memberType: String; let status: String; let startDate: String
        let endDate: String?; let autoRenew: Bool; let purchaseDate: String
    }

    /// 获取会员信息
    static func getMemberInfo() async throws -> MemberInfoVO {
        try await get("/api/v1/member/info")
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

    // MARK: - Vision (视觉分析)

    /// 视觉完整度分析（用于 CI 自动化测试）
    static func analyzeVision(image: String, page: String, checks: [String] = ["all_elements"]) async throws -> CCVisionAnalyzeResult {
        try await post("/api/v1/vision/analyze", body: CCVisionAnalyzeRequest(image: image, page: page, checks: checks))
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

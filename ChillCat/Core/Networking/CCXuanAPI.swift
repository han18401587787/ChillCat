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
        config.timeoutIntervalForRequest = CCNetworkConfig.requestTimeout   // 统一请求超时
        config.timeoutIntervalForResource = CCNetworkConfig.resourceTimeout // 统一资源超时
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

    struct TokenRefreshRequest: Encodable {
        let refreshToken: String
        enum CodingKeys: String, CodingKey {
            case refreshToken = "refresh_token"
        }
    }

    struct TokenRefreshResponse: Decodable {
        let accessToken: String
        let refreshToken: String
        let userId: Int64?
        let username: String?
    }

    static func anonymousLogin() async throws -> AnonymousResponse {
        try await post("/api/v1/auth/anonymous", body: Optional<String>.none)
    }

    /// 刷新 Token（使用 refresh token 获取新的 access token）
    static func refreshToken(refreshToken: String) async throws -> TokenRefreshResponse {
        try await post("/api/v1/auth/refresh", body: TokenRefreshRequest(refreshToken: refreshToken))
    }

    // MARK: - Auth (Login / Register)

    struct LoginRequest: Encodable { let username: String; let password: String }
    struct RegisterRequest: Encodable { let username: String; let password: String; let email: String }

    static func login(username: String, password: String) async throws -> CCUserDTO {
        try await post("/api/v1/auth/login", body: LoginRequest(username: username, password: password))
    }

    static func register(username: String, password: String, email: String) async throws -> CCUserDTO {
        try await post("/api/v1/auth/register", body: RegisterRequest(username: username, password: password, email: email))
    }

    // MARK: - User Profile

    static func getProfile() async throws -> CCUserDTO {
        try await get("/api/v1/user/profile")
    }

    static func logout() async throws {
        let _: CCEmptyResponse = try await get("/api/v1/auth/logout")
    }

    static func deleteAccount() async throws {
        let _: CCEmptyResponse = try await delete("/api/v1/user/account")
    }

    // MARK: - Member

    static func getMemberInfo() async throws -> CCMemberInfoDTO {
        try await get("/api/v1/member/info")
    }

    static func getMemberProducts() async throws -> [CCMemberProductDTO] {
        let response: CCAPIResponse<[CCMemberProductDTO]> = try await getRaw("/api/v1/member/products")
        return response.data ?? []
    }

    static func getMemberPrivileges() async throws -> [CCMemberPrivilegeDTO] {
        let response: CCAPIResponse<[CCMemberPrivilegeDTO]> = try await getRaw("/api/v1/member/privileges")
        return response.data ?? []
    }

    struct PurchaseRequest: Encodable {
        let productId: String
        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
        }
    }

    static func purchaseMember(productId: String) async throws -> CCMemberInfoDTO {
        try await post("/api/v1/member/purchase", body: PurchaseRequest(productId: productId))
    }

    // MARK: - Emotion

    struct CheckinRequest: Encodable { let emotion: String; let note: String }
    struct TodayResponse: Decodable {
        let id: Int64?
        let emotion: String?
        let note: String?
        let checkinDate: String?
        let streakDays: Int64?
    }
    struct JournalEntry: Decodable, Identifiable, Hashable {
        let id: Int64; let emotion: String?; let note: String?
        let hasDoodle: Bool?; let checkinDate: String?; let createdAt: String?
    }
    struct JournalPage: Decodable { let list: [JournalEntry]?; let total: Int64? }
    struct WeeklyStats: Decodable {
        let entries: [JournalEntry]?; let totalCount: Int64?
        let streakDays: Int64?; let topEmotion: String?; let insight: String?
    }

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

    struct PostRequest: Encodable {
        let content: String; let scope: String; let isAnonymous: Bool
        enum CodingKeys: String, CodingKey {
            case content, scope
            case isAnonymous = "is_anonymous"
        }
    }
    struct PostResponse: Decodable, Identifiable {
        let id: Int64; let content: String?; let scope: String?
        let isAnonymous: Bool?; let hugs: Int64?; let createdAt: String?; let displayName: String?
    }
    struct PostPage: Decodable { let list: [PostResponse]?; let total: Int64? }

    static func createPost(content: String, scope: String, isAnonymous: Bool) async throws -> PostResponse {
        try await post("/api/v1/treehole/posts", body: PostRequest(content: content, scope: scope, isAnonymous: isAnonymous))
    }
    static func listPosts(page: Int = 1) async throws -> PostPage { try await get("/api/v1/treehole/posts?page=\(page)") }
    static func hugPost(id: Int64) async throws {
        let path = "/api/v1/treehole/posts/\(id)/hug"
        let start = CFAbsoluteTimeGetCurrent()
        LogD("→ POST \(path)", module: .network, category: "TreeHole")
        do {
            let data = try await session.request(fullURL(path), method: .post)
                .validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            // 检测 HTML 响应（DNS 劫持）
            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)", module: .network, category: "TreeHole")
                throw CCAPIError.serverError(0)
            }

            // 解析业务码
            let resp = try decoder.decode(CCAPIResponse<CCEmptyResponse>.self, from: data)
            guard resp.isSuccess else {
                LogE("← code=\(resp.code) \(resp.message) (\(elapsed)ms)", module: .network, category: "TreeHole")
                if resp.code == 10002 {
                    try await refreshTokenAndRetry()
                    return try await hugPost(id: id)
                }
                throw apiError(for: resp.code, message: resp.message)
            }
            LogD("← 200 \(path) (\(elapsed)ms)", module: .network, category: "TreeHole")
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error \(path): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "TreeHole", error: error)
            CCErrorReporter.shared.report(error, context: ["path": path, "elapsed_ms": elapsed])
            throw error
        }
    }

    // MARK: - Courses

    struct CourseItem: Decodable, Identifiable, Hashable {
        let id: Int64; let title: String?; let description: String?
        let duration: Int?; let category: String?; let tag: String?
    }

    static func getCourses(category: String = "") async throws -> [CourseItem] {
        try await get("/api/v1/courses" + (category.isEmpty ? "" : "?category=\(category)"))
    }

    // MARK: - AI Empathy (AI 倾听官)

    struct EmpathyRequest: Encodable { let text: String }
    struct EmpathyResponse: Decodable { let responses: [String] }
    struct EmpathyFeedbackRequest: Encodable {
        let responseIndex: Int; let helpful: Bool
        enum CodingKeys: String, CodingKey {
            case responseIndex = "response_index"
            case helpful
        }
    }

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

    struct VoiceAnalysisRequest: Encodable {
        let audioData: String; let duration: Int
        enum CodingKeys: String, CodingKey {
            case audioData = "audio_data"
            case duration
        }
    }
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
        let id: Int64; let content: String?
        let emotionType: String?
        let isAnonymous: Bool?; let resonanceCount: Int64?
        let createdAt: String?; let displayName: String?
    }
    struct ResonancePage: Decodable { let list: [ResonanceItem]?; let total: Int64?; let onlineCount: Int64? }
    struct ResonanceDetailResponse: Decodable {
        let item: ResonanceItem?
        let replies: [ResonanceReply]?
        // 后端可能直接返回 ResonanceItem 而非 {item, replies} 结构
        // 通过自定义解码兼容两种格式
        let id: Int64?
        let content: String?
        let emotionType: String?
        let isAnonymous: Bool?
        let resonanceCount: Int64?
        let displayName: String?
        let createdAt: String?

        var resolvedItem: ResonanceItem? {
            if let item = item { return item }
            if let id = id {
                return ResonanceItem(
                    id: id,
                    content: content,
                    emotionType: emotionType,
                    isAnonymous: isAnonymous,
                    resonanceCount: resonanceCount,
                    createdAt: createdAt,
                    displayName: displayName
                )
            }
            return nil
        }

        var resolvedReplies: [ResonanceReply] {
            replies ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case item, replies
            case id, content, emotionType, isAnonymous, resonanceCount, displayName, createdAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // 尝试解析 {item, replies} 结构
            item = try? container.decodeIfPresent(ResonanceItem.self, forKey: .item)
            replies = try? container.decodeIfPresent([ResonanceReply].self, forKey: .replies)
            // 尝试解析扁平的 ResonanceItem 结构
            id = try? container.decodeIfPresent(Int64.self, forKey: .id)
            content = try? container.decodeIfPresent(String.self, forKey: .content)
            emotionType = try? container.decodeIfPresent(String.self, forKey: .emotionType)
            isAnonymous = try? container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
            resonanceCount = try? container.decodeIfPresent(Int64.self, forKey: .resonanceCount)
            displayName = try? container.decodeIfPresent(String.self, forKey: .displayName)
            createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
        }
    }
    struct ResonanceReply: Decodable, Identifiable { let id: Int64; let content: String?; let createdAt: String? }
    struct ResonancePostRequest: Encodable {
        let emotion: String; let content: String; let isAnonymous: Bool
        enum CodingKeys: String, CodingKey {
            case emotion, content
            case isAnonymous = "is_anonymous"
        }
    }

    static func listResonance(page: Int = 1) async throws -> ResonancePage {
        try await get("/api/v1/resonance/stories?page=\(page)")
    }
    static func getResonanceDetail(id: Int64) async throws -> ResonanceItem {
        // 后端返回扁平的 ResonanceItem 结构，直接解码
        let start = CFAbsoluteTimeGetCurrent()
        LogD("→ GET /api/v1/resonance/stories/\(id)", module: .network, category: "Resonance")
        do {
            let data = try await session.request(fullURL("/api/v1/resonance/stories/\(id)")).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) /api/v1/resonance/stories/\(id) (\(elapsed)ms)", module: .network, category: "Resonance")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<ResonanceItem>.self, from: data)
            guard resp.isSuccess, let d = resp.data else {
                LogE("← code=\(resp.code) \(resp.message) (\(elapsed)ms)", module: .network, category: "Resonance")
                if resp.code == 10002 {
                    try await refreshTokenAndRetry()
                    return try await getResonanceDetail(id: id)
                }
                throw apiError(for: resp.code, message: resp.message)
            }
            LogD("← 200 /api/v1/resonance/stories/\(id) (\(elapsed)ms)", module: .network, category: "Resonance")
            return d
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error /api/v1/resonance/stories/\(id): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "Resonance", error: error)
            CCErrorReporter.shared.report(error, context: ["path": "/api/v1/resonance/stories/\(id)", "elapsed_ms": elapsed])
            throw error
        }
    }
    static func hugResonance(id: Int64, message: String? = nil) async throws {
        let path = "/api/v1/resonance/stories/\(id)/resonate"
        let start = CFAbsoluteTimeGetCurrent()
        LogD("→ POST \(path)", module: .network, category: "Resonance")
        do {
            let data = try await session.request(fullURL(path), method: .post,
                parameters: ["message": message].compactMapValues { $0 }, encoder: JSONParameterEncoder.default)
                .validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            // 检测 HTML 响应（DNS 劫持）
            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)", module: .network, category: "Resonance")
                throw CCAPIError.serverError(0)
            }

            // 解析业务码
            let resp = try decoder.decode(CCAPIResponse<CCEmptyResponse>.self, from: data)
            guard resp.isSuccess else {
                LogE("← code=\(resp.code) \(resp.message) (\(elapsed)ms)", module: .network, category: "Resonance")
                if resp.code == 10002 {
                    try await refreshTokenAndRetry()
                    return try await hugResonance(id: id, message: message)
                }
                throw apiError(for: resp.code, message: resp.message)
            }
            LogD("← 200 \(path) (\(elapsed)ms)", module: .network, category: "Resonance")
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error \(path): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "Resonance", error: error)
            CCErrorReporter.shared.report(error, context: ["path": path, "elapsed_ms": elapsed])
            throw error
        }
    }
    static func createResonancePost(emotion: String, content: String, isAnonymous: Bool) async throws -> ResonanceItem {
        try await post("/api/v1/resonance/stories", body: ResonancePostRequest(emotion: emotion, content: content, isAnonymous: isAnonymous))
    }

    // MARK: - Encourage Chain (鼓励链)

    struct ChainLink: Decodable, Identifiable, Hashable {
        let id: Int64; let chainId: Int64?; let content: String?; let position: Int?; let createdAt: String?
    }
    struct ChainResponse: Decodable { let chainId: Int64?; let links: [ChainLink]?; let participantCount: Int64? }
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
        enum CodingKeys: String, CodingKey {
            case toolType = "tool_type"
            case duration, completed
        }
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

    /// 返回完整 CCAPIResponse，供需要检查 code 的场景使用
    private static func getRaw<T: Decodable>(_ path: String) async throws -> CCAPIResponse<T> {
        let start = CFAbsoluteTimeGetCurrent()
        LogD("→ GET \(path)", module: .network, category: "API")
        do {
            let data = try await session.request(fullURL(path)).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)", module: .network, category: "API")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            LogD("← 200 \(path) code=\(resp.code) (\(elapsed)ms)", module: .network, category: "API")
            return resp
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error \(path): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "API", error: error)
            CCErrorReporter.shared.report(error, context: ["path": path, "elapsed_ms": elapsed])
            throw error
        }
    }

    /// DELETE 请求辅助方法
    private static func delete<T: Decodable>(_ path: String) async throws -> T {
        let start = CFAbsoluteTimeGetCurrent()
        LogD("→ DELETE \(path)", module: .network, category: "API")
        do {
            let data = try await session.request(fullURL(path), method: .delete).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)", module: .network, category: "API")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else {
                LogE("← code=\(resp.code) \(resp.message) (\(elapsed)ms)", module: .network, category: "API")
                throw CCAPIError.badRequest
            }
            LogD("← 200 \(path) (\(elapsed)ms)", module: .network, category: "API")
            return d
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error \(path): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "API", error: error)
            CCErrorReporter.shared.report(error, context: ["path": path, "elapsed_ms": elapsed])
            throw error
        }
    }

    // MARK: - 业务码 → CCAPIError 映射
    private static func apiError(for code: Int, message: String) -> CCAPIError {
        switch code {
        case 10001: return .badRequest
        case 10002: return .unauthorized
        case 10003: return .forbidden
        case 10004: return .notFound
        case 10005: return .tooManyRequests
        case 10006: return .serverError(500)
        case 10007: return .unprocessableEntity
        default:     return .unexpectedStatusCode(code)
        }
    }

    // MARK: - Token 自动刷新（遇到 10002 时调用）
    private static var isRefreshingToken = false
    private static let refreshLock = NSLock()

    private static func refreshTokenAndRetry() async throws {
        refreshLock.lock()
        if isRefreshingToken {
            refreshLock.unlock()
            // 等待正在进行的刷新完成
            for _ in 0..<20 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                refreshLock.lock()
                if !isRefreshingToken {
                    refreshLock.unlock()
                    return
                }
                refreshLock.unlock()
            }
            throw CCAPIError.unauthorized
        }
        isRefreshingToken = true
        refreshLock.unlock()

        defer {
            refreshLock.lock()
            isRefreshingToken = false
            refreshLock.unlock()
        }

        LogI("业务码 10002，自动刷新 token...", module: .auth, category: "Token")
        let keychain = Keychain(service: "app.xuanpeace.token")

        // 优先尝试 refresh_token
        if let refreshToken = keychain["refresh_token"], !refreshToken.isEmpty {
            do {
                let resp = try await CCXuanAPI.refreshToken(refreshToken: refreshToken)
                keychain["access_token"] = resp.accessToken
                if !resp.refreshToken.isEmpty {
                    keychain["refresh_token"] = resp.refreshToken
                }
                LogI("refresh_token 刷新成功", module: .auth, category: "Token")
                return
            } catch {
                LogW("refresh_token 刷新失败: \(error)，尝试匿名登录", module: .auth, category: "Token")
            }
        }

        // 降级：匿名登录
        do {
            let resp = try await anonymousLogin()
            keychain["access_token"] = resp.token
            LogI("匿名登录获取新 token 成功", module: .auth, category: "Token")
        } catch {
            LogE("匿名登录也失败: \(error)", module: .auth, category: "Token", error: error)
            CCErrorReporter.shared.report(error, context: ["stage": "refresh_token_and_retry"])
            try? keychain.remove("access_token")
            try? keychain.remove("refresh_token")
            throw CCAPIError.unauthorized
        }
    }

    private static func get<T: Decodable>(_ path: String) async throws -> T {
        try await getWithRetry(path, retryCount: 0)
    }

    private static func getWithRetry<T: Decodable>(_ path: String, retryCount: Int) async throws -> T {
        let start = CFAbsoluteTimeGetCurrent()
        LogD("→ GET \(path)", module: .network, category: "API")
        do {
            let data = try await session.request(fullURL(path)).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            // 检测 HTML 响应（DNS 劫持/备案拦截）
            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)", module: .network, category: "API")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else {
                LogE("← code=\(resp.code) \(resp.message) (\(elapsed)ms)", module: .network, category: "API")

                // 业务码 10002 = token 过期，自动刷新重试一次
                if resp.code == 10002 && retryCount < 1 {
                    try await refreshTokenAndRetry()
                    LogI("token 已刷新，重试 GET \(path)", module: .network, category: "API")
                    return try await getWithRetry(path, retryCount: retryCount + 1)
                }

                throw apiError(for: resp.code, message: resp.message)
            }
            LogD("← 200 \(path) (\(elapsed)ms)", module: .network, category: "API")
            if elapsed > 10_000 {
                LogW("慢请求 GET \(path) 耗时 \(elapsed)ms", module: .network, category: "Performance")
            }
            return d
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error \(path): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "API", error: error)
            CCErrorReporter.shared.report(error, context: ["path": path, "elapsed_ms": elapsed])
            throw error
        }
    }

    private static func post<T: Decodable, B: Encodable>(_ path: String, body: B?) async throws -> T {
        try await postWithRetry(path, body: body, retryCount: 0)
    }

    private static func postWithRetry<T: Decodable, B: Encodable>(_ path: String, body: B?, retryCount: Int) async throws -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let bodyPreview: String = {
            guard let body else { return "nil" }
            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(body),
                  let str = String(data: json, encoding: .utf8) else { return "<encodable>" }
            return String(str.prefix(200))
        }()
        LogD("→ POST \(path)", module: .network, category: "API")
        if body != nil { LogD("  📤 \(bodyPreview)", module: .network, category: "API") }
        do {
            let data = try await session.request(fullURL(path), method: .post, parameters: body, encoder: JSONParameterEncoder.default).validate().serializingData().value
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)

            // 检测 HTML 响应
            if let str = String(data: data, encoding: .utf8), str.hasPrefix("<!DOCTYPE") || str.hasPrefix("<html") {
                LogW("← HTML response (可能DNS劫持) \(path) (\(elapsed)ms)", module: .network, category: "API")
                throw CCAPIError.serverError(0)
            }

            let resp = try decoder.decode(CCAPIResponse<T>.self, from: data)
            guard resp.isSuccess, let d = resp.data else {
                LogE("← code=\(resp.code) \(resp.message) (\(elapsed)ms)", module: .network, category: "API")

                // 业务码 10002 = token 过期，自动刷新重试一次
                if resp.code == 10002 && retryCount < 1 {
                    try await refreshTokenAndRetry()
                    LogI("token 已刷新，重试 POST \(path)", module: .network, category: "API")
                    return try await postWithRetry(path, body: body, retryCount: retryCount + 1)
                }

                throw apiError(for: resp.code, message: resp.message)
            }
            LogD("← 200 \(path) (\(elapsed)ms)", module: .network, category: "API")
            if elapsed > 10_000 {
                LogW("慢请求 POST \(path) 耗时 \(elapsed)ms", module: .network, category: "Performance")
            }
            return d
        } catch let error as CCAPIError {
            throw error
        } catch {
            let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
            LogE("← error \(path): \(error.localizedDescription) (\(elapsed)ms)", module: .network, category: "API", error: error)
            CCErrorReporter.shared.report(error, context: ["path": path, "elapsed_ms": elapsed])
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
                LogW("401 自动重试匿名登录...", module: .auth, category: "Interceptor")
                Task {
                    do {
                        let resp = try await CCXuanAPI.anonymousLogin()
                        keychain["access_token"] = resp.token
                        LogI("重试登录成功", module: .auth, category: "Interceptor")
                        completion(.retry)
                    } catch {
                        LogE("重试登录失败: \(error)", module: .auth, category: "Interceptor", error: error)
                        CCErrorReporter.shared.report(error, context: ["stage": "401_retry"])
                        completion(.doNotRetryWithError(error))
                    }
                }
                return
            }
            completion(.doNotRetry)
            return
        }

        // 5xx 服务端错误：使用 CCNetworkConfig 配置的重试次数
        if let statusCode = request.response?.statusCode, (500...599).contains(statusCode) {
            let maxRetry = CCNetworkConfig.maxRetryCount
            guard request.retryCount < maxRetry else {
                LogE("5xx 已达最大重试次数(\(maxRetry))，放弃重试", module: .network, category: "Interceptor")
                completion(.doNotRetry); return
            }
            let delay = CCNetworkConfig.retryDelay(for: request.retryCount + 1)
            LogW("5xx 第 \(request.retryCount + 1)/\(maxRetry) 次重试，延迟 \(String(format: "%.1f", delay))s", module: .network, category: "Interceptor")
            completion(.retryWithDelay(delay))
            return
        }

        // 网络错误分类处理
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                // 超时重试（使用配置的重试次数）
                let maxRetry = CCNetworkConfig.maxRetryCount
                guard request.retryCount < maxRetry else {
                    LogE("超时已达最大重试次数(\(maxRetry))，放弃重试", module: .network, category: "Interceptor")
                    completion(.doNotRetry); return
                }
                let delay = CCNetworkConfig.retryDelay(for: request.retryCount + 1)
                LogW("超时第 \(request.retryCount + 1)/\(maxRetry) 次重试，延迟 \(String(format: "%.1f", delay))s", module: .network, category: "Interceptor")
                completion(.retryWithDelay(delay))
                return
            case NSURLErrorCancelled,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorCannotFindHost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorNotConnectedToInternet:
                completion(.doNotRetry)  // DNS/无网络不重试
                return
            default:
                break
            }
        }

        // 其他连接错误：使用配置的重试次数和指数退避
        let maxRetry = CCNetworkConfig.maxRetryCount
        guard request.retryCount < maxRetry else {
            LogE("连接错误已达最大重试次数(\(maxRetry))，放弃重试", module: .network, category: "Interceptor")
            completion(.doNotRetry); return
        }
        let delay = CCNetworkConfig.retryDelay(for: request.retryCount + 1)
        LogW("连接错误第 \(request.retryCount + 1)/\(maxRetry) 次重试，延迟 \(String(format: "%.1f", delay))s", module: .network, category: "Interceptor")
        completion(.retryWithDelay(delay))
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

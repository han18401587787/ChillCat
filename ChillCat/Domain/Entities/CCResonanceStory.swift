//
//  CCResonanceStory.swift
//  绪安
//
//  共鸣墙 — 故事卡片 & 共鸣回应模型
//

import Foundation

/// 共鸣墙故事卡片
struct CCResonanceStory: Identifiable, Codable, Hashable {
    let id: String
    let content: String
    let emotion: CCResonanceEmotion
    var resonanceCount: Int
    var hasResonated: Bool
    let createdAt: Date
    let isAnonymous: Bool

    init(
        id: String = UUID().uuidString,
        content: String,
        emotion: CCResonanceEmotion = .calm,
        resonanceCount: Int = 0,
        hasResonated: Bool = false,
        createdAt: Date = Date(),
        isAnonymous: Bool = true
    ) {
        self.id = id
        self.content = content
        self.emotion = emotion
        self.resonanceCount = resonanceCount
        self.hasResonated = hasResonated
        self.createdAt = createdAt
        self.isAnonymous = isAnonymous
    }

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }
        return "\(Int(d/86400))天前"
    }

    var formattedResonance: String {
        if resonanceCount >= 10000 {
            return String(format: "%.1f万", Double(resonanceCount) / 10000.0)
        }
        return "\(resonanceCount)"
    }

    /// Truncated content (max 280 chars)
    var truncatedContent: String {
        content.count <= 280 ? content : String(content.prefix(280)) + "..."
    }

    var displayName: String { isAnonymous ? "匿名" : "我" }

    /// Sample data
    static let sampleStories: [CCResonanceStory] = [
        CCResonanceStory(
            content: "三十岁生日一个人过的，给自己买了个小蛋糕。有点孤独，但也挺自由的。",
            emotion: .calm, resonanceCount: 2341, createdAt: Date().addingTimeInterval(-7200)
        ),
        CCResonanceStory(
            content: "下周一就答辩了，PPT 改了八遍了还是不满意。",
            emotion: .anxious, resonanceCount: 892, createdAt: Date().addingTimeInterval(-18000)
        ),
        CCResonanceStory(
            content: "今天下班路上看到夕阳特别美，站在天桥上看了好久。好像很久没有这样停下来过了。",
            emotion: .calm, resonanceCount: 1205, createdAt: Date().addingTimeInterval(-36000)
        ),
        CCResonanceStory(
            content: "妈妈打电话说我太久没回家了，我嘴上说忙，其实是不知道该以什么样的状态面对他们。",
            emotion: .wronged, resonanceCount: 678, createdAt: Date().addingTimeInterval(-54000)
        ),
    ]
}

/// 共鸣情绪类型
enum CCResonanceEmotion: String, Codable, Hashable, CaseIterable {
    case calm    = "平静"
    case anxious = "焦虑"
    case sad     = "难过"
    case wronged = "委屈"
    case lonely  = "孤独"
    case moved   = "感动"

    var id: String { rawValue }

    /// 左侧情绪色条颜色 (hex)
    var colorHex: String {
        switch self {
        case .calm:    return "66BB6A"
        case .anxious: return "D4C8E8"
        case .sad:     return "B8D4E3"
        case .wronged: return "E8B8C8"
        case .lonely:  return "7A9AAA"
        case .moved:   return "C9A063"
        }
    }

    /// 对应 SF Symbol 图标
    var iconName: String {
        switch self {
        case .calm:    return "leaf.fill"
        case .anxious: return "tornado"
        case .sad:     return "cloud.rain.fill"
        case .wronged: return "drop.fill"
        case .lonely:  return "cloud.fill"
        case .moved:   return "heart.fill"
        }
    }

    /// 共鸣色点 emoji
    var dotEmoji: String {
        switch self {
        case .calm:    return "🟢"
        case .anxious: return "🟡"
        case .sad:     return "🔵"
        case .wronged: return "🩷"
        case .lonely:  return "🩵"
        case .moved:   return "🟠"
        }
    }
}

/// 共鸣回应 (全屏详情)
struct CCResonanceResponse: Identifiable, Codable, Hashable {
    let id: String
    let storyId: String
    let message: String   // 鼓励语
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        storyId: String,
        message: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.storyId = storyId
        self.message = message
        self.createdAt = createdAt
    }

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }
        return "\(Int(d/86400))天前"
    }
}

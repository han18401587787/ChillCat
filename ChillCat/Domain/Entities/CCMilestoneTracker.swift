//
//  CCMilestoneTracker.swift
//  ChillCat
//
//  成长档案 — 里程碑实体
//

import Foundation

// MARK: - Milestone Type

enum CCMilestoneType: String, Codable, CaseIterable {
    case streak    = "坚持"
    case emotion   = "情绪"
    case tool      = "工具"
    case community = "社区"
    case personal  = "个人"

    var displayName: String { rawValue }

    var iconName: String {
        switch self {
        case .streak:    return "flame.fill"
        case .emotion:   return "chart.pie.fill"
        case .tool:      return "hammer.fill"
        case .community: return "heart.fill"
        case .personal:  return "person.fill"
        }
    }
}

// MARK: - Milestone

struct CCMilestone: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let type: CCMilestoneType
}

// MARK: - Growth Stats

struct CCGrowthStats: Codable {
    let totalCheckins: Int
    let emotionTypes: Int
    let toolsUsed: Int
    let communityInteractions: Int
    let streakDays: Int
    let totalDiaryEntries: Int
    let totalMeditationMinutes: Int
    let aiInsights: [String]
    let topEmotions: [(String, Int)]        // (emotion name, count)
    let toolUsage: [(String, Int)]          // (tool name, count)
    let growthKeywords: [String]
}

// MARK: - Mock Data

extension CCMilestone {
    static let mockMilestones: [CCMilestone] = [
        .init(id: "m1",  title: "完成首次情绪打卡",     description: "迈出了关注内心世界的第一步",          date: Date().addingTimeInterval(-86400 * 30), type: .emotion),
        .init(id: "m2",  title: "连续打卡7天达成",      description: "坚持让觉察成为习惯",                  date: Date().addingTimeInterval(-86400 * 23), type: .streak),
        .init(id: "m3",  title: "首次使用呼吸训练",     description: "学会了用呼吸安抚自己",                date: Date().addingTimeInterval(-86400 * 20), type: .tool),
        .init(id: "m4",  title: "完成第一次冥想",       description: "体验了独处放松的力量",                date: Date().addingTimeInterval(-86400 * 17), type: .tool),
        .init(id: "m5",  title: "记录5种不同情绪",      description: "你的情绪词汇越来越丰富了",            date: Date().addingTimeInterval(-86400 * 14), type: .emotion),
        .init(id: "m6",  title: "发布第一篇共鸣帖",     description: "勇敢地表达了真实的自己",              date: Date().addingTimeInterval(-86400 * 11), type: .community),
        .init(id: "m7",  title: "创建个人安全计划",     description: "为自己建立了一份安全守护",            date: Date().addingTimeInterval(-86400 * 8),  type: .personal),
        .init(id: "m8",  title: "连续打卡21天达成",     description: "你已经形成了稳定的觉察习惯",          date: Date().addingTimeInterval(-86400 * 5),  type: .streak),
        .init(id: "m9",  title: "使用3种不同工具",      description: "找到了适合自己的疗愈方式",            date: Date().addingTimeInterval(-86400 * 3),  type: .tool),
        .init(id: "m10", title: "累计打卡30天",         description: "一个月的成长，值得庆祝",              date: Date().addingTimeInterval(-86400 * 1),  type: .milestone),
    ]
}

extension CCGrowthStats {
    static let mock: CCGrowthStats = .init(
        totalCheckins: 32,
        emotionTypes: 7,
        toolsUsed: 5,
        communityInteractions: 23,
        streakDays: 12,
        totalDiaryEntries: 18,
        totalMeditationMinutes: 145,
        aiInsights: [
            "你最近的焦虑情绪有所减少，平静和开心的时刻变多了。",
            "使用CBT认知重构后，你的负面思维频率下降了约30%。",
            "你在独处放松方面表现突出，建议继续保持这个习惯。",
            "你的情绪词汇量在增长，这说明你对自己的感受越来越敏锐了。",
        ],
        topEmotions: [("平静", 12), ("开心", 8), ("焦虑", 5), ("疲惫", 3), ("孤独", 2)],
        toolUsage: [("呼吸训练", 10), ("冥想", 8), ("感恩日记", 5), ("CBT认知重构", 3), ("身体扫描", 2)],
        growthKeywords: ["自我觉察", "坚持", "平静", "成长", "疗愈", "勇气", "接纳", "表达", "放松", "感恩", "觉察", "蜕变"]
    )
}

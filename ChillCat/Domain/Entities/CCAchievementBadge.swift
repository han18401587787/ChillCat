//
//  CCAchievementBadge.swift
//  ChillCat
//
//  成长档案 — 成就徽章实体
//

import Foundation

struct CCAchievementBadge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: CCBadgeCategory
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Int
    var targetValue: Int

    var progressPercent: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(progress) / Double(targetValue), 1.0)
    }

    var isCompleted: Bool {
        progress >= targetValue
    }

    enum CCBadgeCategory: String, Codable, CaseIterable {
        case streak    = "坚持"
        case emotion   = "情绪"
        case tool      = "工具"
        case community = "社区"
        case milestone = "里程碑"

        var displayName: String { rawValue }

        var sortOrder: Int {
            switch self {
            case .streak:    return 0
            case .emotion:   return 1
            case .tool:      return 2
            case .community: return 3
            case .milestone: return 4
            }
        }
    }
}

// MARK: - Predefined Badges

extension CCAchievementBadge {
    static let allBadges: [CCAchievementBadge] = [
        .init(id: "first_checkin",       name: "初来乍到",    description: "完成首次情绪打卡",           iconName: "leaf.fill",                   category: .emotion,   isUnlocked: false, progress: 0, targetValue: 1),
        .init(id: "streak_7",            name: "情绪探索者",  description: "连续打卡7天",                iconName: "flame.fill",                  category: .streak,    isUnlocked: false, progress: 0, targetValue: 7),
        .init(id: "streak_30",           name: "坚韧之星",    description: "连续打卡30天",               iconName: "star.fill",                   category: .streak,    isUnlocked: false, progress: 0, targetValue: 30),
        .init(id: "checkin_100",         name: "百日记念",    description: "累计打卡100天",              iconName: "calendar.badge.clock",         category: .milestone, isUnlocked: false, progress: 0, targetValue: 100),
        .init(id: "emotions_5",          name: "情绪观察者",  description: "记录5种不同情绪",            iconName: "eye.fill",                    category: .emotion,   isUnlocked: false, progress: 0, targetValue: 5),
        .init(id: "emotions_10",         name: "情绪图谱",    description: "记录全部10种情绪",           iconName: "chart.pie.fill",              category: .emotion,   isUnlocked: false, progress: 0, targetValue: 10),
        .init(id: "tools_3",             name: "工具探索者",  description: "使用3种不同工具",            iconName: "hammer.fill",                 category: .tool,      isUnlocked: false, progress: 0, targetValue: 3),
        .init(id: "tools_5",             name: "工具箱达人",  description: "使用5种不同工具",            iconName: "wrench.and.screwdriver.fill",  category: .tool,      isUnlocked: false, progress: 0, targetValue: 5),
        .init(id: "tools_all",           name: "全情投入",    description: "使用全部10种工具",           iconName: "trophy.fill",                 category: .tool,      isUnlocked: false, progress: 0, targetValue: 10),
        .init(id: "posts_1",             name: "勇敢发声",    description: "发布第一篇共鸣帖",           iconName: "megaphone.fill",              category: .community, isUnlocked: false, progress: 0, targetValue: 1),
        .init(id: "posts_10",            name: "共鸣之声",    description: "发布10篇帖子",               iconName: "message.fill",                category: .community, isUnlocked: false, progress: 0, targetValue: 10),
        .init(id: "hugs_50",             name: "鼓励天使",    description: "送出50次温暖拥抱",           iconName: "heart.fill",                  category: .community, isUnlocked: false, progress: 0, targetValue: 50),
        .init(id: "safety_plan",         name: "安全守护者",  description: "创建个人安全计划",           iconName: "shield.checkered",             category: .milestone, isUnlocked: false, progress: 0, targetValue: 1),
        .init(id: "meditation_10",       name: "冥想修行者",  description: "完成10次冥想练习",           iconName: "brain.head.profile",           category: .tool,      isUnlocked: false, progress: 0, targetValue: 10),
        .init(id: "journal_30",          name: "日记达人",    description: "写满30篇情绪日记",           iconName: "book.fill",                   category: .emotion,   isUnlocked: false, progress: 0, targetValue: 30),
        .init(id: "gratitude_21",        name: "感恩之心",    description: "连续21天写感恩日记",         iconName: "heart.text.square.fill",       category: .streak,    isUnlocked: false, progress: 0, targetValue: 21),
        .init(id: "cbt_5",               name: "思维重塑者",  description: "完成5次CBT认知重构",         iconName: "brain.fill",                  category: .tool,      isUnlocked: false, progress: 0, targetValue: 5),
        .init(id: "body_scan_10",        name: "身体觉察者",  description: "完成10次身体扫描",           iconName: "figure.mind.and.body",         category: .tool,      isUnlocked: false, progress: 0, targetValue: 10),
        .init(id: "values_done",         name: "价值明确者",  description: "完成价值观探索练习",         iconName: "compass.drawing",             category: .tool,      isUnlocked: false, progress: 0, targetValue: 1),
        .init(id: "activation_7",        name: "行动派",      description: "连续7天完成行为激活",        iconName: "bolt.fill",                   category: .streak,    isUnlocked: false, progress: 0, targetValue: 7),
    ]
}

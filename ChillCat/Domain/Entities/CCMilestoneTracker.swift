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

struct CCGrowthStats {
    let totalCheckins: Int
    let emotionTypes: Int
    let toolsUsed: Int
    let communityInteractions: Int
    let streakDays: Int
    let totalDiaryEntries: Int
    let totalMeditationMinutes: Int
    let aiInsights: [String]
    let topEmotions: [EmotionCount]
    let toolUsage: [ToolUsageCount]
    let growthKeywords: [String]
}

struct EmotionCount: Codable {
    let name: String
    let count: Int
}

struct ToolUsageCount: Codable {
    let name: String
    let count: Int
}


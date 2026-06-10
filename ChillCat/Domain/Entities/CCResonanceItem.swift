//
//  CCResonanceItem.swift
//  绪安 - 共鸣墙 实体
//

import Foundation

/// 共鸣墙卡片
struct CCResonanceItem: Identifiable, Hashable {
    let id: Int64
    let content: String
    let emotion: String
    let emotionColor: String
    let resonanceCount: Int64
    let createdAt: Date
    let isAnonymous: Bool
    let displayName: String
    var hasResonated: Bool

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d / 60))分钟前" }
        if d < 86400 { return "\(Int(d / 3600))小时前" }
        return "\(Int(d / 86400))天前"
    }

    var emotionDotColor: String {
        switch emotion {
        case "平静", "calm": return "66BB6A"
        case "开心", "happy": return "C9A063"
        case "焦虑", "anxious": return "D4C8E8"
        case "疲惫", "tired": return "B8D4E3"
        case "委屈", "wronged": return "E8B8C8"
        case "孤独", "lonely": return "7A9AAA"
        case "烦躁", "irritable": return "E57373"
        case "迷茫", "confused": return "E8D9F0"
        case "易怒", "anger": return "8B6F47"
        case "内耗", "drained": return "AAAAAA"
        default: return "5A7A8A"
        }
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CCResonanceItem, rhs: CCResonanceItem) -> Bool { lhs.id == rhs.id }
}

/// 共鸣回复
struct CCResonanceReply: Identifiable {
    let id: Int64
    let content: String
    let createdAt: Date
    var displayName: String?

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d / 60))分钟前" }
        if d < 86400 { return "\(Int(d / 3600))小时前" }
        return "\(Int(d / 86400))天前"
    }
}

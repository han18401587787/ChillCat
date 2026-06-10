//
//  CCEncourageChain.swift
//  绪安 - 鼓励链 实体
//

import Foundation

/// 鼓励链节点 (单条接力)
struct CCEncourageChainLink: Identifiable, Hashable, Codable {
    let id: Int64
    let chainId: Int64
    let content: String
    let position: Int
    let createdAt: Date

    var displayName: String { "匿名" }

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d / 60))分钟前" }
        if d < 86400 { return "\(Int(d / 3600))小时前" }
        return "\(Int(d / 86400))天前"
    }

    /// 接力阶段图标
    var stageIcon: String {
        switch position {
        case 0: return "🌸"
        case 1: return "💪"
        default: return "🍀"
        }
    }

    /// 接力阶段标签
    var stageLabel: String {
        switch position {
        case 0: return "起点"
        case 1: return "接力"
        default: return "继续"
        }
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CCEncourageChainLink, rhs: CCEncourageChainLink) -> Bool { lhs.id == rhs.id }
}

/// 完整鼓励链
struct CCEncourageChain: Identifiable, Codable {
    let id: Int64
    let chainNumber: Int64
    let links: [CCEncourageChainLink]
    let participantCount: Int64
    let createdAt: Date

    var displayTitle: String { "鼓励链 #\(chainNumber)" }

    var milestone: Int? {
        let m = (Int(participantCount) / 100) * 100
        return m > 0 ? m : nil
    }

    var remainingToNextMilestone: Int {
        let m = milestone ?? 0
        return max(0, 100 - (Int(participantCount) - m))
    }

    /// Sample data
    static let sampleChain: CCEncourageChain = CCEncourageChain(
        id: 2841,
        chainNumber: 2841,
        links: [
            CCEncourageChainLink(
                id: 1, chainId: 2841,
                content: "今天我想鼓励每一个正在焦虑的人。你担心的事情，90%都不会发生。",
                position: 0, createdAt: Date().addingTimeInterval(-7200)
            ),
            CCEncourageChainLink(
                id: 2, chainId: 2841,
                content: "谢谢！我今天正需要这个。也鼓励每一个在努力的人。",
                position: 1, createdAt: Date().addingTimeInterval(-3600)
            ),
            CCEncourageChainLink(
                id: 3, chainId: 2841,
                content: "面试刚挂了，但看到这条觉得好多了。接力！",
                position: 2, createdAt: Date().addingTimeInterval(-1800)
            ),
        ],
        participantCount: 47,
        createdAt: Date().addingTimeInterval(-7200)
    )

    /// "我的鼓励链" sample
    static let myChains: [CCEncourageChain] = [sampleChain]
}

/// 鼓励链里程碑
struct CCChainMilestone: Identifiable, Codable {
    let id: Int64
    let chainNumber: Int64
    let targetCount: Int
    let title: String
    let description: String
}

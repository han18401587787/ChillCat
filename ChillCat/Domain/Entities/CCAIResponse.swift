//
//  CCAIResponse.swift
//  绪安
//
//  AI 情绪倾听官 — AI 回应模型
//

import Foundation

/// AI 单条回应
struct CCAIResponse: Identifiable, Codable, Hashable {
    let id: String
    let emoji: String
    let text: String
    var feedback: CCFeedbackState

    init(
        id: String = UUID().uuidString,
        emoji: String = "💚",
        text: String,
        feedback: CCFeedbackState = .none
    ) {
        self.id = id
        self.emoji = emoji
        self.text = text
        self.feedback = feedback
    }
}

enum CCFeedbackState: String, Codable, Hashable {
    case none
    case helpful
    case notHelpful
}

/// AI 倾听会话 (单次对话)
struct CCAISession: Identifiable, Codable, Hashable {
    let id: String
    let userInput: String
    let responses: [CCAIResponse]
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        userInput: String,
        responses: [CCAIResponse],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userInput = userInput
        self.responses = responses
        self.createdAt = createdAt
    }

    var timeAgo: String {
        let d = Date().timeIntervalSince(createdAt)
        if d < 60 { return "刚刚" }
        if d < 3600 { return "\(Int(d/60))分钟前" }
        if d < 86400 { return "\(Int(d/3600))小时前" }
        return "\(Int(d/86400))天前"
    }

    var aiEmojis: [String] { ["💚", "🌿", "🕊️"] }

    /// 本地占位数据 (无网络时)
    static let placeholderResponses: [CCAIResponse] = [
        CCAIResponse(emoji: "💚", text: "听到你了"),
        CCAIResponse(emoji: "🌿", text: "我理解这种感觉"),
        CCAIResponse(emoji: "🕊️", text: "愿意多说一点吗？")
    ]
}

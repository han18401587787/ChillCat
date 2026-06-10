//
//  CCEmotionDecode.swift
//  绪安 - 情绪解码器 实体
//

import Foundation

/// 情绪解码器单层结果
struct CCEmotionLayer: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let confidence: Double?
}

/// 情绪解码建议
struct CCDecodeSuggestion: Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let description: String

    var iconName: String {
        switch type {
        case "breathe": return "wind"
        case "write": return "pencil.and.outline"
        case "read": return "book.fill"
        case "move": return "figure.walk"
        case "meditate": return "sparkles"
        case "talk": return "bubble.left.and.bubble.right"
        default: return "lightbulb.fill"
        }
    }
}

/// 情绪解码器完整结果
struct CCEmotionDecodeResult {
    let surfaceEmotion: CCEmotionLayer
    let middleEmotions: [CCEmotionLayer]
    let deepNeeds: [CCEmotionLayer]
    let suggestions: [CCDecodeSuggestion]
}

/// 情绪解码阶段
enum CCDecodeStage: Int, Equatable, Comparable {
    case input = 0
    case submitting
    case surface
    case middle
    case deep
    case suggestions
    case complete
    case error

    static func < (lhs: CCDecodeStage, rhs: CCDecodeStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

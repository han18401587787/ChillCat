import SwiftUI

// MARK: - EmotionColors v3.0
/// 绪安情绪色板 - 基于Ardot CCEmotion.swift设计规范
/// 10色情绪色板，严格遵循Ardot设计稿
enum EmotionColors {
    // MARK: - 10色情绪色板（Ardot设计规范）
    
    /// 平静 — Ardot 薄荷绿
    static let calm = Color(hex: "A8D9BA")
    /// 开心 — Ardot 暖杏
    static let happy = Color(hex: "D4A882")
    /// 疲惫
    static let tired = Color(hex: "7ABF9E")
    /// 焦虑
    static let anxious = Color(hex: "A085C6")
    /// 委屈 — Ardot 樱花粉
    static let wronged = Color(hex: "F5A6BA")
    /// 孤独 — Ardot 信息蓝
    static let lonely = Color(hex: "63B5F5")
    /// 烦躁 — Ardot 危机红
    static let irritable = Color(hex: "E67373")
    /// 迷茫
    static let lost = Color(hex: "E8D9F0")
    /// 易怒 — Ardot 深暖杏
    static let angry = Color(hex: "D4A882")
    /// 内耗
    static let overthinking = Color(hex: "8C7D6E")
    
    // MARK: - 情绪列表（Ardot设计规范）
    
    static let allEmotions: [(name: String, chinese: String, color: Color, sfSymbol: String)] = [
        ("calm", "平静", calm, "leaf.fill"),
        ("happy", "开心", happy, "sun.max.fill"),
        ("tired", "疲惫", tired, "cloud.fill"),
        ("anxious", "焦虑", anxious, "waveform.path.ecg"),
        ("wronged", "委屈", wronged, "drop.fill"),
        ("lonely", "孤独", lonely, "moon.fill"),
        ("irritable", "烦躁", irritable, "flame.fill"),
        ("lost", "迷茫", lost, "questionmark.circle.fill"),
        ("angry", "易怒", angry, "exclamationmark.triangle.fill"),
        ("overthinking", "内耗", overthinking, "arrow.triangle.2.circlepath")
    ]
    
    // MARK: - 情绪分类
    
    enum Category: String, CaseIterable {
        case positive = "正面"
        case negative = "负面"
        case mixed = "混合"
        
        var emotions: [(name: String, chinese: String, color: Color)] {
            switch self {
            case .positive:
                return [("calm", "平静", calm), ("happy", "开心", happy)]
            case .negative:
                return [
                    ("tired", "疲惫", tired),
                    ("anxious", "焦虑", anxious),
                    ("wronged", "委屈", wronged),
                    ("lonely", "孤独", lonely),
                    ("irritable", "烦躁", irritable),
                    ("angry", "易怒", angry)
                ]
            case .mixed:
                return [("lost", "迷茫", lost), ("overthinking", "内耗", overthinking)]
            }
        }
    }
    
    // MARK: - 情绪强度
    
    enum Intensity: Int, CaseIterable {
        case veryLow = 1
        case low = 2
        case moderate = 3
        case high = 4
        case veryHigh = 5
        
        var color: Color {
            switch self {
            case .veryLow: return Color(hex: "B8D4E3")
            case .low: return Color(hex: "7A9AAA")
            case .moderate: return Color(hex: "C9A063")
            case .high: return Color(hex: "E57373")
            case .veryHigh: return Color(hex: "8B6F47")
            }
        }
    }
    
    // MARK: - 根据情绪名称获取颜色
    
    static func color(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "calm", "平静": return calm
        case "happy", "开心": return happy
        case "tired", "疲惫": return tired
        case "anxious", "焦虑": return anxious
        case "wronged", "委屈": return wronged
        case "lonely", "孤独": return lonely
        case "irritable", "烦躁": return irritable
        case "lost", "迷茫": return lost
        case "angry", "易怒": return angry
        case "overthinking", "内耗": return overthinking
        default: return Color.xuanApricot
        }
    }
}

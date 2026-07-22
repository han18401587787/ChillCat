//
//  CCEmotionSet.swift
//  绪安 v3.0 — 24 款原创情绪表情元数据定义
//
//  基于 Plutchik 情绪轮简化：6 种基础情绪 × 4 种强度 = 24 款表情
//

import SwiftUI

// MARK: - CCEmotionType（情绪类型）

enum CCEmotionType: String, CaseIterable {
    case joy
    case sadness
    case anger
    case fear
    case disgust
    case surprise

    var displayName: String {
        switch self {
        case .joy:      return "快乐"
        case .sadness:  return "悲伤"
        case .anger:    return "愤怒"
        case .fear:     return "恐惧"
        case .disgust:  return "厌恶"
        case .surprise: return "惊喜"
        }
    }

    var colorHex: String {
        switch self {
        case .joy:      return "F5A623"   // v3 暖化: F9A826 → F5A623
        case .sadness:  return "7A9AAA"   // v3 暖化: 5A7A8A → 7A9AAA
        case .anger:    return "E8846E"   // v3 暖化: E06C5C → E8846E
        case .fear:     return "A085C6"   // v3 暖化: 8E6BBF → A085C6
        case .disgust:  return "7CB887"   // v3 暖化: 6DBF6E → 7CB887
        case .surprise: return "D4A85C"   // v3 暖化: C9A063 → D4A85C
        }
    }

    var color: Color {
        Color(hex: colorHex)
    }

    var iconName: String {
        switch self {
        case .joy:      return "sun.max.fill"
        case .sadness:  return "cloud.rain.fill"
        case .anger:    return "flame.fill"
        case .fear:     return "moon.stars.fill"
        case .disgust:  return "leaf.fill"
        case .surprise: return "sparkles"
        }
    }
}

// MARK: - CCEmotionIntensity（强度等级）

enum CCEmotionIntensity: Int, CaseIterable {
    case mild     = 1
    case moderate = 2
    case strong   = 3
    case extreme  = 4

    var displayName: String {
        switch self {
        case .mild:     return "轻微"
        case .moderate: return "中等"
        case .strong:   return "强烈"
        case .extreme:  return "极度"
        }
    }

    var description: String {
        switch self {
        case .mild:     return "日常打卡、轻度情绪"
        case .moderate: return "情绪日记、一般表达"
        case .strong:   return "情绪解码、共鸣墙"
        case .extreme:  return "危机信号、需要关注"
        }
    }

    /// 视觉缩放因子：强度越高，表情越大
    var visualScale: CGFloat {
        switch self {
        case .mild:     return 0.85
        case .moderate: return 1.0
        case .strong:   return 1.12
        case .extreme:  return 1.25
        }
    }

    /// 视觉透明度：强度越高，越不透明
    var visualOpacity: Double {
        switch self {
        case .mild:     return 0.7
        case .moderate: return 0.85
        case .strong:   return 1.0
        case .extreme:  return 1.0
        }
    }
}

// MARK: - CCEmotionEmoji（单个表情定义）

struct CCEmotionEmoji: Identifiable, Hashable {
    /// "joy_1", "sadness_3" 等
    let id: String
    let emotionType: CCEmotionType
    let intensity: CCEmotionIntensity
    /// 中文名："平静", "开心", "狂喜" 等
    let displayName: String
    /// Asset Catalog 中的图片名，格式 emotion_{type}_{intensity}，如 emotion_joy_1
    let assetName: String
    /// 简短描述
    let description: String
    /// 搜索关键词
    let keywords: [String]
    /// Lottie 动画文件名（可选，后续由设计师补充）
    let lottieAnimationName: String?

    // MARK: - Placeholder 占位渲染

    /// 用纯色圆形 + 文字渲染占位表情（后续替换为原创设计稿）
    @ViewBuilder
    func placeholderView(size: CGFloat = 48) -> some View {
        let displayChar = placeholderCharacter

        ZStack {
            Circle()
                .fill(emotionType.color.opacity(intensity == .mild ? 0.2 : 0.3))

            Text(displayChar)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(emotionType.color)

            // 强度指示环
            Circle()
                .stroke(emotionType.color.opacity(0.5), lineWidth: intensityIndicatorWidth)
        }
        .frame(width: size, height: size)
    }

    /// 占位字符映射
    private var placeholderCharacter: String {
        switch emotionType {
        case .joy:      return intensity.joyChar
        case .sadness:  return intensity.sadnessChar
        case .anger:    return intensity.angerChar
        case .fear:     return intensity.fearChar
        case .disgust:  return intensity.disgustChar
        case .surprise: return intensity.surpriseChar
        }
    }

    private var intensityIndicatorWidth: CGFloat {
        switch intensity {
        case .mild:     return 1
        case .moderate: return 2
        case .strong:   return 2.5
        case .extreme:  return 3
        }
    }
}

// MARK: - 强度占位字符映射

private extension CCEmotionIntensity {
    var joyChar: String {
        switch self {
        case .mild: return "☺️"
        case .moderate: return "😊"
        case .strong: return "😄"
        case .extreme: return "🤩"
        }
    }
    var sadnessChar: String {
        switch self {
        case .mild: return "😔"
        case .moderate: return "😢"
        case .strong: return "😭"
        case .extreme: return "💔"
        }
    }
    var angerChar: String {
        switch self {
        case .mild: return "😐"
        case .moderate: return "😠"
        case .strong: return "😡"
        case .extreme: return "🤬"
        }
    }
    var fearChar: String {
        switch self {
        case .mild: return "😟"
        case .moderate: return "😨"
        case .strong: return "😱"
        case .extreme: return "🫣"
        }
    }
    var disgustChar: String {
        switch self {
        case .mild: return "🙁"
        case .moderate: return "😒"
        case .strong: return "🤢"
        case .extreme: return "🤮"
        }
    }
    var surpriseChar: String {
        switch self {
        case .mild: return "🤔"
        case .moderate: return "😯"
        case .strong: return "😲"
        case .extreme: return "🤯"
        }
    }
}

// MARK: - CCEmotionSet（表情集合）

enum CCEmotionSet {

    // MARK: - 24 款表情完整定义

    static let all: [CCEmotionEmoji] = [
        // ── 快乐 (Joy) ──
        CCEmotionEmoji(
            id: "joy_1",
            emotionType: .joy,
            intensity: .mild,
            displayName: "平静",
            assetName: "emotion_joy_1",
            description: "内心平和，安宁舒适",
            keywords: ["平静", "安宁", "舒适", "平和", "放松"],
            lottieAnimationName: "emotion_joy_1"
        ),
        CCEmotionEmoji(
            id: "joy_2",
            emotionType: .joy,
            intensity: .moderate,
            displayName: "愉悦",
            assetName: "emotion_joy_2",
            description: "心情愉悦，面带微笑",
            keywords: ["愉悦", "微笑", "轻松", "惬意", "满足"],
            lottieAnimationName: "emotion_joy_2"
        ),
        CCEmotionEmoji(
            id: "joy_3",
            emotionType: .joy,
            intensity: .strong,
            displayName: "开心",
            assetName: "emotion_joy_3",
            description: "由衷开心，欢喜洋溢",
            keywords: ["开心", "高兴", "欢喜", "快乐", "兴奋"],
            lottieAnimationName: "emotion_joy_3"
        ),
        CCEmotionEmoji(
            id: "joy_4",
            emotionType: .joy,
            intensity: .extreme,
            displayName: "狂喜",
            assetName: "emotion_joy_4",
            description: "欣喜若狂，无比激动",
            keywords: ["狂喜", "激动", "狂喜", "兴奋不已", "欢呼"],
            lottieAnimationName: "emotion_joy_4"
        ),

        // ── 悲伤 (Sadness) ──
        CCEmotionEmoji(
            id: "sadness_1",
            emotionType: .sadness,
            intensity: .mild,
            displayName: "低落",
            assetName: "emotion_sadness_1",
            description: "情绪低落，有些闷闷不乐",
            keywords: ["低落", "闷闷不乐", "消沉", "没精神"],
            lottieAnimationName: "emotion_sadness_1"
        ),
        CCEmotionEmoji(
            id: "sadness_2",
            emotionType: .sadness,
            intensity: .moderate,
            displayName: "难过",
            assetName: "emotion_sadness_2",
            description: "心中难过，想要倾诉",
            keywords: ["难过", "伤感", "忧愁", "心酸", "委屈"],
            lottieAnimationName: "emotion_sadness_2"
        ),
        CCEmotionEmoji(
            id: "sadness_3",
            emotionType: .sadness,
            intensity: .strong,
            displayName: "悲伤",
            assetName: "emotion_sadness_3",
            description: "悲伤涌上心头，难以释怀",
            keywords: ["悲伤", "哀伤", "伤心", "悲痛", "哭泣"],
            lottieAnimationName: "emotion_sadness_3"
        ),
        CCEmotionEmoji(
            id: "sadness_4",
            emotionType: .sadness,
            intensity: .extreme,
            displayName: "悲痛",
            assetName: "emotion_sadness_4",
            description: "极度悲痛，需要陪伴和支持",
            keywords: ["悲痛", "绝望", "崩溃", "心碎", "需要帮助"],
            lottieAnimationName: "emotion_sadness_4"
        ),

        // ── 愤怒 (Anger) ──
        CCEmotionEmoji(
            id: "anger_1",
            emotionType: .anger,
            intensity: .mild,
            displayName: "不悦",
            assetName: "emotion_anger_1",
            description: "微微不快，略有不满",
            keywords: ["不悦", "不满", "不爽", "烦躁", "介意"],
            lottieAnimationName: "emotion_anger_1"
        ),
        CCEmotionEmoji(
            id: "anger_2",
            emotionType: .anger,
            intensity: .moderate,
            displayName: "生气",
            assetName: "emotion_anger_2",
            description: "心中生气，需要宣泄",
            keywords: ["生气", "恼火", "气愤", "不快", "发怒"],
            lottieAnimationName: "emotion_anger_2"
        ),
        CCEmotionEmoji(
            id: "anger_3",
            emotionType: .anger,
            intensity: .strong,
            displayName: "愤怒",
            assetName: "emotion_anger_3",
            description: "怒火中烧，难以平静",
            keywords: ["愤怒", "暴怒", "怒不可遏", "火大", "气炸"],
            lottieAnimationName: "emotion_anger_3"
        ),
        CCEmotionEmoji(
            id: "anger_4",
            emotionType: .anger,
            intensity: .extreme,
            displayName: "暴怒",
            assetName: "emotion_anger_4",
            description: "极度愤怒，需要冷静和疏导",
            keywords: ["暴怒", "狂怒", "怒发冲冠", "失控", "需要冷静"],
            lottieAnimationName: "emotion_anger_4"
        ),

        // ── 恐惧 (Fear) ──
        CCEmotionEmoji(
            id: "fear_1",
            emotionType: .fear,
            intensity: .mild,
            displayName: "紧张",
            assetName: "emotion_fear_1",
            description: "略微紧张，心神不宁",
            keywords: ["紧张", "不安", "焦虑", "心慌", "忐忑"],
            lottieAnimationName: "emotion_fear_1"
        ),
        CCEmotionEmoji(
            id: "fear_2",
            emotionType: .fear,
            intensity: .moderate,
            displayName: "害怕",
            assetName: "emotion_fear_2",
            description: "感到害怕，想要退缩",
            keywords: ["害怕", "畏惧", "胆怯", "退缩", "担忧"],
            lottieAnimationName: "emotion_fear_2"
        ),
        CCEmotionEmoji(
            id: "fear_3",
            emotionType: .fear,
            intensity: .strong,
            displayName: "恐惧",
            assetName: "emotion_fear_3",
            description: "深深恐惧，无法自拔",
            keywords: ["恐惧", "恐慌", "战栗", "惊惶", "毛骨悚然"],
            lottieAnimationName: "emotion_fear_3"
        ),
        CCEmotionEmoji(
            id: "fear_4",
            emotionType: .fear,
            intensity: .extreme,
            displayName: "惊恐",
            assetName: "emotion_fear_4",
            description: "极度惊恐，需要安抚和安全感",
            keywords: ["惊恐", "惊骇", "魂飞魄散", "需要安全感", "求助"],
            lottieAnimationName: "emotion_fear_4"
        ),

        // ── 厌恶 (Disgust) ──
        CCEmotionEmoji(
            id: "disgust_1",
            emotionType: .disgust,
            intensity: .mild,
            displayName: "不适",
            assetName: "emotion_disgust_1",
            description: "略感不适，有点别扭",
            keywords: ["不适", "别扭", "不舒服", "反感", "不对劲"],
            lottieAnimationName: "emotion_disgust_1"
        ),
        CCEmotionEmoji(
            id: "disgust_2",
            emotionType: .disgust,
            intensity: .moderate,
            displayName: "讨厌",
            assetName: "emotion_disgust_2",
            description: "心生讨厌，想要远离",
            keywords: ["讨厌", "嫌弃", "厌恶", "不喜欢", "排斥"],
            lottieAnimationName: "emotion_disgust_2"
        ),
        CCEmotionEmoji(
            id: "disgust_3",
            emotionType: .disgust,
            intensity: .strong,
            displayName: "厌恶",
            assetName: "emotion_disgust_3",
            description: "强烈厌恶，难以忍受",
            keywords: ["厌恶", "恶心", "反感", "憎恶", "受不了"],
            lottieAnimationName: "emotion_disgust_3"
        ),
        CCEmotionEmoji(
            id: "disgust_4",
            emotionType: .disgust,
            intensity: .extreme,
            displayName: "憎恶",
            assetName: "emotion_disgust_4",
            description: "极度憎恶，需要情绪疏导",
            keywords: ["憎恶", "深恶痛绝", "痛恨", "无法忍受", "需要疏导"],
            lottieAnimationName: "emotion_disgust_4"
        ),

        // ── 惊喜 (Surprise) ──
        CCEmotionEmoji(
            id: "surprise_1",
            emotionType: .surprise,
            intensity: .mild,
            displayName: "好奇",
            assetName: "emotion_surprise_1",
            description: "微微好奇，想知道更多",
            keywords: ["好奇", "感兴趣", "探索", "疑问", "期待"],
            lottieAnimationName: "emotion_surprise_1"
        ),
        CCEmotionEmoji(
            id: "surprise_2",
            emotionType: .surprise,
            intensity: .moderate,
            displayName: "惊讶",
            assetName: "emotion_surprise_2",
            description: "感到惊讶，出乎意料",
            keywords: ["惊讶", "意外", "没想到", "诧异", "吃惊"],
            lottieAnimationName: "emotion_surprise_2"
        ),
        CCEmotionEmoji(
            id: "surprise_3",
            emotionType: .surprise,
            intensity: .strong,
            displayName: "惊喜",
            assetName: "emotion_surprise_3",
            description: "又惊又喜，激动不已",
            keywords: ["惊喜", "喜出望外", "激动", "开心", "振奋"],
            lottieAnimationName: "emotion_surprise_3"
        ),
        CCEmotionEmoji(
            id: "surprise_4",
            emotionType: .surprise,
            intensity: .extreme,
            displayName: "震撼",
            assetName: "emotion_surprise_4",
            description: "心灵震撼，难以置信",
            keywords: ["震撼", "震惊", "难以置信", "惊呆了", "不可思议"],
            lottieAnimationName: "emotion_surprise_4"
        ),
    ]

    // MARK: - 筛选

    static func filter(by type: CCEmotionType) -> [CCEmotionEmoji] {
        all.filter { $0.emotionType == type }
    }

    static func filter(by intensity: CCEmotionIntensity) -> [CCEmotionEmoji] {
        all.filter { $0.intensity == intensity }
    }

    /// 按关键词搜索
    static func search(_ query: String) -> [CCEmotionEmoji] {
        guard !query.isEmpty else { return all }
        let lowercased = query.lowercased()
        return all.filter { emoji in
            emoji.keywords.contains { $0.lowercased().contains(lowercased) }
            || emoji.displayName.lowercased().contains(lowercased)
            || emoji.description.lowercased().contains(lowercased)
        }
    }

    /// 根据 ID 查找
    static func byID(_ id: String) -> CCEmotionEmoji? {
        all.first { $0.id == id }
    }
}

// MARK: - 最近使用管理

struct CCEmotionRecentManager {
    private static let storageKey = "CCEmotionRecentIDs"
    private static let maxCount = 12

    /// 获取最近使用的表情 ID 列表
    static var recentIDs: [String] {
        UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }

    /// 获取最近使用的表情
    static var recentEmojis: [CCEmotionEmoji] {
        recentIDs.compactMap { CCEmotionSet.byID($0) }
    }

    /// 记录使用
    static func record(_ emoji: CCEmotionEmoji) {
        var ids = recentIDs
        ids.removeAll { $0 == emoji.id }
        ids.insert(emoji.id, at: 0)
        if ids.count > maxCount {
            ids = Array(ids.prefix(maxCount))
        }
        UserDefaults.standard.set(ids, forKey: storageKey)
    }

    /// 清空记录
    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

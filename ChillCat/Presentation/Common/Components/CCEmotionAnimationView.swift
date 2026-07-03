//
//  CCEmotionAnimationView.swift
//  ChillCat — Lottie 情绪动画组件
//

import SwiftUI
import Lottie

/// 情绪类型 → Lottie 动画文件名映射
enum CCEmotionAnimation: String, CaseIterable {
    case joy       = "joy"
    case sadness   = "sadness"
    case anger     = "anger"
    case fear      = "fear"
    case disgust   = "disgust"
    case surprise  = "surprise"
    case calm      = "calm"
    case anxiety   = "anxiety"

    /// 根据情绪名称获取动画枚举
    static func from(_ emotionString: String) -> CCEmotionAnimation {
        let lower = emotionString.lowercased()
        switch lower {
        case "joy", "开心", "快乐", "happy":      return .joy
        case "sadness", "悲伤", "sad":            return .sadness
        case "anger", "愤怒", "angry":            return .anger
        case "fear", "恐惧", "害怕":              return .fear
        case "disgust", "厌恶":                   return .disgust
        case "surprise", "惊讶":                  return .surprise
        case "calm", "平静":                      return .calm
        case "anxiety", "焦虑", "anxious":        return .anxiety
        default:                                   return .calm
        }
    }

    /// Lottie 动画文件名（不含 .json 扩展名）
    /// 每个 emotion 有 4 个等级变体，默认用 level 1
    func lottieName(level: Int = 1) -> String {
        let clampedLevel = max(1, min(4, level))
        switch self {
        case .joy:      return "emotion_joy_\(clampedLevel)"
        case .sadness:  return "emotion_sadness_\(clampedLevel)"
        case .anger:    return "emotion_anger_\(clampedLevel)"
        case .fear:     return "emotion_fear_\(clampedLevel)"
        case .disgust:  return "emotion_disgust_\(clampedLevel)"
        case .surprise: return "emotion_surprise_\(clampedLevel)"
        case .calm:     return "emotion_joy_\(clampedLevel)"     // calm 暂用 joy
        case .anxiety:  return "emotion_fear_\(clampedLevel)"    // anxiety 暂用 fear
        }
    }
}

/// Lottie 情绪动画视图
struct CCEmotionAnimationView: View {
    let emotion: CCEmotionAnimation
    let level: Int
    let loopMode: LottieLoopMode
    let size: CGFloat

    init(
        emotion: CCEmotionAnimation,
        level: Int = 1,
        loopMode: LottieLoopMode = .loop,
        size: CGFloat = 60
    ) {
        self.emotion = emotion
        self.level = level
        self.loopMode = loopMode
        self.size = size
    }

    /// 从字符串便捷初始化
    init(
        emotion: String,
        level: Int = 1,
        loopMode: LottieLoopMode = .loop,
        size: CGFloat = 60
    ) {
        self.emotion = CCEmotionAnimation.from(emotion)
        self.level = level
        self.loopMode = loopMode
        self.size = size
    }

    var body: some View {
        let animationName = emotion.lottieName(level: level)

        if LottieAnimation.named(animationName, bundle: .main) != nil {
            LottieView(animation: LottieAnimation.named(animationName))
                .playbackMode(.playing(.toProgress(1, loopMode: loopMode)))
                .animationSpeed(1.0)
                .frame(width: size, height: size)
        } else {
            // Fallback: 显示 emoji
            Text(emoji)
                .font(.system(size: size * 0.6))
                .frame(width: size, height: size)
        }
    }

    private var emoji: String {
        switch emotion {
        case .joy:      return "😊"
        case .sadness:  return "😢"
        case .anger:    return "😠"
        case .fear:     return "😨"
        case .disgust:  return "😖"
        case .surprise: return "😲"
        case .calm:     return "😌"
        case .anxiety:  return "😰"
        }
    }
}

// MARK: - 点赞心跳动画（Lottie + SwiftUI fallback）

/// 点赞/共鸣心跳动画
/// 使用 Lottie joy 动画（项目中有 emotion_joy_1~4），播放一次
/// 如果 Lottie 文件不存在则使用 SwiftUI 原生动画
struct CCHeartBeatAnimation: View {
    @Binding var trigger: Bool
    let size: CGFloat

    init(trigger: Binding<Bool>, size: CGFloat = 40) {
        self._trigger = trigger
        self.size = size
    }

    var body: some View {
        // 使用 joy 动画作为点赞反馈（项目中有 emotion_joy_1~4.json）
        let lottieName = "emotion_joy_2"
        if LottieAnimation.named(lottieName) != nil {
            LottieView(animation: LottieAnimation.named(lottieName))
                .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                .animationSpeed(1.5)
                .frame(width: size, height: size)
                .scaleEffect(trigger ? 1.0 : 0.3)
                .opacity(trigger ? 1 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: trigger)
        } else {
            // Fallback: SwiftUI 原生心跳动画
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.5))
                .foregroundColor(Color.xuanPink)
                .scaleEffect(trigger ? 1.4 : 1.0)
                .opacity(trigger ? 1.0 : 0.7)
                .animation(.spring(response: 0.25, dampingFraction: 0.3), value: trigger)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Lottie 扩展：检查动画是否存在

extension LottieAnimation {
    /// 安全加载动画，不存在返回 nil（不崩溃）
    static func safeNamed(_ name: String, bundle: Bundle = .main) -> LottieAnimation? {
        return LottieAnimation.named(name, bundle: bundle)
    }
}

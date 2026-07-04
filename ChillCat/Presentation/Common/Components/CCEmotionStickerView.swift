//
//  CCEmotionStickerView.swift
//  绪安 - Emotion Sticker component for Emotion Decoder
//
//  Created by doudou.han on 2026/6/10.
//

import SwiftUI

// MARK: - Sticker Style

enum CCEmotionStickerStyle {
    /// Compact circle with icon only (40pt)
    case compact
    /// Circle with icon + short label (60pt)
    case label
    /// Full card with icon, emotion name, and description
    case card
    /// Layered card with depth indicator (for 表层/中层/深层)
    case layered(depth: CCLayerDepth)
}

enum CCLayerDepth: String {
    case surface  = "表层情绪"
    case middle   = "中层情绪"
    case deep     = "深层需求"

    var label: String { rawValue }

    var color: Color {
        switch self {
        case .surface: return Color(hex: "A085C6")   // softPurple
        case .middle:  return Color.xuanInfo   // primaryMuted
        case .deep:    return Color.xuanMint    // softGreen
        }
    }

    var iconName: String {
        switch self {
        case .surface: return "bubble.left.fill"
        case .middle:  return "arrow.triangle.branch"
        case .deep:    return "heart.fill"
        }
    }
}

// MARK: - Emotion Sticker Data

struct CCEmotionStickerData: Identifiable {
    let id: String
    let emotion: CCEmotion
    let emoji: String
    let label: String
    let description: String?

    init(emotion: CCEmotion, emoji: String, label: String, description: String? = nil) {
        self.id = emotion.id
        self.emotion = emotion
        self.emoji = emoji
        self.label = label
        self.description = description
    }

    /// Match CCEmotion to a representative emoji
    static func from(_ emotion: CCEmotion) -> CCEmotionStickerData {
        switch emotion {
        case .calm:      return .init(emotion: emotion, emoji: "😌", label: emotion.rawValue)
        case .happy:     return .init(emotion: emotion, emoji: "😊", label: emotion.rawValue)
        case .tired:     return .init(emotion: emotion, emoji: "😴", label: emotion.rawValue)
        case .anxious:   return .init(emotion: emotion, emoji: "😰", label: emotion.rawValue)
        case .wronged:   return .init(emotion: emotion, emoji: "🥺", label: emotion.rawValue)
        case .lonely:    return .init(emotion: emotion, emoji: "😢", label: emotion.rawValue)
        case .irritable: return .init(emotion: emotion, emoji: "😤", label: emotion.rawValue)
        case .confused:  return .init(emotion: emotion, emoji: "🤔", label: emotion.rawValue)
        case .anger:     return .init(emotion: emotion, emoji: "😡", label: emotion.rawValue)
        case .drained:   return .init(emotion: emotion, emoji: "🫠", label: emotion.rawValue)
        }
    }
}

// MARK: - Emotion Color Mapping

extension CCEmotion {
    /// Returns the mapped theme color for this emotion
    var emotionColor: Color {
        switch colorName {
        case "softGreen":       return Color.xuanMint
        case "warmLight":       return Color.xuanApricotDark
        case "primaryMuted":    return Color.xuanInfo
        case "softPurple":      return Color(hex: "A085C6")
        case "softPink":        return Color.xuanPink
        case "primaryLight":    return Color.xuanInfo
        case "error":           return Color.xuanDanger
        case "softPurpleLight": return Color(hex: "A085C6").opacity(0.3)
        case "warm":            return Color.xuanApricotDark
        case "textMuted":       return Color.xuanTextTertiary
        default:                return Color.xuanApricotDark
        }
    }
}

// MARK: - CCEmotionStickerView

struct CCEmotionStickerView: View {
    let data: CCEmotionStickerData
    let style: CCEmotionStickerStyle
    var animate: Bool = true

    @State private var isVisible = false

    var body: some View {
        Group {
            switch style {
            case .compact:
                compactSticker
            case .label:
                labelSticker
            case .card:
                cardSticker
            case .layered(let depth):
                layeredSticker(depth: depth)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.6)
        .onAppear {
            if animate {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isVisible = true
                }
            } else {
                isVisible = true
            }
        }
    }

    // MARK: - Compact

    private var compactSticker: some View {
        Text(data.emoji)
            .font(.system(size: 28))
            .frame(width: 44, height: 44)
            .background(data.emotion.emotionColor.opacity(0.15))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(data.emotion.emotionColor.opacity(0.4), lineWidth: 1.5)
            )
            .contentShape(Circle())
    }

    // MARK: - Label

    private var labelSticker: some View {
        VStack(spacing: 4) {
            Text(data.emoji)
                .font(.system(size: 24))
            Text(data.label)
                .font(.system(size: 11))
                .foregroundColor(data.emotion.emotionColor)
                .lineLimit(1)
        }
        .frame(width: 64, height: 64)
        .background(
            Circle()
                .fill(data.emotion.emotionColor.opacity(0.12))
        )
        .overlay(
            Circle()
                .stroke(data.emotion.emotionColor.opacity(0.3), lineWidth: 1.5)
        )
    }

    // MARK: - Card

    private var cardSticker: some View {
        HStack(spacing: 12) {
            CCIconMapper.image(for: data.emotion.iconName)
                .font(.system(size: 22))
                .foregroundColor(data.emotion.emotionColor)
                .frame(width: 44, height: 44)
                .background(data.emotion.emotionColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(data.label)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.xuanTextPrimary)
                if let desc = data.description {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(Color.xuanTextSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.xuanApricotBg)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(data.emotion.emotionColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Layered (for Emotion Decoder)

    private func layeredSticker(depth: CCLayerDepth) -> some View {
        VStack(spacing: 0) {
            // Depth label badge
            HStack(spacing: 4) {
                CCIconMapper.image(for: depth.iconName)
                    .font(.system(size: 10))
                Text(depth.label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(depth.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(depth.color.opacity(0.15))
            )

            Spacer().frame(height: 10)

            // Emotion content
            VStack(spacing: 6) {
                Text(data.emoji)
                    .font(.system(size: 36))

                Text(data.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.xuanTextPrimary)

                if let desc = data.description {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(Color.xuanTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(depth.color.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(depth.color.opacity(0.25), lineWidth: 1)
            )
        }
    }
}

// MARK: - Connecting Arrow (breathing animation)

struct CCEmotionLayerArrow: View {
    @State private var breathing = false

    var body: some View {
        VStack(spacing: 2) {
            Image("common_more")
                .font(.system(size: 20, weight: .medium))
            Image("common_more")
                .font(.system(size: 20, weight: .medium))
                .offset(y: -8)
        }
        .foregroundColor(Color.xuanInfo)
        .scaleEffect(breathing ? 1.15 : 0.9)
        .opacity(breathing ? 1.0 : 0.5)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
            ) {
                breathing = true
            }
        }
    }
}

// MARK: - Emotion Decoder Section (groups sticker + arrow)

struct CCEmotionDecoderLayer: View {
    let data: CCEmotionStickerData
    let depth: CCLayerDepth
    let showArrow: Bool
    var animate: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            CCEmotionStickerView(data: data, style: .layered(depth: depth), animate: animate)

            if showArrow {
                CCEmotionLayerArrow()
                    .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CCEmotionStickerView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Compact").font(.headline)
                HStack(spacing: 12) {
                    CCEmotionStickerView(data: .from(.anxious), style: .compact)
                    CCEmotionStickerView(data: .from(.calm), style: .compact)
                    CCEmotionStickerView(data: .from(.happy), style: .compact)
                }

                Text("Label").font(.headline)
                HStack(spacing: 12) {
                    CCEmotionStickerView(data: .from(.anxious), style: .label)
                    CCEmotionStickerView(data: .from(.tired), style: .label)
                }

                Text("Card").font(.headline)
                CCEmotionStickerView(
                    data: .init(
                        emotion: .anxious,
                        emoji: "😰",
                        label: "焦虑",
                        description: "对不确定性的担忧，常常伴随着身体紧张"
                    ),
                    style: .card
                )
                .padding(.horizontal)

                Text("Layered (Emotion Decoder)").font(.headline)
                VStack(spacing: 0) {
                    CCEmotionDecoderLayer(
                        data: .init(emotion: .anxious, emoji: "😰", label: "焦虑"),
                        depth: .surface,
                        showArrow: true
                    )
                    CCEmotionDecoderLayer(
                        data: .init(emotion: .confused, emoji: "🤔", label: "对不确定性的恐惧"),
                        depth: .middle,
                        showArrow: true
                    )
                    CCEmotionDecoderLayer(
                        data: .init(emotion: .calm, emoji: "💚", label: "需要安全感"),
                        depth: .deep,
                        showArrow: false
                    )
                }
            }
            .padding()
        }
        .background(Color.xuanApricotBg)
    }
}
#endif

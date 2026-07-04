//
//  CCEmojiPicker.swift
//  绪安 v3.0 — 24 款原创情绪表情选择器
//
//  基于 Plutchik 情绪轮：6 种基础情绪 × 4 种强度 = 24 款表情
//  替换旧版系统 Emoji 体系，全面升级为情绪表情系统
//

import SwiftUI

// MARK: - CCEmojiPicker

struct CCEmojiPicker: View {
    @Binding var isShowing: Bool
    var onSelect: (CCEmotionEmoji) -> Void

    @State private var selectedType: CCEmotionType = .joy
    @State private var searchText: String = ""
    @State private var appeared = false
    @State private var animatingEmojiID: String?
    @State private var recentEmojis: [CCEmotionEmoji] = CCEmotionRecentManager.recentEmojis
    @State private var previewEmoji: CCEmotionEmoji?

    /// 当前显示的表情列表
    private var displayEmojis: [CCEmotionEmoji] {
        if !searchText.isEmpty {
            return CCEmotionSet.search(searchText)
        }
        return CCEmotionSet.filter(by: selectedType)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.xuanTextTertiary.opacity(0.35))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 6)

            // 搜索栏
            searchBar
                .padding(.horizontal, XuanSpacing.md)
                .padding(.bottom, 8)

            // 情绪类型 Tab 栏
            typeTabs
                .padding(.bottom, 8)

            // 活跃分类指示条
            activeTypeBar
                .padding(.horizontal, XuanSpacing.md)
                .padding(.bottom, 8)

            // 最近使用（仅在非搜索模式下显示）
            if searchText.isEmpty && !recentEmojis.isEmpty {
                recentSection
            }

            // 表情网格
            emojiGrid

            // 强度说明（非搜索模式下）
            if searchText.isEmpty {
                intensityLegend
                    .padding(.horizontal, XuanSpacing.md)
                    .padding(.top, XuanSpacing.sm)
                    .padding(.bottom, 4)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: XuanRadius.xl)
                .fill(Color.xuanApricotBg)
                .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
        )
        .offset(y: appeared ? 0 : 300)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: appeared)
        .onAppear {
            appeared = true
            recentEmojis = CCEmotionRecentManager.recentEmojis
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image("common_search")
                .font(.system(size: 14))
                .foregroundColor(Color.xuanTextTertiary)

            TextField("搜索表情...", text: $searchText)
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextPrimary)

            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanTextTertiary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: XuanRadius.sm)
                .fill(Color.xuanSurface)
        )
    }

    // MARK: - Type Tabs

    private var typeTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: XuanSpacing.xs) {
                ForEach(CCEmotionType.allCases, id: \.self) { type in
                    typeTab(type)
                }
            }
            .padding(.horizontal, XuanSpacing.md)
        }
    }

    private func typeTab(_ type: CCEmotionType) -> some View {
        let isSelected = selectedType == type && searchText.isEmpty
        return Button(action: {
            CCHaptic.light()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedType = type
                searchText = ""
            }
        }) {
            VStack(spacing: 3) {
                Image(systemName: type.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? type.color : Color.xuanTextTertiary)
                Text(type.displayName)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? type.color : Color.xuanTextTertiary)
            }
            .frame(width: 52)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.sm)
                    .fill(isSelected ? type.color.opacity(0.1) : Color.clear)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }

    // MARK: - Active Type Bar

    private var activeTypeBar: some View {
        HStack(spacing: XuanSpacing.xs) {
            ForEach(CCEmotionType.allCases, id: \.self) { type in
                Rectangle()
                    .fill(selectedType == type && searchText.isEmpty ? type.color : Color.clear)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedType)
    }

    // MARK: - Recent Section

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("最近使用")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.xuanTextTertiary)

                Spacer()

                Button(action: {
                    withAnimation {
                        CCEmotionRecentManager.clear()
                        recentEmojis = []
                    }
                }) {
                    Text("清除")
                        .font(.system(size: 10))
                        .foregroundColor(Color.xuanTextTertiary)
                }
            }
            .padding(.horizontal, XuanSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XuanSpacing.sm) {
                    ForEach(recentEmojis) { emoji in
                        recentEmojiCell(emoji)
                    }
                }
                .padding(.horizontal, XuanSpacing.md)
            }
        }
        .padding(.bottom, 6)
    }

    private func recentEmojiCell(_ emoji: CCEmotionEmoji) -> some View {
        Button(action: { selectEmoji(emoji) }) {
            VStack(spacing: 3) {
                emoji.placeholderView(size: 36)

                Text(emoji.displayName)
                    .font(.system(size: 9))
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: 44)
        }
    }

    // MARK: - Emoji Grid

    private var emojiGrid: some View {
        ScrollView {
            if displayEmojis.isEmpty {
                emptyState
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: XuanSpacing.sm), count: 4),
                    spacing: XuanSpacing.md
                ) {
                    ForEach(displayEmojis) { emoji in
                        emotionCell(emoji)
                    }
                }
                .padding(.horizontal, XuanSpacing.md)
                .padding(.vertical, XuanSpacing.sm)
            }
        }
        .frame(height: 220)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image("common_search")
                .font(.system(size: 28))
                .foregroundColor(Color.xuanTextTertiary.opacity(0.5))
            Text("没有找到匹配的表情")
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }

    // MARK: - Emotion Cell

    private func emotionCell(_ emoji: CCEmotionEmoji) -> some View {
        let isAnimating = animatingEmojiID == emoji.id
        let isPreviewing = previewEmoji?.id == emoji.id
        let scale = emoji.intensity.visualScale
        let opacity = emoji.intensity.visualOpacity

        return Button(action: { selectEmoji(emoji) }) {
            VStack(spacing: 4) {
                // 表情占位图 + 动画预览层
                ZStack {
                    emoji.placeholderView(size: 42)
                        .scaleEffect(isAnimating ? 1.25 : scale)
                        .opacity(opacity)
                        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isAnimating)

                    // 长按预览动画覆盖层
                    if isPreviewing {
                        previewAnimationOverlay(for: emoji)
                    }
                }

                // 表情名称
                Text(emoji.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineLimit(1)

                // 强度标签
                intensityBadge(emoji.intensity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.sm)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.md)
                    .fill(emoji.emotionType.color.opacity(isPreviewing ? 0.2 : (isAnimating ? 0.15 : 0.06)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.md)
                    .stroke(emoji.emotionType.color.opacity(isPreviewing ? 0.5 : (isAnimating ? 0.4 : 0)), lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: isAnimating)
            .animation(.easeInOut(duration: 0.2), value: isPreviewing)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.3) {
            CCHaptic.medium()
            playLottiePreview(for: emoji)
        } onPressingChanged: { isPressing in
            if !isPressing {
                previewEmoji = nil
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(emoji.displayName) \(emoji.intensity.displayName)强度")
        .accessibilityHint("双击选择此表情，长按预览动画")
    }

    /// 长按预览动画覆盖层 — 原生 SwiftUI 动画
    @ViewBuilder
    private func previewAnimationOverlay(for emoji: CCEmotionEmoji) -> some View {
        let color = emoji.emotionType.color
        let intensityConfig = previewIntensityConfig(for: emoji.intensity)

        ZStack {
            // 底层圆形呼吸缩放
            Circle()
                .stroke(color.opacity(0.6), lineWidth: 3)
                .frame(width: 48, height: 48)
                .scaleEffect(intensityConfig.breathScale)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: intensityConfig.breathScale
                )

            // 填充圆形
            Circle()
                .fill(color.opacity(0.25))
                .frame(width: 48, height: 48)
                .scaleEffect(intensityConfig.breathScale)
                .animation(
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: intensityConfig.breathScale
                )

            // 顶层表情弹跳
            emoji.placeholderView(size: 36)
                .offset(y: intensityConfig.bounceOffset)
                .scaleEffect(intensityConfig.emojiScale)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.6),
                    value: intensityConfig.bounceOffset
                )

            // 极端强度额外抖动
            if emoji.intensity == .extreme {
                emoji.placeholderView(size: 36)
                    .offset(x: intensityConfig.shakeOffset)
                    .animation(
                        .easeInOut(duration: 0.15).repeatForever(autoreverses: true),
                        value: intensityConfig.shakeOffset
                    )
            }
        }
        .frame(width: 56, height: 56)
        .transition(.scale.combined(with: .opacity))
    }

    private func intensityBadge(_ intensity: CCEmotionIntensity) -> some View {
        let dots = String(repeating: "●", count: intensity.rawValue)

        return Text(dots)
            .font(.system(size: 7))
            .foregroundColor(Color.xuanTextTertiary.opacity(0.5))
            .tracking(1)
    }

    // MARK: - Intensity Legend

    private var intensityLegend: some View {
        HStack(spacing: XuanSpacing.md) {
            ForEach(CCEmotionIntensity.allCases, id: \.self) { intensity in
                HStack(spacing: 3) {
                    let dots = String(repeating: "●", count: intensity.rawValue)
                    Text(dots)
                        .font(.system(size: 6))
                        .foregroundColor(Color.xuanTextTertiary)
                        .tracking(0.5)

                    Text(intensity.displayName)
                        .font(.system(size: 9))
                        .foregroundColor(Color.xuanTextTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Selection

    private func selectEmoji(_ emoji: CCEmotionEmoji) {
        CCHaptic.selection()

        // 记录最近使用
        CCEmotionRecentManager.record(emoji)
        recentEmojis = CCEmotionRecentManager.recentEmojis

        // 播放选中动画
        animatingEmojiID = emoji.id

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animatingEmojiID = nil
        }

        onSelect(emoji)
        isShowing = false
    }

    // MARK: - Lottie Preview

    private func playLottiePreview(for emoji: CCEmotionEmoji) {
        // 使用原生 SwiftUI 动画替代 Lottie SDK
        withAnimation(.easeInOut(duration: 0.2)) {
            previewEmoji = emoji
        }

        // 1.5s 后自动消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                if previewEmoji?.id == emoji.id {
                    previewEmoji = nil
                }
            }
        }
    }

    /// 预览动画强度参数
    private func previewIntensityConfig(for intensity: CCEmotionIntensity) -> PreviewIntensityConfig {
        switch intensity {
        case .mild:
            return PreviewIntensityConfig(breathScale: 1.04, emojiScale: 1.02, bounceOffset: -2, shakeOffset: 0)
        case .moderate:
            return PreviewIntensityConfig(breathScale: 1.08, emojiScale: 1.05, bounceOffset: -3, shakeOffset: 0)
        case .strong:
            return PreviewIntensityConfig(breathScale: 1.14, emojiScale: 1.08, bounceOffset: -4, shakeOffset: 0)
        case .extreme:
            return PreviewIntensityConfig(breathScale: 1.18, emojiScale: 1.12, bounceOffset: -5, shakeOffset: 3)
        }
    }
}

// MARK: - Preview Intensity Config

/// 预览动画强度参数配置
private struct PreviewIntensityConfig {
    var breathScale: CGFloat
    var emojiScale: CGFloat
    var bounceOffset: CGFloat
    var shakeOffset: CGFloat
}

// MARK: - Overlay Modifier

extension View {
    /// 以底部浮层样式展示 CCEmojiPicker
    func cc_emojiPickerOverlay(
        isShowing: Binding<Bool>,
        onSelect: @escaping (CCEmotionEmoji) -> Void
    ) -> some View {
        self.overlay(alignment: .bottom) {
            if isShowing.wrappedValue {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isShowing.wrappedValue = false
                            }
                        }

                    CCEmojiPicker(isShowing: isShowing, onSelect: onSelect)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing.wrappedValue)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CCEmojiPicker_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var show = true
        @State private var selected: CCEmotionEmoji?

        var body: some View {
            ZStack {
                Color.xuanApricotBg.ignoresSafeArea()
                VStack(spacing: 16) {
                    if let emoji = selected {
                        VStack(spacing: 8) {
                            emoji.placeholderView(size: 64)
                            Text(emoji.displayName)
                                .font(XuanFont.h3)
                            Text(emoji.description)
                                .font(XuanFont.bodyM)
                                .foregroundColor(Color.xuanTextSecondary)
                            Text("强度: \(emoji.intensity.displayName)")
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextTertiary)
                        }
                    } else {
                        Text("请选择表情")
                            .font(XuanFont.h3)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                    Button("打开选择器") { withAnimation { show = true } }
                        .buttonStyle(.borderedProminent)
                }
            }
            .cc_emojiPickerOverlay(isShowing: $show) { selected = $0 }
        }
    }
    static var previews: some View { PreviewWrapper() }
}
#endif

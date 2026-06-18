//
//  CCEmojiPicker.swift
//  绪安 - 升级版表情选择器（分类 + 动画）
//
//  基于设计规格书 §1.4 / §2.5，为情绪解码器做准备
//

import SwiftUI

// MARK: - Emoji Category

enum CCEmojiCategory: String, CaseIterable, Hashable {
    case basic     = "基础情绪"
    case healing   = "治愈系"
    case encourage = "鼓励系"
    case xuan      = "绪安专属"

    var iconName: String {
        switch self {
        case .basic:     return "face.smiling"
        case .healing:   return "leaf.fill"
        case .encourage: return "flame.fill"
        case .xuan:      return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .basic:     return Color(hex: "5A7A8A")
        case .healing:   return Color(hex: "66BB6A")
        case .encourage: return Color(hex: "C9A063")
        case .xuan:      return Color(hex: "D4C8E8")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .basic:     return Color(hex: "5A7A8A").opacity(0.1)
        case .healing:   return Color(hex: "66BB6A").opacity(0.1)
        case .encourage: return Color(hex: "C9A063").opacity(0.1)
        case .xuan:      return Color(hex: "D4C8E8").opacity(0.15)
        }
    }
}

// MARK: - CCEmoji (Upgraded)

/// 绪安表情包 — 24 款，分 4 类（设计规格书 §1.4）
struct CCEmoji: Identifiable, Hashable {
    let id: String
    let text: String
    let category: CCEmojiCategory

    static let all: [CCEmoji] = [
        // 基础情绪（8）
        CCEmoji(id: "e01", text: "😊", category: .basic),
        CCEmoji(id: "e02", text: "😢", category: .basic),
        CCEmoji(id: "e03", text: "😡", category: .basic),
        CCEmoji(id: "e04", text: "😰", category: .basic),
        CCEmoji(id: "e05", text: "😴", category: .basic),
        CCEmoji(id: "e06", text: "🥰", category: .basic),
        CCEmoji(id: "e07", text: "😤", category: .basic),
        CCEmoji(id: "e08", text: "🤗", category: .basic),
        // 治愈系（8）
        CCEmoji(id: "h01", text: "🌸", category: .healing),
        CCEmoji(id: "h02", text: "🌿", category: .healing),
        CCEmoji(id: "h03", text: "☀️", category: .healing),
        CCEmoji(id: "h04", text: "🌙", category: .healing),
        CCEmoji(id: "h05", text: "💚", category: .healing),
        CCEmoji(id: "h06", text: "🕊️", category: .healing),
        CCEmoji(id: "h07", text: "🍃", category: .healing),
        CCEmoji(id: "h08", text: "💫", category: .healing),
        // 鼓励系（8）
        CCEmoji(id: "c01", text: "💪", category: .encourage),
        CCEmoji(id: "c02", text: "🔥", category: .encourage),
        CCEmoji(id: "c03", text: "✨", category: .encourage),
        CCEmoji(id: "c04", text: "🌟", category: .encourage),
        CCEmoji(id: "c05", text: "🎯", category: .encourage),
        CCEmoji(id: "c06", text: "🏆", category: .encourage),
        CCEmoji(id: "c07", text: "👏", category: .encourage),
        CCEmoji(id: "c08", text: "💖", category: .encourage),
        // 绪安专属（8）— 新增
        CCEmoji(id: "x01", text: "🧸", category: .xuan),
        CCEmoji(id: "x02", text: "☁️", category: .xuan),
        CCEmoji(id: "x03", text: "🎵", category: .xuan),
        CCEmoji(id: "x04", text: "📝", category: .xuan),
        CCEmoji(id: "x05", text: "🧘", category: .xuan),
        CCEmoji(id: "x06", text: "🌈", category: .xuan),
        CCEmoji(id: "x07", text: "🫧", category: .xuan),
        CCEmoji(id: "x08", text: "🍂", category: .xuan),
    ]

    static func filter(by category: CCEmojiCategory) -> [CCEmoji] {
        all.filter { $0.category == category }
    }
}

// MARK: - CCEmojiPicker (Upgraded)

@available(*, deprecated, message: "Use CCEmojiPickerV3 instead. v3 supports 24 emotion-based emojis with 6 types × 4 intensities.")
struct CCEmojiPicker: View {
    @Binding var isShowing: Bool
    var onSelect: (String) -> Void

    @State private var selectedCategory: CCEmojiCategory = .basic
    @State private var emojis: [CCEmoji] = CCEmoji.filter(by: .basic)
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(AppTheme.textMuted.opacity(0.35))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 6)

            // Category tabs
            HStack(spacing: 0) {
                ForEach(CCEmojiCategory.allCases, id: \.self) { cat in
                    categoryTab(cat)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            // Active category bar
            HStack(spacing: 0) {
                ForEach(CCEmojiCategory.allCases, id: \.self) { cat in
                    Rectangle()
                        .fill(selectedCategory == cat ? cat.color : Color.clear)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: selectedCategory)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Emoji grid with animation
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 6),
                    spacing: AppSpacing.md
                ) {
                    ForEach(emojis) { emoji in
                        emojiCell(emoji)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
            }
            .frame(height: 260)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppTheme.background)
                .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
        )
        .offset(y: appeared ? 0 : 300)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: appeared)
        .onAppear { appeared = true }
        .onChange(of: selectedCategory) { _, newCat in
            withAnimation(.easeInOut(duration: 0.2)) {
                emojis = CCEmoji.filter(by: newCat)
            }
        }
    }

    // MARK: - Category Tab

    private func categoryTab(_ cat: CCEmojiCategory) -> some View {
        let isSelected = selectedCategory == cat
        return Button(action: {
            CCHaptic.light()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedCategory = cat
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: cat.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? cat.color : AppTheme.textMuted)
                Text(cat.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? cat.color : AppTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(isSelected ? cat.backgroundColor : Color.clear)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }

    // MARK: - Emoji Cell

    private func emojiCell(_ emoji: CCEmoji) -> some View {
        Button(action: {
            CCHaptic.selection()
            onSelect(emoji.text)
            isShowing = false
        }) {
            Text(emoji.text)
                .font(.system(size: 32))
        }
        .frame(width: 52, height: 52)
        .buttonStyle(.plain)
    }
}

// MARK: - Overlay Modifier

extension View {
    /// 以底部浮层样式展示 CCEmojiPicker
    @available(*, deprecated, message: "Use cc_emojiPickerV3Overlay instead.")
    func cc_emojiPickerOverlay(
        isShowing: Binding<Bool>,
        onSelect: @escaping (String) -> Void
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
        @State private var selected = ""

        var body: some View {
            ZStack {
                Color(hex: "F9F6F2").ignoresSafeArea()
                VStack {
                    Text("选中: \(selected)").font(.title2)
                    Button("打开") { withAnimation { show = true } }
                        .buttonStyle(.borderedProminent)
                }
            }
            .cc_emojiPickerOverlay(isShowing: $show) { selected = $0 }
        }
    }
    static var previews: some View { PreviewWrapper() }
}
#endif

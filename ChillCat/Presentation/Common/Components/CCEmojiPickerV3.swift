import SwiftUI

// MARK: - EmojiPickerView v3.0
/// 绪安表情选择器 - 24款表情，分类标签，选中动效
/// 用系统emoji占位，后续可替换为自定义绪安表情

// MARK: - Emoji Category
enum EmojiCategory: String, CaseIterable {
    case positive = "正面"
    case negative = "负面"
    case mixed = "混合"

    var sfSymbol: String {
        switch self {
        case .positive: return "sun.max.fill"
        case .negative: return "cloud.rain.fill"
        case .mixed: return "circle.lefthalf.filled"
        }
    }

    var color: Color {
        switch self {
        case .positive: return AppTheme.safeGreen
        case .negative: return AppTheme.crisisRed
        case .mixed: return AppTheme.warmGlow
        }
    }
}

// MARK: - XuAn Emoji
struct XuAnEmoji: Identifiable, Equatable {
    let id: String
    let emoji: String
    let name: String
    let category: EmojiCategory

    static let all: [XuAnEmoji] = [
        // 正面情绪 (8个)
        XuAnEmoji(id: "e01", emoji: "😊", name: "开心", category: .positive),
        XuAnEmoji(id: "e02", emoji: "🥰", name: "幸福", category: .positive),
        XuAnEmoji(id: "e03", emoji: "😌", name: "平静", category: .positive),
        XuAnEmoji(id: "e04", emoji: "🙏", name: "感恩", category: .positive),
        XuAnEmoji(id: "e05", emoji: "💪", name: "自信", category: .positive),
        XuAnEmoji(id: "e06", emoji: "🌟", name: "希望", category: .positive),
        XuAnEmoji(id: "e07", emoji: "😄", name: "兴奋", category: .positive),
        XuAnEmoji(id: "e08", emoji: "🤗", name: "温暖", category: .positive),

        // 负面情绪 (8个)
        XuAnEmoji(id: "e09", emoji: "😢", name: "难过", category: .negative),
        XuAnEmoji(id: "e10", emoji: "😰", name: "焦虑", category: .negative),
        XuAnEmoji(id: "e11", emoji: "😡", name: "愤怒", category: .negative),
        XuAnEmoji(id: "e12", emoji: "😨", name: "恐惧", category: .negative),
        XuAnEmoji(id: "e13", emoji: "😔", name: "失落", category: .negative),
        XuAnEmoji(id: "e14", emoji: "😩", name: "疲惫", category: .negative),
        XuAnEmoji(id: "e15", emoji: "🤯", name: "崩溃", category: .negative),
        XuAnEmoji(id: "e16", emoji: "😶", name: "麻木", category: .negative),

        // 混合情绪 (8个)
        XuAnEmoji(id: "e17", emoji: "😅", name: "尴尬", category: .mixed),
        XuAnEmoji(id: "e18", emoji: "🤔", name: "困惑", category: .mixed),
        XuAnEmoji(id: "e19", emoji: "😮", name: "惊讶", category: .mixed),
        XuAnEmoji(id: "e20", emoji: "🫠", name: "复杂", category: .mixed),
        XuAnEmoji(id: "e21", emoji: "😬", name: "紧张", category: .mixed),
        XuAnEmoji(id: "e22", emoji: "🥺", name: "委屈", category: .mixed),
        XuAnEmoji(id: "e23", emoji: "😤", name: "烦躁", category: .mixed),
        XuAnEmoji(id: "e24", emoji: "🫂", name: "需要拥抱", category: .mixed),
    ]
}

// MARK: - Emoji Picker View
struct EmojiPickerView: View {
    @Binding var selectedEmoji: XuAnEmoji?
    @State private var selectedCategory: EmojiCategory = .positive
    @State private var animatingEmojiID: String?

    let onSelect: ((XuAnEmoji) -> Void)?

    init(
        selectedEmoji: Binding<XuAnEmoji?>,
        onSelect: ((XuAnEmoji) -> Void)? = nil
    ) {
        self._selectedEmoji = selectedEmoji
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // 分类标签
            categoryTabs

            // 表情网格
            emojiGrid
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Category Tabs
    private var categoryTabs: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(EmojiCategory.allCases, id: \.self) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: category.sfSymbol)
                            .font(.system(size: 12))

                        Text(category.rawValue)
                            .font(AppFont.caption)
                    }
                    .foregroundColor(selectedCategory == category ? .white : AppTheme.textSecondary)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        selectedCategory == category
                            ? category.color
                            : AppTheme.backgroundSecondary
                    )
                    .clipShape(Capsule())
                }
                .accessibilityLabel("\(category.rawValue)表情")
                .accessibilityHint("双击查看\(category.rawValue)情绪的表情列表")
            }

            Spacer()
        }
    }

    // MARK: - Emoji Grid
    private var emojiGrid: some View {
        let filteredEmojis = XuAnEmoji.all.filter { $0.category == selectedCategory }

        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 4),
            spacing: AppSpacing.md
        ) {
            ForEach(filteredEmojis) { emoji in
                EmojiCell(
                    emoji: emoji,
                    isSelected: selectedEmoji?.id == emoji.id,
                    isAnimating: animatingEmojiID == emoji.id,
                    categoryColor: selectedCategory.color
                )
                .onTapGesture {
                    selectEmoji(emoji)
                }
            }
        }
    }

    // MARK: - Selection
    private func selectEmoji(_ emoji: XuAnEmoji) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        selectedEmoji = emoji

        // 播放选中动画
        animatingEmojiID = emoji.id
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            // 动画由EmojiCell内部处理
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animatingEmojiID = nil
        }

        onSelect?(emoji)
    }
}

// MARK: - Emoji Cell
struct EmojiCell: View {
    let emoji: XuAnEmoji
    let isSelected: Bool
    let isAnimating: Bool
    let categoryColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji.emoji)
                .font(.system(size: 36))
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)

            Text(emoji.name)
                .font(.system(size: 11))
                .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(isSelected ? categoryColor.opacity(0.12) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(
                    isSelected ? categoryColor.opacity(0.4) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(emoji.name) \(isSelected ? "已选中" : "")")
        .accessibilityHint("双击选择\(emoji.name)表情")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview
#Preview {
    VStack {
        EmojiPickerView(selectedEmoji: .constant(nil)) { emoji in
            print("选中: \(emoji.name)")
        }
        .padding()

        Spacer()
    }
    .background(AppTheme.background)
}

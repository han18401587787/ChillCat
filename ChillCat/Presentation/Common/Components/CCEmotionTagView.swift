import SwiftUI

// MARK: - Emotion Tag View (Standalone)
/// 独立的情绪标签组件，用于各处复用
struct CCEmotionTagView: View {
    let emotion: String
    let color: Color
    let icon: String
    var size: Size = .medium
    var showIcon: Bool = true
    
    enum Size {
        case small
        case medium
        case large
        
        var font: Font {
            switch self {
            case .small: return AppFont.caption2
            case .medium: return AppFont.caption
            case .large: return AppFont.body
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return AppSpacing.sm
            case .medium: return AppSpacing.md
            case .large: return AppSpacing.lg
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return AppSpacing.xs
            case .large: return AppSpacing.sm
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            if showIcon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize))
            }
            Text(emotion)
                .font(size.font)
        }
        .foregroundColor(color)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("\(emotion)情绪标签")
    }
}

// MARK: - Emotion Flow Layout
/// 流式布局情绪选择器
struct EmotionFlowLayout: View {
    let emotions: [(name: String, chinese: String, color: Color, sfSymbol: String)]
    @Binding var selectedEmotions: Set<String>
    
    var body: some View {
        FlowLayout(spacing: AppSpacing.sm) {
            ForEach(emotions, id: \.name) { emotion in
                Button {
                    if selectedEmotions.contains(emotion.name) {
                        selectedEmotions.remove(emotion.name)
                    } else {
                        selectedEmotions.insert(emotion.name)
                    }
                } label: {
                    CCEmotionTagView(
                        emotion: emotion.chinese,
                        color: emotion.color,
                        icon: emotion.sfSymbol,
                        size: selectedEmotions.contains(emotion.name) ? .large : .medium
                    )
                    .opacity(
                        selectedEmotions.isEmpty || selectedEmotions.contains(emotion.name)
                            ? 1.0 : 0.4
                    )
                }
                .accessibilityLabel("\(emotion.chinese)情绪")
                .accessibilityHint(
                    selectedEmotions.contains(emotion.name)
                        ? "双击取消选择"
                        : "双击选择"
                )
                .accessibilityAddTraits(
                    selectedEmotions.contains(emotion.name) ? .isSelected : []
                )
            }
        }
    }
}

// MARK: - Flow Layout Implementation
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.maxHeight } + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            for item in row {
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.sizeThatFits(.unspecified).width + spacing
            }
            y += row.maxHeight + spacing
        }
    }
    
    private struct Row {
        let items: [LayoutSubview]
        let maxHeight: CGFloat
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentRow: [LayoutSubview] = []
        var currentWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if !currentRow.isEmpty && currentWidth + size.width + spacing > maxWidth {
                rows.append(Row(items: currentRow, maxHeight: maxHeight))
                currentRow = []
                currentWidth = 0
                maxHeight = 0
            }
            
            currentRow.append(subview)
            currentWidth += size.width + (currentRow.count > 1 ? spacing : 0)
            maxHeight = max(maxHeight, size.height)
        }
        
        if !currentRow.isEmpty {
            rows.append(Row(items: currentRow, maxHeight: maxHeight))
        }
        
        return rows
    }
}

// MARK: - Preview
#Preview("Emotion Tags") {
    VStack(spacing: 20) {
        HStack {
            CCEmotionTagView(emotion: "喜悦", color: EmotionColors.joy, icon: "sun.max.fill")
            CCEmotionTagView(emotion: "平静", color: EmotionColors.calm, icon: "wind")
            CCEmotionTagView(emotion: "焦虑", color: EmotionColors.anxiety, icon: "waveform.path.ecg")
        }
        
        EmotionFlowLayout(
            emotions: EmotionColors.allEmotions,
            selectedEmotions: .constant(["joy", "calm"])
        )
        .padding()
    }
}

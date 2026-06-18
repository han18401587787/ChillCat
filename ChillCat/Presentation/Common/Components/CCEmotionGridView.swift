import SwiftUI

// MARK: - Emotion Grid View
/// 情绪选择网格 - 10色情绪色板
struct CCEmotionGridView: View {
    let emotions: [(name: String, chinese: String, color: Color, sfSymbol: String)]
    @Binding var selectedEmotion: String?
    let onSelect: ((String, String, Color, String)) -> Void
    
    // 自适应列数
    private var columns: [GridItem] {
        let count = ScreenAdapter.isSmallScreen ? 5 : 5
        return Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: count)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(emotions, id: \.name) { emotion in
                emotionButton(emotion)
            }
        }
    }
    
    private func emotionButton(_ emotion: (name: String, chinese: String, color: Color, sfSymbol: String)) -> some View {
        Button {
            onSelect(emotion)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            selectedEmotion == emotion.chinese
                                ? emotion.color
                                : emotion.color.opacity(0.12)
                        )
                        .frame(
                            width: ScreenAdapter.isSmallScreen ? 48 : 56,
                            height: ScreenAdapter.isSmallScreen ? 48 : 56
                        )
                    
                    Image(systemName: emotion.sfSymbol)
                        .font(.system(size: ScreenAdapter.isSmallScreen ? 20 : 24))
                        .foregroundColor(
                            selectedEmotion == emotion.chinese
                                ? .white
                                : emotion.color
                        )
                }
                .overlay(
                    selectedEmotion == emotion.chinese
                        ? Circle()
                            .stroke(emotion.color, lineWidth: 3)
                            .frame(
                                width: ScreenAdapter.isSmallScreen ? 54 : 62,
                                height: ScreenAdapter.isSmallScreen ? 54 : 62
                            )
                        : nil
                )
                
                Text(emotion.chinese)
                    .font(ScreenAdapter.isSmallScreen ? AppFont.caption2 : AppFont.caption)
                    .foregroundColor(
                        selectedEmotion == emotion.chinese
                            ? emotion.color
                            : AppTheme.textSecondary
                    )
            }
        }
        .accessibilityLabel(AccessibilityConfig.emotionLabel(
            emotion.chinese,
            isSelected: selectedEmotion == emotion.chinese
        ))
        .accessibilityHint("双击选择\(emotion.chinese)情绪")
        .accessibilityAddTraits(selectedEmotion == emotion.chinese ? .isSelected : [])
    }
}

// MARK: - Emotion Tag View
/// 情绪标签视图
struct EmotionTagView: View {
    let emotion: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(emotion)
                .font(AppFont.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("\(emotion)情绪标签")
    }
}

// MARK: - Emotion Intensity Picker
/// 情绪强度选择器
struct EmotionIntensityPicker: View {
    @Binding var intensity: EmotionColors.Intensity
    let emotionColor: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("强度")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Text(intensity.description)
                    .font(AppFont.caption)
                    .foregroundColor(intensity.color)
            }
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(EmotionColors.Intensity.allCases, id: \.rawValue) { level in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            intensity = level
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                intensity.rawValue >= level.rawValue
                                    ? emotionColor
                                    : emotionColor.opacity(0.15)
                            )
                            .frame(height: 8)
                            .overlay(
                                intensity == level
                                    ? RoundedRectangle(cornerRadius: 4)
                                        .stroke(emotionColor, lineWidth: 2)
                                    : nil
                            )
                    }
                    .accessibilityLabel("强度\(level.rawValue)")
                    .accessibilityHint("双击设置情绪强度为\(level.rawValue)级")
                }
            }
        }
    }
}

extension EmotionColors.Intensity: CustomStringConvertible {
    public var description: String {
        switch self {
        case .veryLow: return "很弱"
        case .low: return "较弱"
        case .moderate: return "中等"
        case .high: return "较强"
        case .veryHigh: return "很强"
        }
    }
}

// MARK: - Emotion History Timeline
/// 情绪时间线视图
struct EmotionTimelineView: View {
    let entries: [EmotionEntry]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    // 时间线指示器
                    VStack(spacing: 0) {
                        Circle()
                            .fill(entry.color)
                            .frame(width: 12, height: 12)
                        
                        if index < entries.count - 1 {
                            Rectangle()
                                .fill(AppTheme.border)
                                .frame(width: 2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.time)
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                            
                            EmotionTagView(
                                emotion: entry.emotion,
                                color: entry.color,
                                icon: entry.icon
                            )
                        }
                        
                        if let note = entry.note {
                            Text(note)
                                .font(AppFont.body)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        ComponentStyles.IntensityBar(value: entry.intensityValue, color: entry.color)
                            .frame(width: 120)
                    }
                    .padding(.bottom, AppSpacing.lg)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("情绪时间线")
    }
}

// MARK: - Emotion Entry Model
struct EmotionEntry: Identifiable {
    let id = UUID()
    let emotion: String
    let color: Color
    let icon: String
    let intensityValue: Double
    let time: String
    let note: String?
}

// MARK: - Emotion Checkin Success Animation
/// 打卡成功动画
struct EmotionCheckinSuccessView: View {
    let emotion: String
    let color: Color
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var rotation: Double = -30
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(color)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(opacity)
            }
            
            Text("打卡成功")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)
                .opacity(opacity)
            
            Text("已记录「\(emotion)」情绪")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
        }
    }
}

// MARK: - Preview
#Preview("Emotion Grid") {
    VStack {
        CCEmotionGridView(
            emotions: EmotionColors.allEmotions,
            selectedEmotion: .constant("平静"),
            onSelect: { _, _, _, _ in }
        )
        .padding()
    }
}

#Preview("Checkin Success") {
    EmotionCheckinSuccessView(emotion: "平静", color: EmotionColors.calm)
}

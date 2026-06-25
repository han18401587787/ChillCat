import Combine
import SwiftUI

// MARK: - EmotionCorrectionView v3.0
/// 情绪标签纠错组件
/// 弹出式情绪选择问卷 + 强度滑块 + 提交后更新情绪画像

struct CCEmotionCorrectionView: View {
    let currentEmotion: String
    let currentIntensity: Double
    let onCorrect: (String, Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmotionCorrectionViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // 标题
                    headerSection
                    
                    // 当前识别结果
                    currentResultSection
                    
                    // 情绪选择
                    emotionSelectionSection
                    
                    // 强度滑块
                    intensitySection
                    
                    // 纠错次数提示
                    if viewModel.correctionCount >= 3 {
                        adjustmentNotice
                    }
                    
                    // 提交按钮
                    submitButton
                    
                    Spacer(minLength: 20)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppTheme.background)
            .navigationTitle("纠错")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary)
            
            Text("帮助AI更懂你")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("选择更符合你感受的情绪和强度\n这能帮助我们提升识别准确度")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, AppSpacing.lg)
    }
    
    // MARK: - Current Result
    private var currentResultSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("当前识别结果")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            HStack(spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.xs) {
                    Text(emotionEmoji(for: currentEmotion))
                        .font(.system(size: 28))
                    
                    Text(currentEmotion)
                        .font(AppFont.bodyBold)
                        .foregroundColor(EmotionColors.color(for: currentEmotion))
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(EmotionColors.color(for: currentEmotion).opacity(0.1))
                .clipShape(Capsule())
                
                Text("强度 \(Int(currentIntensity))/10")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
    
    // MARK: - Emotion Selection
    private var emotionSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("选择正确的情绪")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                ForEach(EmotionColors.allEmotions, id: \.name) { emotion in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.selectedEmotion = emotion.chinese
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: emotion.sfSymbol)
                                .font(.system(size: 16))
                                .foregroundColor(
                                    viewModel.selectedEmotion == emotion.chinese
                                        ? .white
                                        : emotion.color
                                )
                            
                            Text(emotion.chinese)
                                .font(AppFont.body)
                                .foregroundColor(
                                    viewModel.selectedEmotion == emotion.chinese
                                        ? .white
                                        : AppTheme.textPrimary
                                )
                            
                            Spacer()
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            viewModel.selectedEmotion == emotion.chinese
                                ? emotion.color
                                : AppTheme.surface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        .shadow(
                            color: viewModel.selectedEmotion == emotion.chinese
                                ? emotion.color.opacity(0.3)
                                : .black.opacity(0.03),
                            radius: viewModel.selectedEmotion == emotion.chinese ? 8 : 4,
                            x: 0,
                            y: viewModel.selectedEmotion == emotion.chinese ? 4 : 1
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Intensity Section
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("情绪强度")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("强度：\(Int(viewModel.selectedIntensity))/10")
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text(intensityLabel(for: viewModel.selectedIntensity))
                        .font(AppFont.caption)
                        .foregroundColor(intensityColor(for: viewModel.selectedIntensity))
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(intensityColor(for: viewModel.selectedIntensity).opacity(0.1))
                        .clipShape(Capsule())
                }
                
                HStack(spacing: AppSpacing.sm) {
                    Text("1")
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Slider(value: $viewModel.selectedIntensity, in: 1...10, step: 1)
                        .tint(intensityColor(for: viewModel.selectedIntensity))
                    
                    Text("10")
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                // 强度可视化
                HStack(spacing: 4) {
                    ForEach(1...10, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                Double(level) <= viewModel.selectedIntensity
                                    ? intensityColor(for: viewModel.selectedIntensity)
                                    : AppTheme.backgroundSecondary
                            )
                            .frame(height: 8)
                    }
                }
            }
            .padding()
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Adjustment Notice
    private var adjustmentNotice: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("我们将调整识别方式")
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.primary)
                
                Text("你已连续纠错\(viewModel.correctionCount)次，AI会重新校准你的情绪模型以提供更准确的解读。")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(AppTheme.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppTheme.primary.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            viewModel.submitCorrection()
            onCorrect(viewModel.selectedEmotion, viewModel.selectedIntensity)
            dismiss()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("确认纠错")
            }
        }
        .buttonStyle(ComponentStyles.PrimaryButtonStyle())
        .disabled(viewModel.selectedEmotion.isEmpty)
        .opacity(viewModel.selectedEmotion.isEmpty ? 0.5 : 1.0)
    }
    
    // MARK: - Helpers
    private func emotionEmoji(for emotion: String) -> String {
        switch emotion {
        case "喜悦": return "😊"
        case "平静": return "😌"
        case "悲伤": return "😢"
        case "愤怒": return "😡"
        case "恐惧": return "😨"
        case "厌恶": return "😣"
        case "惊喜": return "😲"
        case "焦虑": return "😰"
        case "感恩": return "🙏"
        case "希望": return "🌟"
        default: return "🤔"
        }
    }
    
    private func intensityLabel(for value: Double) -> String {
        switch Int(value) {
        case 1...3: return "轻微"
        case 4...6: return "中等"
        case 7...8: return "较强"
        case 9...10: return "强烈"
        default: return ""
        }
    }
    
    private func intensityColor(for value: Double) -> Color {
        switch Int(value) {
        case 1...3: return EmotionColors.calm
        case 4...6: return AppTheme.warmGlow
        case 7...8: return AppTheme.vibrantOrange
        case 9...10: return AppTheme.crisisRed
        default: return AppTheme.textTertiary
        }
    }
}

// MARK: - ViewModel
@MainActor
final class EmotionCorrectionViewModel: ObservableObject {
    @Published var selectedEmotion: String = ""
    @Published var selectedIntensity: Double = 5
    @Published var correctionCount: Int = 3 // 模拟已有纠错次数
    
    func submitCorrection() {
        correctionCount += 1
    }
}

#Preview {
    CCEmotionCorrectionView(
        currentEmotion: "焦虑",
        currentIntensity: 6,
        onCorrect: { _, _ in }
    )
}

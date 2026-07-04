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
                VStack(spacing: XuanSpacing.xl) {
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
                .padding(XuanSpacing.lg)
            }
            .background(Color.xuanApricotBg)
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
        VStack(spacing: XuanSpacing.md) {
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.xuanApricot)
            
            Text("帮助AI更懂你")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)
            
            Text("选择更符合你感受的情绪和强度\n这能帮助我们提升识别准确度")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, XuanSpacing.lg)
    }
    
    // MARK: - Current Result
    private var currentResultSection: some View {
        VStack(spacing: XuanSpacing.sm) {
            Text("当前识别结果")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
            
            HStack(spacing: XuanSpacing.md) {
                HStack(spacing: XuanSpacing.xs) {
                    Text(emotionEmoji(for: currentEmotion))
                        .font(.system(size: 28))
                    
                    Text(currentEmotion)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(EmotionColors.color(for: currentEmotion))
                }
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.vertical, XuanSpacing.sm)
                .background(EmotionColors.color(for: currentEmotion).opacity(0.1))
                .clipShape(Capsule())
                
                Text("强度 \(Int(currentIntensity))/10")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
        .padding()
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
    }
    
    // MARK: - Emotion Selection
    private var emotionSelectionSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("选择正确的情绪")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: XuanSpacing.sm) {
                ForEach(EmotionColors.allEmotions, id: \.name) { emotion in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.selectedEmotion = emotion.chinese
                        }
                    } label: {
                        HStack(spacing: XuanSpacing.sm) {
                            Image(systemName: emotion.sfSymbol)
                                .font(.system(size: 16))
                                .foregroundColor(
                                    viewModel.selectedEmotion == emotion.chinese
                                        ? .white
                                        : emotion.color
                                )
                            
                            Text(emotion.chinese)
                                .font(XuanFont.bodyL)
                                .foregroundColor(
                                    viewModel.selectedEmotion == emotion.chinese
                                        ? .white
                                        : Color.xuanTextPrimary
                                )
                            
                            Spacer()
                        }
                        .padding(.horizontal, XuanSpacing.lg)
                        .padding(.vertical, XuanSpacing.md)
                        .background(
                            viewModel.selectedEmotion == emotion.chinese
                                ? emotion.color
                                : Color.xuanSurface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
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
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪强度")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            
            VStack(spacing: XuanSpacing.md) {
                HStack {
                    Text("强度：\(Int(viewModel.selectedIntensity))/10")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Spacer()
                    
                    Text(intensityLabel(for: viewModel.selectedIntensity))
                        .font(XuanFont.bodyM)
                        .foregroundColor(intensityColor(for: viewModel.selectedIntensity))
                        .padding(.horizontal, XuanSpacing.md)
                        .padding(.vertical, XuanSpacing.xs)
                        .background(intensityColor(for: viewModel.selectedIntensity).opacity(0.1))
                        .clipShape(Capsule())
                }
                
                HStack(spacing: XuanSpacing.sm) {
                    Text("1")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                    
                    Slider(value: $viewModel.selectedIntensity, in: 1...10, step: 1)
                        .tint(intensityColor(for: viewModel.selectedIntensity))
                    
                    Text("10")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                }
                
                // 强度可视化
                HStack(spacing: 4) {
                    ForEach(1...10, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                Double(level) <= viewModel.selectedIntensity
                                    ? intensityColor(for: viewModel.selectedIntensity)
                                    : Color.xuanSurface
                            )
                            .frame(height: 8)
                    }
                }
            }
            .padding()
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Adjustment Notice
    private var adjustmentNotice: some View {
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.xuanApricot)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("我们将调整识别方式")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanApricot)
                
                Text("你已连续纠错\(viewModel.correctionCount)次，AI会重新校准你的情绪模型以提供更准确的解读。")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(Color.xuanApricot.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .stroke(Color.xuanApricot.opacity(0.15), lineWidth: 1)
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
                Image("home_checkin")
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
        case 4...6: return Color.xuanApricotDark
        case 7...8: return Color.xuanWarning
        case 9...10: return Color.xuanDanger
        default: return Color.xuanTextTertiary
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

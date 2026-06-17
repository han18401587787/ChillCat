import SwiftUI

// MARK: - CheckinResultView v3.0
/// 情绪打卡结果页
/// 展示：日期 + 情绪标签 + 强度滑块 + AI摘要 + 原始内容
/// 功能：编辑标签和强度、发布到共鸣墙（默认匿名）、查看情绪解码

struct CheckinResultView: View {
    @StateObject private var viewModel = CheckinResultViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showPublishSheet: Bool = false
    @State private var showEmotionDecode: Bool = false
    @State private var showHealingOverlay: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // 打卡成功动效区域
                successHeader

                // 日期
                dateSection

                // 情绪标签
                emotionTagSection

                // 强度滑块
                intensitySection

                // AI摘要
                aiSummarySection

                // 原始内容
                originalContentSection

                // 操作按钮
                actionButtons
            }
            .padding(AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("打卡结果")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    showHealingOverlay = true
                }
            }
        }
        .sheet(isPresented: $showPublishSheet) {
            PublishToResonanceView(isPresented: $showPublishSheet)
        }
        .sheet(isPresented: $showEmotionDecode) {
            EmotionDecodeView(
                emotion: viewModel.emotionLabel,
                intensity: viewModel.intensity,
                summary: viewModel.aiSummary
            )
        }
        .overlay {
            if showHealingOverlay {
                HealingOverlayView(
                    isPresented: $showHealingOverlay,
                    title: "打卡完成",
                    subtitle: "你今天的记录已经被安全保存\n每一次记录都是对自己的关爱"
                )
            }
        }
    }

    // MARK: - Success Header
    private var successHeader: some View {
        VStack(spacing: AppSpacing.md) {
            CheckinCompleteAnimation(size: 100)

            Text("记录成功")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.safeGreen)

            Text("你已连续打卡 \(viewModel.streakDays) 天")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, AppSpacing.lg)
    }

    // MARK: - Date Section
    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textTertiary)

            Text(viewModel.formattedDate)
                .font(AppFont.body)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Text(viewModel.timeString)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }

    // MARK: - Emotion Tag Section
    private var emotionTagSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "情绪标签", icon: "tag.fill")

            // 可编辑标签
            EmotionTagEditor(
                selectedEmotion: $viewModel.emotionLabel,
                emotionColor: EmotionColors.color(for: viewModel.emotionLabel)
            )

            // 备选标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(EmotionColors.allEmotions, id: \.name) { emotion in
                        Button {
                            viewModel.emotionLabel = emotion.chinese
                        } label: {
                            Text(emotion.chinese)
                                .font(AppFont.footnote)
                                .foregroundColor(
                                    viewModel.emotionLabel == emotion.chinese
                                        ? .white
                                        : emotion.color
                                )
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.xs)
                                .background(
                                    viewModel.emotionLabel == emotion.chinese
                                        ? emotion.color
                                        : emotion.color.opacity(0.1)
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .sectionGroup()
    }

    // MARK: - Intensity Section
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "情绪强度", icon: "speedometer")

            VStack(spacing: AppSpacing.md) {
                // 强度值显示
                HStack {
                    Text("强度：\(Int(viewModel.intensity))/10")
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    Text(intensityLabel)
                        .font(AppFont.caption)
                        .foregroundColor(intensityColor)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(intensityColor.opacity(0.1))
                        .clipShape(Capsule())
                }

                // 滑块
                HStack(spacing: AppSpacing.sm) {
                    Text("1")
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)

                    Slider(value: $viewModel.intensity, in: 1...10, step: 1)
                        .tint(intensityColor)

                    Text("10")
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                }

                // 强度条可视化
                ComponentStyles.IntensityBar(
                    value: viewModel.intensity / 10.0,
                    color: intensityColor
                )
            }
        }
        .sectionGroup()
    }

    // MARK: - AI Summary Section
    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "AI 情绪摘要", icon: "brain.head.profile")

            HStack(alignment: .top, spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppTheme.secondary.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.secondary)
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(viewModel.aiSummary)
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineSpacing(4)

                    Button {
                        showEmotionDecode = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("查看情绪解码")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                        }
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.primary)
                    }
                }
            }
        }
        .sectionGroup()
    }

    // MARK: - Original Content Section
    private var originalContentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "原始内容", icon: "text.quote")

            Text(viewModel.originalContent)
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(6)
                .padding()
                .background(AppTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .sectionGroup()
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            // 发布到共鸣墙
            Button {
                showPublishSheet = true
            } label: {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                    Text("发布到共鸣墙")
                    Spacer()
                    Text("默认匿名")
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 2)
                        .background(AppTheme.backgroundSecondary)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(ComponentStyles.PrimaryButtonStyle())

            // 查看情绪解码
            Button {
                showEmotionDecode = true
            } label: {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("查看情绪解码")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
            }
            .buttonStyle(ComponentStyles.SecondaryButtonStyle())

            Spacer(minLength: 40)
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)

            Text(title)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
        }
    }

    // MARK: - Computed
    private var intensityLabel: String {
        switch Int(viewModel.intensity) {
        case 1...3: return "轻微"
        case 4...6: return "中等"
        case 7...8: return "较强"
        case 9...10: return "强烈"
        default: return ""
        }
    }

    private var intensityColor: Color {
        switch Int(viewModel.intensity) {
        case 1...3: return EmotionColors.calm
        case 4...6: return AppTheme.warmGlow
        case 7...8: return AppTheme.vibrantOrange
        case 9...10: return AppTheme.crisisRed
        default: return AppTheme.textTertiary
        }
    }
}

// MARK: - Emotion Tag Editor
struct EmotionTagEditor: View {
    @Binding var selectedEmotion: String
    let emotionColor: Color

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(selectedEmotion)
                .font(AppFont.title3)
                .foregroundColor(emotionColor)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(emotionColor.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(emotionColor.opacity(0.3), lineWidth: 1.5)
                )

            Spacer()

            Image(systemName: "pencil")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
        }
    }
}

// MARK: - ViewModel
@MainActor
final class CheckinResultViewModel: ObservableObject {
    @Published var emotionLabel: String = "焦虑"
    @Published var intensity: Double = 6
    @Published var aiSummary: String = ""
    @Published var originalContent: String = ""
    @Published var streakDays: Int = 0

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: Date())
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    init() {
        loadMockData()
    }

    func loadMockData() {
        streakDays = 7
        originalContent = "今天上班的时候突然感到一阵焦虑，心跳加速，手心出汗。深呼吸了几次才稍微好一点。可能是因为下周的汇报压力太大了，感觉自己准备得还不够充分。"
        aiSummary = "你今天的情绪以焦虑为主，可能与工作压力有关。你的身体出现了心跳加速和出汗等生理反应，但通过深呼吸有效缓解了症状。这是一种正常的压力反应，你已经展示了良好的自我调节能力。"
    }
}

// MARK: - Publish to Resonance Sheet
struct PublishToResonanceView: View {
    @Binding var isPresented: Bool
    @State private var isAnonymous: Bool = true
    @State private var allowComments: Bool = true
    @State private var selectedEmoji: XuAnEmoji?

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                // 预览卡片
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("分享预览")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textTertiary)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.textTertiary)
                            Text(isAnonymous ? "匿名用户" : "我")
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text("刚刚")
                                .font(AppFont.caption2)
                                .foregroundColor(AppTheme.textTertiary)
                        }

                        Text("今天的心情：焦虑")
                            .font(AppFont.body)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("有时候焦虑并不是软弱，而是因为在乎。")
                            .font(AppFont.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                }

                // 发布选项
                VStack(spacing: AppSpacing.md) {
                    ToggleRow(
                        icon: "theatermasks.fill",
                        title: "匿名发布",
                        subtitle: "你的身份将不会显示",
                        isOn: $isAnonymous
                    )

                    ToggleRow(
                        icon: "bubble.left.and.bubble.right",
                        title: "允许评论",
                        subtitle: "其他人可以给你的分享留言",
                        isOn: $allowComments
                    )
                }
                .sectionGroup()

                // 添加表情
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("添加心情表情")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textTertiary)

                    EmojiPickerView(selectedEmoji: $selectedEmoji)
                }

                Spacer()

                // 发布按钮
                Button {
                    isPresented = false
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("发布到共鸣墙")
                    }
                }
                .buttonStyle(ComponentStyles.PrimaryButtonStyle())
            }
            .padding(AppSpacing.lg)
            .navigationTitle("发布到共鸣墙")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Toggle Row
struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.textTertiary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textPrimary)

                Text(subtitle)
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CheckinResultView()
    }
}

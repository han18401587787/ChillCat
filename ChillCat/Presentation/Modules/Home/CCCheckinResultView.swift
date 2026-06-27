import Combine
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
    @State private var showEmojiPicker: Bool = false
    @State private var selectedEmoji: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl) {
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
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
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
            CCEmotionDecodeView(
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
        VStack(spacing: XuanSpacing.md) {
            CheckinCompleteAnimation(size: 100)

            Text("记录成功")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanSuccess)

            Text("你已连续打卡 \(viewModel.streakDays) 天")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .padding(.vertical, XuanSpacing.lg)
    }

    // MARK: - Date Section
    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 16))
                .foregroundColor(Color.xuanTextTertiary)

            Text(viewModel.formattedDate)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextPrimary)

            Spacer()

            Text(viewModel.timeString)
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
        }
        .padding()
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
    }

    // MARK: - Emotion Tag Section
    private var emotionTagSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "情绪标签", icon: "tag.fill")

            // 可编辑标签
            EmotionTagEditor(
                selectedEmotion: $viewModel.emotionLabel,
                emotionColor: EmotionColors.color(for: viewModel.emotionLabel)
            )

            // 备选标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: XuanSpacing.sm) {
                    ForEach(EmotionColors.allEmotions, id: \.name) { emotion in
                        Button {
                            viewModel.emotionLabel = emotion.chinese
                        } label: {
                            Text(emotion.chinese)
                                .font(XuanFont.bodyS)
                                .foregroundColor(
                                    viewModel.emotionLabel == emotion.chinese
                                        ? .white
                                        : emotion.color
                                )
                                .padding(.horizontal, XuanSpacing.md)
                                .padding(.vertical, XuanSpacing.xs)
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
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "情绪强度", icon: "speedometer")

            VStack(spacing: XuanSpacing.md) {
                // 强度值显示
                HStack {
                    Text("强度：\(Int(viewModel.intensity))/10")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)

                    Spacer()

                    Text(intensityLabel)
                        .font(XuanFont.bodyM)
                        .foregroundColor(intensityColor)
                        .padding(.horizontal, XuanSpacing.md)
                        .padding(.vertical, XuanSpacing.xs)
                        .background(intensityColor.opacity(0.1))
                        .clipShape(Capsule())
                }

                // 滑块
                HStack(spacing: XuanSpacing.sm) {
                    Text("1")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)

                    Slider(value: $viewModel.intensity, in: 1...10, step: 1)
                        .tint(intensityColor)

                    Text("10")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
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
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "AI 情绪摘要", icon: "brain.head.profile")

            HStack(alignment: .top, spacing: XuanSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.xuanTextSecondary.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(Color.xuanTextSecondary)
                }

                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text(viewModel.aiSummary)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextPrimary)
                        .lineSpacing(4)

                    Button {
                        showEmotionDecode = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("查看情绪解码")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                        }
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanApricot)
                    }
                }
            }
        }
        .sectionGroup()
    }

    // MARK: - Original Content Section
    private var originalContentSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "原始内容", icon: "text.quote")

            Text(viewModel.originalContent)
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(6)
                .padding()
                .background(Color.xuanSurface)
                .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
        }
        .sectionGroup()
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: XuanSpacing.md) {
            // 发布到共鸣墙
            Button {
                showPublishSheet = true
            } label: {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                    Text("发布到共鸣墙")
                    Spacer()
                    Text("默认匿名")
                        .font(XuanFont.caption)
                        .foregroundColor(Color.xuanTextTertiary)
                        .padding(.horizontal, XuanSpacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.xuanSurface)
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
                .foregroundColor(Color.xuanTextTertiary)

            Text(title)
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
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
        case 4...6: return Color.xuanApricotDark
        case 7...8: return Color.xuanWarning
        case 9...10: return Color.xuanDanger
        default: return Color.xuanTextTertiary
        }
    }
}

// MARK: - Emotion Tag Editor
struct EmotionTagEditor: View {
    @Binding var selectedEmotion: String
    let emotionColor: Color

    var body: some View {
        HStack(spacing: XuanSpacing.sm) {
            Text(selectedEmotion)
                .font(XuanFont.h3)
                .foregroundColor(emotionColor)
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.vertical, XuanSpacing.sm)
                .background(emotionColor.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(emotionColor.opacity(0.3), lineWidth: 1.5)
                )

            Spacer()

            Image(systemName: "pencil")
                .font(.system(size: 14))
                .foregroundColor(Color.xuanTextTertiary)
        }
    }
}

// MARK: - ViewModel
@MainActor
final class CheckinResultViewModel: ObservableObject {
    @Published var emotionLabel: String = ""
    @Published var intensity: Double = 6
    @Published var aiSummary: String = ""
    @Published var originalContent: String = ""
    @Published var streakDays: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

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
        Task { await loadCheckinResult() }
    }

    func loadCheckinResult() async {
        isLoading = true
        errorMessage = nil
        do {
            let today = try await CCXuanAPI.getToday()
            emotionLabel = today.emotion
            originalContent = today.note
            streakDays = Int(today.streakDays)
            
            // Get AI analysis
            if !today.note.isEmpty {
                do {
                    let analysis = try await CCXuanAPI.analyze(text: today.note)
                    aiSummary = analysis.insight ?? "今天记录了你的情绪。继续保持这项习惯。"
                    if !analysis.tags.isEmpty {
                        emotionLabel = analysis.emotion
                    }
                } catch {
                    aiSummary = "你今天的情绪记录已保存。每一次记录都是对自己的关爱。"
                    print("⚠️ [CheckinResult] Analyze API failed: \(error)")
                }
            } else {
                aiSummary = "你今天的情绪记录已保存。"
            }
        } catch {
            emotionLabel = ""
            originalContent = ""
            aiSummary = ""
            errorMessage = "加载打卡结果失败"
            print("⚠️ [CheckinResult] API failed: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Publish to Resonance Sheet
struct PublishToResonanceView: View {
    @Binding var isPresented: Bool
    @State private var isAnonymous: Bool = true
    @State private var allowComments: Bool = true
    @State private var selectedEmoji: CCEmotionEmoji?
    @State private var showEmojiPicker: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: XuanSpacing.xl) {
                // 预览卡片
                VStack(alignment: .leading, spacing: XuanSpacing.md) {
                    Text("分享预览")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextTertiary)

                    VStack(alignment: .leading, spacing: XuanSpacing.md) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.xuanTextTertiary)
                            Text(isAnonymous ? "匿名用户" : "我")
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextSecondary)
                            Spacer()
                            Text("刚刚")
                                .font(XuanFont.caption)
                                .foregroundColor(Color.xuanTextTertiary)
                        }

                        Text("今天的心情：焦虑")
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanTextPrimary)

                        Text("有时候焦虑并不是软弱，而是因为在乎。")
                            .font(XuanFont.bodyM)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                    .padding()
                    .background(Color.xuanSurface)
                    .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
                }

                // 发布选项
                VStack(spacing: XuanSpacing.md) {
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
                VStack(alignment: .leading, spacing: XuanSpacing.md) {
                    Text("添加心情表情")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextTertiary)

                    CCEmojiPicker(isShowing: $showEmojiPicker, onSelect: { emoji in
                        selectedEmoji = emoji
                    })
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
            .padding(XuanSpacing.lg)
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
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.xuanTextTertiary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)

                Text(subtitle)
                    .font(XuanFont.caption)
                    .foregroundColor(Color.xuanTextTertiary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.xuanApricot)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CheckinResultView()
    }
}

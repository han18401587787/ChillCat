import SwiftUI

// MARK: - EmotionDecodeView v3.0 (完善版)
/// 情绪解码页
/// 包含：4维度滑动展示、置信度标注、纠错按钮、推荐练习、连续低分预警

struct EmotionDecodeView: View {
    let emotion: String
    let intensity: Double
    let summary: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmotionDecodeViewModel()
    @State private var selectedDimension: DecodeDimension = .emotionType
    @State private var showCorrection = false
    @State private var showHealingPlan = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // 情绪解码头
                    decodeHeader
                    
                    // 置信度标注
                    confidenceBadge
                    
                    // 4维度选择器
                    dimensionSelector
                    
                    // 维度内容
                    dimensionContent
                    
                    // 纠错按钮
                    correctionButton
                    
                    // 低分预警
                    if viewModel.showLowScoreWarning {
                        lowScoreWarning
                    }
                    
                    // 推荐稳情练习
                    healingPlanRecommendation
                    
                    Spacer(minLength: 40)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppTheme.background)
            .navigationTitle("情绪解码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCorrection) {
                EmotionCorrectionView(
                    currentEmotion: emotion,
                    currentIntensity: intensity,
                    onCorrect: { newEmotion, newIntensity in
                        viewModel.applyCorrection(emotion: newEmotion, intensity: newIntensity)
                    }
                )
            }
            .fullScreenCover(isPresented: $showHealingPlan) {
                NavigationStack {
                    HealingPlanView()
                }
            }
        }
    }
    
    // MARK: - Decode Header
    private var decodeHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                EmotionColors.color(for: viewModel.correctedEmotion).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                
                VStack(spacing: AppSpacing.xs) {
                    Text(decodeEmoji)
                        .font(.system(size: 48))
                    
                    Text(viewModel.correctedEmotion)
                        .font(AppFont.title3)
                        .foregroundColor(EmotionColors.color(for: viewModel.correctedEmotion))
                }
            }
            
            Text("情绪解码结果")
                .font(AppFont.title2)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("基于你的记录，AI为你解读今日情绪")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.top, AppSpacing.lg)
    }
    
    // MARK: - Confidence Badge
    private var confidenceBadge: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: viewModel.confidence >= 60 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 18))
                .foregroundColor(viewModel.confidence >= 60 ? AppTheme.safeGreen : AppTheme.vibrantOrange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.confidence >= 60 ? "识别置信度：\(Int(viewModel.confidence))%" : "识别置信度较低")
                    .font(AppFont.bodyBold)
                    .foregroundColor(viewModel.confidence >= 60 ? AppTheme.safeGreen : AppTheme.vibrantOrange)
                
                if viewModel.confidence < 60 {
                    Text("AI对本次识别的把握较低，你可以进行纠错帮助提升准确性")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            viewModel.confidence >= 60
                ? AppTheme.safeGreenLight
                : AppTheme.vibrantOrangeLight
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
    
    // MARK: - Dimension Selector
    private var dimensionSelector: some View {
        VStack(spacing: AppSpacing.md) {
            Text("解读维度")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textTertiary)
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(DecodeDimension.allCases, id: \.self) { dimension in
                    DimensionTab(
                        dimension: dimension,
                        isSelected: selectedDimension == dimension
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDimension = dimension
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Dimension Content
    private var dimensionContent: some View {
        VStack(spacing: AppSpacing.lg) {
            switch selectedDimension {
            case .emotionType:
                emotionTypeContent
            case .intensity:
                intensityContent
            case .keywords:
                keywordsContent
            case .trend:
                trendContent
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.3), value: selectedDimension)
    }
    
    // MARK: - Emotion Type Content
    private var emotionTypeContent: some View {
        VStack(spacing: AppSpacing.md) {
            DecodeCard(
                icon: "chart.bar.fill",
                title: "主要情绪",
                content: "\(viewModel.correctedEmotion) · 强度 \(Int(viewModel.correctedIntensity))/10",
                color: EmotionColors.color(for: viewModel.correctedEmotion)
            )
            
            DecodeCard(
                icon: "text.alignleft",
                title: "AI分析",
                content: viewModel.correctedSummary,
                color: AppTheme.secondary
            )
            
            DecodeCard(
                icon: "lightbulb.fill",
                title: "建议",
                content: decodeSuggestion,
                color: AppTheme.warmGlow
            )
        }
    }
    
    // MARK: - Intensity Content
    private var intensityContent: some View {
        VStack(spacing: AppSpacing.md) {
            DecodeCard(
                icon: "speedometer",
                title: "情绪强度分析",
                content: intensityAnalysis,
                color: AppTheme.vibrantOrange
            )
            
            VStack(spacing: AppSpacing.md) {
                Text("强度分布")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textTertiary)
                
                // 强度可视化
                VStack(spacing: AppSpacing.sm) {
                    ForEach(1...10, id: \.self) { level in
                        HStack(spacing: AppSpacing.sm) {
                            Text("\(level)")
                                .font(AppFont.caption2)
                                .foregroundColor(AppTheme.textTertiary)
                                .frame(width: 20)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppTheme.backgroundSecondary)
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(intensityColor(for: Double(level)))
                                        .frame(
                                            width: geometry.size.width * viewModel.intensityDistribution[level - 1],
                                            height: 10
                                        )
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                }
            }
            .padding()
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Keywords Content
    private var keywordsContent: some View {
        VStack(spacing: AppSpacing.md) {
            DecodeCard(
                icon: "tag.fill",
                title: "情绪关键词",
                content: "AI从你的记录中提取了以下关键词",
                color: AppTheme.softPurple
            )
            
            // 关键词云
            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(viewModel.keywords, id: \.self) { keyword in
                    KeywordBubble(keyword: keyword)
                }
            }
            .padding()
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Trend Content
    private var trendContent: some View {
        VStack(spacing: AppSpacing.md) {
            DecodeCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "情绪趋势",
                content: trendAnalysis,
                color: AppTheme.hopeCyan
            )
            
            // 近7天趋势图
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("近7天情绪变化")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textTertiary)
                
                HStack(alignment: .bottom, spacing: AppSpacing.md) {
                    ForEach(viewModel.weeklyTrend) { day in
                        VStack(spacing: AppSpacing.xs) {
                            Text(day.emotionEmoji)
                                .font(.system(size: 20))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(day.emotionColor)
                                .frame(width: 28, height: CGFloat(day.intensity) * 10)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: day.intensity)
                            
                            Text(day.dayShort)
                                .font(AppFont.caption2)
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                }
            }
            .padding()
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Correction Button
    private var correctionButton: some View {
        Button {
            showCorrection = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "pencil.circle")
                Text("这个解读不准，我要纠错")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .font(AppFont.body)
            .foregroundColor(AppTheme.textSecondary)
            .padding()
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Low Score Warning
    private var lowScoreWarning: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.crisisRed)
                
                Text("情绪健康提醒")
                    .font(AppFont.bodyBold)
                    .foregroundColor(AppTheme.crisisRed)
            }
            
            Text("你已经连续\(viewModel.lowScoreDays)天情绪评分偏低，建议关注自己的心理健康状态。如有需要，可以尝试稳情练习或寻求专业帮助。")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .background(AppTheme.crisisRedLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppTheme.crisisRed.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Healing Plan Recommendation
    private var healingPlanRecommendation: some View {
        Button {
            showHealingPlan = true
        } label: {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppTheme.calmBlue.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.calmBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("推荐稳情练习")
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("4-7-8呼吸法 + 白噪音放松")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.calmBlue)
            }
            .padding()
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: AppTheme.calmBlue.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Computed
    private var decodeEmoji: String {
        switch viewModel.correctedEmotion {
        case "焦虑": return "😰"
        case "悲伤": return "😢"
        case "愤怒": return "😡"
        case "恐惧": return "😨"
        case "喜悦": return "😊"
        case "平静": return "😌"
        case "感恩": return "🙏"
        case "希望": return "🌟"
        case "惊喜": return "😲"
        case "厌恶": return "😣"
        default: return "🤔"
        }
    }
    
    private var decodeSuggestion: String {
        switch viewModel.correctedEmotion {
        case "焦虑":
            return "尝试4-7-8呼吸法：吸气4秒，屏息7秒，呼气8秒。重复3-5次。焦虑往往源于对未来的担忧，试着把注意力带回当下。"
        case "悲伤":
            return "允许自己感受悲伤，它是人类情感的一部分。写日记或与信任的人交谈可以帮助释放情绪。"
        case "愤怒":
            return "愤怒是一种信号，它在告诉你某些界限被触碰了。尝试通过运动来释放身体的紧张感。"
        case "恐惧":
            return "恐惧是自我保护的本能。试着分析你的恐惧是否基于现实，或者只是想象中的最坏情况。"
        case "喜悦":
            return "珍惜这份喜悦，试着记录下让你开心的事情，建立自己的快乐清单。"
        case "平静":
            return "保持这份宁静，可以尝试冥想或正念练习来维持内心的平和。"
        case "感恩":
            return "写下让你感恩的三件事，这种练习可以持续提升幸福感。"
        case "希望":
            return "这份希望是宝贵的动力，用它来规划下一步的小目标。"
        default:
            return "继续记录你的情绪变化，这会帮助你更好地了解自己的情绪模式。每天花几分钟与自己对话，温柔对待自己的感受。"
        }
    }
    
    private var intensityAnalysis: String {
        let level = Int(viewModel.correctedIntensity)
        switch level {
        case 1...3: return "当前情绪强度较低，情绪处于相对平稳的状态。这是进行自我反思和规划的好时机。"
        case 4...6: return "当前情绪处于中等强度，情绪波动在正常范围内。注意观察是否有持续上升的趋势。"
        case 7...8: return "当前情绪强度较高，建议关注情绪变化，可以尝试一些放松练习来调节。"
        case 9...10: return "当前情绪强度非常高，情绪波动显著。强烈建议进行稳情练习或与信任的人交谈。"
        default: return ""
        }
    }
    
    private var trendAnalysis: String {
        if viewModel.showLowScoreWarning {
            return "近3天情绪持续偏低，需要关注。建议每天进行稳情练习，并考虑增加社交活动。"
        } else {
            return "近期情绪呈波动状态，属于正常范围。继续保持每日打卡记录，有助于了解自己的情绪模式。"
        }
    }
    
    private func intensityColor(for level: Double) -> Color {
        switch level {
        case 1...3: return EmotionColors.calm
        case 4...6: return AppTheme.warmGlow
        case 7...8: return AppTheme.vibrantOrange
        case 9...10: return AppTheme.crisisRed
        default: return AppTheme.textTertiary
        }
    }
}

// MARK: - Dimension Enum
enum DecodeDimension: CaseIterable {
    case emotionType
    case intensity
    case keywords
    case trend
    
    var title: String {
        switch self {
        case .emotionType: return "情绪类型"
        case .intensity: return "强度分析"
        case .keywords: return "关键词"
        case .trend: return "情绪趋势"
        }
    }
    
    var icon: String {
        switch self {
        case .emotionType: return "chart.bar.fill"
        case .intensity: return "speedometer"
        case .keywords: return "tag.fill"
        case .trend: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: Color {
        switch self {
        case .emotionType: return AppTheme.primary
        case .intensity: return AppTheme.vibrantOrange
        case .keywords: return AppTheme.softPurple
        case .trend: return AppTheme.hopeCyan
        }
    }
}

// MARK: - Dimension Tab
struct DimensionTab: View {
    let dimension: DecodeDimension
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: dimension.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? dimension.color : AppTheme.textTertiary)
                
                Text(dimension.title)
                    .font(AppFont.caption2)
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                isSelected ? dimension.color.opacity(0.08) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
}

// MARK: - Keyword Bubble
struct KeywordBubble: View {
    let keyword: String
    
    var body: some View {
        Text(keyword)
            .font(AppFont.footnote)
            .foregroundColor(AppTheme.primary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(AppTheme.primary.opacity(0.08))
            .clipShape(Capsule())
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.maxHeight }.reduce(0, +) + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentRow = Row()
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRow.width + size.width + (currentRow.items.isEmpty ? 0 : spacing) > maxWidth {
                rows.append(currentRow)
                currentRow = Row()
            }
            currentRow.add(subview: subview, size: size, spacing: spacing)
        }
        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }
        return rows
    }
    
    struct Row {
        var items: [Item] = []
        var width: CGFloat { items.map { $0.size.width }.reduce(0, +) + CGFloat(max(0, items.count - 1)) * 8 }
        var maxHeight: CGFloat { items.map { $0.size.height }.max() ?? 0 }
        
        mutating func add(subview: LayoutSubview, size: CGSize, spacing: CGFloat) {
            items.append(Item(subview: subview, size: size))
        }
        
        struct Item {
            let subview: LayoutSubview
            let size: CGSize
        }
    }
}

// MARK: - Weekly Trend Data
struct WeeklyTrendData: Identifiable {
    let id = UUID()
    let dayShort: String
    let intensity: Double
    let emotionEmoji: String
    let emotionColor: Color
}

// MARK: - ViewModel
@MainActor
final class EmotionDecodeViewModel: ObservableObject {
    @Published var confidence: Double = 55
    @Published var correctedEmotion: String
    @Published var correctedIntensity: Double
    @Published var correctedSummary: String
    @Published var showLowScoreWarning: Bool = true
    @Published var lowScoreDays: Int = 3
    @Published var correctionCount: Int = 1
    @Published var keywords: [String] = []
    @Published var intensityDistribution: [Double] = []
    @Published var weeklyTrend: [WeeklyTrendData] = []
    
    init(emotion: String = "焦虑", intensity: Double = 6, summary: String = "") {
        self.correctedEmotion = emotion
        self.correctedIntensity = intensity
        self.correctedSummary = summary.isEmpty ? "你今天的情绪以焦虑为主，可能与工作压力有关。" : summary
        loadMockData()
    }
    
    func applyCorrection(emotion: String, intensity: Double) {
        correctedEmotion = emotion
        correctedIntensity = intensity
        correctedSummary = "已根据你的纠错更新了解读结果。"
        correctionCount += 1
        confidence = min(confidence + 10, 100)
    }
    
    private func loadMockData() {
        keywords = ["工作压力", "深呼吸", "心跳加速", "汇报", "紧张", "手心出汗", "准备", "焦虑感"]
        
        intensityDistribution = [0.1, 0.15, 0.2, 0.3, 0.5, 0.8, 0.4, 0.2, 0.1, 0.05]
        
        weeklyTrend = [
            WeeklyTrendData(dayShort: "周三", intensity: 6, emotionEmoji: "😰", emotionColor: EmotionColors.anxiety),
            WeeklyTrendData(dayShort: "周四", intensity: 7, emotionEmoji: "😰", emotionColor: EmotionColors.anxiety),
            WeeklyTrendData(dayShort: "周五", intensity: 5, emotionEmoji: "😔", emotionColor: EmotionColors.sad),
            WeeklyTrendData(dayShort: "周六", intensity: 4, emotionEmoji: "😌", emotionColor: EmotionColors.calm),
            WeeklyTrendData(dayShort: "周日", intensity: 3, emotionEmoji: "😊", emotionColor: EmotionColors.joy),
            WeeklyTrendData(dayShort: "周一", intensity: 7, emotionEmoji: "😰", emotionColor: EmotionColors.anxiety),
            WeeklyTrendData(dayShort: "周二", intensity: 8, emotionEmoji: "😰", emotionColor: EmotionColors.anxiety),
        ]
    }
}

#Preview {
    EmotionDecodeView(
        emotion: "焦虑",
        intensity: 6,
        summary: "你今天的情绪以焦虑为主，可能与工作压力有关。"
    )
}

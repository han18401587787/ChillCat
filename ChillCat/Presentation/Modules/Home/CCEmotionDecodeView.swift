import Combine
import SwiftUI 

// MARK: - EmotionDecodeView v3.0 (完善版)
/// 情绪解码页
/// 包含：4维度滑动展示、置信度标注、纠错按钮、推荐练习、连续低分预警

struct CCEmotionDecodeView: View {
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
                VStack(spacing: XuanSpacing.xl) {
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
                .padding(XuanSpacing.lg)
            }
            .background(Color.xuanApricotBg)
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
                CCEmotionCorrectionView(
                    currentEmotion: emotion,
                    currentIntensity: intensity,
                    onCorrect: { newEmotion, newIntensity in
                        viewModel.applyCorrection(emotion: newEmotion, intensity: newIntensity)
                    }
                )
            }
            .fullScreenCover(isPresented: $showHealingPlan) {
                NavigationStack {
                    CCHealingPlanView()
                }
            }
        }
    }
    
    // MARK: - Decode Header
    private var decodeHeader: some View {
        VStack(spacing: XuanSpacing.md) {
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
                
                VStack(spacing: XuanSpacing.xs) {
                    Text(decodeEmoji)
                        .font(.system(size: 48))
                    
                    Text(viewModel.correctedEmotion)
                        .font(XuanFont.h3)
                        .foregroundColor(EmotionColors.color(for: viewModel.correctedEmotion))
                }
            }
            
            Text("情绪解码结果")
                .font(XuanFont.h2)
                .foregroundColor(Color.xuanTextPrimary)
            
            Text("基于你的记录，AI为你解读今日情绪")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .padding(.top, XuanSpacing.lg)
    }
    
    // MARK: - Confidence Badge
    private var confidenceBadge: some View {
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: viewModel.confidence >= 60 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 18))
                .foregroundColor(viewModel.confidence >= 60 ? Color.xuanSuccess : Color.xuanWarning)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.confidence >= 60 ? "识别置信度：\(Int(viewModel.confidence))%" : "识别置信度较低")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(viewModel.confidence >= 60 ? Color.xuanSuccess : Color.xuanWarning)
                
                if viewModel.confidence < 60 {
                    Text("AI对本次识别的把握较低，你可以进行纠错帮助提升准确性")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            viewModel.confidence >= 60
                ? Color(hex: "D4EDD6")
                : Color.xuanWarning.opacity(0.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
    }
    
    // MARK: - Dimension Selector
    private var dimensionSelector: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("解读维度")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextTertiary)
            
            HStack(spacing: XuanSpacing.sm) {
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
        VStack(spacing: XuanSpacing.lg) {
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
        VStack(spacing: XuanSpacing.md) {
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
                color: Color.xuanTextSecondary
            )
            
            DecodeCard(
                icon: "lightbulb.fill",
                title: "建议",
                content: decodeSuggestion,
                color: Color.xuanApricotDark
            )
        }
    }
    
    // MARK: - Intensity Content
    private var intensityContent: some View {
        VStack(spacing: XuanSpacing.md) {
            DecodeCard(
                icon: "speedometer",
                title: "情绪强度分析",
                content: intensityAnalysis,
                color: Color.xuanWarning
            )
            
            VStack(spacing: XuanSpacing.md) {
                Text("强度分布")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextTertiary)
                
                // 强度可视化
                VStack(spacing: XuanSpacing.sm) {
                    ForEach(1...10, id: \.self) { level in
                        HStack(spacing: XuanSpacing.sm) {
                            Text("\(level)")
                                .font(XuanFont.caption)
                                .foregroundColor(Color.xuanTextTertiary)
                                .frame(width: 20)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.xuanSurface)
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
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Keywords Content
    private var keywordsContent: some View {
        VStack(spacing: XuanSpacing.md) {
            DecodeCard(
                icon: "tag.fill",
                title: "情绪关键词",
                content: "AI从你的记录中提取了以下关键词",
                color: Color(hex: "A085C6").opacity(0.5)
            )
            
            // 关键词云
            FlowLayout(spacing: XuanSpacing.sm) {
                ForEach(viewModel.keywords, id: \.self) { keyword in
                    KeywordBubble(keyword: keyword)
                }
            }
            .padding()
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Trend Content
    private var trendContent: some View {
        VStack(spacing: XuanSpacing.md) {
            DecodeCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "情绪趋势",
                content: trendAnalysis,
                color: Color(hex: "7CB8B0")
            )
            
            // 近7天趋势图
            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                Text("近7天情绪变化")
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextTertiary)
                
                HStack(alignment: .bottom, spacing: XuanSpacing.md) {
                    ForEach(viewModel.weeklyTrend) { day in
                        VStack(spacing: XuanSpacing.xs) {
                            Text(day.emotionEmoji)
                                .font(.system(size: 20))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(day.emotionColor)
                                .frame(width: 28, height: CGFloat(day.intensity) * 10)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: day.intensity)
                            
                            Text(day.dayShort)
                                .font(XuanFont.caption)
                                .foregroundColor(Color.xuanTextTertiary)
                        }
                    }
                }
            }
            .padding()
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        }
    }
    
    // MARK: - Correction Button
    private var correctionButton: some View {
        Button {
            showCorrection = true
        } label: {
            HStack(spacing: XuanSpacing.sm) {
                Image(systemName: "pencil.circle")
                Text("这个解读不准，我要纠错")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .font(XuanFont.bodyL)
            .foregroundColor(Color.xuanTextSecondary)
            .padding()
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: XuanRadius.lg)
                    .stroke(Color.xuanBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Low Score Warning
    private var lowScoreWarning: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack {
                Image("alert_warn")
                    .font(.system(size: 20))
                    .foregroundColor(Color.xuanDanger)
                
                Text("情绪健康提醒")
                    .font(XuanFont.bodyLBold)
                    .foregroundColor(Color.xuanDanger)
            }
            
            Text("你已经连续\(viewModel.lowScoreDays)天情绪评分偏低，建议关注自己的心理健康状态。如有需要，可以尝试稳情练习或寻求专业帮助。")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(hex: "FFDAD5"))
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.lg)
                .stroke(Color.xuanDanger.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Healing Plan Recommendation
    private var healingPlanRecommendation: some View {
        Button {
            showHealingPlan = true
        } label: {
            HStack(spacing: XuanSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.xuanInfo.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image("healing_breath")
                        .font(.system(size: 22))
                        .foregroundColor(Color.xuanInfo)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("推荐稳情练习")
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(Color.xuanTextPrimary)
                    
                    Text("4-7-8呼吸法 + 白噪音放松")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.xuanInfo)
            }
            .padding()
            .background(Color.xuanSurface)
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
            .shadow(color: Color.xuanInfo.opacity(0.1), radius: 8, x: 0, y: 2)
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
        case 4...6: return Color.xuanApricotDark
        case 7...8: return Color.xuanWarning
        case 9...10: return Color.xuanDanger
        default: return Color.xuanTextTertiary
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
        case .emotionType: return Color.xuanApricot
        case .intensity: return Color.xuanWarning
        case .keywords: return Color(hex: "A085C6").opacity(0.5)
        case .trend: return Color(hex: "7CB8B0")
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
            VStack(spacing: XuanSpacing.xs) {
                Image(systemName: dimension.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? dimension.color : Color.xuanTextTertiary)
                
                Text(dimension.title)
                    .font(XuanFont.caption)
                    .foregroundColor(isSelected ? Color.xuanTextPrimary : Color.xuanTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.md)
            .background(
                isSelected ? dimension.color.opacity(0.08) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: XuanRadius.md))
        }
    }
}

// MARK: - Keyword Bubble
struct KeywordBubble: View {
    let keyword: String
    
    var body: some View {
        Text(keyword)
            .font(XuanFont.bodyS)
            .foregroundColor(Color.xuanApricot)
            .padding(.horizontal, XuanSpacing.md)
            .padding(.vertical, XuanSpacing.xs)
            .background(Color.xuanApricot.opacity(0.08))
            .clipShape(Capsule())
    }
}

// MARK: - Flow Layout

struct DecodeFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let totalHeight = rows.reduce(0) { $0 + $1.maxHeight + spacing } - (rows.isEmpty ? 0 : spacing)
        return CGSize(width: proposal.width ?? 0, height: totalHeight)
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
    @Published var showLowScoreWarning: Bool = false
    @Published var lowScoreDays: Int = 0
    @Published var correctionCount: Int = 0
    @Published var keywords: [String] = []
    @Published var intensityDistribution: [Double] = []
    @Published var weeklyTrend: [WeeklyTrendData] = []
    @Published var isLoadingDecode = false
    
    init(emotion: String = "", intensity: Double = 0, summary: String = "") {
        self.correctedEmotion = emotion
        self.correctedIntensity = intensity
        self.correctedSummary = summary.isEmpty ? "" : summary
        if !summary.isEmpty {
            Task { await loadDecodeData() }
            Task { await loadWeeklyTrend() }
        }
    }
    
    func applyCorrection(emotion: String, intensity: Double) {
        correctedEmotion = emotion
        correctedIntensity = intensity
        correctedSummary = "已根据你的纠错更新了解读结果。"
        correctionCount += 1
        confidence = min(confidence + 10, 100)
    }
    
    func loadDecodeData() async {
        isLoadingDecode = true
        do {
            let decode = try await CCXuanAPI.decodeEmotion(text: correctedSummary)
            confidence = decode.surface.confidence ?? 55
            keywords = decode.middle.map { $0.label } + decode.deep.map { $0.label }
            intensityDistribution = Array(repeating: 0.1, count: 10)
            let idx = Int(correctedIntensity.rounded())
            if idx >= 1, idx <= 10 {
                intensityDistribution[idx - 1] = 0.8
            }
        } catch {
            print("⚠️ [EmotionDecode] API failed: \(error)")
        }
        isLoadingDecode = false
    }
    
    func loadWeeklyTrend() async {
        do {
            let stats = try await CCXuanAPI.getWeeklyStats()
            let dayNames = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
            let calendar = Calendar.current
            weeklyTrend = (stats.entries ?? []).compactMap { entry in
                let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
                guard let dateStr = entry.checkinDate, let date = f.date(from: dateStr) else { return nil }
                let weekday = calendar.component(.weekday, from: date) - 1
                return WeeklyTrendData(
                    dayShort: dayNames[weekday],
                    intensity: 5,
                    emotionEmoji: "😌",
                    emotionColor: EmotionColors.color(for: entry.emotion ?? "")
                )
            }
            // Check for low score warning
            if weeklyTrend.count >= 3 {
                lowScoreDays = weeklyTrend.count
                showLowScoreWarning = weeklyTrend.count >= 3
            }
        } catch {
            print("⚠️ [EmotionDecode] WeeklyStats API failed: \(error)")
        }
    }
}

// MARK: - DecodeCard
struct DecodeCard: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(spacing: XuanSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(XuanFont.bodyM)
                    .foregroundColor(Color.xuanTextSecondary)
                Text(content)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextPrimary)
            }
            Spacer()
        }
        .padding()
        .background(Color.xuanSurface)
        .clipShape(RoundedRectangle(cornerRadius: XuanRadius.lg))
    }
}

#Preview {
    CCEmotionDecodeView(
        emotion: "焦虑",
        intensity: 6,
        summary: "你今天的情绪以焦虑为主，可能与工作压力有关。"
    )
}

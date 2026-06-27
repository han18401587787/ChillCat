import SwiftUI

// MARK: - 情绪地图 (对照截图 #8 像素级还原)
/// 布局: 本月/本周切换 → 五维雷达图谱 → 5条进度条 → AI建议卡片

struct CCEmotionDecoderView: View {
    @State private var viewModel = CCEmotionDecoderViewModel()
    @State private var selectedPeriod: Period = .month
    @State private var showEmoji = false
    @FocusState private var isFocused: Bool

    enum Period: String, CaseIterable { case week = "本周", month = "本月" }

    // 五维情绪数据
    struct RadarData: Identifiable {
        let id = UUID()
        let label: String
        let value: Double  // 0-1
        let color: Color
    }

    private let radarValues: [RadarData] = [
        RadarData(label: "焦虑", value: 0.6, color: AppTheme.warmPurple),
        RadarData(label: "平静", value: 0.8, color: AppTheme.accentMint),
        RadarData(label: "开心", value: 0.5, color: AppTheme.warmGold),
        RadarData(label: "委屈", value: 0.35, color: AppTheme.warmPink),
        RadarData(label: "疲惫", value: 0.55, color: AppTheme.info),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                // 周期切换
                periodSwitcher

                // 五维雷达图
                radarChartSection

                // 5条进度条
                progressBarsSection

                // AI 洞察卡片
                aiInsightCard

                Spacer(minLength: 40)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("情绪地图")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 周期切换
    private var periodSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedPeriod = period }
                }) {
                    Text(period.rawValue)
                        .font(AppFont.bodyBold)
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            selectedPeriod == period
                                ? AppTheme.primary
                                : Color.clear
                        )
                        .cornerRadius(AppRadius.full)
                }
            }
        }
        .padding(4)
        .background(AppTheme.surface)
        .cornerRadius(AppRadius.full)
    }

    // MARK: - 五维雷达图
    private var radarChartSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("情绪分布")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 雷达图
            ZStack {
                // 背景网格 (5边形)
                ForEach(1...5, id: \.self) { level in
                    let scale = CGFloat(level) / 5.0
                    Pentagon()
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                        .frame(width: 200 * scale, height: 200 * scale)
                }

                // 数据多边形
                Pentagon()
                    .fill(AppTheme.accentMint.opacity(0.2))
                    .overlay(
                        Pentagon()
                            .stroke(AppTheme.accentMint, lineWidth: 2)
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(x: 0.65, y: 0.65, anchor: .center)

                // 标签
                ForEach(Array(radarValues.enumerated()), id: \.element.id) { index, item in
                    let angle = Double(index) / Double(radarValues.count) * 2 * .pi - .pi / 2
                    let radius: CGFloat = 120
                    Text(item.label)
                        .font(AppFont.caption2)
                        .foregroundColor(item.color)
                        .position(
                            x: 150 + cos(angle) * radius,
                            y: 150 + sin(angle) * radius
                        )
                }
            }
            .frame(width: 300, height: 300)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - 5条进度条
    private var progressBarsSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("情绪强度")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(radarValues) { item in
                VStack(spacing: AppSpacing.xs) {
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.label)
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(Int(item.value * 100))%")
                            .font(AppFont.caption2)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppTheme.surface)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.color)
                                .frame(width: geo.size.width * item.value, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .xuanCardShadow()
    }

    // MARK: - AI 洞察
    private var aiInsightCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentMint.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.accentMint)
                }
                Text("AI 洞察")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Text("本月你的主导情绪是「平静」，焦虑情绪较上周下降 12%。你正在逐渐找到内心的平衡。建议继续保持每日冥想练习。")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(6)

            HStack(spacing: AppSpacing.sm) {
                insightTag("💪 好转中", color: AppTheme.accentMint)
                insightTag("🧘 推荐冥想", color: AppTheme.warmPurple)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .xuanCardShadow()
    }

    private func insightTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppFont.caption2)
            .foregroundColor(color)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(AppRadius.full)
    }
}

// MARK: - 五边形 Shape
struct Pentagon: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let count = 5
        var path = Path()
        for i in 0..<count {
            let angle = Double(i) / Double(count) * 2 * .pi - .pi / 2
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

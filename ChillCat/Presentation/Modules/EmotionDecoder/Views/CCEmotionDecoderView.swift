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
        RadarData(label: "焦虑", value: 0.6, color: Color(hex: "A085C6")),
        RadarData(label: "平静", value: 0.8, color: Color.xuanMint),
        RadarData(label: "开心", value: 0.5, color: Color.xuanApricotDark),
        RadarData(label: "委屈", value: 0.35, color: Color.xuanPink),
        RadarData(label: "疲惫", value: 0.55, color: Color.xuanInfo),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
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
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("情绪地图")
        .navigationBarTitleDisplayMode(.large)
        .trackPage("EmotionDecoder:CCEmotionDecoderView")
    }

    // MARK: - 周期切换
    private var periodSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedPeriod = period }
                }) {
                    Text(period.rawValue)
                        .font(XuanFont.bodyLBold)
                        .foregroundColor(selectedPeriod == period ? .white : Color.xuanTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.sm)
                        .background(
                            selectedPeriod == period
                                ? Color.xuanApricot
                                : Color.clear
                        )
                        .cornerRadius(XuanRadius.full)
                }
                .accessibilityIdentifier("decoder_period_\(period.rawValue)")
            }
        }
        .padding(4)
        .background(Color.xuanSurface)
        .cornerRadius(XuanRadius.full)
        .accessibilityIdentifier("decoder_period_switcher")
    }

    // MARK: - 五维雷达图
    private var radarChartSection: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("情绪分布")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            radarChartContent
                .frame(width: 300, height: 300)
                .accessibilityIdentifier("decoder_radar_chart")
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
        .accessibilityIdentifier("decoder_radar_section")
    }

    private var radarChartContent: some View {
        AnyView(
            ZStack {
                radarGridBackground
                radarDataOverlay
                radarLabels
            }
        )
    }

    private var radarGridBackground: some View {
        Group {
            gridPentagon(level: 1)
            gridPentagon(level: 2)
            gridPentagon(level: 3)
            gridPentagon(level: 4)
            gridPentagon(level: 5)
        }
    }

    private func gridPentagon(level: Int) -> some View {
        let scale = CGFloat(level) / 5.0
        return Pentagon()
            .stroke(Color.xuanBorder.opacity(0.5), lineWidth: 1)
            .frame(width: 200 * scale, height: 200 * scale)
    }

    private var radarDataOverlay: some View {
        AnyView(
            Pentagon()
                .fill(Color.xuanMint.opacity(0.2))
                .overlay(
                    Pentagon()
                        .stroke(Color.xuanMint, lineWidth: 2)
                )
                .frame(width: 200, height: 200)
                .scaleEffect(x: 0.65, y: 0.65, anchor: .center)
        )
    }

    private var radarLabels: some View {
        AnyView(
            ForEach(Array(radarValues.enumerated()), id: \.element.id) { index, item in
                radarLabelView(index: index, item: item)
            }
        )
    }

    private func radarLabelView(index: Int, item: RadarData) -> some View {
        let angle = Double(index) / Double(radarValues.count) * 2 * .pi - .pi / 2
        let radius: CGFloat = 120
        let xPos: CGFloat = 150 + cos(angle) * radius
        let yPos: CGFloat = 150 + sin(angle) * radius
        return Text(item.label)
            .font(XuanFont.caption)
            .foregroundColor(item.color)
            .position(x: xPos, y: yPos)
    }

    // MARK: - 5条进度条
    private var progressBarsSection: some View {
        VStack(spacing: XuanSpacing.md) {
            Text("情绪强度")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(radarValues) { item in
                VStack(spacing: XuanSpacing.xs) {
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.label)
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextPrimary)
                        Spacer()
                        Text("\(Int(item.value * 100))%")
                            .font(XuanFont.caption)
                            .foregroundColor(Color.xuanTextTertiary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.xuanSurface)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.color)
                                .frame(width: geo.size.width * item.value, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .accessibilityIdentifier("decoder_progress_\(item.label)")
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
        .accessibilityIdentifier("decoder_progress_section")
    }

    // MARK: - AI 洞察
    private var aiInsightCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            HStack(spacing: XuanSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.xuanMint.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image("home_mood")
                        .font(.system(size: 16))
                        .foregroundColor(Color.xuanMint)
                }
                Text("AI 洞察")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
            }

            Text("本月你的主导情绪是「平静」，焦虑情绪较上周下降 12%。你正在逐渐找到内心的平衡。建议继续保持每日冥想练习。")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(6)

            HStack(spacing: XuanSpacing.sm) {
                insightTag("💪 好转中", color: Color.xuanMint)
                    .accessibilityIdentifier("decoder_insight_improving")
                insightTag("🧘 推荐冥想", color: Color(hex: "A085C6"))
                    .accessibilityIdentifier("decoder_insight_meditation")
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
        .accessibilityIdentifier("decoder_ai_insight")
    }

    private func insightTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(XuanFont.caption)
            .foregroundColor(color)
            .padding(.horizontal, XuanSpacing.sm)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(XuanRadius.full)
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

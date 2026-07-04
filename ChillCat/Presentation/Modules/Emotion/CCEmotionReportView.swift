//
//  CCEmotionReportView.swift
//  绪安 - 情绪报告 (严格对照设计稿 page_23 像素级还原)
//

import SwiftUI

struct CCEmotionReportView: View {
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var selectedPeriod: Period = .week

    enum Period: String, CaseIterable {
        case week = "本周"
        case month = "本月"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: XuanSpacing.xl2) {
                // 周期切换
                periodSwitcher

                // 7日情绪趋势图
                trendChart

                // 情绪分布
                distributionCard

                // AI洞察
                aiInsightCard
            }
            .padding(XuanSpacing.lg)
        }
        .background(Color.xuanApricotBg)
        .navigationTitle("情绪报告")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 周期切换
    private var periodSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
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
            }
        }
        .padding(4)
        .background(Color.xuanSurface)
        .cornerRadius(XuanRadius.full)
    }

    // MARK: - 7日情绪趋势图
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪趋势")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.md) {
                // 简易柱状图
                HStack(alignment: .bottom, spacing: XuanSpacing.sm) {
                    ForEach(Array(emotionDays.enumerated()), id: \.offset) { index, day in
                        VStack(spacing: XuanSpacing.xs) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [day.color, day.color.opacity(0.5)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 36, height: max(20, day.height))

                            Text(day.label)
                                .font(XuanFont.caption)
                                .foregroundColor(Color.xuanTextTertiary)
                        }
                    }
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)

                // 图例
                HStack(spacing: XuanSpacing.xl) {
                    legendDot(color: Color.xuanMint, label: "平静/愉悦")
                    legendDot(color: Color.xuanApricot, label: "中性")
                    legendDot(color: Color(hex: "A085C6"), label: "焦虑/低落")
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(XuanFont.caption)
                .foregroundColor(Color.xuanTextSecondary)
        }
    }

    // MARK: - 情绪分布卡片
    private var distributionCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            Text("情绪分布")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            VStack(spacing: XuanSpacing.md) {
                distributionRow(label: "平静", value: 0.35, color: Color.xuanMint, icon: "😌")
                distributionRow(label: "愉悦", value: 0.25, color: Color.xuanApricot, icon: "😊")
                distributionRow(label: "焦虑", value: 0.20, color: Color(hex: "A085C6"), icon: "😰")
                distributionRow(label: "低落", value: 0.12, color: Color.xuanInfo, icon: "😢")
                distributionRow(label: "其他", value: 0.08, color: Color.xuanTextTertiary, icon: "🤔")
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func distributionRow(label: String, value: Double, color: Color, icon: String) -> some View {
        VStack(spacing: XuanSpacing.xs) {
            HStack {
                Text(icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextPrimary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.xuanSurface)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * value, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - AI洞察
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

            Text("本周你的主导情绪是「平静」，焦虑情绪较上周下降 12%。你正在逐渐找到内心的平衡。建议继续保持每日冥想练习。")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(6)

            HStack(spacing: XuanSpacing.sm) {
                insightChip("💪 好转中", color: Color.xuanMint)
                insightChip("🧘 推荐冥想", color: Color(hex: "A085C6"))
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .xuanCardShadow()
    }

    private func insightChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(XuanFont.caption)
            .foregroundColor(color)
            .padding(.horizontal, XuanSpacing.sm)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(XuanRadius.full)
    }

    // MARK: - 示例数据
    private struct EmotionDay {
        let label: String
        let height: CGFloat
        let color: Color
    }

    private let emotionDays: [EmotionDay] = [
        EmotionDay(label: "一", height: 80, color: Color.xuanMint),
        EmotionDay(label: "二", height: 95, color: Color.xuanMint),
        EmotionDay(label: "三", height: 55, color: Color.xuanApricot),
        EmotionDay(label: "四", height: 40, color: Color(hex: "A085C6")),
        EmotionDay(label: "五", height: 70, color: Color.xuanMint),
        EmotionDay(label: "六", height: 110, color: Color.xuanMint),
        EmotionDay(label: "日", height: 90, color: Color.xuanApricot),
    ]
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CCEmotionReportView()
    }
}

//
//  CCGrowthReportView.swift
//  ChillCat
//
//  成长档案 — 成长报告页
//

import SwiftUI

// MARK: - Growth Report View

struct CCGrowthReportView: View {
    @State private var viewModel = CCGrowthArchiveViewModel()
    @Environment(\.ccAppTheme) private var theme
    @State private var selectedPeriod: String = "month"

    private let periods = ["week": "本周", "month": "本月", "quarter": "本季度"]

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingXL) {
                periodPicker
                emotionTrendSection
                toolUsageSection
                growthKeywordsSection
                milestoneReviewSection
                aiInsightSection
                shareButton
                bottomPadding
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("成长报告")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await viewModel.loadData() }
        .task {
            viewModel.selectedPeriod = selectedPeriod
            await viewModel.loadData()
        }
        .onChange(of: selectedPeriod) { _, newPeriod in
            viewModel.selectedPeriod = newPeriod
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(["week", "month", "quarter"], id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: theme.durationFast)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(periods[period] ?? period)
                        .font(theme.fontBodyS)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .foregroundColor(selectedPeriod == period ? .white : theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingSM)
                        .background(
                            selectedPeriod == period
                                ? theme.primary
                                : Color.clear
                        )
                }
            }
        }
        .background(theme.surface)
        .cornerRadius(theme.radiusSM)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radiusSM)
                .stroke(theme.divider, lineWidth: 1)
        )
    }

    // MARK: - Emotion Trend Section

    private var emotionTrendSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(title: "情绪趋势", icon: "chart.bar.fill", color: theme.softPurple)

            if let stats = viewModel.stats, !stats.topEmotions.isEmpty {
                // Bar chart using colored rectangles
                let maxCount = stats.topEmotions.map(\.1).max() ?? 1
                VStack(spacing: theme.spacingSM) {
                    ForEach(stats.topEmotions, id: \.0) { emotion, count in
                        emotionBar(emotion: emotion, count: count, maxCount: maxCount)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 5)
            } else {
                Text("暂无情绪数据")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: theme.shadowColor.opacity(theme.shadowOpacitySM), radius: theme.shadowRadiusSM, x: 0, y: theme.shadowYSM)
    }

    private func emotionBar(emotion: String, count: Int, maxCount: Int) -> some View {
        let ratio = CGFloat(count) / CGFloat(max(maxCount, 1))
        let barColor = emotionBarColor(emotion)

        return HStack(spacing: theme.spacingSM) {
            Text(emotion)
                .font(theme.fontCaption)
                .foregroundColor(theme.textSecondary)
                .frame(width: 40, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.surface)
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: max(geo.size.width * ratio, ratio > 0 ? 20 : 0), height: 20)
                }
            }
            .frame(height: 20)

            Text("\(count)次")
                .font(theme.fontCaption)
                .foregroundColor(theme.textMuted)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func emotionBarColor(_ emotion: String) -> Color {
        switch emotion {
        case "平静": return theme.softGreen
        case "开心": return theme.warmLight
        case "焦虑": return theme.softPurple
        case "疲惫": return theme.primaryMuted
        case "孤独": return theme.primaryLight
        case "委屈": return theme.softPink
        case "烦躁": return theme.error
        case "迷茫": return theme.softPurpleLight
        case "易怒": return theme.warm
        case "内耗": return theme.textMuted
        default:     return theme.primary
        }
    }

    // MARK: - Tool Usage Section

    private var toolUsageSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(title: "工具使用", icon: "wrench.and.screwdriver.fill", color: theme.softGreen)

            if let stats = viewModel.stats, !stats.toolUsage.isEmpty {
                let maxCount = stats.toolUsage.map(\.1).max() ?? 1
                VStack(spacing: theme.spacingSM) {
                    ForEach(stats.toolUsage, id: \.0) { tool, count in
                        HStack(spacing: theme.spacingSM) {
                            Text(tool)
                                .font(theme.fontBodyS)
                                .foregroundColor(theme.textPrimary)
                                .frame(width: 80, alignment: .leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(theme.surface)
                                        .frame(height: 16)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(theme.softGreen)
                                        .frame(
                                            width: max(geo.size.width * CGFloat(count) / CGFloat(max(maxCount, 1)), 20),
                                            height: 16
                                        )
                                }
                            }
                            .frame(height: 16)

                            Text("\(count)")
                                .font(theme.fontCaption)
                                .foregroundColor(theme.textMuted)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 4)
            } else {
                Text("暂无工具使用数据")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: theme.shadowColor.opacity(theme.shadowOpacitySM), radius: theme.shadowRadiusSM, x: 0, y: theme.shadowYSM)
    }

    // MARK: - Growth Keywords Section

    private var growthKeywordsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(title: "成长关键词", icon: "tag.fill", color: theme.warm)

            if let stats = viewModel.stats, !stats.growthKeywords.isEmpty {
                FlowLayout(spacing: theme.spacingSM) {
                    ForEach(stats.growthKeywords, id: \.self) { keyword in
                        keywordChip(keyword)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonCard()
            } else {
                Text("暂无关键词")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: theme.shadowColor.opacity(theme.shadowOpacitySM), radius: theme.shadowRadiusSM, x: 0, y: theme.shadowYSM)
    }

    private func keywordChip(_ keyword: String) -> some View {
        let colors: [Color] = [
            theme.softPurpleLight, theme.softGreenLight, theme.softPinkLight,
            theme.primaryMuted, theme.warmMuted, theme.infoLight,
        ]
        let color = colors[abs(keyword.hashValue) % colors.count]

        return Text(keyword)
            .font(theme.fontCaption)
            .foregroundColor(theme.textPrimary)
            .padding(.horizontal, theme.spacingMD)
            .padding(.vertical, theme.spacingXS + 2)
            .background(color)
            .cornerRadius(theme.radiusFull)
    }

    // MARK: - Milestone Review Section

    private var milestoneReviewSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(title: "里程碑回顾", icon: "flag.fill", color: theme.primary)

            let periodMilestones = viewModel.periodMilestones
            if !periodMilestones.isEmpty {
                VStack(spacing: theme.spacingSM) {
                    ForEach(periodMilestones) { milestone in
                        HStack(spacing: theme.spacingMD) {
                            Image(systemName: milestone.type.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(milestoneTypeColor(milestone.type))
                                .frame(width: 28, height: 28)
                                .background(milestoneTypeColor(milestone.type).opacity(0.12))
                                .cornerRadius(theme.radiusSM)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(milestone.title)
                                    .font(theme.fontBodyS)
                                    .fontWeight(.medium)
                                    .foregroundColor(theme.textPrimary)
                                Text(milestone.description)
                                    .font(theme.fontCaption)
                                    .foregroundColor(theme.textMuted)
                            }

                            Spacer()
                        }
                        .padding(theme.spacingSM)
                        .background(theme.surface.opacity(0.5))
                        .cornerRadius(theme.radiusSM)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 3)
            } else {
                Text("本周期暂无里程碑")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: theme.shadowColor.opacity(theme.shadowOpacitySM), radius: theme.shadowRadiusSM, x: 0, y: theme.shadowYSM)
    }

    private func milestoneTypeColor(_ type: CCMilestoneType) -> Color {
        switch type {
        case .streak:    return theme.warm
        case .emotion:   return theme.softPurple
        case .tool:      return theme.softGreen
        case .community: return theme.softPink
        case .personal:  return theme.primary
        }
    }

    // MARK: - AI Insight Section

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            sectionHeader(title: "AI 洞察", icon: "sparkles", color: theme.warm)

            let insights = viewModel.periodInsights
            if !insights.isEmpty {
                VStack(spacing: theme.spacingSM) {
                    ForEach(Array(insights.enumerated()), id: \.offset) { _, insight in
                        HStack(alignment: .top, spacing: theme.spacingMD) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.warm)
                                .frame(width: 24, height: 24)
                                .padding(4)

                            Text(insight)
                                .font(theme.fontBodyS)
                                .foregroundColor(theme.textSecondary)
                                .lineSpacing(2)

                            Spacer()
                        }
                        .padding(theme.spacingMD)
                        .background(theme.warmMuted.opacity(0.3))
                        .cornerRadius(theme.radiusSM)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonCard()
            } else {
                Text("暂无AI洞察")
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: theme.shadowColor.opacity(theme.shadowOpacitySM), radius: theme.shadowRadiusSM, x: 0, y: theme.shadowYSM)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: {
            // Share report as image
            shareReport()
        }) {
            HStack(spacing: theme.spacingSM) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                Text("分享成长报告")
                    .font(theme.fontBodyL)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacingMD)
            .background(theme.primary)
            .cornerRadius(theme.radiusMD)
        }
        .padding(.top, theme.spacingSM)
    }

    private func shareReport() {
        // In a real app, this would render the view as an image and present a share sheet
        print("📤 [GrowthReport] Share triggered")
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: theme.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)
            Spacer()
        }
    }

    private var bottomPadding: some View {
        Color.clear.frame(height: theme.spacing3XL)
    }
}

// MARK: - Flow Layout (for keyword chips)


    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(bounds.width, subviews: subviews)
        for (_, row) in rows.enumerated() {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private struct FlowItem {
        let index: Int
        let size: CGSize
        var x: CGFloat = 0
    }

    private struct FlowRow {
        var items: [FlowItem] = []
        var y: CGFloat = 0
        var maxY: CGFloat { y + (items.map(\.size.height).max() ?? 0) }
    }

    private func arrange(_ width: CGFloat, subviews: Subviews) -> [FlowRow] {
        var rows: [FlowRow] = []
        var currentRow = FlowRow()
        var currentX: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > width && !currentRow.items.isEmpty {
                currentRow.y = rows.last.map { $0.maxY + spacing } ?? 0
                rows.append(currentRow)
                currentRow = FlowRow()
                currentX = 0
            }

            var item = FlowItem(index: index, size: size, x: currentX)
            currentRow.items.append(item)
            currentX += size.width + spacing
        }

        if !currentRow.items.isEmpty {
            currentRow.y = rows.last.map { $0.maxY + spacing } ?? 0
            rows.append(currentRow)
        }

        return rows
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCGrowthReportView()
            .environment(\.ccAppTheme, CCLightTheme())
    }
}

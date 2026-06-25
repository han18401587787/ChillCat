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
        @State private var selectedPeriod: String = "month"

    private let periods = ["week": "本周", "month": "本月", "quarter": "本季度"]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                periodPicker
                emotionTrendSection
                toolUsageSection
                growthKeywordsSection
                milestoneReviewSection
                aiInsightSection
                shareButton
                bottomPadding
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
        }
        .background(AppTheme.background.ignoresSafeArea())
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(periods[period] ?? period)
                        .font(AppFont.footnote)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            selectedPeriod == period
                                ? AppTheme.primary
                                : Color.clear
                        )
                }
            }
        }
        .background(AppTheme.surface)
        .cornerRadius(AppRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    // MARK: - Emotion Trend Section

    private var emotionTrendSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "情绪趋势", icon: "chart.bar.fill", color: Color(hex: "D4C8E8"))

            if let stats = viewModel.stats, !stats.topEmotions.isEmpty {
                // Bar chart using colored rectangles
                let maxCount = stats.topEmotions.map(\.count).max() ?? 1
                VStack(spacing: AppSpacing.sm) {
                    ForEach(stats.topEmotions, id: \.name) { item in
                        emotionBar(emotion: item.name, count: item.count, maxCount: maxCount)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 5)
            } else {
                Text("暂无情绪数据")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func emotionBar(emotion: String, count: Int, maxCount: Int) -> some View {
        let ratio = CGFloat(count) / CGFloat(max(maxCount, 1))
        let barColor = emotionBarColor(emotion)

        return HStack(spacing: AppSpacing.sm) {
            Text(emotion)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 40, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.surface)
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: max(geo.size.width * ratio, ratio > 0 ? 20 : 0), height: 20)
                }
            }
            .frame(height: 20)

            Text("\(count)次")
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func emotionBarColor(_ emotion: String) -> Color {
        switch emotion {
        case "平静": return Color(hex: "66BB6A")
        case "开心": return Color(hex: "C9A063")
        case "焦虑": return Color(hex: "D4C8E8")
        case "疲惫": return AppTheme.primaryMuted
        case "孤独": return AppTheme.primaryLight
        case "委屈": return Color(hex: "E8B8C8")
        case "烦躁": return Color.red
        case "迷茫": return Color(hex: "D4C8E8").opacity(0.3)
        case "易怒": return Color(hex: "8B6F47")
        case "内耗": return AppTheme.textSecondary
        default:     return AppTheme.primary
        }
    }

    // MARK: - Tool Usage Section

    private var toolUsageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "工具使用", icon: "wrench.and.screwdriver.fill", color: Color(hex: "66BB6A"))

            if let stats = viewModel.stats, !stats.toolUsage.isEmpty {
                let maxCount = stats.toolUsage.map(\.count).max() ?? 1
                VStack(spacing: AppSpacing.sm) {
                    ForEach(stats.toolUsage, id: \.name) { item in
                        HStack(spacing: AppSpacing.sm) {
                            Text(item.name)
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(width: 80, alignment: .leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppTheme.surface)
                                        .frame(height: 16)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "66BB6A"))
                                        .frame(
                                            width: max(geo.size.width * CGFloat(item.count) / CGFloat(max(maxCount, 1)), 20),
                                            height: 16
                                        )
                                }
                            }
                            .frame(height: 16)

                            Text("\(item.count)")
                                .font(AppFont.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 4)
            } else {
                Text("暂无工具使用数据")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Growth Keywords Section

    private var growthKeywordsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "成长关键词", icon: "tag.fill", color: Color(hex: "8B6F47"))

            if let stats = viewModel.stats, !stats.growthKeywords.isEmpty {
                KeywordFlowLayout(spacing: AppSpacing.sm) {
                    ForEach(stats.growthKeywords, id: \.self) { keyword in
                        keywordChip(keyword)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonCard()
            } else {
                Text("暂无关键词")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func keywordChip(_ keyword: String) -> some View {
        let colors: [Color] = [
            Color(hex: "D4C8E8").opacity(0.3), Color(hex: "66BB6A").opacity(0.3), Color(hex: "E8B8C8").opacity(0.3),
            AppTheme.primaryMuted, Color(hex: "8B6F47").opacity(0.6), Color.blue.opacity(0.3),
        ]
        let color = colors[abs(keyword.hashValue) % colors.count]

        return Text(keyword)
            .font(AppFont.caption)
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs + 2)
            .background(color)
            .cornerRadius(AppRadius.full)
    }

    // MARK: - Milestone Review Section

    private var milestoneReviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "里程碑回顾", icon: "flag.fill", color: AppTheme.primary)

            let periodMilestones = viewModel.periodMilestones
            if !periodMilestones.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(periodMilestones) { milestone in
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: milestone.type.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(milestoneTypeColor(milestone.type))
                                .frame(width: 28, height: 28)
                                .background(milestoneTypeColor(milestone.type).opacity(0.12))
                                .cornerRadius(AppRadius.sm)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(milestone.title)
                                    .font(AppFont.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text(milestone.description)
                                    .font(AppFont.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(AppSpacing.sm)
                        .background(AppTheme.surface.opacity(0.5))
                        .cornerRadius(AppRadius.sm)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 3)
            } else {
                Text("本周期暂无里程碑")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func milestoneTypeColor(_ type: CCMilestoneType) -> Color {
        switch type {
        case .streak:    return Color(hex: "8B6F47")
        case .emotion:   return Color(hex: "D4C8E8")
        case .tool:      return Color(hex: "66BB6A")
        case .community: return Color(hex: "E8B8C8")
        case .personal:  return AppTheme.primary
        }
    }

    // MARK: - AI Insight Section

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionHeader(title: "AI 洞察", icon: "sparkles", color: Color(hex: "8B6F47"))

            let insights = viewModel.periodInsights
            if !insights.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(Array(insights.enumerated()), id: \.offset) { _, insight in
                        HStack(alignment: .top, spacing: AppSpacing.md) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B6F47"))
                                .frame(width: 24, height: 24)
                                .padding(4)

                            Text(insight)
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(2)

                            Spacer()
                        }
                        .padding(AppSpacing.md)
                        .background(Color(hex: "8B6F47").opacity(0.6).opacity(0.3))
                        .cornerRadius(AppRadius.sm)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonCard()
            } else {
                Text("暂无AI洞察")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: {
            // Share report as image
            shareReport()
        }) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                Text("分享成长报告")
                    .font(AppFont.body.weight(.medium))
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppTheme.primary)
            .cornerRadius(AppRadius.md)
        }
        .padding(.top, AppSpacing.sm)
    }

    private func shareReport() {
        // In a real app, this would render the view as an image and present a share sheet
        print("📤 [GrowthReport] Share triggered")
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
        }
    }

    private var bottomPadding: some View {
        Color.clear.frame(height: AppSpacing.xl)
    }
}

// MARK: - Flow Layout (for keyword chips)

struct KeywordFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal.width ?? 0, subviews: subviews)
        let height = rows.last?.maxY ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
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
        CCGrowthReportView()}
}

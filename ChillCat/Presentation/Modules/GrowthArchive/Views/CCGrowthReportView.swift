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
            VStack(spacing: XuanSpacing.xl) {
                periodPicker
                emotionTrendSection
                toolUsageSection
                growthKeywordsSection
                milestoneReviewSection
                aiInsightSection
                shareButton
                bottomPadding
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.sm)
        }
        .background(Color.xuanApricotBg.ignoresSafeArea())
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
                        .font(XuanFont.bodyS)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .foregroundColor(selectedPeriod == period ? .white : Color.xuanTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.sm)
                        .background(
                            selectedPeriod == period
                                ? Color.xuanApricot
                                : Color.clear
                        )
                }
            }
        }
        .background(Color.xuanSurface)
        .cornerRadius(XuanRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: XuanRadius.sm)
                .stroke(Color.xuanBorder, lineWidth: 1)
        )
    }

    // MARK: - Emotion Trend Section

    private var emotionTrendSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "情绪趋势", icon: "chart.bar.fill", color: Color(hex: "A085C6"))

            if let stats = viewModel.stats, !stats.topEmotions.isEmpty {
                // Bar chart using colored rectangles
                let maxCount = stats.topEmotions.map(\.count).max() ?? 1
                VStack(spacing: XuanSpacing.sm) {
                    ForEach(stats.topEmotions, id: \.name) { item in
                        emotionBar(emotion: item.name, count: item.count, maxCount: maxCount)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 5)
            } else {
                Text("暂无情绪数据")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func emotionBar(emotion: String, count: Int, maxCount: Int) -> some View {
        let ratio = CGFloat(count) / CGFloat(max(maxCount, 1))
        let barColor = emotionBarColor(emotion)

        return HStack(spacing: XuanSpacing.sm) {
            Text(emotion)
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .frame(width: 40, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.xuanSurface)
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: max(geo.size.width * ratio, ratio > 0 ? 20 : 0), height: 20)
                }
            }
            .frame(height: 20)

            Text("\(count)次")
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func emotionBarColor(_ emotion: String) -> Color {
        switch emotion {
        case "平静": return Color.xuanMint
        case "开心": return Color.xuanApricotDark
        case "焦虑": return Color(hex: "A085C6")
        case "疲惫": return Color.xuanApricot.opacity(0.6)
        case "孤独": return Color.xuanApricotLight
        case "委屈": return Color.xuanPink
        case "烦躁": return Color.red
        case "迷茫": return Color(hex: "A085C6").opacity(0.3)
        case "易怒": return Color.xuanApricotDark
        case "内耗": return Color.xuanTextSecondary
        default:     return Color.xuanApricot
        }
    }

    // MARK: - Tool Usage Section

    private var toolUsageSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "工具使用", icon: "wrench.and.screwdriver.fill", color: Color.xuanMint)

            if let stats = viewModel.stats, !stats.toolUsage.isEmpty {
                let maxCount = stats.toolUsage.map(\.count).max() ?? 1
                VStack(spacing: XuanSpacing.sm) {
                    ForEach(stats.toolUsage, id: \.name) { item in
                        HStack(spacing: XuanSpacing.sm) {
                            Text(item.name)
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextPrimary)
                                .frame(width: 80, alignment: .leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.xuanSurface)
                                        .frame(height: 16)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.xuanMint)
                                        .frame(
                                            width: max(geo.size.width * CGFloat(item.count) / CGFloat(max(maxCount, 1)), 20),
                                            height: 16
                                        )
                                }
                            }
                            .frame(height: 16)

                            Text("\(item.count)")
                                .font(XuanFont.bodyM)
                                .foregroundColor(Color.xuanTextSecondary)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 4)
            } else {
                Text("暂无工具使用数据")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Growth Keywords Section

    private var growthKeywordsSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "成长关键词", icon: "tag.fill", color: Color.xuanApricotDark)

            if let stats = viewModel.stats, !stats.growthKeywords.isEmpty {
                KeywordFlowLayout(spacing: XuanSpacing.sm) {
                    ForEach(stats.growthKeywords, id: \.self) { keyword in
                        keywordChip(keyword)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonCard()
            } else {
                Text("暂无关键词")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func keywordChip(_ keyword: String) -> some View {
        let colors: [Color] = [
            Color(hex: "A085C6").opacity(0.3), Color.xuanMint.opacity(0.3), Color.xuanPink.opacity(0.3),
            Color.xuanApricot.opacity(0.6), Color.xuanApricotDark.opacity(0.6), Color.blue.opacity(0.3),
        ]
        let color = colors[abs(keyword.hashValue) % colors.count]

        return Text(keyword)
            .font(XuanFont.bodyM)
            .foregroundColor(Color.xuanTextPrimary)
            .padding(.horizontal, XuanSpacing.md)
            .padding(.vertical, XuanSpacing.xs + 2)
            .background(color)
            .cornerRadius(XuanRadius.full)
    }

    // MARK: - Milestone Review Section

    private var milestoneReviewSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "里程碑回顾", icon: "flag.fill", color: Color.xuanApricot)

            let periodMilestones = viewModel.periodMilestones
            if !periodMilestones.isEmpty {
                VStack(spacing: XuanSpacing.sm) {
                    ForEach(periodMilestones) { milestone in
                        HStack(spacing: XuanSpacing.md) {
                            CCIconMapper.image(for: milestone.type.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(milestoneTypeColor(milestone.type))
                                .frame(width: 28, height: 28)
                                .background(milestoneTypeColor(milestone.type).opacity(0.12))
                                .cornerRadius(XuanRadius.sm)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(milestone.title)
                                    .font(XuanFont.bodyS)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.xuanTextPrimary)
                                Text(milestone.description)
                                    .font(XuanFont.bodyM)
                                    .foregroundColor(Color.xuanTextSecondary)
                            }

                            Spacer()
                        }
                        .padding(XuanSpacing.sm)
                        .background(Color.xuanSurface.opacity(0.5))
                        .cornerRadius(XuanRadius.sm)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonList(count: 3)
            } else {
                Text("本周期暂无里程碑")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func milestoneTypeColor(_ type: CCMilestoneType) -> Color {
        switch type {
        case .streak:    return Color.xuanApricotDark
        case .emotion:   return Color(hex: "A085C6")
        case .tool:      return Color.xuanMint
        case .community: return Color.xuanPink
        case .personal:  return Color.xuanApricot
        }
    }

    // MARK: - AI Insight Section

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.md) {
            sectionHeader(title: "AI 洞察", icon: "sparkles", color: Color.xuanApricotDark)

            let insights = viewModel.periodInsights
            if !insights.isEmpty {
                VStack(spacing: XuanSpacing.sm) {
                    ForEach(Array(insights.enumerated()), id: \.offset) { _, insight in
                        HStack(alignment: .top, spacing: XuanSpacing.md) {
                            Image("ai_think")
                                .font(.system(size: 14))
                                .foregroundColor(Color.xuanApricotDark)
                                .frame(width: 24, height: 24)
                                .padding(4)

                            Text(insight)
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextSecondary)
                                .lineSpacing(2)

                            Spacer()
                        }
                        .padding(XuanSpacing.md)
                        .background(Color.xuanApricotDark.opacity(0.6).opacity(0.3))
                        .cornerRadius(XuanRadius.sm)
                    }
                }
            } else if viewModel.isLoading {
                CCSkeletonCard()
            } else {
                Text("暂无AI洞察")
                    .font(XuanFont.bodyS)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: {
            // Share report as image
            shareReport()
        }) {
            HStack(spacing: XuanSpacing.sm) {
                Image("common_share")
                    .font(.system(size: 16))
                Text("分享成长报告")
                    .font(XuanFont.bodyLMedium)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.md)
            .background(Color.xuanApricot)
            .cornerRadius(XuanRadius.md)
        }
        .padding(.top, XuanSpacing.sm)
    }

    private func shareReport() {
        // In a real app, this would render the view as an image and present a share sheet
        print("📤 [GrowthReport] Share triggered")
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: XuanSpacing.sm) {
            CCIconMapper.image(for: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)
            Spacer()
        }
    }

    private var bottomPadding: some View {
        Color.clear.frame(height: XuanSpacing.xl)
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

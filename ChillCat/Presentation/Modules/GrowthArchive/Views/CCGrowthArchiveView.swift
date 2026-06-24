//
//  CCGrowthArchiveView.swift
//  ChillCat
//
//  成长档案 — 主页面
//

import SwiftUI

// MARK: - Growth Archive View

struct CCGrowthArchiveView: View {
    @State private var viewModel = CCGrowthArchiveViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator
    @Environment(\.ccAppTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingXL) {
                statsSummaryCard
                achievementSection
                milestoneTimeline
                reportEntryCard
                bottomPadding
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("成长档案")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await viewModel.loadData() }
        .task { await viewModel.loadData() }
    }

    // MARK: - Stats Summary Card

    private var statsSummaryCard: some View {
        VStack(spacing: theme.spacingMD) {
            HStack {
                Text("成长概览")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: theme.spacingSM), count: 4), spacing: theme.spacingSM) {
                statItem(
                    value: "\(viewModel.stats?.totalCheckins ?? 0)",
                    label: "累计打卡",
                    icon: "calendar.badge.checkmark",
                    color: theme.primary
                )
                statItem(
                    value: "\(viewModel.stats?.emotionTypes ?? 0)",
                    label: "记录情绪",
                    icon: "chart.pie.fill",
                    color: theme.softPurple
                )
                statItem(
                    value: "\(viewModel.stats?.toolsUsed ?? 0)",
                    label: "使用工具",
                    icon: "hammer.fill",
                    color: theme.softGreen
                )
                statItem(
                    value: "\(viewModel.stats?.communityInteractions ?? 0)",
                    label: "社区互动",
                    icon: "heart.fill",
                    color: theme.softPink
                )
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusLG)
        .shadow(color: theme.shadowColor.opacity(theme.shadowOpacitySM), radius: theme.shadowRadiusSM, x: 0, y: theme.shadowYSM)
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: theme.spacingXS) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(height: 24)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.textPrimary)
            Text(label)
                .font(theme.fontLabel)
                .foregroundColor(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacingSM)
        .background(color.opacity(0.08))
        .cornerRadius(theme.radiusSM)
    }

    // MARK: - Achievement Section

    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            HStack {
                Text("成就徽章")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Text("\(viewModel.unlockedCount)/\(viewModel.totalCount)")
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
            }

            // Category filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacingSM) {
                    categoryChip(label: "全部", category: nil)

                    ForEach(CCAchievementBadge.CCBadgeCategory.allCases, id: \.self) { cat in
                        categoryChip(label: cat.displayName, category: cat)
                    }
                }
            }

            // Badge grid
            if viewModel.isLoading {
                CCSkeletonGrid()
            } else if viewModel.filteredAchievements.isEmpty {
                CCEmptyStateView(title: "暂无徽章", message: "继续使用绪安，解锁更多成就吧")
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: theme.spacingSM), count: 4),
                    spacing: theme.spacingMD
                ) {
                    ForEach(viewModel.filteredAchievements) { badge in
                        badgeCell(badge)
                    }
                }
            }
        }
    }

    private func categoryChip(label: String, category: CCAchievementBadge.CCBadgeCategory?) -> some View {
        let isSelected = viewModel.categoryFilter == category
        return Button(action: {
            withAnimation(.easeInOut(duration: theme.durationFast)) {
                viewModel.categoryFilter = category
            }
        }) {
            Text(label)
                .font(theme.fontCaption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : theme.textSecondary)
                .padding(.horizontal, theme.spacingMD)
                .padding(.vertical, theme.spacingXS + 2)
                .background(isSelected ? theme.primary : theme.surface)
                .cornerRadius(theme.radiusFull)
        }
    }

    private func badgeCell(_ badge: CCAchievementBadge) -> some View {
        VStack(spacing: 6) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(badge.isUnlocked ? badgeCategoryColor(badge.category) : theme.divider, lineWidth: 2)
                    .frame(width: 52, height: 52)

                if badge.isUnlocked {
                    Circle()
                        .fill(badgeCategoryColor(badge.category).opacity(0.15))
                        .frame(width: 48, height: 48)
                }

                // Icon
                Image(systemName: badge.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(badge.isUnlocked ? badgeCategoryColor(badge.category) : theme.textMuted)

                // Progress ring for in-progress badges
                if !badge.isUnlocked && badge.progress > 0 {
                    Circle()
                        .trim(from: 0, to: badge.progressPercent)
                        .stroke(badgeCategoryColor(badge.category), lineWidth: 2)
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))
                }
            }

            Text(badge.name)
                .font(.system(size: 11))
                .foregroundColor(badge.isUnlocked ? theme.textPrimary : theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacingSM)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
        .opacity(badge.isUnlocked ? 1.0 : 0.6)
    }

    private func badgeCategoryColor(_ category: CCAchievementBadge.CCBadgeCategory) -> Color {
        switch category {
        case .streak:    return theme.warm
        case .emotion:   return theme.softPurple
        case .tool:      return theme.softGreen
        case .community: return theme.softPink
        case .milestone: return theme.primary
        }
    }

    // MARK: - Milestone Timeline

    private var milestoneTimeline: some View {
        VStack(alignment: .leading, spacing: theme.spacingMD) {
            Text("里程碑")
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)

            if viewModel.isLoading {
                CCSkeletonList(count: 3)
            } else if viewModel.milestones.isEmpty {
                CCEmptyStateView(title: "暂无里程碑", message: "每一次成长都值得被记录")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.milestones.enumerated()), id: \.element.id) { index, milestone in
                        milestoneRow(milestone, isLast: index == viewModel.milestones.count - 1)
                    }
                }
            }
        }
    }

    private func milestoneRow(_ milestone: CCMilestone, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: theme.spacingMD) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(milestoneTypeColor(milestone.type))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(milestoneTypeColor(milestone.type).opacity(0.3), lineWidth: 3)
                    )

                if !isLast {
                    Rectangle()
                        .fill(theme.divider)
                        .frame(width: 2)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: milestone.type.iconName)
                        .font(.system(size: 12))
                        .foregroundColor(milestoneTypeColor(milestone.type))

                    Text(milestone.title)
                        .font(theme.fontBodyL)
                        .fontWeight(.medium)
                        .foregroundColor(theme.textPrimary)
                }

                Text(milestone.description)
                    .font(theme.fontBodyS)
                    .foregroundColor(theme.textSecondary)

                Text(formattedDate(milestone.date))
                    .font(theme.fontCaption)
                    .foregroundColor(theme.textMuted)
            }
            .padding(.bottom, isLast ? 0 : theme.spacingLG)
        }
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }

    // MARK: - Report Entry Card

    private var reportEntryCard: some View {
        Button {
            coordinator.navigate(to: .growthReport)
        } label: {
            HStack(spacing: theme.spacingMD) {
                // Icon
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundColor(theme.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("成长报告")
                        .font(theme.fontH3)
                        .foregroundColor(theme.textPrimary)
                    Text("查看你的情绪趋势、工具使用和AI洞察")
                        .font(theme.fontBodyS)
                        .foregroundColor(theme.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("查看完整报告")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.primary)
                }
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusLG)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radiusLG)
                    .stroke(theme.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Padding

    private var bottomPadding: some View {
        Color.clear.frame(height: theme.spacing2XL)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCGrowthArchiveView()
            .environment(CCAppCoordinator())
            .environment(\.ccAppTheme, CCLightTheme())
    }
}

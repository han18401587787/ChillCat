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
        var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                statsSummaryCard
                achievementSection
                milestoneTimeline
                reportEntryCard
                bottomPadding
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("成长档案")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await viewModel.loadData() }
        .task { await viewModel.loadData() }
    }

    // MARK: - Stats Summary Card

    private var statsSummaryCard: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("成长概览")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 4), spacing: AppSpacing.sm) {
                statItem(
                    value: "\(viewModel.stats?.totalCheckins ?? 0)",
                    label: "累计打卡",
                    icon: "calendar.badge.checkmark",
                    color: AppTheme.primary
                )
                statItem(
                    value: "\(viewModel.stats?.emotionTypes ?? 0)",
                    label: "记录情绪",
                    icon: "chart.pie.fill",
                    color: AppTheme.warmPurple
                )
                statItem(
                    value: "\(viewModel.stats?.toolsUsed ?? 0)",
                    label: "使用工具",
                    icon: "hammer.fill",
                    color: AppTheme.accentMint
                )
                statItem(
                    value: "\(viewModel.stats?.communityInteractions ?? 0)",
                    label: "社区互动",
                    icon: "heart.fill",
                    color: AppTheme.warmPink
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(height: 24)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.08))
        .cornerRadius(AppRadius.sm)
    }

    // MARK: - Achievement Section

    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("成就徽章")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(viewModel.unlockedCount)/\(viewModel.totalCount)")
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }

            // Category filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
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
                    columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 4),
                    spacing: AppSpacing.md
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
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.categoryFilter = category
            }
        }) {
            Text(label)
                .font(AppFont.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs + 2)
                .background(isSelected ? AppTheme.primary : AppTheme.surface)
                .cornerRadius(AppRadius.full)
        }
    }

    private func badgeCell(_ badge: CCAchievementBadge) -> some View {
        VStack(spacing: 6) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(badge.isUnlocked ? badgeCategoryColor(badge.category) : AppTheme.border, lineWidth: 2)
                    .frame(width: 52, height: 52)

                if badge.isUnlocked {
                    Circle()
                        .fill(badgeCategoryColor(badge.category).opacity(0.15))
                        .frame(width: 48, height: 48)
                }

                // Icon
                Image(systemName: badge.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(badge.isUnlocked ? badgeCategoryColor(badge.category) : AppTheme.textSecondary)

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
                .foregroundColor(badge.isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
        .opacity(badge.isUnlocked ? 1.0 : 0.6)
    }

    private func badgeCategoryColor(_ category: CCAchievementBadge.CCBadgeCategory) -> Color {
        switch category {
        case .streak:    return AppTheme.warmGold
        case .emotion:   return AppTheme.warmPurple
        case .tool:      return AppTheme.accentMint
        case .community: return AppTheme.warmPink
        case .milestone: return AppTheme.primary
        }
    }

    // MARK: - Milestone Timeline

    private var milestoneTimeline: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("里程碑")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

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
        HStack(alignment: .top, spacing: AppSpacing.md) {
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
                        .fill(AppTheme.border)
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
                        .font(AppFont.body.weight(.medium))
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textPrimary)
                }

                Text(milestone.description)
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)

                Text(formattedDate(milestone.date))
                    .font(AppFont.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.bottom, isLast ? 0 : AppSpacing.lg)
        }
    }

    private func milestoneTypeColor(_ type: CCMilestoneType) -> Color {
        switch type {
        case .streak:    return AppTheme.warmGold
        case .emotion:   return AppTheme.warmPurple
        case .tool:      return AppTheme.accentMint
        case .community: return AppTheme.warmPink
        case .personal:  return AppTheme.primary
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
            HStack(spacing: AppSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("成长报告")
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("查看你的情绪趋势、工具使用和AI洞察")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("查看完整报告")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(AppTheme.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Padding

    private var bottomPadding: some View {
        Color.clear.frame(height: AppSpacing.xl)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCGrowthArchiveView()
            .environment(CCAppCoordinator())}
}

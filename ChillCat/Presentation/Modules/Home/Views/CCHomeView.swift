//
//  CCHomeView.swift
//  绪安 - 首页 (Ardot v3 对照截图 #9 完整重构)
//
//  布局：问候区 → 4需求卡片 → 打卡按钮 → 今日暖心 → 稳情计划预览 → 情绪探索

import SwiftUI

struct CCHomeView: View {
    @State private var viewModel = CCEmotionViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator

    // 4 个需求入口 (2×2)
    let needGridColumns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 2)

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                if viewModel.isLoading {
                    loadingContent
                } else {
                    // 1. 问候区
                    greetingSection

                    // 2. 需求选择卡片 (4个, 2×2)
                    needSelectionSection

                    // 3. 打卡按钮
                    if viewModel.selectedEmotion != nil && !viewModel.hasCheckedIn {
                        checkInButtonSection
                    }

                    // 4. 今日已打卡
                    if viewModel.hasCheckedIn {
                        checkedInCelebration
                    }

                    // 5. 今日暖心推荐
                    todayWarmthCard

                    // 6. 稳情计划预览
                    healingPlanPreview

                    // 7. 情绪探索
                    emotionExploreSection
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppTheme.background)
        .navigationTitle("绪安")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadData() }
    }

    // MARK: - Loading
    private var loadingContent: some View {
        VStack(spacing: AppSpacing.lg) {
            greetingSection
            skeletonCard(height: 200)
            skeletonCard(height: 48)
            skeletonCard(height: 120)
            skeletonCard(height: 80)
            skeletonCard(height: 200)
        }
    }

    private func skeletonCard(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: AppRadius.md)
            .fill(AppTheme.surface)
            .frame(height: height)
            .opacity(0.5)
    }

    // MARK: - 1. 问候区
    private var greetingSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("现在是什么感受？")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)
                Text("已陪伴你 \(viewModel.totalDays) 天")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()

            // 连续打卡徽章
            VStack(spacing: 2) {
                Text("\(viewModel.streakDays)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                Text("连续天")
                    .font(AppFont.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(AppTheme.primary.opacity(0.08))
            )
        }
    }

    // MARK: - 2. 需求选择卡片 (4个, 2×2)
    private var needSelectionSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("选择你的情绪")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: needGridColumns, spacing: AppSpacing.sm) {
                ForEach(viewModel.topEmotions, id: \.self) { emotion in
                    needCard(emotion)
                }
            }
        }
    }

    private func needCard(_ emotion: CCEmotion) -> some View {
        Button(action: {
            CCHaptic.selection()
            viewModel.selectEmotion(emotion)
        }) {
            HStack(spacing: AppSpacing.md) {
                // 左侧表情
                ZStack {
                    Circle()
                        .fill(
                            viewModel.selectedEmotion == emotion
                                ? AppTheme.primary.opacity(0.15)
                                : AppTheme.surface
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: emotion.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(
                            viewModel.selectedEmotion == emotion
                                ? AppTheme.primary
                                : AppTheme.textSecondary
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(emotion.rawValue)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(emotionSubtitle(emotion))
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(
                        viewModel.selectedEmotion == emotion
                            ? AppTheme.primary.opacity(0.4)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func emotionSubtitle(_ emotion: CCEmotion) -> String {
        switch emotion {
        case .happy:    return "想分享快乐"
        case .calm:     return "感到平静"
        case .anxious:  return "有点焦虑"
        case .wronged:  return "心里委屈"
        default:        return "需要陪伴"
        }
    }

    // MARK: - 3. 打卡按钮
    private var checkInButtonSection: some View {
        VStack(spacing: AppSpacing.md) {
            // 心情备注
            TextField("写下此刻的感受（可选）...", text: $viewModel.todayNote, axis: .vertical)
                .font(AppFont.body)
                .padding(AppSpacing.md)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.md)
                .lineLimit(2...4)

            // 打卡按钮
            Button(action: {
                CCHaptic.success()
                viewModel.completeCheckIn()
            }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .medium))
                    Text("就是这样，打卡记录")
                        .font(AppFont.buttonLabel)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppRadius.lg)
                .shadow(color: AppTheme.primary.opacity(0.25), radius: 8, x: 0, y: 3)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - 4. 今日已打卡
    private var checkedInCelebration: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.accentMint)

            VStack(alignment: .leading, spacing: 2) {
                Text("今日已打卡")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Text("完成了！你真的很棒")
                    .font(AppFont.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.accentMint.opacity(0.1))
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - 5. 今日暖心推荐
    private var todayWarmthCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.warmGold)
                Text("今日暖心")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
            }

            HStack(spacing: AppSpacing.lg) {
                Image(systemName: viewModel.dailyTaskCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.dailyTaskCompleted ? AppTheme.accentMint : AppTheme.textMuted)

                Text(viewModel.dailyTask)
                    .font(AppFont.body)
                    .foregroundColor(viewModel.dailyTaskCompleted ? AppTheme.textSecondary : AppTheme.textPrimary)
                    .strikethrough(viewModel.dailyTaskCompleted)

                Spacer()
            }
            .padding(AppSpacing.md)
            .background(AppTheme.surface)
            .cornerRadius(AppRadius.md)
            .onTapGesture {
                if !viewModel.dailyTaskCompleted {
                    viewModel.completeDailyTask()
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color(hex: "2C2416").opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - 6. 稳情计划预览
    private var healingPlanPreview: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.accentMint)
                Text("稳情计划")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }

            // 本周进度
            HStack(spacing: AppSpacing.xs) {
                ForEach(0..<7) { day in
                    Circle()
                        .fill(
                            day < viewModel.weeklyProgress
                                ? AppTheme.accentMint
                                : AppTheme.surface
                        )
                        .frame(width: 8, height: 8)
                }
            }

            Text("本周已完成 \(viewModel.weeklyProgress)/7 天")
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.lg)
        .shadow(color: Color(hex: "2C2416").opacity(0.04), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            coordinator.navigate(to: .safetyPlan)
        }
    }

    // MARK: - 7. 情绪探索
    private var emotionExploreSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("探索更多可能")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.sm),
                          GridItem(.flexible(), spacing: AppSpacing.sm)],
                spacing: AppSpacing.sm
            ) {
                exploreCard(
                    icon: "heart.fill",
                    title: "共鸣墙",
                    subtitle: "匿名分享心声",
                    color: AppTheme.warmPink,
                    route: .resonanceWall
                )
                exploreCard(
                    icon: "leaf.fill",
                    title: "治愈空间",
                    subtitle: "冥想与放松",
                    color: AppTheme.accentMint,
                    route: .healing
                )
                exploreCard(
                    icon: "brain.head.profile",
                    title: "情绪解码",
                    subtitle: "了解你的情绪",
                    color: AppTheme.warmPurple,
                    route: .emotionDecoder
                )
                exploreCard(
                    icon: "chart.bar.fill",
                    title: "情绪趋势",
                    subtitle: "查看变化轨迹",
                    color: AppTheme.info,
                    route: .trends
                )
            }
        }
    }

    private func exploreCard(icon: String, title: String, subtitle: String, color: Color, route: CCAppRoute) -> some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyBold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppFont.caption2)
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.lg)
        }
    }
}

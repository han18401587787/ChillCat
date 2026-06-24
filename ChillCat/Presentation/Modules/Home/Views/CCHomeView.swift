//
//  CCHomeView.swift
//  绪安 - 首页情绪打卡
//

import SwiftUI

struct CCHomeView: View {
    @State private var viewModel = CCEmotionViewModel()
    @Environment(CCAppCoordinator.self) private var coordinator

    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                if viewModel.isLoading {
                    loadingContent
                } else {
                    // 头部问候
                    headerSection

                    // AI 情绪倾听官
                    CCAIListenerCard()

                    // 情绪选择
                    if !viewModel.hasCheckedIn {
                        emotionCheckInSection
                    } else {
                        checkedInCard
                    }

                    // 今日任务
                    dailyTaskSection

                    // 本周回顾
                    weeklyReviewCard

                    // 探索更多
                    exploreSection

                    // 每日语录
                    quoteCard
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("绪安")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadData() }
    }

    // MARK: - Loading Skeleton

    private var loadingContent: some View {
        VStack(spacing: AppSpacing.lg) {
            headerSection
            skeletonCard(height: 120)
            skeletonCard(height: 200)
            skeletonCard(height: 48)
            skeletonCard(height: 100)
            skeletonCard(height: 300)
            skeletonCard(height: 100)
        }
    }

    private func skeletonCard(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: AppRadius.md)
            .fill(AppTheme.surface)
            .frame(height: height)
            .opacity(0.5)
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("现在是什么感受？")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("已陪伴你 \(viewModel.totalDays) 天")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Text("连续\(viewModel.streakDays)天")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.primaryMuted.opacity(0.3))
                .cornerRadius(AppRadius.sm)
        }
    }

    // MARK: - Emotion Grid
    private var emotionCheckInSection: some View {
        VStack(spacing: AppSpacing.md) {
            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(CCEmotion.allCases) { emotion in
                    emotionButton(emotion)
                }
            }

            if let selected = viewModel.selectedEmotion {
                VStack(spacing: AppSpacing.md) {
                    TextField("不用勉强说…", text: $viewModel.todayNote, axis: .vertical)
                        .font(.system(size: 15))
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppRadius.md)
                        .lineLimit(3...5)

                    Button(action: { CCHaptic.success(); viewModel.completeCheckIn() }) {
                        Text("就是这样，进去看看")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.primary)
                            .cornerRadius(AppRadius.md)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedEmotion)
    }

    private func emotionButton(_ emotion: CCEmotion) -> some View {
        Button(action: { CCHaptic.selection(); viewModel.selectEmotion(emotion) }) {
            VStack(spacing: 6) {
                Image(systemName: emotion.iconName)
                    .font(.system(size: 22))
                Text(emotion.rawValue)
                    .font(.system(size: 11))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                viewModel.selectedEmotion == emotion
                    ? AppTheme.primary.opacity(0.15)
                    : AppTheme.surface
            )
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(
                        viewModel.selectedEmotion == emotion
                            ? AppTheme.primary : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .foregroundColor(AppTheme.textPrimary)
    }

    // MARK: - Checked In State
    private var checkedInCard: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).foregroundColor(AppTheme.softGreen)
            Text("今日已打卡")
                .font(.system(size: 18, weight: .semibold))
            Text("完成了！你真的很棒")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppTheme.softGreenLight.opacity(0.3))
        .cornerRadius(AppRadius.lg)
    }

    // MARK: - Daily Task
    private var dailyTaskSection: some View {
        HStack {
            Button(action: { viewModel.completeDailyTask() }) {
                Image(systemName: viewModel.dailyTaskCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(viewModel.dailyTaskCompleted ? AppTheme.softGreen : AppTheme.textMuted)
            }

            Text(viewModel.dailyTask)
                .font(.system(size: 15))
                .foregroundColor(
                    viewModel.dailyTaskCompleted ? AppTheme.textSecondary : AppTheme.textPrimary
                )
                .strikethrough(viewModel.dailyTaskCompleted)

            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Weekly Review
    private var weeklyReviewCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("本周情绪回顾")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("本周 14 个")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Text(viewModel.weeklyNote)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
        .contentShape(Rectangle())
        .onTapGesture {
            coordinator.navigate(to: .trends)
        }
    }

    // MARK: - Explore
    private var exploreSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("探索更多可能")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.sm),
                          GridItem(.flexible())],
                spacing: AppSpacing.sm
            ) {
                exploreCard(icon: "square.grid.2x2.fill", title: "工具箱", color: Color(hex: "B8D4E3"), route: .toolbox)
                exploreCard(icon: "chart.line.uptrend.xyaxis", title: "成长档案", color: Color(hex: "66BB6A"), route: .growthArchive)
                exploreCard(icon: "person.3.fill", title: "互助小组", color: Color(hex: "8B6F47"), route: .mutualAidGroups)
                exploreCard(icon: "cross.case.fill", title: "专业资源", color: Color(hex: "E8B8C8"), route: .professionalResources)
                exploreCard(icon: "chart.bar.fill", title: "情绪趋势", color: Color(hex: "D4C8E8"), route: .trends)
                exploreCard(icon: "book.fill", title: "情绪日记", color: Color(hex: "D9C8E3"), route: .journal)
                exploreCard(icon: "brain.head.profile", title: "冥想放松", color: Color(hex: "B8D4E3"), route: .meditation)
                exploreCard(icon: "lightbulb.fill", title: "小课堂", color: Color(hex: "D5E8D4"), route: .courses)

            }
        }
    }

    func exploreCard(icon: String, title: String, color: Color, route: CCAppRoute) -> some View {
        NavigationLink(value: route) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.15))
                    .cornerRadius(AppRadius.sm)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - Quote
    private var quoteCard: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "quote.opening")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primaryMuted)

            Text(viewModel.quote)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Image(systemName: "quote.closing")
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primaryMuted)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.softPurpleLight.opacity(0.3))
        .cornerRadius(AppRadius.lg)
    }
}

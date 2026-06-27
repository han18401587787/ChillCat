//
//  CCBehavioralActivationView.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 行为激活 View
//

import SwiftUI

// MARK: - Behavioral Activation View

struct CCBehavioralActivationView: View {
        @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCBehavioralActivationViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // View mode selector
                    viewModePicker

                    // Content based on mode
                    switch viewModel.selectedViewMode {
                    case .today:
                        todayView
                    case .weekly:
                        weeklyView
                    case .stats:
                        statsView
                    }

                    // Add button
                    addActivityButton
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppTheme.background.ignoresSafeArea())

            // New activity sheet overlay
            if viewModel.showNewActivityForm {
                newActivityOverlay
            }

            // Rating sheet overlay
            if viewModel.showRatingSheet {
                ratingOverlay
            }
        }
        .navigationTitle("行为激活")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(AppTheme.primary)
            }
        }
    }

    // MARK: - View Mode Picker

    private var viewModePicker: some View {
        HStack(spacing: 0) {
            ForEach(CCBAViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.selectedViewMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(AppFont.footnote.weight(.medium))
                        .foregroundColor(
                            viewModel.selectedViewMode == mode ? .white : AppTheme.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            viewModel.selectedViewMode == mode
                                ? AppTheme.warmGold : Color.clear
                        )
                        .cornerRadius(AppRadius.sm)
                }
            }
        }
        .padding(4)
        .background(AppTheme.surface)
        .cornerRadius(AppRadius.sm)
    }

    // MARK: - Today View

    private var todayView: some View {
        VStack(spacing: AppSpacing.xl) {
            if viewModel.isEmpty {
                emptyState
            } else {
                // Completion summary
                if !viewModel.plannedActivities.isEmpty {
                    HStack(spacing: AppSpacing.sm) {
                        statBadge(
                            label: "完成",
                            value: "\(viewModel.completedActivities.count)/\(viewModel.plannedActivities.count)",
                            color: AppTheme.accentMint
                        )
                        statBadge(
                            label: "完成率",
                            value: "\(Int(viewModel.completionRate * 100))%",
                            color: AppTheme.warmGold
                        )
                        statBadge(
                            label: "预期提升",
                            value: String(format: "%.1f", viewModel.averageExpectedBoost),
                            color: AppTheme.primary
                        )
                    }
                }

                // Today's activity list
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("今日活动")
                        .font(AppFont.title1)
                        .foregroundColor(AppTheme.textPrimary)

                    if viewModel.todaysActivities.isEmpty && !viewModel.plannedActivities.isEmpty {
                        Text("今天没有安排活动，可以查看周视图")
                            .font(AppFont.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                    }

                    ForEach(viewModel.plannedActivities) { activity in
                        activityRow(activity)
                    }
                }
            }
        }
    }

    // MARK: - Weekly View

    private var weeklyView: some View {
        VStack(spacing: AppSpacing.lg) {
            if viewModel.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.weeklyActivities, id: \.0) { date, activities in
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Day header
                        HStack {
                            let formatter = DateFormatter()
                            let dayStr: String = {
                                formatter.dateFormat = "M月d日 EEEE"
                                formatter.locale = Locale(identifier: "zh_CN")
                                return formatter.string(from: date)
                            }()
                            Text(dayStr)
                                .font(AppFont.body.weight(.medium))
                                .foregroundColor(AppTheme.textPrimary)

                            Spacer()

                            if !activities.isEmpty {
                                Text("\(activities.filter(\.isCompleted).count)/\(activities.count) 完成")
                                    .font(AppFont.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }

                        if activities.isEmpty {
                            Text("暂无活动")
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.vertical, AppSpacing.sm)
                        } else {
                            ForEach(activities) { activity in
                                activityRow(activity)
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppRadius.md)
                }
            }
        }
    }

    // MARK: - Stats View

    private var statsView: some View {
        VStack(spacing: AppSpacing.xl) {
            if viewModel.completedActivities.isEmpty {
                VStack(spacing: AppSpacing.lg) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("完成一些活动后，这里会显示心情对比数据")
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(AppSpacing.xl)
            } else {
                // Mood-energy comparison
                VStack(spacing: AppSpacing.md) {
                    Text("预期 vs 实际心情提升")
                        .font(AppFont.title1)
                        .foregroundColor(AppTheme.textPrimary)

                    // Visual comparison bars
                    HStack(alignment: .bottom, spacing: AppSpacing.xl) {
                        VStack(spacing: AppSpacing.sm) {
                            Text(String(format: "%.1f", viewModel.averageExpectedBoost))
                                .font(AppFont.largeTitle)
                                .foregroundColor(AppTheme.textSecondary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.textSecondary.opacity(0.4))
                                .frame(width: 40, height: max(4, CGFloat(viewModel.averageExpectedBoost) * 20))
                            Text("预期")
                                .font(AppFont.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        VStack(spacing: AppSpacing.sm) {
                            Text(String(format: "%.1f", viewModel.averageActualBoost))
                                .font(AppFont.largeTitle)
                                .foregroundColor(AppTheme.warmGold)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.warmGold)
                                .frame(width: 40, height: max(4, CGFloat(viewModel.averageActualBoost) * 20))
                            Text("实际")
                                .font(AppFont.caption)
                                .foregroundColor(AppTheme.warmGold)
                        }
                    }
                    .frame(height: 220)

                    Text(viewModel.moodBoostComparison)
                        .font(AppFont.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.md)

                // Per-activity comparison list
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("各活动对比")
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.textPrimary)

                    ForEach(viewModel.completedActivities) { activity in
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: activity.type.icon)
                                .foregroundColor(activity.type.color)
                                .frame(width: 24)

                            Text(activity.name)
                                .font(AppFont.footnote)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("预期:\(activity.expectedMoodBoost)")
                                    .font(AppFont.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("→")
                                    .font(AppFont.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("实际:\(activity.actualMoodBoost ?? 0)")
                                    .font(AppFont.caption.weight(.medium))
                                    .foregroundColor(
                                        (activity.actualMoodBoost ?? 0) >= activity.expectedMoodBoost
                                            ? AppTheme.accentMint : AppTheme.warmGold
                                    )
                            }
                        }
                        .padding(.vertical, AppSpacing.xs)
                    }
                }
                .padding(AppSpacing.lg)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppRadius.md)
            }
        }
    }

    // MARK: - Activity Row

    private func activityRow(_ activity: CCActivity) -> some View {
        HStack(spacing: AppSpacing.md) {
            // Completion checkbox
            Button {
                CCHaptic.medium()
                viewModel.toggleCompletion(activity)
            } label: {
                Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(activity.isCompleted ? AppTheme.accentMint : AppTheme.textSecondary)
            }

            // Type icon
            Image(systemName: activity.type.icon)
                .foregroundColor(activity.type.color)
                .font(.system(size: 14))
                .frame(width: 20)

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.name)
                    .font(AppFont.body.weight(.medium))
                    .foregroundColor(
                        activity.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary
                    )
                    .strikethrough(activity.isCompleted)

                HStack(spacing: AppSpacing.sm) {
                    Text(activity.type.rawValue)
                        .font(AppFont.caption)
                        .foregroundColor(activity.type.color)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(activity.type.color.opacity(0.15))
                        .cornerRadius(4)

                    Text("预期提升: \(activity.expectedMoodBoost)")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)

                    if let actual = activity.actualMoodBoost {
                        Text("实际: \(actual)")
                            .font(AppFont.caption)
                            .foregroundColor(
                                actual >= activity.expectedMoodBoost ? AppTheme.accentMint : AppTheme.warmGold
                            )
                    }
                }
            }

            Spacer()

            // Delete
            Button {
                viewModel.deleteActivity(activity)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .opacity(0.5)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.sm)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 56))
                .foregroundColor(AppTheme.warmGold.opacity(0.6))
                .padding(.top, AppSpacing.xl)

            Text("还没有计划")
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)

            Text("添加一个让你愉悦的活动吧")
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)

            Text("即使是小事也很重要：喝一杯好咖啡、散步10分钟、给朋友发条消息...")
                .font(AppFont.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Add Button

    private var addActivityButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                viewModel.showNewActivityForm = true
            }
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("添加活动")
            }
            .font(AppFont.body.weight(.medium).weight(.medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppTheme.warmGold)
            .cornerRadius(AppRadius.md)
        }
    }

    // MARK: - New Activity Overlay

    private var newActivityOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        viewModel.showNewActivityForm = false
                    }
                }

            VStack(spacing: AppSpacing.lg) {
                Text("添加新活动")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)

                // Activity name
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("活动名称")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                    TextField("例如：去公园散步20分钟", text: $viewModel.newActivityName)
                        .font(AppFont.body)
                        .padding(AppSpacing.md)
                        .background(AppTheme.surface)
                        .cornerRadius(AppRadius.sm)
                }

                // Type selector
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("活动类型")
                        .font(AppFont.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(CCActivityType.allCases) { type in
                            Button {
                                viewModel.newActivityType = type
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 11))
                                    Text(type.rawValue)
                                        .font(AppFont.caption)
                                }
                                .foregroundColor(
                                    viewModel.newActivityType == type ? .white : AppTheme.textSecondary
                                )
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, AppSpacing.xs)
                                .background(
                                    viewModel.newActivityType == type ? type.color : AppTheme.surface
                                )
                                .cornerRadius(AppRadius.full)
                            }
                        }
                    }
                }

                // Expected mood boost
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text("预期心情提升")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                        Text("\(Int(viewModel.newExpectedMoodBoost))/10")
                            .font(AppFont.body.weight(.medium))
                            .foregroundColor(AppTheme.warmGold)
                    }
                    Slider(value: $viewModel.newExpectedMoodBoost, in: 1...10, step: 1)
                        .tint(AppTheme.warmGold)
                }

                // Scheduled time
                DatePicker(
                    "计划时间",
                    selection: $viewModel.newScheduledTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(AppFont.footnote)
                .foregroundColor(AppTheme.textSecondary)
                .tint(AppTheme.primary)

                // Action buttons
                HStack(spacing: AppSpacing.md) {
                    Button {
                        withAnimation {
                            viewModel.showNewActivityForm = false
                        }
                    } label: {
                        Text("取消")
                            .font(AppFont.body.weight(.medium).weight(.medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(AppTheme.surface)
                            .cornerRadius(AppRadius.md)
                    }

                    Button {
                        viewModel.addActivity()
                    } label: {
                        Text("添加")
                            .font(AppFont.body.weight(.medium).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(
                                viewModel.newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? AppTheme.textSecondary : AppTheme.warmGold
                            )
                            .cornerRadius(AppRadius.md)
                    }
                    .disabled(viewModel.newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(AppTheme.cardBackground)
            )
            .padding(AppSpacing.lg)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Rating Overlay

    private var ratingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.submitRating()
                }

            VStack(spacing: AppSpacing.lg) {
                Text("实际心情提升")
                    .font(AppFont.title1)
                    .foregroundColor(AppTheme.textPrimary)

                Text("完成活动后，你的心情提升了多少？")
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)

                HStack {
                    Text("没变化")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(Int(viewModel.ratingValue))/10")
                        .font(AppFont.largeTitle)
                        .foregroundColor(AppTheme.accentMint)
                    Spacer()
                    Text("非常大")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Slider(value: $viewModel.ratingValue, in: 1...10, step: 1)
                    .tint(AppTheme.accentMint)

                Button {
                    viewModel.submitRating()
                } label: {
                    Text("确认")
                        .font(AppFont.body.weight(.medium).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppTheme.accentMint)
                        .cornerRadius(AppRadius.md)
                }
            }
            .padding(AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(AppTheme.cardBackground)
            )
            .padding(AppSpacing.xl)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Helpers

    private func statBadge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppFont.title3)
                .foregroundColor(color)
            Text(label)
                .font(AppFont.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(AppRadius.sm)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCBehavioralActivationView().environment(CCAppCoordinator())
    }
}

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
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCBehavioralActivationViewModel()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: theme.spacingXL) {
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
                .padding(.horizontal, theme.spacingLG)
                .padding(.top, theme.spacingSM)
                .padding(.bottom, theme.spacing3XL)
            }
            .background(theme.background.ignoresSafeArea())

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
                    .foregroundColor(theme.primary)
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
                        .font(theme.fontBodyS.weight(.medium))
                        .foregroundColor(
                            viewModel.selectedViewMode == mode ? .white : theme.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingSM)
                        .background(
                            viewModel.selectedViewMode == mode
                                ? theme.warm : Color.clear
                        )
                        .cornerRadius(theme.radiusSM)
                }
            }
        }
        .padding(4)
        .background(theme.surface)
        .cornerRadius(theme.radiusSM)
    }

    // MARK: - Today View

    private var todayView: some View {
        VStack(spacing: theme.spacingXL) {
            if viewModel.isEmpty {
                emptyState
            } else {
                // Completion summary
                if !viewModel.plannedActivities.isEmpty {
                    HStack(spacing: theme.spacingSM) {
                        statBadge(
                            label: "完成",
                            value: "\(viewModel.completedActivities.count)/\(viewModel.plannedActivities.count)",
                            color: theme.softGreen
                        )
                        statBadge(
                            label: "完成率",
                            value: "\(Int(viewModel.completionRate * 100))%",
                            color: theme.warm
                        )
                        statBadge(
                            label: "预期提升",
                            value: String(format: "%.1f", viewModel.averageExpectedBoost),
                            color: theme.primary
                        )
                    }
                }

                // Today's activity list
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("今日活动")
                        .font(theme.fontH2)
                        .foregroundColor(theme.textPrimary)

                    if viewModel.todaysActivities.isEmpty && !viewModel.plannedActivities.isEmpty {
                        Text("今天没有安排活动，可以查看周视图")
                            .font(theme.fontBody)
                            .foregroundColor(theme.textMuted)
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
        VStack(spacing: theme.spacingLG) {
            if viewModel.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.weeklyActivities, id: \.0) { date, activities in
                    VStack(alignment: .leading, spacing: theme.spacingSM) {
                        // Day header
                        HStack {
                            let formatter = DateFormatter()
                            let dayStr: String = {
                                formatter.dateFormat = "M月d日 EEEE"
                                formatter.locale = Locale(identifier: "zh_CN")
                                return formatter.string(from: date)
                            }()
                            Text(dayStr)
                                .font(theme.fontBody.weight(.medium))
                                .foregroundColor(theme.textPrimary)

                            Spacer()

                            if !activities.isEmpty {
                                Text("\(activities.filter(\.isCompleted).count)/\(activities.count) 完成")
                                    .font(theme.fontCaption)
                                    .foregroundColor(theme.textMuted)
                            }
                        }

                        if activities.isEmpty {
                            Text("暂无活动")
                                .font(theme.fontBodyS)
                                .foregroundColor(theme.textMuted)
                                .padding(.vertical, theme.spacingSM)
                        } else {
                            ForEach(activities) { activity in
                                activityRow(activity)
                            }
                        }
                    }
                    .padding(theme.spacingLG)
                    .background(theme.cardBackground)
                    .cornerRadius(theme.radiusMD)
                }
            }
        }
    }

    // MARK: - Stats View

    private var statsView: some View {
        VStack(spacing: theme.spacingXL) {
            if viewModel.completedActivities.isEmpty {
                VStack(spacing: theme.spacingLG) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(theme.textMuted)
                    Text("完成一些活动后，这里会显示心情对比数据")
                        .font(theme.fontBody)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(theme.spacing3XL)
            } else {
                // Mood-energy comparison
                VStack(spacing: theme.spacingMD) {
                    Text("预期 vs 实际心情提升")
                        .font(theme.fontH2)
                        .foregroundColor(theme.textPrimary)

                    // Visual comparison bars
                    HStack(alignment: .bottom, spacing: theme.spacing2XL) {
                        VStack(spacing: theme.spacingSM) {
                            Text(String(format: "%.1f", viewModel.averageExpectedBoost))
                                .font(theme.fontH1)
                                .foregroundColor(theme.textMuted)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.textMuted.opacity(0.4))
                                .frame(width: 40, height: max(4, CGFloat(viewModel.averageExpectedBoost) * 20))
                            Text("预期")
                                .font(theme.fontCaption)
                                .foregroundColor(theme.textMuted)
                        }

                        VStack(spacing: theme.spacingSM) {
                            Text(String(format: "%.1f", viewModel.averageActualBoost))
                                .font(theme.fontH1)
                                .foregroundColor(theme.warm)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.warm)
                                .frame(width: 40, height: max(4, CGFloat(viewModel.averageActualBoost) * 20))
                            Text("实际")
                                .font(theme.fontCaption)
                                .foregroundColor(theme.warm)
                        }
                    }
                    .frame(height: 220)

                    Text(viewModel.moodBoostComparison)
                        .font(theme.fontBody)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(theme.spacingLG)
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusMD)

                // Per-activity comparison list
                VStack(alignment: .leading, spacing: theme.spacingSM) {
                    Text("各活动对比")
                        .font(theme.fontH3)
                        .foregroundColor(theme.textPrimary)

                    ForEach(viewModel.completedActivities) { activity in
                        HStack(spacing: theme.spacingMD) {
                            Image(systemName: activity.type.icon)
                                .foregroundColor(activity.type.color)
                                .frame(width: 24)

                            Text(activity.name)
                                .font(theme.fontBodyS)
                                .foregroundColor(theme.textPrimary)
                                .lineLimit(1)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("预期:\(activity.expectedMoodBoost)")
                                    .font(theme.fontCaption)
                                    .foregroundColor(theme.textMuted)
                                Text("→")
                                    .font(theme.fontCaption)
                                    .foregroundColor(theme.textMuted)
                                Text("实际:\(activity.actualMoodBoost ?? 0)")
                                    .font(theme.fontCaption.weight(.medium))
                                    .foregroundColor(
                                        (activity.actualMoodBoost ?? 0) >= activity.expectedMoodBoost
                                            ? theme.softGreen : theme.warm
                                    )
                            }
                        }
                        .padding(.vertical, theme.spacingXS)
                    }
                }
                .padding(theme.spacingLG)
                .background(theme.cardBackground)
                .cornerRadius(theme.radiusMD)
            }
        }
    }

    // MARK: - Activity Row

    private func activityRow(_ activity: CCActivity) -> some View {
        HStack(spacing: theme.spacingMD) {
            // Completion checkbox
            Button {
                CCHaptic.medium()
                viewModel.toggleCompletion(activity)
            } label: {
                Image(systemName: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(activity.isCompleted ? theme.softGreen : theme.textMuted)
            }

            // Type icon
            Image(systemName: activity.type.icon)
                .foregroundColor(activity.type.color)
                .font(.system(size: 14))
                .frame(width: 20)

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.name)
                    .font(theme.fontBody.weight(.medium))
                    .foregroundColor(
                        activity.isCompleted ? theme.textSecondary : theme.textPrimary
                    )
                    .strikethrough(activity.isCompleted)

                HStack(spacing: theme.spacingSM) {
                    Text(activity.type.rawValue)
                        .font(theme.fontLabel)
                        .foregroundColor(activity.type.color)
                        .padding(.horizontal, theme.spacingXS)
                        .padding(.vertical, 2)
                        .background(activity.type.color.opacity(0.15))
                        .cornerRadius(4)

                    Text("预期提升: \(activity.expectedMoodBoost)")
                        .font(theme.fontLabel)
                        .foregroundColor(theme.textMuted)

                    if let actual = activity.actualMoodBoost {
                        Text("实际: \(actual)")
                            .font(theme.fontLabel)
                            .foregroundColor(
                                actual >= activity.expectedMoodBoost ? theme.softGreen : theme.warm
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
                    .foregroundColor(theme.textMuted)
            }
            .opacity(0.5)
        }
        .padding(theme.spacingMD)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusSM)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: theme.spacingLG) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 56))
                .foregroundColor(theme.warmMuted)
                .padding(.top, theme.spacing3XL)

            Text("还没有计划")
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)

            Text("添加一个让你愉悦的活动吧")
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)

            Text("即使是小事也很重要：喝一杯好咖啡、散步10分钟、给朋友发条消息...")
                .font(theme.fontBody)
                .foregroundColor(theme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacingLG)
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
            .font(theme.fontBodyL.weight(.medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacingMD)
            .background(theme.warm)
            .cornerRadius(theme.radiusMD)
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

            VStack(spacing: theme.spacingLG) {
                Text("添加新活动")
                    .font(theme.fontH2)
                    .foregroundColor(theme.textPrimary)

                // Activity name
                VStack(alignment: .leading, spacing: theme.spacingXS) {
                    Text("活动名称")
                        .font(theme.fontBodyS)
                        .foregroundColor(theme.textSecondary)
                    TextField("例如：去公园散步20分钟", text: $viewModel.newActivityName)
                        .font(theme.fontBody)
                        .padding(theme.spacingMD)
                        .background(theme.surface)
                        .cornerRadius(theme.radiusSM)
                }

                // Type selector
                VStack(alignment: .leading, spacing: theme.spacingXS) {
                    Text("活动类型")
                        .font(theme.fontBodyS)
                        .foregroundColor(theme.textSecondary)
                    HStack(spacing: theme.spacingSM) {
                        ForEach(CCActivityType.allCases) { type in
                            Button {
                                viewModel.newActivityType = type
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 11))
                                    Text(type.rawValue)
                                        .font(theme.fontCaption)
                                }
                                .foregroundColor(
                                    viewModel.newActivityType == type ? .white : theme.textSecondary
                                )
                                .padding(.horizontal, theme.spacingSM)
                                .padding(.vertical, theme.spacingXS)
                                .background(
                                    viewModel.newActivityType == type ? type.color : theme.surface
                                )
                                .cornerRadius(theme.radiusFull)
                            }
                        }
                    }
                }

                // Expected mood boost
                VStack(alignment: .leading, spacing: theme.spacingXS) {
                    HStack {
                        Text("预期心情提升")
                            .font(theme.fontBodyS)
                            .foregroundColor(theme.textSecondary)
                        Spacer()
                        Text("\(Int(viewModel.newExpectedMoodBoost))/10")
                            .font(theme.fontBody.weight(.medium))
                            .foregroundColor(theme.warm)
                    }
                    Slider(value: $viewModel.newExpectedMoodBoost, in: 1...10, step: 1)
                        .tint(theme.warm)
                }

                // Scheduled time
                DatePicker(
                    "计划时间",
                    selection: $viewModel.newScheduledTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(theme.fontBodyS)
                .foregroundColor(theme.textSecondary)
                .tint(theme.primary)

                // Action buttons
                HStack(spacing: theme.spacingMD) {
                    Button {
                        withAnimation {
                            viewModel.showNewActivityForm = false
                        }
                    } label: {
                        Text("取消")
                            .font(theme.fontBodyL.weight(.medium))
                            .foregroundColor(theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacingMD)
                            .background(theme.surface)
                            .cornerRadius(theme.radiusMD)
                    }

                    Button {
                        viewModel.addActivity()
                    } label: {
                        Text("添加")
                            .font(theme.fontBodyL.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacingMD)
                            .background(
                                viewModel.newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? theme.textMuted : theme.warm
                            )
                            .cornerRadius(theme.radiusMD)
                    }
                    .disabled(viewModel.newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(theme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: theme.radiusXL)
                    .fill(theme.cardBackground)
            )
            .padding(theme.spacingLG)
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

            VStack(spacing: theme.spacingLG) {
                Text("实际心情提升")
                    .font(theme.fontH2)
                    .foregroundColor(theme.textPrimary)

                Text("完成活动后，你的心情提升了多少？")
                    .font(theme.fontBody)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)

                HStack {
                    Text("没变化")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                    Spacer()
                    Text("\(Int(viewModel.ratingValue))/10")
                        .font(theme.fontH1)
                        .foregroundColor(theme.softGreen)
                    Spacer()
                    Text("非常大")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                }

                Slider(value: $viewModel.ratingValue, in: 1...10, step: 1)
                    .tint(theme.softGreen)

                Button {
                    viewModel.submitRating()
                } label: {
                    Text("确认")
                        .font(theme.fontBodyL.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingMD)
                        .background(theme.softGreen)
                        .cornerRadius(theme.radiusMD)
                }
            }
            .padding(theme.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: theme.radiusXL)
                    .fill(theme.cardBackground)
            )
            .padding(theme.spacing2XL)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Helpers

    private func statBadge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(theme.fontH3)
                .foregroundColor(color)
            Text(label)
                .font(theme.fontLabel)
                .foregroundColor(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacingSM)
        .background(color.opacity(0.1))
        .cornerRadius(theme.radiusSM)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCBehavioralActivationView()
            .environment(\.ccAppTheme, CCLightTheme())
            .environment(CCAppCoordinator())
    }
}

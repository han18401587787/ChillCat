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
                VStack(spacing: XuanSpacing.xl) {
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
                .padding(.horizontal, XuanSpacing.lg)
                .padding(.top, XuanSpacing.sm)
                .padding(.bottom, XuanSpacing.xl)
            }
            .background(Color.xuanApricotBg.ignoresSafeArea())

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
                    .foregroundColor(Color.xuanApricot)
                    .accessibilityIdentifier("ba_close")
            }
        }
        .trackPage("Toolbox:CCBehavioralActivationView")
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
                        .font(XuanFont.bodyS.weight(.medium))
                        .foregroundColor(
                            viewModel.selectedViewMode == mode ? .white : Color.xuanTextSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.sm)
                        .background(
                            viewModel.selectedViewMode == mode
                                ? Color.xuanApricotDark : Color.clear
                        )
                        .cornerRadius(XuanRadius.sm)
                }
                .accessibilityIdentifier("ba_view_mode_\(mode.rawValue)")
            }
        }
        .padding(4)
        .background(Color.xuanSurface)
        .cornerRadius(XuanRadius.sm)
    }

    // MARK: - Today View

    private var todayView: some View {
        VStack(spacing: XuanSpacing.xl) {
            if viewModel.isEmpty {
                emptyState
            } else {
                // Completion summary
                if !viewModel.plannedActivities.isEmpty {
                    HStack(spacing: XuanSpacing.sm) {
                        statBadge(
                            label: "完成",
                            value: "\(viewModel.completedActivities.count)/\(viewModel.plannedActivities.count)",
                            color: Color.xuanMint
                        )
                        statBadge(
                            label: "完成率",
                            value: "\(Int(viewModel.completionRate * 100))%",
                            color: Color.xuanApricotDark
                        )
                        statBadge(
                            label: "预期提升",
                            value: String(format: "%.1f", viewModel.averageExpectedBoost),
                            color: Color.xuanApricot
                        )
                    }
                }

                // Today's activity list
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("今日活动")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)

                    if viewModel.todaysActivities.isEmpty && !viewModel.plannedActivities.isEmpty {
                        Text("今天没有安排活动，可以查看周视图")
                            .font(XuanFont.bodyL)
                            .foregroundColor(Color.xuanTextSecondary)
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
        VStack(spacing: XuanSpacing.lg) {
            if viewModel.isEmpty {
                emptyState
            } else {
                ForEach(viewModel.weeklyActivities, id: \.0) { date, activities in
                    VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                        // Day header
                        HStack {
                            let formatter = DateFormatter()
                            let dayStr: String = {
                                formatter.dateFormat = "M月d日 EEEE"
                                formatter.locale = Locale(identifier: "zh_CN")
                                return formatter.string(from: date)
                            }()
                            Text(dayStr)
                                .font(XuanFont.bodyLMedium)
                                .foregroundColor(Color.xuanTextPrimary)

                            Spacer()

                            if !activities.isEmpty {
                                Text("\(activities.filter(\.isCompleted).count)/\(activities.count) 完成")
                                    .font(XuanFont.bodyM)
                                    .foregroundColor(Color.xuanTextSecondary)
                            }
                        }

                        if activities.isEmpty {
                            Text("暂无活动")
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextSecondary)
                                .padding(.vertical, XuanSpacing.sm)
                        } else {
                            ForEach(activities) { activity in
                                activityRow(activity)
                            }
                        }
                    }
                    .padding(XuanSpacing.lg)
                    .background(Color.xuanWhite)
                    .cornerRadius(XuanRadius.md)
                }
            }
        }
    }

    // MARK: - Stats View

    private var statsView: some View {
        VStack(spacing: XuanSpacing.xl) {
            if viewModel.completedActivities.isEmpty {
                VStack(spacing: XuanSpacing.lg) {
                    Image("report_trend")
                        .font(.system(size: 48))
                        .foregroundColor(Color.xuanTextSecondary)
                    Text("完成一些活动后，这里会显示心情对比数据")
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(XuanSpacing.xl)
            } else {
                // Mood-energy comparison
                VStack(spacing: XuanSpacing.md) {
                    Text("预期 vs 实际心情提升")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)

                    // Visual comparison bars
                    HStack(alignment: .bottom, spacing: XuanSpacing.xl) {
                        VStack(spacing: XuanSpacing.sm) {
                            Text(String(format: "%.1f", viewModel.averageExpectedBoost))
                                .font(XuanFont.h1)
                                .foregroundColor(Color.xuanTextSecondary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.xuanTextSecondary.opacity(0.4))
                                .frame(width: 40, height: max(4, CGFloat(viewModel.averageExpectedBoost) * 20))
                            Text("预期")
                                .font(XuanFont.bodyM)
                                .foregroundColor(Color.xuanTextSecondary)
                        }

                        VStack(spacing: XuanSpacing.sm) {
                            Text(String(format: "%.1f", viewModel.averageActualBoost))
                                .font(XuanFont.h1)
                                .foregroundColor(Color.xuanApricotDark)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.xuanApricotDark)
                                .frame(width: 40, height: max(4, CGFloat(viewModel.averageActualBoost) * 20))
                            Text("实际")
                                .font(XuanFont.bodyM)
                                .foregroundColor(Color.xuanApricotDark)
                        }
                    }
                    .frame(height: 220)

                    Text(viewModel.moodBoostComparison)
                        .font(XuanFont.bodyL)
                        .foregroundColor(Color.xuanTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.md)

                // Per-activity comparison list
                VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                    Text("各活动对比")
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanTextPrimary)

                    ForEach(viewModel.completedActivities) { activity in
                        HStack(spacing: XuanSpacing.md) {
                            CCIconMapper.image(for: activity.type.icon)
                                .foregroundColor(activity.type.color)
                                .frame(width: 24)

                            Text(activity.name)
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanTextPrimary)
                                .lineLimit(1)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("预期:\(activity.expectedMoodBoost)")
                                    .font(XuanFont.bodyM)
                                    .foregroundColor(Color.xuanTextSecondary)
                                Text("→")
                                    .font(XuanFont.bodyM)
                                    .foregroundColor(Color.xuanTextSecondary)
                                Text("实际:\(activity.actualMoodBoost ?? 0)")
                                    .font(XuanFont.bodyM)
                                    .foregroundColor(
                                        (activity.actualMoodBoost ?? 0) >= activity.expectedMoodBoost
                                            ? Color.xuanMint : Color.xuanApricotDark
                                    )
                            }
                        }
                        .padding(.vertical, XuanSpacing.xs)
                    }
                }
                .padding(XuanSpacing.lg)
                .background(Color.xuanWhite)
                .cornerRadius(XuanRadius.md)
            }
        }
    }

    // MARK: - Activity Row

    private func activityRow(_ activity: CCActivity) -> some View {
        HStack(spacing: XuanSpacing.md) {
            // Completion checkbox
            Button {
                CCHaptic.medium()
                viewModel.toggleCompletion(activity)
            } label: {
                CCIconMapper.image(for: activity.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(activity.isCompleted ? Color.xuanMint : Color.xuanTextSecondary)
            }
            .accessibilityIdentifier("ba_activity_check_\(activity.id)")

            // Type icon
            CCIconMapper.image(for: activity.type.icon)
                .foregroundColor(activity.type.color)
                .font(.system(size: 14))
                .frame(width: 20)

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.name)
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(
                        activity.isCompleted ? Color.xuanTextSecondary : Color.xuanTextPrimary
                    )
                    .strikethrough(activity.isCompleted)

                HStack(spacing: XuanSpacing.sm) {
                    Text(activity.type.rawValue)
                        .font(XuanFont.bodyM)
                        .foregroundColor(activity.type.color)
                        .padding(.horizontal, XuanSpacing.xs)
                        .padding(.vertical, 2)
                        .background(activity.type.color.opacity(0.15))
                        .cornerRadius(4)

                    Text("预期提升: \(activity.expectedMoodBoost)")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)

                    if let actual = activity.actualMoodBoost {
                        Text("实际: \(actual)")
                            .font(XuanFont.bodyM)
                            .foregroundColor(
                                actual >= activity.expectedMoodBoost ? Color.xuanMint : Color.xuanApricotDark
                            )
                    }
                }
            }

            Spacer()

            // Delete
            Button {
                viewModel.deleteActivity(activity)
            } label: {
                Image("common_delete")
                    .font(.system(size: 12))
                    .foregroundColor(Color.xuanTextSecondary)
            }
            .opacity(0.5)
            .accessibilityIdentifier("ba_activity_delete_\(activity.id)")
        }
        .padding(XuanSpacing.md)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.sm)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: XuanSpacing.lg) {
            Image("emotion_happy")
                .font(.system(size: 56))
                .foregroundColor(Color.xuanApricotDark.opacity(0.6))
                .padding(.top, XuanSpacing.xl)

            Text("还没有计划")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text("添加一个让你愉悦的活动吧")
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)

            Text("即使是小事也很重要：喝一杯好咖啡、散步10分钟、给朋友发条消息...")
                .font(XuanFont.bodyL)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, XuanSpacing.lg)
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
                Image("common_add")
                Text("添加活动")
            }
            .font(XuanFont.bodyLMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, XuanSpacing.md)
            .background(Color.xuanApricotDark)
            .cornerRadius(XuanRadius.md)
        }
        .accessibilityIdentifier("ba_add_activity")
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

            VStack(spacing: XuanSpacing.lg) {
                Text("添加新活动")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)

                // Activity name
                VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                    Text("活动名称")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                    TextField("例如：去公园散步20分钟", text: $viewModel.newActivityName)
                        .font(XuanFont.bodyL)
                        .padding(XuanSpacing.md)
                        .background(Color.xuanSurface)
                        .cornerRadius(XuanRadius.sm)
                        .accessibilityIdentifier("ba_new_activity_name")
                }

                // Type selector
                VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                    Text("活动类型")
                        .font(XuanFont.bodyS)
                        .foregroundColor(Color.xuanTextSecondary)
                    HStack(spacing: XuanSpacing.sm) {
                        ForEach(CCActivityType.allCases) { type in
                            Button {
                                viewModel.newActivityType = type
                            } label: {
                                HStack(spacing: 4) {
                                    CCIconMapper.image(for: type.icon)
                                        .font(.system(size: 11))
                                    Text(type.rawValue)
                                        .font(XuanFont.bodyM)
                                }
                                .foregroundColor(
                                    viewModel.newActivityType == type ? .white : Color.xuanTextSecondary
                                )
                                .padding(.horizontal, XuanSpacing.sm)
                                .padding(.vertical, XuanSpacing.xs)
                                .background(
                                    viewModel.newActivityType == type ? type.color : Color.xuanSurface
                                )
                                .cornerRadius(XuanRadius.full)
                            }
                            .accessibilityIdentifier("ba_new_activity_type_\(type.rawValue)")
                        }
                    }
                }

                // Expected mood boost
                VStack(alignment: .leading, spacing: XuanSpacing.xs) {
                    HStack {
                        Text("预期心情提升")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                        Spacer()
                        Text("\(Int(viewModel.newExpectedMoodBoost))/10")
                            .font(XuanFont.bodyLMedium)
                            .foregroundColor(Color.xuanApricotDark)
                    }
                    Slider(value: $viewModel.newExpectedMoodBoost, in: 1...10, step: 1)
                        .tint(Color.xuanApricotDark)
                        .accessibilityIdentifier("ba_new_mood_boost_slider")
                }

                // Scheduled time
                DatePicker(
                    "计划时间",
                    selection: $viewModel.newScheduledTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(XuanFont.bodyS)
                .foregroundColor(Color.xuanTextSecondary)
                .tint(Color.xuanApricot)
                .accessibilityIdentifier("ba_new_scheduled_time")

                // Action buttons
                HStack(spacing: XuanSpacing.md) {
                    Button {
                        withAnimation {
                            viewModel.showNewActivityForm = false
                        }
                    } label: {
                        Text("取消")
                            .font(XuanFont.bodyLMedium)
                            .foregroundColor(Color.xuanTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, XuanSpacing.md)
                            .background(Color.xuanSurface)
                            .cornerRadius(XuanRadius.md)
                    }
                    .accessibilityIdentifier("ba_new_activity_cancel")

                    Button {
                        viewModel.addActivity()
                    } label: {
                        Text("添加")
                            .font(XuanFont.bodyLMedium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, XuanSpacing.md)
                            .background(
                                viewModel.newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.xuanTextSecondary : Color.xuanApricotDark
                            )
                            .cornerRadius(XuanRadius.md)
                    }
                    .disabled(viewModel.newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("ba_new_activity_confirm")
                }
            }
            .padding(XuanSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.xl)
                    .fill(Color.xuanWhite)
            )
            .padding(XuanSpacing.lg)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Rating Overlay

    private var ratingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // 点背景关闭浮层，而非误提交评分
                    viewModel.showRatingSheet = false
                }

            VStack(spacing: XuanSpacing.lg) {
                Text("实际心情提升")
                    .font(XuanFont.h1)
                    .foregroundColor(Color.xuanTextPrimary)

                Text("完成活动后，你的心情提升了多少？")
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)

                HStack {
                    Text("没变化")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                    Spacer()
                    Text("\(Int(viewModel.ratingValue))/10")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanMint)
                    Spacer()
                    Text("非常大")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Slider(value: $viewModel.ratingValue, in: 1...10, step: 1)
                    .tint(Color.xuanMint)
                    .accessibilityIdentifier("ba_rating_slider")

                Button {
                    viewModel.submitRating()
                } label: {
                    Text("确认")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanMint)
                        .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("ba_rating_confirm")
            }
            .padding(XuanSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: XuanRadius.xl)
                    .fill(Color.xuanWhite)
            )
            .padding(XuanSpacing.xl)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Helpers

    private func statBadge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(XuanFont.h3)
                .foregroundColor(color)
            Text(label)
                .font(XuanFont.bodyM)
                .foregroundColor(Color.xuanTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, XuanSpacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(XuanRadius.sm)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCBehavioralActivationView().environment(CCAppCoordinator())
    }
}

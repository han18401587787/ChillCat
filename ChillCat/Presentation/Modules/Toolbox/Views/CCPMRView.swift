//
//  CCPMRView.swift
//  ChillCat
//
//  Created by ChillCat on 2026/6/18.
//  绪安 — 渐进式肌肉放松 View
//

import SwiftUI

// MARK: - PMR View

struct CCPMRView: View {
        @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCPMRViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                if case .completed = viewModel.phase {
                    completionContent
                } else {
                    exerciseContent
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("渐进式肌肉放松")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(AppTheme.primary)
            }
        }
        .onDisappear {
            if case .tense = viewModel.phase {
                viewModel.reset()
            }
        }
    }

    // MARK: - Exercise Content

    private var exerciseContent: some View {
        VStack(spacing: AppSpacing.xl) {
            // Progress bar
            progressSection

            // Breathing circle
            breathingCircle

            // Current instruction
            instructionCard

            // Muscle group list
            muscleGroupList

            // Controls
            controlButtons
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.phaseLabel)
                        .font(AppFont.title3)
                        .foregroundColor(AppTheme.primary)
                    if let group = viewModel.currentMuscleGroup, viewModel.phase != .idle {
                        Text("\(group.name) (\(viewModel.currentGroupIndex + 1)/\(viewModel.totalGroups))")
                            .font(AppFont.footnote)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                Spacer()
                if viewModel.phase != .idle {
                    Text(viewModel.formattedRemaining)
                        .font(AppFont.title1)
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.border)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryLight, Color(hex: "66BB6A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                }
            }
            .frame(height: 8)
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Breathing Circle

    private var breathingCircle: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        viewModel.isTense ? Color(hex: "8B6F47").opacity(0.3) : Color(hex: "66BB6A").opacity(0.3),
                        lineWidth: 3
                    )
                    .frame(width: 160, height: 160)

                // Animated ring
                Circle()
                    .trim(from: 0, to: viewModel.isTense ? 1 : viewModel.breathingScale)
                    .stroke(
                        viewModel.isTense ? Color(hex: "8B6F47") : Color(hex: "66BB6A"),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: viewModel.breathingScale)

                // Inner circle that scales
                Circle()
                    .fill(
                        viewModel.isTense
                            ? Color(hex: "8B6F47").opacity(0.15)
                            : Color(hex: "66BB6A").opacity(0.15)
                    )
                    .frame(
                        width: 120 * viewModel.breathingScale,
                        height: 120 * viewModel.breathingScale
                    )
                    .animation(.easeInOut(duration: 0.8), value: viewModel.breathingScale)

                // Center text
                VStack(spacing: 4) {
                    if viewModel.phase == .idle {
                        Image(systemName: "figure.mind.and.body")
                            .font(.system(size: 36))
                            .foregroundColor(AppTheme.primaryMuted)
                        Text("准备")
                            .font(AppFont.body.weight(.medium))
                            .foregroundColor(AppTheme.textSecondary)
                    } else {
                        Text(viewModel.isTense ? "紧张" : "放松")
                            .font(AppFont.title1)
                            .foregroundColor(viewModel.isTense ? Color(hex: "8B6F47") : Color(hex: "66BB6A"))
                            .contentTransition(.identity)
                        Text("\(viewModel.secondsInPhase)s")
                            .font(AppFont.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .monospacedDigit()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isTense)
            }
        }
    }

    // MARK: - Instruction Card

    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let group = viewModel.currentMuscleGroup, viewModel.phase != .idle {
                HStack {
                    Image(systemName: group.icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.primary)
                    Text(group.name)
                        .font(AppFont.title1)
                        .foregroundColor(AppTheme.textPrimary)
                }
            }

            Text(viewModel.phaseDescription)
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    // MARK: - Muscle Group List

    private var muscleGroupList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("肌群列表")
                .font(AppFont.title3)
                .foregroundColor(AppTheme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                    GridItem(.flexible(), spacing: AppSpacing.sm),
                ],
                spacing: AppSpacing.sm
            ) {
                ForEach(Array(CCMuscleGroup.all.enumerated()), id: \.element.id) { index, group in
                    muscleGroupCell(group: group, index: index)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppRadius.md)
    }

    private func muscleGroupCell(group: CCMuscleGroup, index: Int) -> some View {
        let isActive = index == viewModel.currentGroupIndex && viewModel.phase != .idle && viewModel.phase != .completed
        let isDone = index < viewModel.currentGroupIndex

        return HStack(spacing: AppSpacing.sm) {
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "66BB6A"))
                    .font(.system(size: 14))
            } else if isActive {
                Circle()
                    .fill(viewModel.isTense ? Color(hex: "8B6F47") : Color(hex: "66BB6A"))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(
                                viewModel.isTense ? Color(hex: "8B6F47").opacity(0.3) : Color(hex: "66BB6A").opacity(0.3),
                                lineWidth: 3
                            )
                            .scaleEffect(viewModel.isTense ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isTense)
                    )
            } else {
                Circle()
                    .fill(AppTheme.border)
                    .frame(width: 8, height: 8)
            }

            Image(systemName: group.icon)
                .font(.system(size: 11))
                .foregroundColor(isActive ? AppTheme.primary : (isDone ? Color(hex: "66BB6A") : AppTheme.textSecondary))

            Text(group.name)
                .font(AppFont.footnote)
                .foregroundColor(isActive ? AppTheme.textPrimary : (isDone ? Color(hex: "66BB6A") : AppTheme.textSecondary))
                .lineLimit(1)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: AppSpacing.md) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始练习")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.primary)
                    .cornerRadius(AppRadius.md)
                }

            default:
                // Pause/Resume
                Button {
                    viewModel.togglePause()
                } label: {
                    HStack {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        Text(viewModel.isPaused ? "继续" : "暂停")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.primary.opacity(0.1))
                    .cornerRadius(AppRadius.md)
                }

                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重新开始")
                    }
                    .font(AppFont.body.weight(.medium).weight(.medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppTheme.surface)
                    .cornerRadius(AppRadius.md)
                }
            }
        }
    }

    // MARK: - Completion

    private var completionContent: some View {
        VStack(spacing: AppSpacing.xl) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color(hex: "66BB6A").opacity(0.3))
                    .frame(width: 100, height: 100)
                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: "66BB6A"))
            }
            .padding(.top, AppSpacing.xl)

            Text("放松练习完成！")
                .font(AppFont.largeTitle)
                .foregroundColor(AppTheme.textPrimary)

            Text("你完成了全部16个肌群的渐进式放松练习。花一点时间感受身体的感受。")
                .font(AppFont.body.weight(.medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)

            // Body feeling rating
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("身体感受评分")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)

                HStack {
                    Text("非常紧张")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(Int(viewModel.bodyFeelingRating))/10")
                        .font(AppFont.title1)
                        .foregroundColor(Color(hex: "66BB6A"))
                    Spacer()
                    Text("完全放松")
                        .font(AppFont.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Slider(value: $viewModel.bodyFeelingRating, in: 1...10, step: 1)
                    .tint(Color(hex: "66BB6A"))

                Text(viewModel.completionMessage)
                    .font(AppFont.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Muscle groups completed
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("已完成的肌群")
                    .font(AppFont.title3)
                    .foregroundColor(AppTheme.textPrimary)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppSpacing.sm),
                        GridItem(.flexible(), spacing: AppSpacing.sm),
                    ],
                    spacing: AppSpacing.sm
                ) {
                    ForEach(CCMuscleGroup.all) { group in
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "66BB6A"))
                                .font(.system(size: 12))
                            Image(systemName: group.icon)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "66BB6A"))
                            Text(group.name)
                                .font(AppFont.footnote)
                                .foregroundColor(Color(hex: "66BB6A"))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppRadius.md)

            // Actions
            VStack(spacing: AppSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次")
                        .font(AppFont.body.weight(.medium).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppTheme.primary)
                        .cornerRadius(AppRadius.md)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(AppFont.body.weight(.medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.top, AppSpacing.lg)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCPMRView().environment(CCAppCoordinator())
    }
}

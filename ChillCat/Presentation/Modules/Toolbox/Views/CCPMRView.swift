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
    @Environment(\.ccAppTheme) private var theme
    @Environment(CCAppCoordinator.self) private var coordinator
    @State private var viewModel = CCPMRViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingXL) {
                if case .completed = viewModel.phase {
                    completionContent
                } else {
                    exerciseContent
                }
            }
            .padding(.horizontal, theme.spacingLG)
            .padding(.top, theme.spacingSM)
            .padding(.bottom, theme.spacing3XL)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("渐进式肌肉放松")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(theme.primary)
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
        VStack(spacing: theme.spacingXL) {
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
        VStack(spacing: theme.spacingSM) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.phaseLabel)
                        .font(theme.fontH3)
                        .foregroundColor(theme.primary)
                    if let group = viewModel.currentMuscleGroup, viewModel.phase != .idle {
                        Text("\(group.name) (\(viewModel.currentGroupIndex + 1)/\(viewModel.totalGroups))")
                            .font(theme.fontBodyS)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                Spacer()
                if viewModel.phase != .idle {
                    Text(viewModel.formattedRemaining)
                        .font(theme.fontH2)
                        .foregroundColor(theme.textPrimary)
                        .monospacedDigit()
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.divider)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [theme.primaryLight, theme.softGreen],
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
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Breathing Circle

    private var breathingCircle: some View {
        VStack(spacing: theme.spacingMD) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        viewModel.isTense ? theme.warm.opacity(0.3) : theme.softGreen.opacity(0.3),
                        lineWidth: 3
                    )
                    .frame(width: 160, height: 160)

                // Animated ring
                Circle()
                    .trim(from: 0, to: viewModel.isTense ? 1 : viewModel.breathingScale)
                    .stroke(
                        viewModel.isTense ? theme.warm : theme.softGreen,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: viewModel.breathingScale)

                // Inner circle that scales
                Circle()
                    .fill(
                        viewModel.isTense
                            ? theme.warm.opacity(0.15)
                            : theme.softGreen.opacity(0.15)
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
                            .foregroundColor(theme.primaryMuted)
                        Text("准备")
                            .font(theme.fontBodyL)
                            .foregroundColor(theme.textSecondary)
                    } else {
                        Text(viewModel.isTense ? "紧张" : "放松")
                            .font(theme.fontH2)
                            .foregroundColor(viewModel.isTense ? theme.warm : theme.softGreen)
                            .contentTransition(.identity)
                        Text("\(viewModel.secondsInPhase)s")
                            .font(theme.fontCaption)
                            .foregroundColor(theme.textMuted)
                            .monospacedDigit()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isTense)
            }
        }
    }

    // MARK: - Instruction Card

    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            if let group = viewModel.currentMuscleGroup, viewModel.phase != .idle {
                HStack {
                    Image(systemName: group.icon)
                        .font(.system(size: 24))
                        .foregroundColor(theme.primary)
                    Text(group.name)
                        .font(theme.fontH2)
                        .foregroundColor(theme.textPrimary)
                }
            }

            Text(viewModel.phaseDescription)
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    // MARK: - Muscle Group List

    private var muscleGroupList: some View {
        VStack(alignment: .leading, spacing: theme.spacingSM) {
            Text("肌群列表")
                .font(theme.fontH3)
                .foregroundColor(theme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: theme.spacingSM),
                    GridItem(.flexible(), spacing: theme.spacingSM),
                ],
                spacing: theme.spacingSM
            ) {
                ForEach(Array(CCMuscleGroup.all.enumerated()), id: \.element.id) { index, group in
                    muscleGroupCell(group: group, index: index)
                }
            }
        }
        .padding(theme.spacingLG)
        .background(theme.cardBackground)
        .cornerRadius(theme.radiusMD)
    }

    private func muscleGroupCell(group: CCMuscleGroup, index: Int) -> some View {
        let isActive = index == viewModel.currentGroupIndex && viewModel.phase != .idle && viewModel.phase != .completed
        let isDone = index < viewModel.currentGroupIndex

        return HStack(spacing: theme.spacingSM) {
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(theme.softGreen)
                    .font(.system(size: 14))
            } else if isActive {
                Circle()
                    .fill(viewModel.isTense ? theme.warm : theme.softGreen)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(
                                viewModel.isTense ? theme.warm.opacity(0.3) : theme.softGreen.opacity(0.3),
                                lineWidth: 3
                            )
                            .scaleEffect(viewModel.isTense ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isTense)
                    )
            } else {
                Circle()
                    .fill(theme.divider)
                    .frame(width: 8, height: 8)
            }

            Image(systemName: group.icon)
                .font(.system(size: 11))
                .foregroundColor(isActive ? theme.primary : (isDone ? theme.softGreen : theme.textMuted))

            Text(group.name)
                .font(theme.fontBodyS)
                .foregroundColor(isActive ? theme.textPrimary : (isDone ? theme.softGreen : theme.textMuted))
                .lineLimit(1)
        }
        .padding(.vertical, theme.spacingXS)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: theme.spacingMD) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始练习")
                    }
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.primary)
                    .cornerRadius(theme.radiusMD)
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
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.primary.opacity(0.1))
                    .cornerRadius(theme.radiusMD)
                }

                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重新开始")
                    }
                    .font(theme.fontBodyL.weight(.medium))
                    .foregroundColor(theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacingMD)
                    .background(theme.surface)
                    .cornerRadius(theme.radiusMD)
                }
            }
        }
    }

    // MARK: - Completion

    private var completionContent: some View {
        VStack(spacing: theme.spacingXL) {
            // Success icon
            ZStack {
                Circle()
                    .fill(theme.softGreenLight)
                    .frame(width: 100, height: 100)
                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 44))
                    .foregroundColor(theme.softGreen)
            }
            .padding(.top, theme.spacing2XL)

            Text("放松练习完成！")
                .font(theme.fontH1)
                .foregroundColor(theme.textPrimary)

            Text("你完成了全部16个肌群的渐进式放松练习。花一点时间感受身体的感受。")
                .font(theme.fontBodyL)
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.spacingLG)

            // Body feeling rating
            VStack(alignment: .leading, spacing: theme.spacingMD) {
                Text("身体感受评分")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)

                HStack {
                    Text("非常紧张")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                    Spacer()
                    Text("\(Int(viewModel.bodyFeelingRating))/10")
                        .font(theme.fontH2)
                        .foregroundColor(theme.softGreen)
                    Spacer()
                    Text("完全放松")
                        .font(theme.fontCaption)
                        .foregroundColor(theme.textMuted)
                }

                Slider(value: $viewModel.bodyFeelingRating, in: 1...10, step: 1)
                    .tint(theme.softGreen)

                Text(viewModel.completionMessage)
                    .font(theme.fontBody)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Muscle groups completed
            VStack(alignment: .leading, spacing: theme.spacingSM) {
                Text("已完成的肌群")
                    .font(theme.fontH3)
                    .foregroundColor(theme.textPrimary)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: theme.spacingSM),
                        GridItem(.flexible(), spacing: theme.spacingSM),
                    ],
                    spacing: theme.spacingSM
                ) {
                    ForEach(CCMuscleGroup.all) { group in
                        HStack(spacing: theme.spacingSM) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(theme.softGreen)
                                .font(.system(size: 12))
                            Image(systemName: group.icon)
                                .font(.system(size: 11))
                                .foregroundColor(theme.softGreen)
                            Text(group.name)
                                .font(theme.fontBodyS)
                                .foregroundColor(theme.softGreen)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacingLG)
            .background(theme.cardBackground)
            .cornerRadius(theme.radiusMD)

            // Actions
            VStack(spacing: theme.spacingSM) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次")
                        .font(theme.fontBodyL.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacingMD)
                        .background(theme.primary)
                        .cornerRadius(theme.radiusMD)
                }

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(theme.fontBodyL)
                        .foregroundColor(theme.textSecondary)
                }
            }
            .padding(.top, theme.spacingLG)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCPMRView()
            .environment(\.ccAppTheme, CCLightTheme())
            .environment(CCAppCoordinator())
    }
}

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
            VStack(spacing: XuanSpacing.xl) {
                if case .completed = viewModel.phase {
                    completionContent
                } else {
                    exerciseContent
                }
            }
            .padding(.horizontal, XuanSpacing.lg)
            .padding(.top, XuanSpacing.sm)
            .padding(.bottom, XuanSpacing.xl)
        }
        .background(Color.xuanApricotBg.ignoresSafeArea())
        .navigationTitle("渐进式肌肉放松")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("关闭") { coordinator.dismiss() }
                    .foregroundColor(Color.xuanApricot)
                    .accessibilityIdentifier("pmr_close")
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
        VStack(spacing: XuanSpacing.xl) {
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
        VStack(spacing: XuanSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.phaseLabel)
                        .font(XuanFont.h3)
                        .foregroundColor(Color.xuanApricot)
                    if let group = viewModel.currentMuscleGroup, viewModel.phase != .idle {
                        Text("\(group.name) (\(viewModel.currentGroupIndex + 1)/\(viewModel.totalGroups))")
                            .font(XuanFont.bodyS)
                            .foregroundColor(Color.xuanTextSecondary)
                    }
                }
                Spacer()
                if viewModel.phase != .idle {
                    Text(viewModel.formattedRemaining)
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)
                        .monospacedDigit()
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.xuanBorder)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.xuanApricotLight, Color.xuanMint],
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
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Breathing Circle

    private var breathingCircle: some View {
        VStack(spacing: XuanSpacing.md) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        viewModel.isTense ? Color.xuanApricotDark.opacity(0.3) : Color.xuanMint.opacity(0.3),
                        lineWidth: 3
                    )
                    .frame(width: 160, height: 160)

                // Animated ring
                Circle()
                    .trim(from: 0, to: viewModel.isTense ? 1 : viewModel.breathingScale)
                    .stroke(
                        viewModel.isTense ? Color.xuanApricotDark : Color.xuanMint,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: viewModel.breathingScale)

                // Inner circle that scales
                Circle()
                    .fill(
                        viewModel.isTense
                            ? Color.xuanApricotDark.opacity(0.15)
                            : Color.xuanMint.opacity(0.15)
                    )
                    .frame(
                        width: 120 * viewModel.breathingScale,
                        height: 120 * viewModel.breathingScale
                    )
                    .animation(.easeInOut(duration: 0.8), value: viewModel.breathingScale)

                // Center text
                VStack(spacing: 4) {
                    if viewModel.phase == .idle {
                        Image("healing_breath")
                            .font(.system(size: 36))
                            .foregroundColor(Color.xuanApricot.opacity(0.6))
                        Text("准备")
                            .font(XuanFont.bodyLMedium)
                            .foregroundColor(Color.xuanTextSecondary)
                    } else {
                        Text(viewModel.isTense ? "紧张" : "放松")
                            .font(XuanFont.h1)
                            .foregroundColor(viewModel.isTense ? Color.xuanApricotDark : Color.xuanMint)
                            .contentTransition(.identity)
                        Text("\(viewModel.secondsInPhase)s")
                            .font(XuanFont.bodyM)
                            .foregroundColor(Color.xuanTextSecondary)
                            .monospacedDigit()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isTense)
            }
        }
    }

    // MARK: - Instruction Card

    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            if let group = viewModel.currentMuscleGroup, viewModel.phase != .idle {
                HStack {
                    CCIconMapper.image(for: group.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color.xuanApricot)
                    Text(group.name)
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanTextPrimary)
                }
            }

            Text(viewModel.phaseDescription)
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    // MARK: - Muscle Group List

    private var muscleGroupList: some View {
        VStack(alignment: .leading, spacing: XuanSpacing.sm) {
            Text("肌群列表")
                .font(XuanFont.h3)
                .foregroundColor(Color.xuanTextPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                    GridItem(.flexible(), spacing: XuanSpacing.sm),
                ],
                spacing: XuanSpacing.sm
            ) {
                ForEach(Array(CCMuscleGroup.all.enumerated()), id: \.element.id) { index, group in
                    muscleGroupCell(group: group, index: index)
                }
            }
        }
        .padding(XuanSpacing.lg)
        .background(Color.xuanWhite)
        .cornerRadius(XuanRadius.md)
    }

    private func muscleGroupCell(group: CCMuscleGroup, index: Int) -> some View {
        let isActive = index == viewModel.currentGroupIndex && viewModel.phase != .idle && viewModel.phase != .completed
        let isDone = index < viewModel.currentGroupIndex

        return HStack(spacing: XuanSpacing.sm) {
            if isDone {
                Image("home_checkin")
                    .foregroundColor(Color.xuanMint)
                    .font(.system(size: 14))
            } else if isActive {
                Circle()
                    .fill(viewModel.isTense ? Color.xuanApricotDark : Color.xuanMint)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(
                                viewModel.isTense ? Color.xuanApricotDark.opacity(0.3) : Color.xuanMint.opacity(0.3),
                                lineWidth: 3
                            )
                            .scaleEffect(viewModel.isTense ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isTense)
                    )
            } else {
                Circle()
                    .fill(Color.xuanBorder)
                    .frame(width: 8, height: 8)
            }

            CCIconMapper.image(for: group.icon)
                .font(.system(size: 11))
                .foregroundColor(isActive ? Color.xuanApricot : (isDone ? Color.xuanMint : Color.xuanTextSecondary))

            Text(group.name)
                .font(XuanFont.bodyS)
                .foregroundColor(isActive ? Color.xuanTextPrimary : (isDone ? Color.xuanMint : Color.xuanTextSecondary))
                .lineLimit(1)
        }
        .padding(.vertical, XuanSpacing.xs)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: XuanSpacing.md) {
            switch viewModel.phase {
            case .idle:
                Button {
                    viewModel.start()
                } label: {
                    HStack {
                        Image("healing_course")
                        Text("开始练习")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricot)
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("pmr_start")

            default:
                // Pause/Resume
                Button {
                    viewModel.togglePause()
                } label: {
                    HStack {
                        CCIconMapper.image(for: viewModel.isPaused ? "play.fill" : "pause.fill")
                        Text(viewModel.isPaused ? "继续" : "暂停")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanApricot)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanApricot.opacity(0.1))
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("pmr_pause_resume")

                // Reset
                Button {
                    viewModel.reset()
                } label: {
                    HStack {
                        Image("common_refresh")
                        Text("重新开始")
                    }
                    .font(XuanFont.bodyLMedium)
                    .foregroundColor(Color.xuanTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, XuanSpacing.md)
                    .background(Color.xuanSurface)
                    .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("pmr_reset")
            }
        }
    }

    // MARK: - Completion

    private var completionContent: some View {
        VStack(spacing: XuanSpacing.xl) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.xuanMint.opacity(0.3))
                    .frame(width: 100, height: 100)
                Image("healing_breath")
                    .font(.system(size: 44))
                    .foregroundColor(Color.xuanMint)
            }
            .padding(.top, XuanSpacing.xl)

            Text("放松练习完成！")
                .font(XuanFont.h1)
                .foregroundColor(Color.xuanTextPrimary)

            Text("你完成了全部16个肌群的渐进式放松练习。花一点时间感受身体的感受。")
                .font(XuanFont.bodyLMedium)
                .foregroundColor(Color.xuanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, XuanSpacing.lg)

            // Body feeling rating
            VStack(alignment: .leading, spacing: XuanSpacing.md) {
                Text("身体感受评分")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)

                HStack {
                    Text("非常紧张")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                    Spacer()
                    Text("\(Int(viewModel.bodyFeelingRating))/10")
                        .font(XuanFont.h1)
                        .foregroundColor(Color.xuanMint)
                    Spacer()
                    Text("完全放松")
                        .font(XuanFont.bodyM)
                        .foregroundColor(Color.xuanTextSecondary)
                }

                Slider(value: $viewModel.bodyFeelingRating, in: 1...10, step: 1)
                    .tint(Color.xuanMint)
                    .accessibilityIdentifier("pmr_body_feeling_slider")

                Text(viewModel.completionMessage)
                    .font(XuanFont.bodyL)
                    .foregroundColor(Color.xuanTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Muscle groups completed
            VStack(alignment: .leading, spacing: XuanSpacing.sm) {
                Text("已完成的肌群")
                    .font(XuanFont.h3)
                    .foregroundColor(Color.xuanTextPrimary)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: XuanSpacing.sm),
                        GridItem(.flexible(), spacing: XuanSpacing.sm),
                    ],
                    spacing: XuanSpacing.sm
                ) {
                    ForEach(CCMuscleGroup.all) { group in
                        HStack(spacing: XuanSpacing.sm) {
                            Image("home_checkin")
                                .foregroundColor(Color.xuanMint)
                                .font(.system(size: 12))
                            CCIconMapper.image(for: group.icon)
                                .font(.system(size: 11))
                                .foregroundColor(Color.xuanMint)
                            Text(group.name)
                                .font(XuanFont.bodyS)
                                .foregroundColor(Color.xuanMint)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(XuanSpacing.lg)
            .background(Color.xuanWhite)
            .cornerRadius(XuanRadius.md)

            // Actions
            VStack(spacing: XuanSpacing.sm) {
                Button {
                    viewModel.reset()
                } label: {
                    Text("再做一次")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, XuanSpacing.md)
                        .background(Color.xuanApricot)
                        .cornerRadius(XuanRadius.md)
                }
                .accessibilityIdentifier("pmr_retry")

                Button {
                    coordinator.dismiss()
                } label: {
                    Text("返回工具箱")
                        .font(XuanFont.bodyLMedium)
                        .foregroundColor(Color.xuanTextSecondary)
                }
                .accessibilityIdentifier("pmr_back")
            }
            .padding(.top, XuanSpacing.lg)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CCPMRView().environment(CCAppCoordinator())
    }
}
